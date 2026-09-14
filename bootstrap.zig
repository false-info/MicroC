const std = @import("std");
const Io = std.Io;
const Allocator = std.mem.Allocator;

const max_source_bytes = 2 * 1024 * 1024;
const max_output_bytes = 16 * 1024 * 1024;
const max_heads = 128;
const max_headers = 256;
const max_nesting = 32;

const BootError = error{
    BadArguments,
    BadSyntax,
    MissingHeadFile,
    UnknownHead,
    HeadCycle,
    HeaderCycle,
    TooManyHeads,
    TooManyHeaders,
    NestingLimit,
    OutputTooLarge,
    InvalidHeaderPath,
    UnknownBuiltinHead,
    DuplicateBuiltinHead,
    MissingCustomHead,
};

const Buffer = struct {
    bytes: []u8,
    len: usize = 0,

    fn init(allocator: Allocator) !Buffer {
        return .{ .bytes = try allocator.alloc(u8, max_output_bytes) };
    }

    fn append(self: *Buffer, data: []const u8) !void {
        if (self.len + data.len > self.bytes.len) return BootError.OutputTooLarge;
        @memcpy(self.bytes[self.len .. self.len + data.len], data);
        self.len += data.len;
    }

    fn appendByte(self: *Buffer, byte: u8) !void {
        if (self.len == self.bytes.len) return BootError.OutputTooLarge;
        self.bytes[self.len] = byte;
        self.len += 1;
    }

    fn slice(self: *const Buffer) []const u8 {
        return self.bytes[0..self.len];
    }
};

const Scanner = struct {
    src: []const u8,
    pos: usize = 0,

    fn eof(self: *const Scanner) bool {
        return self.pos >= self.src.len;
    }

    fn isIdentStart(c: u8) bool {
        return (c >= 'a' and c <= 'z') or (c >= 'A' and c <= 'Z') or c == '_';
    }

    fn isIdent(c: u8) bool {
        return isIdentStart(c) or (c >= '0' and c <= '9');
    }

    fn skipTrivia(self: *Scanner) void {
        while (self.pos < self.src.len) {
            const c = self.src[self.pos];
            if (c == ' ' or c == '\t' or c == '\r' or c == '\n') {
                self.pos += 1;
                continue;
            }
            if (c == '/' and self.pos + 1 < self.src.len and self.src[self.pos + 1] == '/') {
                self.pos += 2;
                while (self.pos < self.src.len and self.src[self.pos] != '\n') self.pos += 1;
                continue;
            }
            if (c == '/' and self.pos + 1 < self.src.len and self.src[self.pos + 1] == '*') {
                self.pos += 2;
                while (self.pos + 1 < self.src.len) {
                    if (self.src[self.pos] == '*' and self.src[self.pos + 1] == '/') {
                        self.pos += 2;
                        break;
                    }
                    self.pos += 1;
                }
                continue;
            }
            break;
        }
    }

    fn byte(self: *Scanner, expected: u8) !void {
        self.skipTrivia();
        if (self.pos >= self.src.len or self.src[self.pos] != expected) return BootError.BadSyntax;
        self.pos += 1;
    }

    fn ident(self: *Scanner) ![]const u8 {
        self.skipTrivia();
        if (self.pos >= self.src.len or !isIdentStart(self.src[self.pos])) return BootError.BadSyntax;
        const start = self.pos;
        self.pos += 1;
        while (self.pos < self.src.len and isIdent(self.src[self.pos])) self.pos += 1;
        return self.src[start..self.pos];
    }

    fn number(self: *Scanner) !usize {
        self.skipTrivia();
        if (self.pos >= self.src.len or self.src[self.pos] < '0' or self.src[self.pos] > '9') return BootError.BadSyntax;
        var value: usize = 0;
        while (self.pos < self.src.len) {
            const c = self.src[self.pos];
            if (c < '0' or c > '9') break;
            value = value * 10 + @as(usize, c - '0');
            self.pos += 1;
        }
        return value;
    }

    fn word(self: *Scanner, expected: []const u8) !void {
        const got = try self.ident();
        if (!std.mem.eql(u8, got, expected)) return BootError.BadSyntax;
    }

    fn string(self: *Scanner) ![]const u8 {
        self.skipTrivia();
        if (self.pos >= self.src.len or self.src[self.pos] != '"') return BootError.BadSyntax;
        self.pos += 1;
        const start = self.pos;
        while (self.pos < self.src.len) {
            const c = self.src[self.pos];
            if (c == '\\') {
                self.pos += 2;
                continue;
            }
            if (c == '"') {
                const out = self.src[start..self.pos];
                self.pos += 1;
                return out;
            }
            self.pos += 1;
        }
        return BootError.BadSyntax;
    }
};

const Seen = struct {
    names: [max_headers][]const u8 = undefined,
    states: [max_headers]u8 = undefined,
    count: usize = 0,

    fn find(self: *const Seen, name: []const u8) ?usize {
        var i: usize = 0;
        while (i < self.count) : (i += 1) {
            if (std.mem.eql(u8, self.names[i], name)) return i;
        }
        return null;
    }
};

const Context = struct {
    allocator: Allocator,
    io: Io,
    out: Buffer,
    root_source: []const u8,
    root_head_file: []const u8,
    heads: Seen = .{},
    headers: Seen = .{},
    depth: usize = 0,

    fn enter(self: *Context) !void {
        if (self.depth >= max_nesting) return BootError.NestingLimit;
        self.depth += 1;
    }

    fn leave(self: *Context) void {
        self.depth -= 1;
    }

    fn joinFromFile(self: *Context, owner_file: []const u8, relative: []const u8) ![]const u8 {
        if (relative.len == 0) return BootError.InvalidHeaderPath;
        if (relative[0] == '/' or relative[0] == '\\') return try self.allocator.dupe(u8, relative);
        if (relative.len >= 2 and relative[1] == ':') return try self.allocator.dupe(u8, relative);

        var cut: usize = 0;
        var i: usize = owner_file.len;
        while (i > 0) {
            i -= 1;
            if (owner_file[i] == '/' or owner_file[i] == '\\') {
                cut = i + 1;
                break;
            }
        }
        const joined = try self.allocator.alloc(u8, cut + relative.len);
        if (cut != 0) @memcpy(joined[0..cut], owner_file[0..cut]);
        @memcpy(joined[cut..], relative);
        return joined;
    }

    fn read(self: *Context, path: []const u8) ![]const u8 {
        return Io.Dir.cwd().readFileAlloc(self.io, path, self.allocator, .limited(max_source_bytes));
    }

    fn beginSeen(self: *Context, table: *Seen, name: []const u8, max_items: usize, cycle_error: anyerror) !?usize {
        _ = self;
        if (table.find(name)) |idx| {
            if (table.states[idx] == 2) return null;
            if (table.states[idx] == 1) return cycle_error;
        }
        if (table.count >= max_items) return BootError.NestingLimit;
        const idx = table.count;
        table.count += 1;
        table.names[idx] = name;
        table.states[idx] = 1;
        return idx;
    }

    fn finishSeen(table: *Seen, idx: usize) void {
        table.states[idx] = 2;
    }

    fn expandHead(self: *Context, name: []const u8) anyerror!void {
        const stable = try self.allocator.dupe(u8, name);
        const slot = try self.beginSeen(&self.heads, stable, max_heads, BootError.HeadCycle) orelse return;
        errdefer self.heads.states[slot] = 0;

        try self.enter();
        defer self.leave();

        const source = self.read(self.root_head_file) catch return BootError.MissingHeadFile;
        var scan = Scanner{ .src = source };
        var found = false;

        while (true) {
            scan.skipTrivia();
            if (scan.eof()) break;
            try scan.word("head");
            try scan.byte('<');
            const candidate = try scan.ident();
            try scan.byte('>');
            scan.skipTrivia();
            if (scan.pos >= source.len or source[scan.pos] != '{') return BootError.BadSyntax;
            const open = scan.pos;
            const close = try findMatchingBrace(source, open);

            if (std.mem.eql(u8, candidate, name)) {
                found = true;
                try self.expandHeadBody(source[open + 1 .. close]);
                break;
            }
            scan.pos = close + 1;
        }

        if (!found) return BootError.UnknownHead;
        finishSeen(&self.heads, slot);
    }

    fn expandHeadBody(self: *Context, body: []const u8) anyerror!void {
        var scan = Scanner{ .src = body };
        while (true) {
            scan.skipTrivia();
            if (scan.eof()) return;
            const directive = try scan.ident();
            if (std.mem.eql(u8, directive, "fhf")) {
                const rel = try scan.string();
                if (!hasHeaderSuffix(rel)) return BootError.InvalidHeaderPath;
                scan.skipTrivia();
                if (!scan.eof() and scan.src[scan.pos] == ';') scan.pos += 1;
                const path = try self.joinFromFile(self.root_head_file, rel);
                try self.expandHeader(path);
                continue;
            }
            if (std.mem.eql(u8, directive, "head")) {
                try scan.byte('<');
                const child = try scan.ident();
                try scan.byte('>');
                scan.skipTrivia();
                if (!scan.eof() and scan.src[scan.pos] == ';') scan.pos += 1;
                try self.expandHead(child);
                continue;
            }
            return BootError.BadSyntax;
        }
    }

    fn expandHeader(self: *Context, path: []const u8) anyerror!void {
        const stable = try self.allocator.dupe(u8, path);
        const slot = try self.beginSeen(&self.headers, stable, max_headers, BootError.HeaderCycle) orelse return;
        errdefer self.headers.states[slot] = 0;

        try self.enter();
        defer self.leave();

        const source = try self.read(stable);
        try self.expandTopLevel(source, stable, false);
        finishSeen(&self.headers, slot);
    }

    fn expandTopLevel(self: *Context, source: []const u8, owner_file: []const u8, allow_code: bool) anyerror!void {
        var i: usize = 0;
        var segment: usize = 0;
        var depth: usize = 0;
        var state: enum { code, string, line_comment, block_comment } = .code;

        while (i < source.len) {
            const c = source[i];
            switch (state) {
                .string => {
                    if (c == '\\' and i + 1 < source.len) { i += 2; continue; }
                    if (c == '"') state = .code;
                    i += 1;
                    continue;
                },
                .line_comment => {
                    if (c == '\n') state = .code;
                    i += 1;
                    continue;
                },
                .block_comment => {
                    if (c == '*' and i + 1 < source.len and source[i + 1] == '/') {
                        state = .code;
                        i += 2;
                        continue;
                    }
                    i += 1;
                    continue;
                },
                .code => {},
            }

            if (c == '"') { state = .string; i += 1; continue; }
            if (c == '/' and i + 1 < source.len and source[i + 1] == '/') { state = .line_comment; i += 2; continue; }
            if (c == '/' and i + 1 < source.len and source[i + 1] == '*') { state = .block_comment; i += 2; continue; }
            if (c == '{') { depth += 1; i += 1; continue; }
            if (c == '}') { if (depth > 0) depth -= 1; i += 1; continue; }

            if (depth == 0 and Scanner.isIdentStart(c) and (i == 0 or !Scanner.isIdent(source[i - 1]))) {
                var probe = Scanner{ .src = source, .pos = i };
                const word = probe.ident() catch { i += 1; continue; };
                if (std.mem.eql(u8, word, "fhf")) {
                    const rel = probe.string() catch { i += 1; continue; };
                    if (!hasHeaderSuffix(rel)) return BootError.InvalidHeaderPath;
                    probe.skipTrivia();
                    if (!probe.eof() and source[probe.pos] == ';') probe.pos += 1;
                    try self.out.append(source[segment..i]);
                    const path = try self.joinFromFile(owner_file, rel);
                    try self.expandHeader(path);
                    try self.out.append("\n");
                    i = probe.pos;
                    segment = i;
                    continue;
                }
                if (std.mem.eql(u8, word, "head")) {
                    probe.skipTrivia();
                    if (!probe.eof() and source[probe.pos] == '<') {
                        probe.pos += 1;
                        const name = probe.ident() catch return BootError.BadSyntax;
                        try probe.byte('>');
                        probe.skipTrivia();
                        if (!probe.eof() and source[probe.pos] == ';') probe.pos += 1;
                        try self.out.append(source[segment..i]);
                        try self.expandHead(name);
                        try self.out.append("\n");
                        i = probe.pos;
                        segment = i;
                        continue;
                    }
                }
            }
            i += 1;
        }

        if (allow_code or segment < source.len) try self.out.append(source[segment..]);
    }
};

fn hasHeaderSuffix(path: []const u8) bool {
    if (path.len < 3) return false;
    const a = path[path.len - 2];
    const b = path[path.len - 1];
    return a == '.' and (b == 'h' or b == 'H');
}

fn findMatchingBrace(src: []const u8, open: usize) !usize {
    if (open >= src.len or src[open] != '{') return BootError.BadSyntax;
    var depth: usize = 1;
    var i = open + 1;
    var state: enum { code, string, line_comment, block_comment } = .code;
    while (i < src.len) {
        const c = src[i];
        switch (state) {
            .string => {
                if (c == '\\' and i + 1 < src.len) { i += 2; continue; }
                if (c == '"') state = .code;
                i += 1;
                continue;
            },
            .line_comment => { if (c == '\n') state = .code; i += 1; continue; },
            .block_comment => {
                if (c == '*' and i + 1 < src.len and src[i + 1] == '/') { state = .code; i += 2; continue; }
                i += 1;
                continue;
            },
            .code => {},
        }
        if (c == '"') { state = .string; i += 1; continue; }
        if (c == '/' and i + 1 < src.len and src[i + 1] == '/') { state = .line_comment; i += 2; continue; }
        if (c == '/' and i + 1 < src.len and src[i + 1] == '*') { state = .block_comment; i += 2; continue; }
        if (c == '{') depth += 1;
        if (c == '}') {
            depth -= 1;
            if (depth == 0) return i;
        }
        i += 1;
    }
    return BootError.BadSyntax;
}

const LegacyHeads = struct {
    custom: bool = false,
    safe: bool = false,
    asm16: bool = false,
    asm32: bool = false,
    asm64: bool = false,
};

fn builtinHeadBit(name: []const u8) ?u64 {
    if (std.mem.eql(u8, name, "custom")) return @as(u64, 1) << 0;
    if (std.mem.eql(u8, name, "memory")) return @as(u64, 1) << 1;
    if (std.mem.eql(u8, name, "input")) return @as(u64, 1) << 2;
    if (std.mem.eql(u8, name, "file")) return @as(u64, 1) << 3;
    if (std.mem.eql(u8, name, "network")) return @as(u64, 1) << 4;
    if (std.mem.eql(u8, name, "networking")) return @as(u64, 1) << 4;
    if (std.mem.eql(u8, name, "time")) return @as(u64, 1) << 5;
    if (std.mem.eql(u8, name, "math")) return @as(u64, 1) << 6;
    if (std.mem.eql(u8, name, "graphics")) return @as(u64, 1) << 7;
    if (std.mem.eql(u8, name, "audio")) return @as(u64, 1) << 8;
    if (std.mem.eql(u8, name, "thread")) return @as(u64, 1) << 9;
    if (std.mem.eql(u8, name, "crypto")) return @as(u64, 1) << 10;
    if (std.mem.eql(u8, name, "process")) return @as(u64, 1) << 11;
    if (std.mem.eql(u8, name, "game")) return @as(u64, 1) << 12;
    if (std.mem.eql(u8, name, "safe")) return @as(u64, 1) << 13;
    if (std.mem.eql(u8, name, "system")) return @as(u64, 1) << 14;
    return null;
}

fn registerBuiltinHead(name: []const u8, mask: *u64, legacy: *LegacyHeads) !void {
    const bit = builtinHeadBit(name) orelse return BootError.UnknownBuiltinHead;
    if ((mask.* & bit) != 0) return BootError.DuplicateBuiltinHead;
    mask.* |= bit;

    if (std.mem.eql(u8, name, "custom")) legacy.custom = true;
    if (std.mem.eql(u8, name, "safe")) legacy.safe = true;
}

fn registerAsmHead(bits: usize, mask: *u64, legacy: *LegacyHeads) !void {
    var bit: u64 = 0;
    if (bits == 16) bit = @as(u64, 1) << 15;
    if (bits == 32) bit = @as(u64, 1) << 16;
    if (bits == 64) bit = @as(u64, 1) << 17;
    if (bit == 0) return BootError.UnknownBuiltinHead;
    if ((mask.* & bit) != 0) return BootError.DuplicateBuiltinHead;
    mask.* |= bit;
    if (bits == 16) legacy.asm16 = true;
    if (bits == 32) legacy.asm32 = true;
    if (bits == 64) legacy.asm64 = true;
}

fn parseBuiltinHead(scan: *Scanner, mask: *u64, legacy: *LegacyHeads) !void {
    try scan.byte('(');
    var count: usize = 0;
    while (true) {
        scan.skipTrivia();
        if (scan.pos >= scan.src.len) return BootError.BadSyntax;
        if (scan.src[scan.pos] == ')') {
            scan.pos += 1;
            if (count == 0) return BootError.BadSyntax;
            return;
        }

        const name = try scan.ident();
        if (std.mem.eql(u8, name, "asm")) {
            try scan.byte('-');
            try scan.word("x86");
            try scan.byte('-');
            const bits = try scan.number();
            try registerAsmHead(bits, mask, legacy);
        } else {
            try registerBuiltinHead(name, mask, legacy);
        }
        count += 1;
    }
}

fn emitLegacyHead(out: *Buffer, legacy: LegacyHeads) !void {
    if (!legacy.custom) return BootError.MissingCustomHead;
    try out.append("head(custom");
    if (legacy.safe) try out.append(" safe");
    if (legacy.asm16) try out.append(" asm-x86-16");
    if (legacy.asm32) try out.append(" asm-x86-32");
    if (legacy.asm64) try out.append(" asm-x86-64");
    try out.append(") {\n");
}

fn rootHeadPath(allocator: Allocator, input: []const u8) ![]const u8 {
    var cut: usize = 0;
    var i = input.len;
    while (i > 0) {
        i -= 1;
        if (input[i] == '/' or input[i] == '\\') { cut = i + 1; break; }
    }
    const name = "head.h";
    const out = try allocator.alloc(u8, cut + name.len);
    if (cut != 0) @memcpy(out[0..cut], input[0..cut]);
    @memcpy(out[cut..], name);
    return out;
}

fn preprocess(allocator: Allocator, io: Io, input_path: []const u8) ![]const u8 {
    const source = try Io.Dir.cwd().readFileAlloc(io, input_path, allocator, .limited(max_source_bytes));
    var scan = Scanner{ .src = source };
    var builtin_mask: u64 = 0;
    var legacy = LegacyHeads{};
    var builtin_count: usize = 0;

    scan.skipTrivia();
    while (!scan.eof()) {
        const start = scan.pos;
        const word = scan.ident() catch {
            scan.pos = start;
            break;
        };
        if (!std.mem.eql(u8, word, "head")) {
            scan.pos = start;
            break;
        }

        scan.skipTrivia();
        if (scan.pos >= source.len or source[scan.pos] != '(') {
            scan.pos = start;
            break;
        }

        try parseBuiltinHead(&scan, &builtin_mask, &legacy);
        builtin_count += 1;

        const after_head = scan.pos;
        scan.skipTrivia();
        if (builtin_count == 1 and scan.pos < source.len and source[scan.pos] == '{') {
            const open = scan.pos;
            const close = try findMatchingBrace(source, open);
            var tail = Scanner{ .src = source, .pos = close + 1 };
            tail.skipTrivia();
            if (!tail.eof()) return BootError.BadSyntax;

            const stage0_mask = (@as(u64, 1) << 0) | (@as(u64, 1) << 13) | (@as(u64, 1) << 15) | (@as(u64, 1) << 16) | (@as(u64, 1) << 17);
            if ((builtin_mask & ~stage0_mask) == 0) {
                return try allocator.dupe(u8, source);
            }

            var wrapped = Context{
                .allocator = allocator,
                .io = io,
                .out = try Buffer.init(allocator),
                .root_source = input_path,
                .root_head_file = try rootHeadPath(allocator, input_path),
            };
            try emitLegacyHead(&wrapped.out, legacy);
            try wrapped.expandTopLevel(source[open + 1 .. close], input_path, true);
            try wrapped.out.append("\n}\n");
            return try allocator.dupe(u8, wrapped.out.slice());
        }
        scan.pos = after_head;
        scan.skipTrivia();
    }

    if (builtin_count == 0) return BootError.BadSyntax;

    var ctx = Context{
        .allocator = allocator,
        .io = io,
        .out = try Buffer.init(allocator),
        .root_source = input_path,
        .root_head_file = try rootHeadPath(allocator, input_path),
    };

    try emitLegacyHead(&ctx.out, legacy);
    try ctx.expandTopLevel(source[scan.pos..], input_path, true);
    try ctx.out.append("\n}\n");
    return try allocator.dupe(u8, ctx.out.slice());
}

fn usage(io: Io) !void {
    try Io.File.stderr().writeStreamingAll(io,
        "mcboot 0.1 - MicroC head bootstrap\n" ++
        "usage: mcboot expand INPUT.mc -o OUTPUT.mc\n" ++
        "       mcboot check INPUT.mc\n");
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);

    if (args.len < 3) {
        try usage(io);
        return BootError.BadArguments;
    }

    if (std.mem.eql(u8, args[1], "check")) {
        if (args.len != 3) return BootError.BadArguments;
        _ = try preprocess(arena, io, args[2]);
        try Io.File.stdout().writeStreamingAll(io, "mcboot: syntax OK\n");
        return;
    }

    if (!std.mem.eql(u8, args[1], "expand")) {
        try usage(io);
        return BootError.BadArguments;
    }
    if (args.len != 5 or !std.mem.eql(u8, args[3], "-o")) return BootError.BadArguments;

    const expanded = try preprocess(arena, io, args[2]);
    var file = try Io.Dir.cwd().createFile(io, args[4], .{});
    defer file.close(io);
    try file.writeStreamingAll(io, expanded);

    try Io.File.stdout().writeStreamingAll(io, "mcboot: expanded MicroC source written\n");
}
