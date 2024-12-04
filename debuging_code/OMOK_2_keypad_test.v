module keypad_RLUD(clk, rst, key_col, state_move, key_row);
    input clk, rst;
    input [3-1:0] key_col;  // 5:up, 7:left, 8:put, 9:right, *:undo, 0:down
    output reg [2:0] state_move;
    output [4-1:0] key_row;
    wire [4-1:0] key_value;
    keypad key(
        .clk(clk), .rst(rst),
        .key_col(key_col),
        .key_value(key_value),
        .key_row(key_row)
        );
        always @ (posedge clk) begin
            case (key_value)
                4'h5: state_move <= 3'd0; // up
                4'h7: state_move <= 3'd1; // left
                4'h8: state_move <= 3'd2; // put
                4'h9: state_move <= 3'd3; // right
                                          // undo
                4'h0: state_move <= 3'd5; // down
                4'hf: state_move <= 3'd6; //keypad_reset
            endcase
        end
endmodule

module keypad(clk, rst, key_col, key_value, key_row);
    input clk, rst;
    input [3-1:0] key_col;
    output reg [4-1:0] key_value;
    output reg [4-1:0] key_row;
    reg [2-1:0] key_counter;
    
    always @ (posedge clk) begin
        if (rst) key_counter = 2'b00;
        else key_counter = key_counter + 2'd1;
    end

    always @ (posedge clk) begin
        if (rst) key_row = 4'b0000;
        else begin
            case (key_counter)
                2'b00: key_row = 4'b1000;
                2'b01: key_row = 4'b0100;
                2'b10: key_row = 4'b0010;
                2'b11: key_row = 4'b0001;
            endcase
        end
    end
    
    always @ (posedge clk) begin
        if (rst) key_value = 4'hf;
        else
            case (key_row)
                4'b1000:
                case (key_col)
                    3'b100: key_value = 4'h1;
                    3'b010: key_value = 4'h2;
                    3'b001: key_value = 4'h3;
                    default: key_value = 4'hf;
                endcase
                // Design your code!
                4'b0100:
                case (key_col)
                    3'b100: key_value = 4'h4;
                    3'b010: key_value = 4'h5;
                    3'b001: key_value = 4'h6;
                    default: key_value = 4'hf;
                endcase
                
                4'b0010:
                case (key_col)
                    3'b100: key_value = 4'h7;
                    3'b010: key_value = 4'h8;
                    3'b001: key_value = 4'h9;
                    default: key_value = 4'hf;
                endcase
                
                4'b0001:
                case (key_col)
                    3'b100: key_value = 4'hc;
                    3'b010: key_value = 4'h0;
                    3'b001: key_value = 4'hd;
                    default: key_value = 4'hf;
                endcase
            endcase
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

module wood_board(clk, Current_pos, put, rst, board_state, turn_map);
    parameter map_size = 11;
    input clk;
    input [7:0] Current_pos;
    input put,rst;
    reg put_prev;
    reg [7:0] turn;
    reg [(map_size-1)*(map_size-1)-1:0] pos_bit;
    reg [(map_size-1)*(map_size-1)-1:0] board_state_mem;
    reg [(map_size-1)*(map_size-1)-1:0] turn_map_mem;
    output [(map_size-1)*(map_size-1)-1:0] board_state;
    output [(map_size-1)*(map_size-1)-1:0] turn_map;
    
    assign board_state = board_state_mem;
    assign turn_map = turn_map_mem;
    
    initial begin
        board_state_mem = 'b0;
        turn_map_mem = 'b0;
        turn = 0;
    end
    
    always @(posedge clk) begin
            put_prev <= put;
    end

    always @(posedge clk)begin
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
        board_state_mem <= board_state_mem | pos_bit;
        if(rst==1)begin
            board_state_mem <= 'b0;
            turn_map_mem <= 'b0;
            turn = 0;
        end
    end
    
endmodule

module OMOK(rst, clk, key_col, R, G, B, den, hsync, vsync, dclk, disp_en, key_row, test_out, test_pos);
    parameter map_size = 11;
    input rst, clk;
    input [2:0] key_col;
    output [8-1:0] R, G, B;
    output den, hsync, vsync, dclk, disp_en;
    output [3:0] key_row;
    output [(map_size-1)*(map_size-1)-1:0] test_out;
    output [7:0] test_pos;
    reg [7:0] Current_pos;
    reg right_prev, left_prev, up_prev, down_prev;
    reg left, right, up, down, put, undo;
    reg [2:0] state_move_reg;
    wire [(map_size-1)*(map_size-1)-1:0] board_state;
    wire [(map_size-1)*(map_size-1)-1:0] turn_map;
    wire [2:0] state_move;
    
    wood_board board(.clk(clk), .Current_pos(Current_pos), .put(put), .rst(rst), .board_state(board_state), .turn_map(turn_map));
    tft_lcd lcd(.clk(clk), .rst(rst), .board_state(board_state), .turn_map(turn_map), .R(R), .G(G), .B(B), .den(den), .hsync(hsync), .vsync(vsync),.dclk(dclk), .disp_en(disp_en));
    keypad_RLUD dirc(.clk(clk), .rst(rst), .key_col(key_col), .state_move(state_move), .key_row(key_row));

    assign test_out = board_state;
    assign test_pos = Current_pos;
    
    initial begin
        Current_pos = 8'd45;
        up = 0;
        left = 0;
        put = 0;
        right = 0;
        down = 0;
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
        state_move_reg <= state_move;
        case(state_move_reg)
            3'd0: up <= 1;
            3'd1: left <= 1;
            3'd2: put <= 1;
            3'd3: right <= 1;
            3'd5: down <= 1;
            3'd6: begin 
                    up <= 0; 
                    left <= 0; 
                    put <= 0;
                    right <= 0;
                    down <= 0;
                end
        endcase
        
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