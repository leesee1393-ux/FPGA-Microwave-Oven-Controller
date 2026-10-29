
`timescale 1ns / 1ps

module rotary(
    input clk,
    input reset,
    input s1,
    input s2,
    input key,

    output [11:0] time_set,
    output [9:0] total_sec,
    output time_setting,
    output [3:0] debug_led
);

    // 1. Rotary 상태 및 카운터
    reg [1:0] r_direction = 2'b00;
    reg [1:0] r_prev_state = 2'b00;
    reg [1:0] r_current_state = 2'b00;
    reg [1:0] r_step = 2'b00;

    // 설정 가능 시간 : 0 ~ 540초
    reg [9:0] r_counter = 10'd0;

    // 분 / 초 저장
    reg [3:0] r_min = 4'd0;
    reg [7:0] r_sec = 8'd0;

    // 2. KEY Toggle
    // 0 : 설정 종료 / 대기
    // 1 : 시간 설정 가능
    reg r_time_toggle = 1'b0;
    reg r_prev_key = 1'b0;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_time_toggle <= 1'b0;
            r_prev_key <= 1'b0;
        end
        else begin
            r_prev_key <= key;

            // KEY 상승 에지 검출
            if(!r_prev_key && key)
                r_time_toggle <= ~r_time_toggle;
        end
    end

    // 3. Rotary 회전 처리
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_direction <= 2'b00;
            r_prev_state <= 2'b00;
            r_current_state <= 2'b00;
            r_step <= 2'b00;
            r_counter <= 10'd0;
        end
        else begin
            r_prev_state <= r_current_state;
            r_current_state <= {s1, s2};

            case ({r_prev_state, r_current_state})

                // CW : 00 -> 10 -> 11 -> 01 -> 00
                4'b0010,
                4'b1011,
                4'b1101,
                4'b0100: begin

                    if(r_direction != 2'b01) begin
                        r_step <= 2'd1;
                    end
                    else begin
                        r_step <= r_step + 1'b1;

                        // 설정 모드에서만 증가
                        if(r_step == 2'b11 &&
                           r_time_toggle == 1'b1 &&
                           r_counter < 10'd540)
                            r_counter <= r_counter + 1'b1;
                    end

                    r_direction <= 2'b01;
                end

                // CCW : 00 -> 01 -> 11 -> 10 -> 00
                4'b0001,
                4'b0111,
                4'b1110,
                4'b1000: begin

                    if(r_direction != 2'b10) begin
                        r_step <= 2'd1;
                    end
                    else begin
                        r_step <= r_step + 1'b1;

                        // 설정 모드에서만 감소
                        if(r_step == 2'b11 &&
                           r_time_toggle == 1'b1 &&
                           r_counter > 10'd0)
                            r_counter <= r_counter - 1'b1;
                    end

                    r_direction <= 2'b10;
                end

                default: begin
                    // 상태 유지
                end

            endcase
        end
    end

    // 4. 총 초 -> 분 / 초 변환
    always @(*) begin
        r_min = r_counter / 60;
        r_sec = r_counter % 60;
    end

    // 5. 출력 연결
    assign time_set = {r_min, r_sec};
    assign total_sec = r_counter;

    // Top으로 설정 상태 전달
    assign time_setting = r_time_toggle;

    // 6. Debug LED
    assign debug_led[0] = s1;
    assign debug_led[1] = s2;
    assign debug_led[2] = r_time_toggle;
    assign debug_led[3] = (r_counter != 0);

endmodule
