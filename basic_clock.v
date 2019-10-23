module basic_clock(reset,indicator_pa,indicator_adj,clk,clk_div,clk_adj,AN,CA,CB,CC,CD,CE,CF,CG,sig_adj,ADJ,led);
    input clk_div,clk_adj,reset,clk,ADJ,indicator_pa,indicator_adj;
    input [1:0] sig_adj;
    output [1:0] led;
    output CA,CB,CC,CD,CE,CF,CG;
    output [3:0] AN;
    reg [3:0] AN;

    
    //wire for adjustment function
    wire sig_second_adj;
    wire sig_minute_adj;
    //state machine
    reg CA,CB,CC,CD,CE,CF,CG;
    reg [3:0]second_state;
    reg [3:0]seconds_state;
    reg [3:0]minute_state;
    reg [3:0]minutes_state;
    reg [3:0]nx_second_state;
    reg [3:0]nx_seconds_state;
    reg [3:0]nx_minute_state;
    reg [3:0]nx_minutes_state;
    integer counter;
    //clock divider 1Hz  
    reg [3:0] clk_dv_inc_second;
    reg indicator_minute;
    reg indicator_second;
    always @(negedge clk_adj or posedge reset) begin
        if(reset) begin
           clk_dv_inc_second<=0;
           second_state<=4'b0000;
           seconds_state<=4'b0000;
           minute_state<=4'b0000;
           minutes_state<=4'b0000;
           counter<=1;
           indicator_minute<=0;
           indicator_second<=0;
        end else if(clk_dv_inc_second==4'b1010) begin//100,000,000 
            clk_dv_inc_second<=4'b0000;
            counter<=counter+1;
            if(counter%1==0&&counter>0) second_state<=nx_second_state;
            if(counter%10==0&&counter>0) seconds_state<=nx_seconds_state;
            if(counter%60==0&&counter>0)minute_state<=nx_minute_state;
            if(counter%600==0&&counter>0)minutes_state<=nx_minutes_state;           
        end else if((indicator_pa|indicator_adj)==0) begin
            clk_dv_inc_second <= clk_dv_inc_second + 1;
        end else if(sig_minute_adj&&!indicator_minute) begin
            indicator_minute<=1;
            counter<=counter+300;
            if(minute_state<4'b0101) minute_state<=4+nx_minute_state;
            else begin
                minute_state<=minute_state-5;
                minutes_state<=nx_minutes_state;
            end
        end else if(sig_second_adj&&!indicator_second) begin
            indicator_second<=1;
            counter<=counter+5;
            if(second_state<4'b0101) second_state<=4+nx_second_state;
            else begin
                second_state<=second_state-5;
                seconds_state<=nx_seconds_state;
            end
        end else if(!sig_minute_adj&&sig_adj==2'b01) begin
            indicator_minute<=0;
        end else if(!sig_second_adj&&sig_adj==2'b10) begin
            indicator_second<=0;
        end
    end 
    //block making the stopwatch to blink
    integer cl;
    reg [9:0] ct_adj_blink;
    reg indicator_1; 
    always @(negedge clk_div or posedge reset) begin
        if(reset) begin
            AN[3:0]<=4'b1111;
            cl<=0;
            indicator_1<=0;
            ct_adj_blink<=0;
        end else if(sig_adj[1]&&!indicator_1) begin
            indicator_1<=1;
            ct_adj_blink<=0;
        end else if(cl==0)begin
            if(sig_adj==2) begin
                if(ct_adj_blink>=9'b1111_1010_0&&ct_adj_blink<10'b1111_1010_00)    AN[3:0]<=4'b1110;
                else if(ct_adj_blink==10'b1111_1010_00) ct_adj_blink<=0;
                else AN[3:0]<=4'b1111;
            end else AN[3:0]<=4'b1110;
            cl<=cl+1;
            ct_adj_blink<=ct_adj_blink+1;
        end else if(cl==1) begin
            if(sig_adj==2) begin
                if(ct_adj_blink>=9'b1111_1010_0&&ct_adj_blink<10'b1111_1010_00) AN[3:0]<=4'b1101;
                else if(ct_adj_blink==10'b1111_1010_00) ct_adj_blink<=0;
                else AN[3:0]<=4'b1111;
            end else AN[3:0]<=4'b1101;
            cl<=cl+1;
            ct_adj_blink<=ct_adj_blink+1;
        end else if(cl==2) begin
            if(sig_adj==1) begin
                 if(ct_adj_blink>=9'b1111_1010_0&&ct_adj_blink<10'b1111_1010_00) AN[3:0]<=4'b1011;
                 else if(ct_adj_blink==10'b1111_1010_00) ct_adj_blink<=0;
                 else AN[3:0]<=4'b1111;
            end else AN[3:0]<=4'b1011;
            cl<=cl+1;
            ct_adj_blink<=ct_adj_blink+1;
        end else if(cl==3)  begin
            if(sig_adj==1) begin
                 if(ct_adj_blink>=9'b1111_1010_0&&ct_adj_blink<10'b1111_1010_00) AN[3:0]<=4'b0111;
                 else if(ct_adj_blink==10'b1111_1010_00) ct_adj_blink<=0;
                 else AN[3:0]<=4'b1111;
            end else AN[3:0]<=4'b0111;
            cl<=0;
            ct_adj_blink<=ct_adj_blink+1;
        end
    end

    
    adjustment ad(clk_adj,reset,ADJ,sig_adj,sig_second_adj,sig_minute_adj,led);
    //combination logic
    always @(*) begin
        nx_second_state=0;
        nx_seconds_state=0;
        nx_minute_state=0;
        nx_minutes_state=0;
        CA=0;
        CB=0;
        CC=0;
        CD=0;
        CE=0;
        CF=0;
        CG=0;
        case(second_state)
            4'b0000: begin
                if(AN[0]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=1;   
                end
                nx_second_state=4'b0001;
            end
            4'b0001: begin
                if(AN[0]==1'b0) begin
                    CB=0;
                    CC=0;
                    CA=1;
                    CD=1;
                    CE=1;
                    CF=1;
                    CG=1;
                end
                nx_second_state=4'b0010;    
            end
            4'b0010: begin
                if(AN[0]==1'b0) begin
                    CA=0;
                    CB=0;
                    CD=0;
                    CE=0;
                    CG=0;
                    CC=1;
                    CF=1;
                end
                nx_second_state=4'b0011;
            end
            4'b0011: begin
                if(AN[0]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CG=0;
                    CE=1;
                    CF=1;
                end
                nx_second_state=4'b0100;
            end
            4'b0100: begin
                if(AN[0]==1'b0) begin
                    CB=0;
                    CC=0;
                    CF=0;
                    CG=0;
                    CA=1;
                    CD=1;
                    CE=1;
                end
                nx_second_state=4'b0101;
            end
            4'b0101: begin
                if(AN[0]==1'b0) begin
                    CA=0;
                    CC=0;
                    CD=0;
                    CF=0;
                    CG=0;
                    CB=1;
                    CE=1;
                end
                nx_second_state=4'b0110;
            end
            4'b0110: begin
                if(AN[0]==1'b0) begin
                    CA=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=0;
                    CB=1;
                end
                nx_second_state=4'b0111;
            end
            4'b0111: begin
                if(AN[0]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=1;
                    CE=1;
                    CF=1;
                    CG=1;
                end
                nx_second_state=4'b1000;
             end
             4'b1000: begin
                 if(AN[0]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=0;
                end
                nx_second_state=4'b1001;
             end
             4'b1001: begin
                 if(AN[0]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CF=0;
                    CG=0;
                    CE=1;
                end
                nx_second_state=4'b0000;
            end
        endcase
         case(seconds_state)
            4'b0000: begin
                if(AN[1]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=1;
                end
                nx_seconds_state=4'b0001;
            end
            4'b0001: begin
                if(AN[1]==1'b0) begin
                    CB=0;
                    CC=0;
                    CA=1;
                    CD=1;
                    CE=1;
                    CF=1;
                    CG=1;
                end
                nx_seconds_state=4'b0010;
            end
            4'b0010: begin
                if(AN[1]==1'b0) begin
                    CA=0;
                    CB=0;
                    CD=0;
                    CE=0;
                    CG=0;
                    CC=1;
                    CF=1;
                end
                nx_seconds_state=4'b0011;
            end
            4'b0011: begin
                if(AN[1]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CG=0;
                    CE=1;
                    CF=1;
                end
                nx_seconds_state=4'b0100;
            end
            4'b0100: begin
                if(AN[1]==1'b0) begin
                    CB=0;
                    CC=0;
                    CF=0;
                    CG=0;
                    CA=1;
                    CD=1;
                    CE=1;
                end
                nx_seconds_state=4'b0101;
            end
            4'b0101: begin
                if(AN[1]==1'b0) begin
                    CA=0;
                    CC=0;
                    CD=0;
                    CF=0;
                    CG=0;
                    CB=1;
                    CE=1;
                end
                nx_seconds_state=4'b0000;
            end
        endcase
        case(minute_state)
            4'b0000: begin
                if(AN[2]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=1;
                end
                nx_minute_state=4'b0001;
            end
            4'b0001: begin
                if(AN[2]==1'b0) begin
                   CB=0;
                   CC=0;
                   CA=1;
                   CD=1;
                   CE=1;
                   CF=1;
                   CG=1;
                end
                nx_minute_state=4'b0010;
            end
            4'b0010: begin
                if(AN[2]==1'b0) begin
                   CA=0;
                   CB=0;
                   CD=0;
                   CE=0;
                   CG=0;
                   CC=1;
                   CF=1;
                end
                nx_minute_state=4'b0011;
            end
            4'b0011: begin
                if(AN[2]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CG=0;
                    CE=1;
                    CF=1;
                end
                nx_minute_state=4'b0100;
            end
            4'b0100: begin
                if(AN[2]==1'b0) begin
                    CB=0;
                    CC=0;
                    CF=0;
                    CG=0;
                    CA=1;
                    CD=1;
                    CE=1;
                end
                nx_minute_state=4'b0101;
            end
            4'b0101: begin
                if(AN[2]==1'b0) begin
                    CA=0;
                    CC=0;
                    CD=0;
                    CF=0;
                    CG=0;
                    CB=1;
                    CE=1;
                end
                nx_minute_state=4'b0110;
            end
            4'b0110: begin
                if(AN[2]==1'b0) begin
                    CA=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=0;
                    CB=1;
                end
                nx_minute_state=4'b0111;
            end
            4'b0111: begin
                if(AN[2]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=1;
                    CE=1;
                    CF=1;
                    CG=1;
                end
                nx_minute_state=4'b1000;
             end
             4'b1000: begin
                 if(AN[2]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=0;
                end
                nx_minute_state=4'b1001;
             end
             4'b1001: begin
                 if(AN[2]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CF=0;
                    CG=0;
                    CE=1;
                end
                nx_minute_state=4'b0000;
            end
        endcase
        case(minutes_state)
            4'b0000: begin
                if(AN[3]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CE=0;
                    CF=0;
                    CG=1;
                end
                nx_minutes_state=4'b0001;
            end
            4'b0001: begin
                if(AN[3]==1'b0) begin
                    CB=0;
                    CC=0;
                    CA=1;
                    CD=1;
                    CE=1;
                    CF=1;
                    CG=1;
                end
                nx_minutes_state=4'b0010;
            end
            4'b0010: begin
                if(AN[3]==1'b0) begin
                    CA=0;
                    CB=0;
                    CD=0;
                    CE=0;
                    CG=0;
                    CC=1;
                    CF=1;
                end
                nx_minutes_state=4'b0011;
            end
            4'b0011: begin
                if(AN[3]==1'b0) begin
                    CA=0;
                    CB=0;
                    CC=0;
                    CD=0;
                    CG=0;
                    CE=1;
                    CF=1;
                end
                nx_minutes_state=4'b0100;
            end
            4'b0100: begin
                if(AN[3]==1'b0) begin
                    CB=0;
                    CC=0;
                    CF=0;
                    CG=0;
                    CA=1;
                    CD=1;
                    CE=1;
                end
                nx_minutes_state=4'b0101;
            end
            4'b0101: begin
                if(AN[3]==1'b0) begin
                    CA=0;
                    CC=0;
                    CD=0;
                    CF=0;
                    CG=0;
                    CB=1;
                    CE=1;
                end
                nx_minutes_state=4'b0000;
            end
        endcase 
    end
endmodule