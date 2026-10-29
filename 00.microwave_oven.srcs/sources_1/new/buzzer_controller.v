`timescale 1ns / 1ps

module buzzer_controller #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TONE_FREQ_HZ = 2_000
)(
    input  clk,
    input  reset,
    input  tick_1ms,
    input  timer_done,
    output buzzer
);

    localparam integer TONE_HALF_PERIOD = CLK_FREQ_HZ / (TONE_FREQ_HZ * 2);

    reg        r_timer_done_d;
    reg        r_sequence_active;
    reg [2:0]  r_phase;
    reg [7:0]  r_ms_count;
    reg [14:0] r_tone_count;
    reg        r_tone;

    wire w_tone_enable = r_sequence_active && !r_phase[0];

    assign buzzer = w_tone_enable ? r_tone : 1'b0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_timer_done_d    <= 1'b0;
            r_sequence_active <= 1'b0;
            r_phase           <= 3'd0;
            r_ms_count        <= 8'd0;
        end else begin
            r_timer_done_d <= timer_done;

            if (timer_done && !r_timer_done_d) begin
                r_sequence_active <= 1'b1;
                r_phase           <= 3'd0;
                r_ms_count        <= 8'd0;
            end else if (r_sequence_active && tick_1ms) begin
                if (r_ms_count == 8'd199) begin
                    r_ms_count <= 8'd0;
                    if (r_phase == 3'd5) begin
                        r_sequence_active <= 1'b0;
                        r_phase           <= 3'd0;
                    end else begin
                        r_phase <= r_phase + 1'b1;
                    end
                end else begin
                    r_ms_count <= r_ms_count + 1'b1;
                end
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_tone_count <= 15'd0;
            r_tone       <= 1'b0;
        end else if (!w_tone_enable) begin
            r_tone_count <= 15'd0;
            r_tone       <= 1'b0;
        end else if (r_tone_count == TONE_HALF_PERIOD - 1) begin
            r_tone_count <= 15'd0;
            r_tone       <= ~r_tone;
        end else begin
            r_tone_count <= r_tone_count + 1'b1;
        end
    end

endmodule
