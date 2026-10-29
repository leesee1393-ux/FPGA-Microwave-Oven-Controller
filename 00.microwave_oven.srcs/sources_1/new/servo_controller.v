
`timescale 1ns / 1ps

module servo_controller(
    input clk,
    input reset,
    input sw,
    output pwm
);

    // 100MHz Clock
    // 20ms = 2,000,000 Clock
    // CLOSE = 1.0ms = 100,000 Clock
    // OPEN  = 1.5ms = 150,000 Clock

    localparam PWM_PERIOD = 2_000_000;
    localparam CLOSE_PWM  = 100_000;
    localparam OPEN_PWM   = 175_000;

    reg [20:0] r_pwm_count;
    reg [20:0] r_pwm_duty;

    // Switch 동기화
    reg r_sw_meta;
    reg r_sw_sync;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_sw_meta <= 1'b0;
            r_sw_sync <= 1'b0;
        end
        else begin
            r_sw_meta <= sw;
            r_sw_sync <= r_sw_meta;
        end
    end

    // PWM 주기 및 Duty 설정
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_pwm_count <= 21'd0;
            r_pwm_duty  <= CLOSE_PWM;
        end
        else begin
            if(r_pwm_count == PWM_PERIOD - 1) begin
                r_pwm_count <= 21'd0;

                if(r_sw_sync)
                    r_pwm_duty <= OPEN_PWM;
                else
                    r_pwm_duty <= CLOSE_PWM;
            end
            else begin
                r_pwm_count <= r_pwm_count + 1'b1;
            end
        end
    end

    // PWM 출력
    assign pwm = !reset && (r_pwm_count < r_pwm_duty);

endmodule
