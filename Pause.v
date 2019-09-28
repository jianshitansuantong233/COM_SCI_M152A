module pa(clk,pause,reset,adj_state,indicator);
    input clk,pause,reset;
    input [1:0] adj_state;
    output indicator;
    reg indicator;//in pause status or not, 0 is no
    reg indicator_2;
    always@(negedge clk) begin
        if(pause&&!indicator_2&&adj_state==2'b00) begin
            indicator_2<=1;
            indicator<=!indicator;
        end else if(reset) begin
            indicator<=0;
            indicator_2<=0;
        end else if(pause==0) indicator_2<=0;
    end
endmodule