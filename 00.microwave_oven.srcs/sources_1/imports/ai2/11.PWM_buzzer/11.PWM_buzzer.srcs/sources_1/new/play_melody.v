`timescale 1ns / 1ps


module play_melody(
    input clk,
    input reset,
    input [6:0] btn,
    output [1:0] led,
    output buzzer
);

    // clk: 100Mhz
    // output : 원하는 주파수 
    // 100Mhz / 원하는 주파수 /2 : duty 50%
    localparam DO = 22'd191_112;  // 50% duty 261.63Hz
    localparam RE = 22'd170_265;  // 래 duty 293.63Hz
    localparam MI = 22'd151_685;  // 미 duty 261.63Hz
    localparam PA = 22'd174_614;  // 파 duty 261.63Hz
    localparam SOL = 22'd127_551;  // 솔 duty 261.63Hz
    localparam RA = 22'd113_636;  // 라 duty 261.63Hz
    localparam SI = 22'd246_941;  // 시 duty 261.63Hz
    

    reg [21:0] r_clk_cnt [6:0]; // 2차원 array
    reg [6:0] r_buzzer_frequnecy;
    integer i; // integer : signed 32bit / unsigned : reg [31:0]

    always @(posedge clk,posedge reset) begin
        if(reset) begin
            for(i=0; i < 7; i=i+1) begin
                r_clk_cnt[i] <= 22'd0;
                r_buzzer_frequnecy[i] <= 1'b0;
            end
        end else begin  //  10ns 상승 에지 클럭
            if (!btn[0]) begin //btnU
                r_clk_cnt[0] <=22'd0;
                r_buzzer_frequnecy[0] <= 1'b0;
            end else if(r_clk_cnt[0]>= DO-1) begin
                r_clk_cnt[0]<=22'd0;
                r_buzzer_frequnecy[0]<= ~r_buzzer_frequnecy[0];
            end else r_clk_cnt[0]<=r_clk_cnt[0] +1;
        

            if (!btn[1]) begin //btnU
                r_clk_cnt[1] <=22'd0;
                r_buzzer_frequnecy[1] <= 1'b0;
            end else if(r_clk_cnt[1]>= RE-1) begin
                r_clk_cnt[1]<=22'd0;
                r_buzzer_frequnecy[1]<= ~r_buzzer_frequnecy[1];
            end else r_clk_cnt[1]<=r_clk_cnt[1] +1;
                
            if (!btn[2]) begin //btnU
                r_clk_cnt[2] <=22'd0;
                r_buzzer_frequnecy[2] <= 1'b0;
            end else if(r_clk_cnt[2]>= MI-1) begin
                r_clk_cnt[2]<=22'd0;
                r_buzzer_frequnecy[2]<= ~r_buzzer_frequnecy[2];
            end else r_clk_cnt[2]<=r_clk_cnt[2] +1;

            if (!btn[3]) begin //btnU
                r_clk_cnt[3] <=22'd0;
                r_buzzer_frequnecy[3] <= 1'b0;
            end else if(r_clk_cnt[3]>= PA-1) begin
                r_clk_cnt[3]<=22'd0;
                r_buzzer_frequnecy[3]<= ~r_buzzer_frequnecy[3];
            end else r_clk_cnt[3]<=r_clk_cnt[3] +1;    
            

            
            if (!btn[4]) begin //btnU
                r_clk_cnt[4] <=22'd0;
                r_buzzer_frequnecy[4] <= 1'b0;
            end else if(r_clk_cnt[4]>= SOL-1) begin
                r_clk_cnt[4]<=22'd0;
                r_buzzer_frequnecy[4]<= ~r_buzzer_frequnecy[4];
            end else r_clk_cnt[4]<=r_clk_cnt[4] +1;
            
            if (!btn[5]) begin //btnU
                r_clk_cnt[5] <=22'd0;
                r_buzzer_frequnecy[5] <= 1'b0;
            end else if(r_clk_cnt[5]>= PA-1) begin
                r_clk_cnt[5]<=22'd0;
                r_buzzer_frequnecy[5]<= ~r_buzzer_frequnecy[5];
            end else r_clk_cnt[5]<=r_clk_cnt[5] +1;    

            if (!btn[6]) begin //btnU
                r_clk_cnt[6] <=22'd0;
                r_buzzer_frequnecy[6] <= 1'b0;
            end else if(r_clk_cnt[6]>= SI-1) begin
                r_clk_cnt[6]<=22'd0;
                r_buzzer_frequnecy[6]<= ~r_buzzer_frequnecy[6];
            end else r_clk_cnt[6]<=r_clk_cnt[6] +1;    
        end
    end
        // assign buzzer = r_buzzer_frequnecy[6] | r_buzzer_frequnecy[5];
        assign buzzer = |r_buzzer_frequnecy;
        // 축약 연산자 or 연산자
endmodule
