`timescale 1ns / 1ps

module tb_microwave_oven;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg sw = 1'b0;
    reg key = 1'b0;
    reg s1 = 1'b0;
    reg s2 = 1'b0;

    wire buzzer;
    wire [3:0] an;
    wire [7:0] seg;
    wire door;
    wire [3:0] led;

    integer errors = 0;

    always #5 clk = ~clk;

    top_microwave_oven dut (
        .sw(sw),
        .clk(clk),
        .key(key),
        .s1(s1),
        .reset(reset),
        .s2(s2),
        .buzzer(buzzer),
        .an(an),
        .seg(seg),
        .door(door),
        .led(led)
    );

    // Simulation only: shorten input filtering, the 1 ms tick, and buzzer tone.
    defparam dut.u_s1_debouncer.DEBOUNCE_LIMIT = 2;
    defparam dut.u_s2_debouncer.DEBOUNCE_LIMIT = 2;
    defparam dut.u_key_debouncer.DEBOUNCE_LIMIT = 2;
    defparam dut.u_tick_generator.TICK_COUNT = 4;
    defparam dut.u_buzzer_controller.CLK_FREQ_HZ = 8_000;

    task check;
        input condition;
        input [8*64-1:0] message;
        begin
            if (condition)
                $display("[PASS] %0s", message);
            else begin
                $display("[FAIL] %0s", message);
                errors = errors + 1;
            end
        end
    endtask

    task press_key;
        begin
            @(negedge clk); key = 1'b1;
            repeat (5) @(negedge clk);
            key = 1'b0;
            repeat (5) @(negedge clk);
        end
    endtask

    task rotary_state;
        input [1:0] state;
        begin
            @(negedge clk);
            {s1, s2} = state;
            repeat (5) @(negedge clk);
        end
    endtask

    task rotate_cw;
        begin
            rotary_state(2'b10);
            rotary_state(2'b11);
            rotary_state(2'b01);
            rotary_state(2'b00);
            repeat (3) @(negedge clk);
        end
    endtask

    task rotate_ccw;
        begin
            rotary_state(2'b01);
            rotary_state(2'b11);
            rotary_state(2'b10);
            rotary_state(2'b00);
            repeat (3) @(negedge clk);
        end
    endtask

    initial begin
        repeat (5) @(negedge clk);
        check((buzzer === 1'b0) && (door === 1'b0),
              "reset stops buzzer and servo PWM");

        reset = 1'b0;
        repeat (3) @(negedge clk);
        check(dut.w_total_sec == 10'd0, "timer resets to 0 seconds");

        press_key;
        check(led[2] === 1'b1, "KEY enters time-setting mode");

        rotate_cw;
        check(dut.w_total_sec == 10'd1, "rotary CW increases time");
        rotate_ccw;
        check(dut.w_total_sec == 10'd0, "rotary CCW decreases time");
        rotate_cw;
        check((dut.w_total_sec == 10'd1) && (dut.w_fnd_data == 14'd1),
              "set time is sent to the FND path");

        press_key;
        check((led[2] === 1'b0) && dut.u_fnd_controller.r_running,
              "KEY leaves setting mode and starts countdown");

        wait (dut.w_timer_done === 1'b1);
        check(dut.u_fnd_controller.r_remaining_sec == 10'd0,
              "countdown reaches zero and raises timer_done");

        wait (dut.u_buzzer_controller.r_sequence_active === 1'b1);
        wait (buzzer === 1'b1);
        check(1'b1, "buzzer starts after timer_done");
        wait (dut.u_buzzer_controller.r_phase == 3'd1); #1;
        check(buzzer === 1'b0, "buzzer first OFF interval");
        wait (dut.u_buzzer_controller.r_phase == 3'd2);
        wait (buzzer === 1'b1);
        check(1'b1, "buzzer second beep");
        wait (dut.u_buzzer_controller.r_phase == 3'd3); #1;
        check(buzzer === 1'b0, "buzzer second OFF interval");
        wait (dut.u_buzzer_controller.r_phase == 3'd4);
        wait (buzzer === 1'b1);
        check(1'b1, "buzzer third beep");
        wait (dut.u_buzzer_controller.r_phase == 3'd5); #1;
        check(buzzer === 1'b0, "buzzer third OFF interval");
        wait (dut.u_buzzer_controller.r_sequence_active === 1'b0); #1;
        check(buzzer === 1'b0, "buzzer stops after three beeps");
        repeat (20) @(posedge dut.w_tick_1ms);
        check(dut.u_buzzer_controller.r_sequence_active === 1'b0,
              "held timer_done does not retrigger buzzer");

        wait (door === 1'b0); #1;
        check(dut.u_servo_controller.r_pwm_count == 21'd100_000,
              "sw=0 produces 1.0 ms CLOSE pulse");
        sw = 1'b1;
        wait (door === 1'b1); #1;
        check((dut.u_servo_controller.r_pwm_count == 21'd0) &&
              (dut.u_servo_controller.r_pwm_duty == 21'd150_000),
              "sw=1 selects OPEN duty on the next PWM frame");
        wait (door === 1'b0); #1;
        check(dut.u_servo_controller.r_pwm_count == 21'd150_000,
              "sw=1 produces 1.5 ms OPEN pulse");

        if (errors == 0)
            $display("\nALL TESTS PASSED");
        else
            $display("\nTEST FAILED: %0d error(s)", errors);
        $finish;
    end

    initial begin
        #25_000_000;
        $display("[FAIL] simulation timeout");
        $finish;
    end
endmodule
