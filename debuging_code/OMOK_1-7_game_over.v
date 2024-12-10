`timescale 1ns / 1ps

//module game_logic(put, Current_pos, clk, rst, board_state, game_over, stone_count_h, stone_count_v, test_1, test_2, test_3);  // bench
module game_logic(put, Current_pos, clk, rst, board_state, game_over);
    parameter map_size = 11;
    input [7:0] Current_pos;
    input clk, rst, put;
    input [(map_size-1)*(map_size-1)*2-1:0] board_state;
    output reg game_over;
    reg [3:0] stone_count_h, stone_count_v;   // bench
    reg [3:0] stone_count_dp, stone_count_dn;
    reg [7:0] cnt_pos_1, cnt_pos_2, cnt_pos_3, cnt_pos_4;
    reg [7:0] cur_row, cur_col, cnt_row_1, cnt_col_2, cnt_col_3, cnt_row_3, cnt_col_4, cnt_row_4;
    initial begin
        stone_count_h = 4'd1;
        stone_count_v = 4'd1;
        stone_count_dp = 4'd1;
        stone_count_dn = 4'd1;
        game_over = 1'b0;
        cnt_col_3 = 'b0;
        cnt_row_3 = 'b0;
        cnt_col_4 = 'b0;
        cnt_row_4 = 'b0;
        cnt_pos_4 = 'b0;
        cnt_pos_1 = 'b0;
        cnt_pos_2 = 'b0;
        cnt_pos_3 = 'b0;
    end

    always @(posedge clk) begin
        cur_row = Current_pos/10;
        cur_col = Current_pos%10;
       
        if(put==1'b1 && game_over!=1) begin
       
            // horizontal
            if (cnt_pos_1 >= Current_pos + 4 || cnt_pos_1 < Current_pos - 4) begin
                if (Current_pos < 5) begin
                    cnt_pos_1 <= 0;
                    cnt_row_1 <= 0;
                end
                else if (Current_pos > 94) begin
                    cnt_pos_1 <= Current_pos - 4;
                    cnt_row_1 <= (Current_pos - 4) / 10;
                end
                else begin
                    cnt_pos_1 <= Current_pos - 4;
                    cnt_row_1 <= (Current_pos - 4) / 10;
                end
            end
            else begin
                cnt_pos_1 <= cnt_pos_1 + 1;
                cnt_row_1 <= (cnt_pos_1 + 1) / 10;
                if (cnt_row_1 == cur_row && board_state[cnt_pos_1 * 2 +: 2] == 2'b11 && board_state[cnt_pos_1 * 2 + 2 +: 2] == 2'b11) begin
                    stone_count_h <= stone_count_h + 1;
                end
                else if (stone_count_h == 5) begin
                    game_over <= 1;
                end
                else begin
                    stone_count_h <= 4'd1;
                end
            end
           
            // vertical
            if (cnt_pos_2 >= Current_pos + 40 || cnt_pos_2 < Current_pos - 40) begin
                if (Current_pos <= 39) begin
                    cnt_pos_2 <= Current_pos % 10;
                    cnt_col_2 <= Current_pos % 10;
                end
                else if (Current_pos >= 60) begin
                    cnt_pos_2 <= Current_pos - 40;
                    cnt_col_2 <= (Current_pos - 40) % 10;
                end
                else begin
                    cnt_pos_2 <= Current_pos - 40;
                    cnt_col_2 <= (Current_pos - 40) % 10;
                end
            end
            else begin
                cnt_pos_2 <= cnt_pos_2 + 10;
                cnt_col_2 <= (cnt_pos_2 + 10) % 10;
                if (cnt_col_2 == cur_col && board_state[cnt_pos_2 * 2 +: 2] == 2'b11 && board_state[cnt_pos_2 * 2 + 20 +: 2] == 2'b11) begin
                    stone_count_v <= stone_count_v + 1;
                end
                else if (stone_count_v == 5) begin
                    game_over <= 1;
                end
                else begin
                    stone_count_v <= 4'd1;
                end
            end
           
            // digonal (/)
            if (cnt_col_3==0 || cnt_row_3==9) begin
                if (cur_row<9-cur_col)begin
                    cnt_pos_3 <= Current_pos-(cur_row)*9;
                    cnt_col_3 <= (Current_pos-(cur_row)*9) % 10;
                    cnt_row_3 <= (Current_pos-(cur_row)*9) / 10;
                end
                else begin
                    cnt_pos_3 <= Current_pos-(9-cur_col)*9;
                    cnt_col_3 <= (Current_pos-(9-cur_col)*9) % 10;
                    cnt_row_3 <= (Current_pos-(9-cur_col)*9) / 10;
                end
            end
            else begin
                cnt_pos_3 <= cnt_pos_3 + 9;
                cnt_col_3 <= (cnt_pos_3 + 9) % 10;
                cnt_row_3 <= (cnt_pos_3 + 9) / 10;
                if (board_state[cnt_pos_3 * 2 +: 2] == 2'b11 && board_state[cnt_pos_3 * 2 + 18 +: 2] == 2'b11) begin
                    stone_count_dp <= stone_count_dp + 1;
                end
                else if (stone_count_dp == 5) begin
                    game_over <= 1;
                end
                else begin
                    stone_count_dp <= 4'd1;
                end
            end
           
            // digonal (\)
            if (cnt_col_4==9 || cnt_row_4==9) begin
                if (cur_row<cur_col)begin
                    cnt_pos_4 <= Current_pos-(cur_row)*11;
                    cnt_col_4 <= (Current_pos-(cur_row)*11) % 10;
                    cnt_row_4 <= (Current_pos-(cur_row)*11) / 10;
                end
                else begin
                    cnt_pos_4 <= Current_pos-(cur_col)*11;
                    cnt_col_4 <= (Current_pos-(cur_col)*11) % 10;
                    cnt_row_4 <= (Current_pos-(cur_col)*11) / 10;
                end
            end
            else begin
                cnt_pos_4 <= cnt_pos_4 + 11;
                cnt_col_4 <= (cnt_pos_4 + 11) % 10;
                cnt_row_4 <= (cnt_pos_4 + 11) / 10;
                if (board_state[cnt_pos_4 * 2 +: 2] == 2'b11 && board_state[cnt_pos_4 * 2 + 22 +: 2] == 2'b11) begin
                    stone_count_dn <= stone_count_dn + 1;
                end
                else if (stone_count_dn == 5) begin
                    game_over <= 1;
                end
                else begin
                    stone_count_dn <= 4'd1;

                end
            end
           

        end
    end
endmodule


module TFT_LCD_controller(clk, rst, counter_h, counter_v, disp_den, disp_hsync, disp_vsync, disp_clk, disp_enb);
    parameter HSIZE = 11;
    parameter VSIZE = 10;
    input clk, rst;
    output reg [HSIZE-1:0] counter_h;
    output reg [VSIZE-1:0] counter_v;
    output reg disp_den, disp_hsync, disp_vsync;
    output disp_clk, disp_enb;

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

module tft_lcd(clk, rst, board_state, Current_pos, R, G, B, den, hsync, vsync, dclk, disp_en);
    parameter map_size = 11;
    input clk, rst;
    input [(map_size-1)*(map_size-1)*2-1:0] board_state;
    input [7:0] Current_pos;
    output reg [8-1:0] R, G, B;
    output den, hsync, vsync;
    output dclk, disp_en;
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
        stone_range = 160'h05080a0c0d0e0f10111212131313141414141414;
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
                if (Current_pos == k) begin
                    row = k/(map_size-1);
                    col = k%(map_size-1);
                    for(r=0;r<20;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[(19-r)*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[(19-r)*8+:8];
                        if(counter_v == 42+40+row*40+(r-20) && x_min<=counter_h && counter_h<=x_max) begin
                            R = 8'h00;
                            G = 8'h00;
                            B = 8'hFF;
                        end
                    end
                    for(r=0;r<20;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[r*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[r*8+:8];
                        if(counter_v == 42+40+row*40+(r) && x_min<=counter_h && counter_h<=x_max) begin
                            R = 8'h00;
                            G = 8'h00;
                            B = 8'hFF;
                        end
                    end                          
                end
                else if (board_state[k*2+:2]==2'b11) begin
                    row = k/(map_size-1);
                    col = k%(map_size-1);
                    for(r=0;r<20;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[(19-r)*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[(19-r)*8+:8];
                        if(counter_v == 42+40+row*40+(r-20) && x_min<=counter_h && counter_h<=x_max) begin
                            R = 8'hFF;
                            G = 8'hFF;
                            B = 8'hFF;
                        end
                    end
                    for(r=0;r<20;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[r*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[r*8+:8];
                        if(counter_v == 42+40+row*40+(r) && x_min<=counter_h && counter_h<=x_max) begin
                            R = 8'hFF;
                            G = 8'hFF;
                            B = 8'hFF;
                        end
                    end                          
                end
                else if (board_state[k*2+:2]==2'b10) begin
                    row = k/(map_size-1);
                    col = k%(map_size-1);
                    for(r=0;r<20;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[(19-r)*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[(19-r)*8+:8];
                        if(counter_v == 42+40+row*40+(r-20) && x_min<=counter_h && counter_h<=x_max) begin
                            R <= 8'h00;
                            G <= 8'h00;
                            B <= 8'h00;
                        end
                    end
                    for(r=0;r<20;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[r*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[r*8+:8];
                        if(counter_v == 42+40+row*40+(r) && x_min<=counter_h && counter_h<=x_max) begin
                            R <= 8'h00;
                            G <= 8'h00;
                            B <= 8'h00;
                        end
                    end
                end
            end
        end
    end
endmodule

//module wood_board(clk, Current_pos, put, rst, board_state, turn_map);
module wood_board(clk, Current_pos, put, rst, board_state);
    parameter map_size = 11;
    input clk;
    input [7:0] Current_pos;
    input put,rst;
    reg [7:0] turn;
    reg [(map_size-1)*(map_size-1)*2-1:0] board_state_mem;
    output [(map_size-1)*(map_size-1)*2-1:0] board_state;

    assign board_state = board_state_mem;

    initial begin
        board_state_mem = 'b0;
        turn = 0;
    end

    always @(posedge clk)begin
        if(put==1'b1 && board_state_mem[Current_pos*2 +:2]==2'b00) begin
            turn = turn + 1;
            if (turn%2==8'b0)begin
                board_state_mem[Current_pos*2 +:2] <= 2'b11; // white stone
            end
            else begin
                board_state_mem[Current_pos*2 +:2] <= 2'b10; // black stone
            end
        end
        if(rst==1)begin
            board_state_mem <= 'b0;
            turn = 0;
        end
    end

endmodule

//module OMOK(left, right, up, down, put, rst, undo, clk, R, G, B, den, hsync, vsync, dclk, disp_en, test_out, test_pos);
module OMOK(left, right, up, down, put, rst, undo, clk, R, G, B, den, hsync, vsync, dclk, disp_en);
    parameter map_size = 11;
    input put, rst, undo, clk;
    input left, right, up, down;
    output [8-1:0] R, G, B;
    output den, hsync, vsync, dclk, disp_en;
    reg [7:0] Current_pos;
    reg right_prev, left_prev, up_prev, down_prev;
    wire [(map_size-1)*(map_size-1)*2-1:0] board_state;
    wire game_over;

    wood_board board(.clk(clk), .Current_pos(Current_pos), .put(put), .rst(rst), .board_state(board_state));
    tft_lcd lcd(.clk(clk), .rst(rst), .board_state(board_state), .Current_pos(Current_pos), .R(R), .G(G), .B(B), .den(den), .hsync(hsync), .vsync(vsync),.dclk(dclk), .disp_en(disp_en));
    game_logic logic(put, Current_pos, clk, rst, board_state, game_over);

    initial begin
        Current_pos = 8'd44;
    end

    always @(posedge clk or posedge rst) begin
        if (rst || game_over) begin
            right_prev <= 1'b0;
            left_prev <= 1'b0;
            up_prev <= 1'b0;
            down_prev <= 1'b0;
            Current_pos = 8'd44;
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
    end
endmodule