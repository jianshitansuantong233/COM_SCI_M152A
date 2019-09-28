`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2019 07:48:30 PM
// Design Name: 
// Module Name: adjustment
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module adjustment(clk_adj,reset,ADJ,adj_state,sig_second_adj,sig_minute_adj,led);
    input clk_adj,ADJ,reset;
    input [1:0] adj_state;
    output [1:0] led;
    output sig_second_adj,sig_minute_adj;
    reg [4:0]ct_adj;
    reg sig_second_adj=0;
    reg sig_minute_adj=0;
    reg [1:0] counter=0;
    //reg [1:0] led;
    assign led[0]=sig_second_adj;
    assign led[1]=sig_minute_adj;
    always @(negedge clk_adj or posedge reset) begin
        if(reset) begin
            ct_adj<=0;
            sig_second_adj<=0;
            sig_minute_adj<=0;
        end else if(ADJ==1'b1&&adj_state!=2'b00) begin
            ct_adj<=ct_adj+1;
        end else if(ct_adj<5'b1111_0&&ct_adj>2'b11&&ADJ==1'b0&&adj_state==2'b01) begin
            sig_minute_adj<=1;
            ct_adj<=0;
            counter<=0;
        end else if(ct_adj<5'b1111_0&&ct_adj>2'b11&&ADJ==1'b0&&adj_state==2'b10) begin
            sig_second_adj<=1;
            ct_adj<=0;
            counter<=0;
        end else if(ct_adj>4'b1100) begin
            ct_adj<=0;
        end else if(adj_state!=2'b00) begin
            if(sig_minute_adj) begin
                counter<=counter+1;
                //led[1]<=!led[1];
                sig_minute_adj<=!counter[1];
            end else if(sig_second_adj) begin
                counter<=counter+1;
                //led[0]<=!led[0];
                sig_second_adj<=!counter[1];
            end
        end
    end 
    
    
endmodule
