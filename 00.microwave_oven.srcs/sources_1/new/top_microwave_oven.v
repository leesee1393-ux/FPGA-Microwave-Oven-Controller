`timescale 1ns / 1ps



module top_microwave_oven(
    input sw,
    input clk,
    input key,
    input s1,
    input reset,
    input s2,

    output buzzer,
    output [3:0] an,
    output [7:0] seg,
    output door  ,
    output [3:0] led
);

    wire w_clean_s1, w_clean_s2, w_clean_key;

    wire [15:0] w_time_set;
    wire [3:0] w_min;
    wire [7:0]  w_sec;
    wire [13:0] w_fnd_data;
    wire [9:0] w_total_sec;

    reg r_prev_key;
    wire w_tick_1ms;
    wire w_timer_done;
    wire w_start;
    wire w_pause;
    wire w_time_setting;


    assign w_min = w_time_set[11:8];
    assign w_sec = w_time_set[7:0];

    assign w_fnd_data = (w_min * 14'd100) + w_sec;

    always @(posedge clk or posedge reset) begin
    if(reset)
        r_prev_key <= 1'b0;
    else
        r_prev_key <= w_clean_key;
    end

    assign w_start = w_clean_key & ~r_prev_key;
    
debouncer #(.DEBOUNCE_LIMIT(200_000)) u_s1_debouncer (  // rotary : 2m(200_000ns)
    .clk(clk),
    .reset(reset),
    .noisy_btn(s1),  // raw noisy button input
    .clean_btn(w_clean_s1)
    );
    debouncer #(.DEBOUNCE_LIMIT(200_000)) u_s2_debouncer (  // rotary : 2m(200_000ns)
    .clk(clk),
    .reset(reset),
    .noisy_btn(s2),  // raw noisy button input
    .clean_btn(w_clean_s2)
    );
    debouncer u_key_debouncer (  // rotary : 2m(200_000ns)
    .clk(clk),
    .reset(reset),
    .noisy_btn(key),  // raw noisy button input
    .clean_btn(w_clean_key)
    );

    rotary u_rotary(
        .clk(clk),
        .reset(reset),
        .s1(w_clean_s1),
        .s2(w_clean_s2),
        .key(w_clean_key),
        .time_set(w_time_set),
        .total_sec(w_total_sec), 
        .time_setting(w_time_setting),
        .debug_led(led)
        

    );


    tick_generator u_tick_generator (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1ms)
    );

    buzzer_controller u_buzzer_controller (
        .clk(clk),
        .reset(reset),
        .tick_1ms(w_tick_1ms),
        .timer_done(w_timer_done),
        .buzzer(buzzer)
    );

    servo_controller u_servo_controller (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .pwm(door)
    );

    // 6. FND Controller
    fnd_controller u_fnd_controller (
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1ms),
        .in_data(w_fnd_data),
        .set_time(w_total_sec), 
        .an(an),
        .start(w_start),
        .pause(1'b0),
        .seg(seg),
        .timer_done(w_timer_done)
    );


endmodule
