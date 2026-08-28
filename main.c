#include <stdio.h>
#include <string.h>
#include <stdint.h>

unsigned char microc_memory[65536];
uint64_t microc_mem_addr = 0;

extern void parse_microc_program(FILE* input_file, FILE* output_file);
extern void emit_elf64_header(FILE* output_file);
extern void emit_program_epilog(FILE* output_file);

int main(int argc, char* argv[]) {
	if (argc < 2) {
		printf("Usage: %s <input_file.mc> [-o <output_file>]\n", argv[0]);
		return 1;
	}

	const char* input_filename = argv[1];
	const char* output_filename = "output.bin";

	for (int i = 2; i < argc; i++) {
		if (strcmp(argv[i], "-o") == 0) {
			if (i + 1 >= argc) {
				printf("Error: -o requires output filename\n");
				return 1;
			}
			output_filename = argv[++i];
			continue;
		}
		printf("Error: Unknown argument '%s'\n", argv[i]);
		return 1;
	}

	microc_mem_addr = (uint64_t)&microc_memory[0];

	FILE* input_file = fopen(input_filename, "rb");
	if (!input_file) {
		printf("Error: Could not open input file '%s'\n", input_filename);
		return 1;
	}

	FILE* output_file = fopen(output_filename, "wb+");
	if (!output_file) {
		printf("Error: Could not create output file '%s'\n", output_filename);
		fclose(input_file);
		return 1;
	}

	int length = strlen(output_filename);
	int is_bin = length >= 4 && strcmp(output_filename + length - 4, ".bin") == 0;

	if (!is_bin)
		emit_elf64_header(output_file);

	parse_microc_program(input_file, output_file);

	if (!is_bin)
		emit_program_epilog(output_file);

	fclose(input_file);
	fclose(output_file);
	return 0;
}
