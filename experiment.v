`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2019 09:59:03 AM
// Design Name: 
// Module Name: experiment
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module experiment(
clk, AN,CA,CB,CC,CD,CE,CF,CG,ADJ,pause,reset,led,LED
    );
    input clk,ADJ,pause,reset;
    output [7:0] AN;
    output CA,CB,CC,CD,CE,CF,CG,LED;
    output [1:0] led;
    assign AN[3:0]=4'b1111;
    //clock divider, basic clock will blink at 250 Hz, the clock itself is 1000Hz
    reg clk_div;
    reg [15:0] clk_dv_inc;
    always @(posedge clk or posedge reset) begin
        if(reset) begin
            clk_dv_inc<=0;
            clk_div<=1'b0;
        end
        else if(clk_dv_inc==16'b1100_0011_0101_0000)begin//50000  1100_0011_0101_0000
            clk_dv_inc<=16'b0000_0000_0000_0000;
            clk_div<=!clk_div;
        end else clk_dv_inc <= clk_dv_inc + 1; 
    end
    //clock divider for ADJ,10Hz
    reg clk_adj;
    reg [5:0] clk_adj_inc;
    always @(posedge clk_div or posedge reset) begin
        if(reset) begin
            clk_adj_inc<=0;
            clk_adj<=1'b0;
        end
        else if(clk_adj_inc==6'b1100_10)begin//50  
            clk_adj_inc<=6'b0000_00;
            clk_adj<=!clk_adj;
        end else clk_adj_inc <= clk_adj_inc + 1; 
    end
    
    //debouncer
    reg LED;
    wire indicator_adj;
    reg [3:0]ct_adj;
    reg [1:0]adj_state;
    reg [1:0]nx_adj_state;
    /*assign led[0]=sig_adj[0];
    assign led[1]=sig_adj[1];
    assign led[2]=indicator_adj;*/
    assign indicator_adj=adj_state[1]^adj_state[0];
    always @(negedge clk_adj or posedge reset) begin
        if(reset) begin
            ct_adj<=0;
            adj_state<=0;
            LED<=0;
        end else if(ADJ==1'b1) begin
            ct_adj<=ct_adj+1;
            if(ct_adj>=4'b1111) begin //30
                adj_state<=nx_adj_state;               
                ct_adj<=4'b0000;
            end
        end else ct_adj<=0;
    end
    always @(*) begin
        nx_adj_state=0;
        case (adj_state) 
            2'b00: begin
                nx_adj_state=2'b01;
            end
            2'b01: begin
                nx_adj_state=2'b10;
            end
            2'b10: begin
                nx_adj_state=2'b00;
            end
        endcase
    end
    wire indicator_pa;
    pa p(clk,pause,reset,adj_state,indicator_pa);
    basic_clock ba(reset, indicator_pa,indicator_adj,clk,clk_div,clk_adj,AN[7:4],CA,CB,CC,CD,CE,CF,CG,adj_state,ADJ,led);
endmodule
