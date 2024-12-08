`timescale 1ns / 1ps

//module game_logic(Current_pos, clk, rst, board_state, game_over, stone_count_h, stone_count_v);  // bench
module game_logic(Current_pos, clk, rst, board_state, game_over);
    parameter map_size = 11;
    input [7:0] Current_pos;
    input clk, rst;
    input [(map_size-1)*(map_size-1)*2-1:0] board_state;
    output reg game_over;
//    output reg [3:0] stone_count_h, stone_count_v;   // bench
    reg [3:0] stone_count_h, stone_count_v, stone_count_d1, stone_count_d2;
    reg [3:0] cnt_row, cur_row, cur_col, cnt_col;
    reg [7:0] position_h, position_v;
    integer i;
    initial begin
        stone_count_h = 1;
        stone_count_v = 1;
        stone_count_d1 = 1;
        stone_count_d2 = 1;
        game_over = 1'b0;
    end

    // violation_checker checker();

    always @(posedge clk) begin
        cur_row = Current_pos/10;
        cur_col = Current_pos%10;
        
        if (stone_count_h==5||stone_count_v==5||stone_count_d1==5||stone_count_d2==5) game_over = 1'b1;
        
        for (i = 0; i < 9; i = i + 1) begin
            // Horizontal
            if(4<=Current_pos && Current_pos<=95) begin
                cnt_row = (Current_pos-4+i)/10;
                if (cnt_row==cur_row && 0<=cnt_row && cnt_row<10) begin
                    position_h = (Current_pos - 4) + i * 1;
                    if (board_state[position_h*2 +:2] == board_state[position_h*2 + 2 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_h = stone_count_h + 1;
                    else stone_count_h = 'b0;
                end
                else stone_count_h = 'b0;            
            end
            
            // Vertical
            if(40<=Current_pos && Current_pos<=59) begin
                cnt_col = (Current_pos-40+i*10)%10;
                if (cnt_col==cur_col && 0<=cnt_col && cnt_col<10) begin
                    position_v = (Current_pos - 40) + i * 10;
                    if (board_state[position_v*2 +:2] == board_state[position_v*2 + 20 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_v = stone_count_v + 1;
                    else stone_count_v = 'b0;
                end
                else stone_count_v = 'b0;            
            end

            // Diagonal(\)
            if(44<=Current_pos && Current_pos<=55) begin
                cnt_d1 = (Current_pos-44+i*11)%10;
                if (cnt_col==cur_col && 0<=cnt_col && cnt_col<10) begin
                    position_v = (Current_pos - 44) + i * 11;
                    if (board_state[position_v*2 +:2] == board_state[position_v*2 + 20 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_d1 = stone_count_d1 + 1;
                    else stone_count_d1 = 'b0;
                end
                else stone_count_d1 = 'b0;            
            end

            // Diagonal(/)
            if(36<=Current_pos && Current_pos<=63) begin
                cnt_col = (Current_pos-36+i*9)%10;
                if (cnt_col==cur_col && 0<=cnt_col && cnt_col<10) begin
                    position_v = (Current_pos - 36) + i * 9;
                    if (board_state[position_v*2 +:2] == board_state[position_v*2 + 20 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_d2 = stone_count_d2 + 1;
                    else stone_count_d2 = 'b0;
                end
                else stone_count_d2 = 'b0;            
            end
        end
    end
endmodule

module violation_checker (Current_pos, clk, rst, board_state, violation_flag);
    parameter map_size = 11;
    input [7:0] Current_pos;
    input clk, rst;
    input [(map_size-1)*(map_size-1)*2-1:0] board_state;
    output reg violation_flag;
//    output reg [3:0] stone_count_h, stone_count_v;   // bench
    reg [3:0] stone_count_h, stone_count_v, stone_count_d1, stone_count_d2;
    reg [3:0] cnt_row, cur_row, cur_col, cnt_col;
    reg [3:0] cnt_three;
    reg [7:0] position_h, position_v;
    integer i;
    initial begin
        stone_count_h = 1;
        stone_count_v = 1;
        stone_count_d1 = 1;
        stone_count_d2 = 1;
        cnt_three = 4'b0;
        violation_flag = 1'b0;
    end

    always @(posedge clk) begin
        cur_row = Current_pos/10;
        cur_col = Current_pos%10;
        
        if (stone_count_h==3) cnt_three = cnt_three + 1;
        else if (stone_count_v==3) cnt_three = cnt_three + 1;
        else if (stone_count_d1==3) cnt_three = cnt_three + 1;
        else if (stone_count_d2==3) cnt_three = cnt_three + 1;
        
        if (cnt_three == 2) violation_flag = 1'b1;


        for (i = 0; i < 5; i = i + 1) begin
            // Horizontal
            if(2<=Current_pos && Current_pos<=97) begin
                cnt_row = (Current_pos-2+i)/10;
                if (cnt_row==cur_row && 0<=cnt_row && cnt_row<10) begin
                    position_h = (Current_pos - 2) + i * 1;
                    if (board_state[position_h*2 +:2] == board_state[position_h*2 + 2 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_h = stone_count_h + 1;
                    else stone_count_h = 'b0;
                end
                else stone_count_h = 'b0;            
            end
            
            // Vertical
            if(20<=Current_pos && Current_pos<=79) begin
                cnt_col = (Current_pos-40+i*10)%10;
                if (cnt_col==cur_col && 0<=cnt_col && cnt_col<10) begin
                    position_v = (Current_pos - 20) + i * 10;
                    if (board_state[position_v*2 +:2] == board_state[position_v*2 + 20 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_v = stone_count_v + 1;
                    else stone_count_v = 'b0;
                end
                else stone_count_v = 'b0;            
            end

            // Diagonal(\)
            if(22<=Current_pos && Current_pos<=77) begin
                cnt_d1 = (Current_pos-44+i*11)%10;
                if (cnt_col==cur_col && 0<=cnt_col && cnt_col<10) begin
                    position_v = (Current_pos - 22) + i * 11;
                    if (board_state[position_v*2 +:2] == board_state[position_v*2 + 20 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_d1 = stone_count_d1 + 1;
                    else stone_count_d1 = 'b0;
                end
                else stone_count_d1 = 'b0;            
            end

            // Diagonal(/)
            if(18<=Current_pos && Current_pos<=81) begin
                cnt_col = (Current_pos-36+i*9)%10;
                if (cnt_col==cur_col && 0<=cnt_col && cnt_col<10) begin
                    position_v = (Current_pos - 18) + i * 9;
                    if (board_state[position_v*2 +:2] == board_state[position_v*2 + 20 +:2] && board_state[position_h*2 +:2]!=2'b00) stone_count_d2 = stone_count_d2 + 1;
                    else stone_count_d2 = 'b0;
                end
                else stone_count_d2 = 'b0;            
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

module tft_lcd(clk, rst, board_state, R, G, B, den, hsync, vsync, dclk, disp_en);
    parameter map_size = 11;
    input clk, rst;
    input [(map_size-1)*(map_size-1)*2-1:0] board_state;
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
                if (board_state[k*2+:2]==2'b11) begin
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

module wood_board(clk, Current_pos, put, rst, board_state);
    parameter map_size = 11;
    input clk;
    input [7:0] Current_pos;
    input put,rst;
    reg [7:0] turn;
    reg [(map_size-1)*(map_size-1)*2-1:0] board_state_mem;
    wire game_over;
    output [(map_size-1)*(map_size-1)*2-1:0] board_state;
    
    assign board_state = board_state_mem;
    
    initial begin
        board_state_mem <= 'b0;
        turn <= 0;
    end

    always @(posedge clk)begin
        if(put==1'b1 && board_state_mem[Current_pos*2 +:2]==2'b00) begin
            turn <= turn + 1;
            if (turn%2==8'b0)begin
                board_state_mem[Current_pos*2 +:2] <= 2'b11; // white stone
            end
            else begin
                board_state_mem[Current_pos*2 +:2] <= 2'b10; // black stone
            end
        end
        if(rst==1 | game_over)begin
            board_state_mem <= 'b0;
            turn <= 0;
        end
    end
endmodule

//module OMOK(left, right, up, down, put, rst, undo, clk, R, G, B, den, hsync, vsync, dclk, disp_en, test_out, test_h, test_v, rst_test);  // bench
module OMOK(left, right, up, down, put, rst, undo, clk, R, G, B, den, hsync, vsync, dclk, disp_en);
    parameter map_size = 11;
    input put, rst, undo, clk;
    input left, right, up, down;
    output [8-1:0] R, G, B;
    output den, hsync, vsync, dclk, disp_en;
//    output [(map_size-1)*(map_size-1)*2-1:0] test_out;   // bench
//    output [3:0] test_h, test_v;                         // bench   
//    output [2:0] rst_test;                               // bench
    reg [7:0] Current_pos;
    reg right_prev, left_prev, up_prev, down_prev;
    wire order_rst;
    wire [(map_size-1)*(map_size-1)*2-1:0] board_state;
    wire game_over;

    wood_board board(.clk(clk), .Current_pos(Current_pos), .put(put), .rst(order_rst), .board_state(board_state));
    tft_lcd lcd(.clk(clk), .rst(order_rst), .board_state(board_state), .R(R), .G(G), .B(B), .den(den), .hsync(hsync), .vsync(vsync),.dclk(dclk), .disp_en(disp_en));
    game_logic logic(.clk(clk), .Current_pos(Current_pos), .rst(order_rst), .board_state(board_state), .game_over(game_over));
//    game_logic logic(.clk(clk), .Current_pos(Current_pos), .rst(order_rst), .board_state(board_state), .game_over(game_over), .stone_count_h(test_h), .stone_count_v(test_v));  // bench 
    
    assign order_rst = rst||game_over;   
//    assign rst_test = {rst, order_rst, game_over};      // bench                 
//    assign test_out = board_state;                     // bench 
    
    initial begin
        Current_pos = 8'd44;
    end
    
    always @(posedge clk) begin
        if (order_rst) begin
            right_prev <= 1'b0;
            left_prev <= 1'b0;
            up_prev <= 1'b0;
            down_prev <= 1'b0;
            Current_pos <= 8'd44;
            
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
//        else if(order_rst==1) begin
//            Current_pos = 8'd44;
//        end
    end
endmodule