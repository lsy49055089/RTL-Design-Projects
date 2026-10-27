`timescale 1ns / 1ps

module tb_xy_detection;
    logic clk = 0;
    logic rst = 1;
    logic red_detect = 0, green_detect = 0;
    logic [9:0] scan_x = 799, scan_y = 524;
    logic ready = 1;
    wire [9:0] stick_x, stick_y, hand_x, hand_y;
    wire [39:0] pixel;
    wire vsync, valid;
    integer errors = 0, frame_count = 0, handshake_count = 0;
    integer scenario = 0;
    logic [9:0] expected_sx, expected_sy, expected_hx, expected_hy;
    logic [39:0] expected_pixel;

    xy_detection dut (
        .clk(clk), .rst(rst),
        .i_red_detect(red_detect), .i_green_detect(green_detect),
        .i_x_detect_pixel(scan_x), .i_y_detect_pixel(scan_y),
        .xy_control_ready(ready),
        .o_stick_x_pixel(stick_x), .o_stick_y_pixel(stick_y),
        .o_hand_x_pixel(hand_x), .o_hand_y_pixel(hand_y),
        .o_vsync(vsync), .o_pixel(pixel), .xy_control_valid(valid)
    );
    always #5 clk = ~clk;

    task automatic check(input bit condition, input string message);
        if (!condition) begin
            errors++;
            $display("ERROR scenario=%0d: %s", scenario, message);
        end
    endtask

    // Expected values are checked after nonblocking assignments settle.
    always @(posedge clk) begin
        if (!rst && dut.frame_done_pulse) begin
            #1;
            frame_count++;
            check({stick_x, stick_y, hand_x, hand_y} === expected_pixel,
                  "coordinate registers differ from expected coordinates");
            check(pixel === expected_pixel, "40-bit packet differs from coordinates");
            check(vsync === 1'b1, "snapshot must assert the internal sync pulse");
            check(valid === 1'b0, "snapshot edge must precede Valid");
            @(posedge clk); #1;
            check(vsync === 1'b0, "sync pulse must last one clock");
            check(valid === (expected_pixel != {4{10'd1023}}),
                  "Valid must reflect object detection on the next clock");
        end
    end

    always @(posedge clk)
        if (!rst && valid && ready) handshake_count++;

    // Full raster coordinates retain the RTL's physical LEFT/UP adjacency.
    // Each pixel is held for two system clocks to check pixel_tick gating.
    task automatic drive_pixel(input integer x, y, fixture);
        begin
            @(negedge clk);
            scan_x = x; scan_y = y;
            red_detect = 0; green_detect = 0;
            case (fixture)
                1, 3, 8: red_detect = x >= 50 && x <= 52 && y >= 60 && y <= 62;
                6: red_detect = x >= 50 && x <= 57 && y == 60;
                7: red_detect = x >= 50 && x <= 58 && y == 60;
            endcase
            case (fixture)
                2, 3: green_detect = x >= 100 && x <= 104 && y >= 80 && y <= 84;
                4: green_detect = x >= 100 && x <= 115 && y == 80;
                5: green_detect = x >= 100 && x <= 116 && y == 80;
            endcase
            if (fixture == 8)
                red_detect = red_detect || (x >= 280 && x <= 281 && y == 200)
                                        || (x == 300 && y == 220);
            repeat (2) begin @(posedge clk); #1; end
        end
    endtask

    task automatic frame(input integer fixture, input bit ready_value,
                         input integer sx, sy, hx, hy, input string label);
        integer x, y, previous_frames;
        begin
            scenario++;
            @(negedge clk);
            ready = ready_value;
            expected_sx = sx; expected_sy = sy;
            expected_hx = hx; expected_hy = hy;
            expected_pixel = {expected_sx, expected_sy, expected_hx, expected_hy};
            previous_frames = frame_count;
            for (y = 0; y < 240; y++)
                for (x = 0; x <= 320; x++) drive_pixel(x, y, fixture);
            repeat (3) begin @(posedge clk); #1; end
            check(frame_count == previous_frames + 1, "exactly one snapshot per raster");
            check(pixel === expected_pixel, "final packet differs from expected coordinates");
            check(valid === (!ready_value && expected_pixel != {4{10'd1023}}),
                  "post-frame Valid/Ready state mismatch");
            $display("FRAME %0d: %s | XY=%0d,%0d,%0d,%0d", scenario, label,
                     stick_x, stick_y, hand_x, hand_y);
        end
    endtask

    task automatic hold_pending;
        logic [39:0] held;
        begin
            held = pixel;
            repeat (6) begin
                @(posedge clk); #1;
                check(valid === 1'b1, "Valid dropped while waiting within the frame");
                check(pixel === held, "packet changed before the next frame snapshot");
            end
        end
    endtask

    initial begin
        repeat (4) @(posedge clk);
        @(negedge clk); rst = 0;

        frame(1, 1, 51, 61, 1023, 1023, "RED / READY=1");
        frame(2, 1, 1023, 1023, 102, 82, "GREEN / READY=1");
        frame(3, 1, 51, 61, 102, 82, "BOTH / READY=1");
        frame(0, 1, 1023, 1023, 1023, 1023, "NONE / READY=1");
        frame(1, 0, 51, 61, 1023, 1023, "RED / READY=0");
        hold_pending();
        frame(2, 0, 1023, 1023, 102, 82, "pending RED replaced by fresh GREEN");
        hold_pending();
        frame(0, 0, 1023, 1023, 1023, 1023, "undetected frame clears pending Valid");
        frame(1, 0, 51, 61, 1023, 1023, "RED / delayed consumer");
        hold_pending();
        @(negedge clk); ready = 1;
        @(posedge clk); #1;
        check(valid === 1'b0, "handshake must clear Valid");
        check(pixel === expected_pixel, "handshake must preserve coordinate registers");

        // A single colored row excludes its first isolated pixel from candidates.
        frame(4, 1, 1023, 1023, 1023, 1023, "GREEN 15 candidates: below minimum 16");
        frame(5, 1, 1023, 1023, 108, 80, "GREEN 16 candidates: exact minimum");
        frame(6, 1, 1023, 1023, 1023, 1023, "RED 7 candidates: below minimum 8");
        frame(7, 1, 54, 60, 1023, 1023, "RED 8 candidates: exact minimum");
        frame(8, 1, 51, 61, 1023, 1023, "RED cluster plus distant color noise");

        check(frame_count == 13, "expected 13 frame snapshots");
        check(handshake_count == 7, "expected seven accepted coordinate packets");
        $display("FRAME_DONE COUNT = %0d", frame_count);
        $display("HANDSHAKE COUNT = %0d", handshake_count);
        $display("ERROR COUNT = %0d", errors);
        if (errors) $fatal(1, "XY REGRESSION FAILED");
        $display("XY REGRESSION PASS: 13 frame scenarios / 0 errors");
        $finish;
    end
endmodule
