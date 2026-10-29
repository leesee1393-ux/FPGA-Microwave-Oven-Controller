`timescale 1ns / 1ps


module fnd_controller(
    input clk,
    input reset,
    input tick,
    input start,
    input pause,
    input [13:0] in_data,
    input [9:0] set_time,

    output [3:0] an,
    output [7:0] seg,
    output reg timer_done
    );

    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;
    wire [13:0] w_display_data;

    reg [9:0] r_ms_count;
    reg [9:0] r_remaining_sec;
    reg r_running;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            r_ms_count <= 10'd0;
            r_remaining_sec <= 10'd0;
            r_running <= 1'b0;
            timer_done <= 1'b0;
        end
        else if(start && !r_running && set_time != 10'd0) begin
            r_remaining_sec <= set_time;
            r_ms_count <= 10'd0;
            r_running <= 1'b1;
            timer_done <= 1'b0;
        end
        else if(r_running && !pause && tick) begin
            if(r_ms_count == 10'd999) begin
                r_ms_count <= 10'd0;

                if(r_remaining_sec > 10'd1)
                    r_remaining_sec <= r_remaining_sec - 1'b1;
                else begin
                    r_remaining_sec <= 10'd0;
                    r_running <= 1'b0;
                    timer_done <= 1'b1;
                end
            end
            else begin
                r_ms_count <= r_ms_count + 1'b1;
            end
        end
    end

assign w_display_data = (r_running || timer_done)
    ? ((r_remaining_sec / 60) * 100 +
       (r_remaining_sec % 60))
    : in_data;


    fnd_digit_select u_fnd_digit_select(
    .clk(clk),
    .reset(reset),
    .tick(tick),
    .sel(w_sel)  // 00 01 10 11 : 1ms 마다 바뀜     
);
    bin2bcd4digit u_bin2cd4digit(
        .in_data(w_display_data),
        .d1(w_d1),
        .d10(w_d10),
        .d100(w_d100),
        .d1000(w_d1000)
    );

    fnd_digit_display u_fnd_digit_display (
         .sel(w_sel),
         .d1(w_d1),
         .d10(w_d10),
         .d100(w_d100),
         .d1000(w_d1000),
         .an(an),
         .seg(seg)
); 
endmodule


//---- 1ms 마다 fnd display digit 1자리씩 선택하는 logic 한다 .
module fnd_digit_select(
    
    input clk,
    input reset,
    input tick,
    output reg [1:0] sel // 00 01 10 11 : 1ms 마다 바뀜

);
    always @(posedge reset, posedge tick) begin
            if(reset) begin
                sel <=0;
            end else begin
                if(tick) begin  // 1ms 
                    sel <= sel + 1; 
                end
                    
            end 
    end

endmodule

// in_data: 14bit fnd에 9999까지 표현 하기 위한 bin size
// 0~~9999 천/ 백 /십/일 자리숫자 0~9 BCD 4bit 표현한다. 

module bin2bcd4digit(
    input [13:0] in_data,
    output [3:0] d1,
    output [3:0] d10,
    output [3:0] d100,
    output [3:0] d1000
);

    assign d1 = in_data % 10 ;
    assign d10 = (in_data / 10) % 10 ;
    assign d100 = (in_data / 100)% 10 ;
    assign d1000 = (in_data / 1000) % 10 ;

endmodule

module fnd_digit_display (
    input [1:0] sel,    // 00 01 10 11  : 1ms 마다 바뀜 
    input [3:0] d1,
    input [3:0] d10,
    input [3:0] d100,
    input [3:0] d1000,
    
    output reg [3:0] an,
    output reg [7:0] seg
);    

    reg [3:0] bcd_data;
    always @(sel) begin // sel 값이 변할떄는 언제나 수행 한다. 
        
        case(sel)
            2'b00: begin
                bcd_data=d1;
                an = 4'b1110;
            end
            2'b01: begin
                bcd_data=d10;
                an = 4'b1101;
            end
            2'b10: begin
                bcd_data=d100;
                an = 4'b1011;
            end
            2'b11: begin
                bcd_data=d1000;
                an = 4'b0111;
            end
            default: begin
                bcd_data = 4'b0000;
                an = 4'b1111;
            end 
        endcase
    end

    always @(bcd_data) begin
        case (bcd_data)
        4'd0: seg = 8'b11000000; // 0
        4'd1: seg = 8'b11111001; // 1
        4'd2: seg = 8'b10100100; // 2
        4'd3: seg = 8'b10110000; // 3
        4'd4: seg = 8'b10011001; // 4
        4'd5: seg = 8'b10010010; // 5
        4'd6: seg = 8'b10000010; // 6
        4'd7: seg = 8'b11111000; // 7
        4'd8: seg = 8'b10000000; // 8
        4'd9: seg = 8'b10010000; // 9

        default: seg = 8'b11111111; // 모든 세그먼트 OFF
        endcase

        if(sel == 2'b10)
            seg[7] = 1'b0;
        else 
            seg[7] = 1'b1;
    end
endmodule
 
