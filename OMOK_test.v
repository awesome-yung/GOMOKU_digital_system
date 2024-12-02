parameter HSIZE = 11;
parameter VSIZE = 10;
parameter map_size = 11;

module SR_Latch(S, R, Q, not_Q);
    input S, R;
    output Q, not_Q;
    
    nand(Q, S, not_Q);
    nand(not_Q, R, Q);
endmodule

module D_FF(clk, D, Q, not_Q);
    input   clk, D;
    output  Q, not_Q;
    
    wire Q1, Q2, not_Q1, not_Q2, S;
    
    and(S, not_Q1, clk);
    
    SR_Latch SR0(not_Q2, clk, Q1, not_Q1);
    SR_Latch SR1(S, D, Q2, not_Q2);
    SR_Latch SR2(not_Q1, Q2, Q, not_Q);
endmodule

module Register_100_bit (clk, D, Q);
    input clk;
    input   [99:0] D;
    output  [99:0] Q;
    genvar k;
    generate
        for(k=0;k<100;k=k+1) begin
            D_FF DF(clk, D[k], Q[k], );
        end
    endgenerate 
endmodule

/*  #################################   */

module wood_board(clk, Current_pos, put, rst, board_state);
    parameter map_size = 11;
    input clk;
    input [7:0] Current_pos;
    input put,rst;
    reg [(map_size-1)*(map_size-1)-1:0] pos_bit;
    reg put_prev;
    wire [(map_size-1)*(map_size-1)-1:0] board_state_out;
    output [(map_size-1)*(map_size-1)-1:0] board_state;
    
    Register_100_bit register(.clk(clk), .D(pos_bit), .Q(board_state_out));
    
    initial begin
        pos_bit = 'b0;
    end
    always @(posedge clk)begin
        pos_bit = 100'b0;
        if(put==1) begin
            pos_bit = 1'b1 << Current_pos;
        end
        if(rst==1)begin
            pos_bit = 'b0;
        end
    end
    assign board_state = board_state_out;    
endmodule

/*  #################################   */

module TFT_LCD_controller(
    input clk, rst,
    output reg [HSIZE-1:0] counter_h,
    output reg [VSIZE-1:0] counter_v,
    output reg disp_den, disp_hsync, disp_vsync,
    output disp_clk, disp_enb
    );
    reg video_on_h, video_on_v;
    assign disp_clk = clk;
    assign disp_enb = 1'b1;
    always @ (posedge rst or posedge clk) begin
        if (rst) begin
            counter_h <= 'd0;
            counter_v <= 'd0;
        end
        else begin
            if (counter_h >= 'd1055) begin
                counter_h <= 'd0;
                if (counter_v >= 'd524) counter_v <= 'd0;
                else counter_v <= counter_v + 'd1;
            end
            else counter_h <= counter_h + 'd1;
        end
    end

    always @ (posedge rst or posedge clk) begin
        if (rst) begin
            disp_hsync <= 'd0;
            disp_vsync <= 'd0;
        end
        else begin
            if ( counter_h == 'd1055 ) disp_hsync <= 'd0;
            else disp_hsync <= 'd1;
            if ( counter_v == 'd525 ) disp_vsync <= 'd0;
            else disp_vsync <= 'd1;
        end
    end

    always @ (posedge rst or posedge clk) begin
        if (rst) begin
            video_on_h <= 'd0;
            video_on_v <= 'd0;
            disp_den <= 'd0;
        end
        else begin
            if ((counter_h <= 'd1010) && (counter_h > 'd210)) video_on_h <= 'd1;
            else video_on_h <= 'd0;
            if ((counter_v <= 'd502 ) && (counter_v > 'd22 )) video_on_v <= 'd1;
            else video_on_v <= 'd0;
            disp_den <= video_on_h & video_on_v;
        end
    end
endmodule

module tft_lcd(
    input clk, rst,
    input [(map_size-1)*(map_size-1)-1:0] board_state,
    output reg [8-1:0] R, G, B,
    output den, hsync, vsync,
    output dclk, disp_en
    );
    wire [11-1:0] counter_h;
    wire [10-1:0] counter_v;
    reg [9:0] row, col, x_min, x_max, row_max;
    reg [8*20*2-1:0] stone_range;
    integer k;
    integer r;
    
    TFT_LCD_controller ctl(
        .clk(clk), .rst(rst),
        .counter_h(counter_h), .counter_v(counter_v),
        .disp_den(den), .disp_hsync(hsync), .disp_vsync(vsync),
        .disp_clk(dclk), .disp_enb(disp_en)
    );
    initial begin
        stone_range = 320'h05080a0c0d0e0f10111212131313141414141414141414141414131313121211100f0e0d0c0a0805;
        row_max = 20;
    end
    
    always @ (posedge rst or posedge clk) begin
        if (rst) begin // background
            R = 8'b0;
            G = 8'b0;
            B = 8'b0;
        end
        else begin
            if (counter_v<42 || 482<counter_v || counter_h<410 || 850<counter_h)begin // background
                R = 8'd0;
                G = 8'd255;
                B = 8'd0;
            end
            else if((counter_v-42)%40 == 0 || (counter_h-410)%40 == 0) begin // black line
                R = 8'h00;
                G = 8'h00;
                B = 8'h00;
            end  
            else if(42<=counter_v && counter_v<=482 && 410<=counter_h && counter_h<=850) begin // wood_board
                R = 8'hCD;
                G = 8'h85;
                B = 8'h3F;
            end
            for (k=0;k<(map_size-1)*(map_size-1);k=k+1) begin  // display stone
                if (board_state[k]==1'b1) begin
                    row = k/(map_size-1);
                    col = k%(map_size-1);
                    for(r=0;r<40;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[r*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[r*8+:8];
                        if(counter_v == 42+40+row*40+(r-20) && x_min<=counter_h && counter_h<=x_max) begin
                            R = 8'hFF;
                            G = 8'hFF;
                            B = 8'hFF;
                        end
                    end                            
                end
            end
        end
    end
endmodule

/*  #################################   */

module OMOK(left, right, up, down, put, rst, undo, clk, R, G, B, den, hsync, vsync, dclk, disp_en);
    parameter map_size = 11;
    input put, rst, undo, clk;
    input left, right, up, down;
    output [8-1:0] R, G, B;
    output den, hsync, vsync, dclk, disp_en;
    reg [7:0] Current_pos;
    reg right_prev, left_prev, up_prev, down_prev;
    wire [(map_size-1)*(map_size-1)-1:0] board_state;
    
    wood_board board(clk, Current_pos, put, rst, board_state);
    tft_lcd lcd(.clk(clk), .rst(rst), .board_state(board_state), .R(R), .G(G), .B(B), .den(den), .hsync(hsync), .vsync(vsync),.dclk(dclk), .disp_en(disp_en));
    
    initial begin
        Current_pos = 8'd14;
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            right_prev <= 1'b0;
            left_prev <= 1'b0;
            up_prev <= 1'b0;
            down_prev <= 1'b0;
        end
        else begin
            right_prev <= right;
            left_prev <= left;
            up_prev <= up;
            down_prev <= down;
        end
    end
    
    always @(posedge clk) begin
        if(right == 1'b1 && right_prev == 1'b0 && Current_pos % (map_size-1) != 9) begin
            Current_pos = Current_pos + 8'd1;
        end
        else if(left == 1'b1 && left_prev == 1'b0 && Current_pos % (map_size-1) != 0) begin
            Current_pos = Current_pos - 8'd1;
        end
        else if(up == 1'b1 && up_prev == 1'b0 && Current_pos / (map_size-1) != 0) begin
            Current_pos = Current_pos - 8'd10;
        end
        else if(down == 1'b1 && down_prev == 1'b0 && Current_pos / (map_size-1) != 9) begin
            Current_pos = Current_pos + 8'd10;
        end
        else if(rst==1) begin
            Current_pos = 8'd44;
        end
    end
endmodule