head(custom)
head(graphics)
head(math)
head(time)

fn draw_ball(I64 cx, I64 cy, I64 radius) {
    I64 y = 0 - radius

    while (y <= radius) {
        I64 x = 0 - radius

        while (x <= radius) {
            I64 d2 = x * x + y * y

            if (d2 <= radius * radius) {
                gfx_pixel(cx + x, cy + y, gfx_rgb(245, 64, 16))
            }

            x = x + 1
        }

        y = y + 1
    }

    return 0
}

fn main() {
    I64 width = 960
    I64 height = 720
    I64 center_x = 480
    I64 center_y = 300

    I64 black = gfx_rgb(0, 0, 0)
    I64 grid = gfx_rgb(128, 130, 140)
    I64 grid_major = gfx_rgb(176, 178, 188)

    F64 pitch = 0.75
    F64 pitch_cos = math_cos(pitch)
    F64 pitch_sin = math_sin(pitch)

    F64 focal = 560.0
    F64 camera_distance = 820.0

    F64 orbit_angle = 0.0
    F64 orbit_radius_x = 150.0
    F64 orbit_radius_z = 100.0

    F64 well_depth = 105.0
    F64 well_width = 7000.0
    F64 ball_lift = 12.0

    gfx_open(width, height)

    I64 running = 1

    while (running != 0) {
        F64 ball1_x = math_cos(orbit_angle) * orbit_radius_x
        F64 ball1_z = math_sin(orbit_angle) * orbit_radius_z

        F64 ball2_x = 0.0 - ball1_x
        F64 ball2_z = 0.0 - ball1_z

        gfx_clear(black)

        I64 row_index = 0
        F64 row_z = -320.0

        while (row_z <= 320.0) {
            F64 row_x = -470.0

            I64 row_have_previous = 0
            I64 row_previous_x = 0
            I64 row_previous_y = 0

            while (row_x <= 470.0) {
                F64 row_dx1 = row_x - ball1_x
                F64 row_dz1 = row_z - ball1_z
                F64 row_r21 = row_dx1 * row_dx1 + row_dz1 * row_dz1

                F64 row_dx2 = row_x - ball2_x
                F64 row_dz2 = row_z - ball2_z
                F64 row_r22 = row_dx2 * row_dx2 + row_dz2 * row_dz2

                F64 row_falloff1 = 1.0 + row_r21 / well_width
                F64 row_falloff2 = 1.0 + row_r22 / well_width

                F64 row_world_y = 0.0 - well_depth / row_falloff1
                row_world_y = row_world_y - well_depth / row_falloff2

                F64 row_camera_y = row_world_y * pitch_cos - row_z * pitch_sin
                F64 row_camera_z = row_world_y * pitch_sin + row_z * pitch_cos + camera_distance

                F64 row_screen_x_f = center_x + row_x * focal / row_camera_z
                F64 row_screen_y_f = center_y - row_camera_y * focal / row_camera_z

                I64 row_screen_x = row_screen_x_f
                I64 row_screen_y = row_screen_y_f

                if (row_have_previous != 0) {
                    I64 row_color = grid

                    if (row_index % 4 == 0) {
                        row_color = grid_major
                    }

                    gfx_line(row_previous_x, row_previous_y, row_screen_x, row_screen_y, row_color)
                }

                row_previous_x = row_screen_x
                row_previous_y = row_screen_y
                row_have_previous = 1

                row_x = row_x + 8.0
            }

            row_z = row_z + 20.0
            row_index = row_index + 1
        }

        I64 column_index = 0
        F64 column_x = -470.0

        while (column_x <= 470.0) {
            F64 column_z = -320.0

            I64 column_have_previous = 0
            I64 column_previous_x = 0
            I64 column_previous_y = 0

            while (column_z <= 320.0) {
                F64 column_dx1 = column_x - ball1_x
                F64 column_dz1 = column_z - ball1_z
                F64 column_r21 = column_dx1 * column_dx1 + column_dz1 * column_dz1

                F64 column_dx2 = column_x - ball2_x
                F64 column_dz2 = column_z - ball2_z
                F64 column_r22 = column_dx2 * column_dx2 + column_dz2 * column_dz2

                F64 column_falloff1 = 1.0 + column_r21 / well_width
                F64 column_falloff2 = 1.0 + column_r22 / well_width

                F64 column_world_y = 0.0 - well_depth / column_falloff1
                column_world_y = column_world_y - well_depth / column_falloff2

                F64 column_camera_y = column_world_y * pitch_cos - column_z * pitch_sin
                F64 column_camera_z = column_world_y * pitch_sin + column_z * pitch_cos + camera_distance

                F64 column_screen_x_f = center_x + column_x * focal / column_camera_z
                F64 column_screen_y_f = center_y - column_camera_y * focal / column_camera_z

                I64 column_screen_x = column_screen_x_f
                I64 column_screen_y = column_screen_y_f

                if (column_have_previous != 0) {
                    I64 column_color = grid

                    if (column_index % 4 == 0) {
                        column_color = grid_major
                    }

                    gfx_line(column_previous_x, column_previous_y, column_screen_x, column_screen_y, column_color)
                }

                column_previous_x = column_screen_x
                column_previous_y = column_screen_y
                column_have_previous = 1

                column_z = column_z + 8.0
            }

            column_x = column_x + 22.0
            column_index = column_index + 1
        }

        F64 ball1_other_dx = ball1_x - ball2_x
        F64 ball1_other_dz = ball1_z - ball2_z
        F64 ball1_other_r2 = ball1_other_dx * ball1_other_dx + ball1_other_dz * ball1_other_dz

        F64 ball1_surface = 0.0 - well_depth
        ball1_surface = ball1_surface - well_depth / (1.0 + ball1_other_r2 / well_width)
        F64 ball1_y = ball1_surface + ball_lift

        F64 ball1_camera_y = ball1_y * pitch_cos - ball1_z * pitch_sin
        F64 ball1_camera_z = ball1_y * pitch_sin + ball1_z * pitch_cos + camera_distance

        F64 ball1_screen_x_f = center_x + ball1_x * focal / ball1_camera_z
        F64 ball1_screen_y_f = center_y - ball1_camera_y * focal / ball1_camera_z

        I64 ball1_screen_x = ball1_screen_x_f
        I64 ball1_screen_y = ball1_screen_y_f

        F64 ball2_other_dx = ball2_x - ball1_x
        F64 ball2_other_dz = ball2_z - ball1_z
        F64 ball2_other_r2 = ball2_other_dx * ball2_other_dx + ball2_other_dz * ball2_other_dz

        F64 ball2_surface = 0.0 - well_depth
        ball2_surface = ball2_surface - well_depth / (1.0 + ball2_other_r2 / well_width)
        F64 ball2_y = ball2_surface + ball_lift

        F64 ball2_camera_y = ball2_y * pitch_cos - ball2_z * pitch_sin
        F64 ball2_camera_z = ball2_y * pitch_sin + ball2_z * pitch_cos + camera_distance

        F64 ball2_screen_x_f = center_x + ball2_x * focal / ball2_camera_z
        F64 ball2_screen_y_f = center_y - ball2_camera_y * focal / ball2_camera_z

        I64 ball2_screen_x = ball2_screen_x_f
        I64 ball2_screen_y = ball2_screen_y_f

        draw_ball(ball1_screen_x, ball1_screen_y, 6)
        draw_ball(ball2_screen_x, ball2_screen_y, 6)

        I64 present_status = gfx_present()

        if (present_status < 0) {
            running = 0
        }

        orbit_angle = orbit_angle + 0.012

        if (orbit_angle > 6.283185307) {
            orbit_angle = orbit_angle - 6.283185307
        }

        sleep_ms(16)
    }

    gfx_close()

    return 0
}
