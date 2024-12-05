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

module tft_lcd(clk, rst, board_state, turn_map, R, G, B, den, hsync, vsync, dclk, disp_en);
    parameter map_size = 11;
    input clk, rst;
    input [(map_size-1)*(map_size-1)-1:0] board_state, turn_map;
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
                if (board_state[k]==1'b1 && turn_map[k]==1) begin
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
                else if (board_state[k]==1'b1 && turn_map[k]==0) begin
                    row = k/(map_size-1);
                    col = k%(map_size-1);
                    for(r=0;r<40;r=r+1) begin
                        x_min = 410 + 40 + col*40 - stone_range[r*8+:8];
                        x_max = 410 + 40 + col*40 + stone_range[r*8+:8];
                        if(counter_v == 42+40+row*40+(r-20) && x_min<=counter_h && counter_h<=x_max) begin
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

module game_logic(Current_pos, rst, turn, board_state, game_over);
    parameter map_size = 11;
    input [7:0] Current_pos;
    input rst;
    input turn;
    input [(map_size-1)*(map_size-1)-1:0] board_state;
    output reg game_over;

    reg [3:0] count_row, count_col, count_diag1, count_diag2;

    task check_line_winning(
        input [(map_size-1)*(map_size-1)-1:0] state, 
        input integer start_pos, 
        input integer delta, // Direction increment (e.g., +1 for horizontal, +map_size for vertical)
        input integer turn_value,
        output reg [3:0] count
    );
        integer i, current_pos;
        begin
            count = 0;
            for (i = -4; i <= 4; i = i + 1) begin
                current_pos = start_pos + i * delta;
                // Boundary check
                if (current_pos >= 0 && current_pos < (map_size-1)*(map_size-1)) begin
                    if (state[current_pos] == turn_value) count = count + 1;
                    else count = 0;
                    // Winning condition
                    if (count == 5) begin
                        game_over = 1'b1;
                        disable check_line_winning; // Exit task on win
                    end
                end
            end
        end
    endtask

    always @(*) begin
        game_over = 1'b0; // Reset game over flag

        // Check for horizontal, vertical, and diagonal wins
        check_line_winning(board_state, Current_pos, 1, turn, count_row); // Horizontal
        check_line_winning(board_state, Current_pos, map_size - 1, turn, count_col); // Vertical
        check_line_winning(board_state, Current_pos, map_size, turn, count_diag1); // Diagonal (\)
        check_line_winning(board_state, Current_pos, map_size - 2, turn, count_diag2); // Diagonal (/)
    end
endmodule

module wood_board(clk, Current_pos, put, rst, board_state, turn_map);
    parameter map_size = 11;
    input clk;
    input [7:0] Current_pos;
    input put, rst;
    reg put_prev;
    reg [7:0] turn;
    reg [(map_size-1)*(map_size-1)-1:0] pos_bit;
    reg [(map_size-1)*(map_size-1)-1:0] board_state_mem;
    reg [(map_size-1)*(map_size-1)-1:0] turn_map_mem;
    reg game_over;

    output [(map_size-1)*(map_size-1)-1:0] board_state;
    output [(map_size-1)*(map_size-1)-1:0] turn_map;

    assign board_state = board_state_mem;
    assign turn_map = turn_map_mem;

    game_logic logic(
    .Current_pos(Current_pos), 
    .rst(rst), 
    .turn(turn % 2), 
    .board_state(board_state_mem), 
    .game_over(game_over)
    );

    initial begin
        board_state_mem = 'b0;
        game_over = 1'b0;
        turn_map_mem = 'b0;
        turn = 0;
    end

    always @(posedge clk) begin
        put_prev <= put;
    end

    always @(posedge clk) begin
        pos_bit = 100'b0;
        if(put==1'b1 && put_prev==1'b0 && board_state_mem[Current_pos]==1'b0) begin
            pos_bit[Current_pos] = 1'b1;
            turn = turn + 1;
            if (turn%2==8'b0)begin
                turn_map_mem[Current_pos] <= 1;
            end
            else begin
                turn_map_mem[Current_pos] <= 0;
            end
        end

        if (game_over == 1) begin
            board_state_mem <= 'b0;
            turn_map_mem <= 'b0;
            turn = 0;
        end

        board_state_mem <= board_state_mem | pos_bit;
        
        if(rst==1)begin
            board_state_mem <= 'b0;
            turn_map_mem <= 'b0;
            turn = 0;
        end
    end

endmodule

module OMOK(left, right, up, down, put, rst, undo, clk, R, G, B, den, hsync, vsync, dclk, disp_en);
    parameter map_size = 11;
    input put, rst, undo, clk;
    input left, right, up, down;
    output [8-1:0] R, G, B;
    output den, hsync, vsync, dclk, disp_en;
    reg [7:0] Current_pos;
    reg right_prev, left_prev, up_prev, down_prev;
    wire [(map_size-1)*(map_size-1)-1:0] board_state;
    wire [(map_size-1)*(map_size-1)-1:0] turn_map;
    
    wood_board board(.clk(clk), .Current_pos(Current_pos), .put(put), .rst(rst), .board_state(board_state), .turn_map(turn_map));
    tft_lcd lcd(.clk(clk), .rst(rst), .board_state(board_state), .turn_map(turn_map), .R(R), .G(G), .B(B), .den(den), .hsync(hsync), .vsync(vsync),.dclk(dclk), .disp_en(disp_en));
    
    initial begin
        Current_pos = 8'd44;
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