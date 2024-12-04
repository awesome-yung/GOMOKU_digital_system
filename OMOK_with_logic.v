parameter HSIZE = 11;
parameter VSIZE = 10;
parameter map_size = 11;

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
    input [(map_size-1)*(map_size-1)-1:0] board_state, turn_map,
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

module wood_board(clk, Current_pos, put, rst, board_state, game_over, invalid_move);
    parameter map_size = 11;
    input clk;
    input [7:0] Current_pos;
    input put, rst;
    reg put_prev;
    reg [7:0] turn;
    reg [(map_size-1)*(map_size-1)-1:0] pos_bit;
    reg [(map_size-1)*(map_size-1)-1:0] board_state_mem;
    reg [(map_size-1)*(map_size-1)-1:0] turn_map_mem;
    output reg [(map_size-1)*(map_size-1)-1:0] board_state;
    output [(map_size-1)*(map_size-1)-1:0] turn_map;

    reg [3:0] count_row, count_col, count_diag1, count_diag2;
    output reg game_over;
    output reg invalid_move; // Signals invalid moves (e.g., double 3)


    assign board_state = board_state_mem;
    assign turn_map = turn_map_mem;

    initial begin
        board_state = 'b0;
        game_over = 1'b0;
        invalid_move = 1'b0;
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
    
    // Check for winning conditions
    task check_winner(input [7:0] pos);
        integer i;
        begin
            count_row = 0;
            count_col = 0;
            count_diag1 = 0;
            count_diag2 = 0;
            
            // Check horizontal
            for (i = -4; i <= 4; i = i + 1) begin
                if (pos % (map_size-1) + i >= 0 && pos % (map_size-1) + i < map_size-1 && board_state[pos + i] == 1'b1)
                    count_row = count_row + 1;
                else
                    count_row = 0;
                if (count_row == 5)
                    game_over = 1'b1;
            end
            
            // Check vertical
            for (i = -4; i <= 4; i = i + 1) begin
                if (pos / (map_size-1) + i >= 0 && pos / (map_size-1) + i < map_size-1 && board_state[pos + i * (map_size-1)] == 1'b1)
                    count_col = count_col + 1;
                else
                    count_col = 0;
                if (count_col == 5)
                    game_over = 1'b1;
            end
            
            // Check diagonal (\)
            for (i = -4; i <= 4; i = i + 1) begin
                if (pos + i * (map_size) >= 0 && pos + i * (map_size) < (map_size-1)*(map_size-1) && board_state[pos + i * (map_size)] == 1'b1)
                    count_diag1 = count_diag1 + 1;
                else
                    count_diag1 = 0;
                if (count_diag1 == 5)
                    game_over = 1'b1;
            end
            
            // Check diagonal (/)
            for (i = -4; i <= 4; i = i + 1) begin
                if (pos + i * (map_size-2) >= 0 && pos + i * (map_size-2) < (map_size-1)*(map_size-1) && board_state[pos + i * (map_size-2)] == 1'b1)
                    count_diag2 = count_diag2 + 1;
                else
                    count_diag2 = 0;
                if (count_diag2 == 5)
                    game_over = 1'b1;
            end
        end
    endtask
    
    // Double 3 Rule
    task check_double_3(input [7:0] pos);
        integer i, j, threes;
        reg [2:0] count; // Counter for consecutive stones
        reg valid_range; // Ensure checks stay within bounds
        begin
            threes = 0;

            // Horizontal Check
            count = 0;
            for (i = -3; i <= 3; i = i + 1) begin
                valid_range = (pos % (map_size-1) + i >= 0) && (pos % (map_size-1) + i < map_size-1);
                if (valid_range && board_state[pos + i] == 1'b1) count = count + 1;
                else count = 0;

                if (count == 3 && i != 3) begin // Prevent overlapping checks
                    threes = threes + 1;
                    count = 0;
                end
            end

            // Vertical Check
            count = 0;
            for (i = -3; i <= 3; i = i + 1) begin
                valid_range = (pos / (map_size-1) + i >= 0) && (pos / (map_size-1) + i < map_size-1);
                if (valid_range && board_state[pos + i * (map_size-1)] == 1'b1) count = count + 1;
                else count = 0;

                if (count == 3 && i != 3) begin
                    threes = threes + 1;
                    count = 0;
                end
            end

            // Diagonal (\) Check
            count = 0;
            for (i = -3; i <= 3; i = i + 1) begin
                valid_range = (pos / (map_size-1) + i >= 0) && (pos % (map_size-1) + i >= 0) &&
                            (pos / (map_size-1) + i < map_size-1) && (pos % (map_size-1) + i < map_size-1);
                if (valid_range && board_state[pos + i * ((map_size-1) + 1)] == 1'b1) count = count + 1;
                else count = 0;

                if (count == 3 && i != 3) begin
                    threes = threes + 1;
                    count = 0;
                end
            end

            // Diagonal (/) Check
            count = 0;
            for (i = -3; i <= 3; i = i + 1) begin
                valid_range = (pos / (map_size-1) + i >= 0) && (pos % (map_size-1) - i >= 0) &&
                            (pos / (map_size-1) + i < map_size-1) && (pos % (map_size-1) - i < map_size-1);
                if (valid_range && board_state[pos + i * ((map_size-1) - 1)] == 1'b1) count = count + 1;
                else count = 0;

                if (count == 3 && i != 3) begin
                    threes = threes + 1;
                    count = 0;
                end
            end

            // If two or more 3-in-a-rows are found, mark the move as invalid
            if (threes >= 2)
                invalid_move = 1'b1;
            else
                invalid_move = 1'b0;

        end
    endtask
    
    // Place stones and check rules
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            board_state = 'b0;
            game_over = 1'b0;
            invalid_move = 1'b0;
        end else if (put && !invalid_move) begin
            pos_bit = 1'b1 << Current_pos;
            if (!(board_state & pos_bit)) begin
                board_state = board_state | pos_bit;
                check_winner(Current_pos);
                check_double_3(Current_pos);
            end
        end
    end
endmodule

module computer_player(
    input clk, rst,
    input [(11-1)*(11-1)-1:0] board_state, // Current state of the board
    output reg [7:0] move // AI's chosen position
    );
    parameter map_size = 11;
    reg [(map_size-1)*(map_size-1)-1:0] opponent_positions;
    reg found_move;

    task check_block;
        input [(map_size-1)*(map_size-1)-1:0] state; // Input board state
        output reg [7:0] block_position; // Position to block
        integer i, j, k, count, gap, diag_index;
        begin
            block_position = 8'hFF; // Default: no block needed
            found_move = 0;

            // Horizontal check
            for (i = 0; i < map_size - 1; i = i + 1) begin
                count = 0; gap = -1;
                for (j = 0; j < map_size - 1; j = j + 1) begin
                    k = i * (map_size - 1) + j;
                    if (state[k]) count = count + 1; // Stone present
                    else if (gap == -1) gap = k; // Mark potential block position
                    else count = 0; // More than one gap

                    if (count == 4 && gap != -1) begin
                        block_position = gap;
                        found_move = 1;
                        disable check_block;
                    end
                end
            end

            // Vertical check
            for (j = 0; j < map_size - 1; j = j + 1) begin
                count = 0; gap = -1;
                for (i = 0; i < map_size - 1; i = i + 1) begin
                    k = i * (map_size - 1) + j;
                    if (state[k]) count = count + 1;
                    else if (gap == -1) gap = k;
                    else count = 0;

                    if (count == 4 && gap != -1) begin
                        block_position = gap;
                        found_move = 1;
                        disable check_block;
                    end
                end
            end

            // Diagonal (left-to-right) check
            for (i = 0; i <= map_size - 5; i = i + 1) begin
                for (j = 0; j <= map_size - 5; j = j + 1) begin
                    count = 0; gap = -1;
                    for (diag_index = 0; diag_index < 5; diag_index = diag_index + 1) begin
                        k = (i + diag_index) * (map_size - 1) + (j + diag_index);
                        if (state[k]) count = count + 1;
                        else if (gap == -1) gap = k;
                        else count = 0;

                        if (count == 4 && gap != -1) begin
                            block_position = gap;
                            found_move = 1;
                            disable check_block;
                        end
                    end
                end
            end

            // Diagonal (right-to-left) check
            for (i = 0; i <= map_size - 5; i = i + 1) begin
                for (j = 4; j < map_size - 1; j = j + 1) begin
                    count = 0; gap = -1;
                    for (diag_index = 0; diag_index < 5; diag_index = diag_index + 1) begin
                        k = (i + diag_index) * (map_size - 1) + (j - diag_index);
                        if (state[k]) count = count + 1;
                        else if (gap == -1) gap = k;
                        else count = 0;

                        if (count == 4 && gap != -1) begin
                            block_position = gap;
                            found_move = 1;
                            disable check_block;
                        end
                    end
                end
            end
        end
    endtask

    task find_adjacent;
        input [(map_size-1)*(map_size-1)-1:0] state;
        output reg [7:0] adjacent_position;
        integer i, j, k, delta_r, delta_c;
        reg found;
        begin
            found = 0;
            adjacent_position = 8'hFF; // Default: no adjacent position found
            for (i = 0; i < map_size - 1; i = i + 1) begin
                for (j = 0; j < map_size - 1; j = j + 1) begin
                    k = i * (map_size - 1) + j;
                    if (state[k]) begin // Stone found at this position
                        for (delta_r = -1; delta_r <= 1; delta_r = delta_r + 1) begin
                            for (delta_c = -1; delta_c <= 1; delta_c = delta_c + 1) begin
                                if (!(delta_r == 0 && delta_c == 0)) begin
                                    adjacent_position = k + delta_r * (map_size - 1) + delta_c;
                                    if (adjacent_position >= 0 && adjacent_position < (map_size - 1) * (map_size - 1) && !state[adjacent_position]) begin
                                        found = 1;
                                        disable find_adjacent; // Exit once a valid move is found
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    endtask

        always @(posedge clk or posedge rst) begin
        if (rst) begin
            move <= 8'hFF; // Default invalid move
        end else begin
            found_move = 0;

            // First, check if blocking is necessary
            check_block(board_state, move);
            if (!found_move) begin
                // If no block is needed, find an adjacent position
                find_adjacent(board_state, move);
            end

            // If no adjacent position is found, choose the first available position
            if (!found_move) begin
                for (move = 0; move < (map_size - 1) * (map_size - 1); move = move + 1) begin
                    if (!board_state[move]) begin
                        found_move = 1;
                        disable always;
                    end
                end
            end
        end
    end
endmodule

module OMOK(
    input left, right, up, down, put, rst, undo, clk,
    output [7:0] R, G, B,
    output den, hsync, vsync, dclk, disp_en
);
    parameter map_size = 11; // Map의 한 변의 크기
    parameter map_area = (map_size-1)*(map_size-1); // 맵 전체 크기 (실제 저장 공간)
    
    reg [7:0] Current_pos; // 현재 커서 위치
    reg right_prev, left_prev, up_prev, down_prev; // 이전 입력 상태 저장
    
    wire [map_area-1:0] board_state; // 게임 보드 상태
    wire [map_area-1:0] turn_map; // 턴 정보 상태
    
    // 서브 모듈 연결
    wood_board board(
        .clk(clk),
        .Current_pos(Current_pos),
        .put(put),
        .rst(rst),
        .board_state(board_state),
        .turn_map(turn_map)
    );
    
    tft_lcd lcd(
        .clk(clk),
        .rst(rst),
        .board_state(board_state),
        .turn_map(turn_map),
        .R(R),
        .G(G),
        .B(B),
        .den(den),
        .hsync(hsync),
        .vsync(vsync),
        .dclk(dclk),
        .disp_en(disp_en)
    );
    
    // 초기화
    initial begin
        Current_pos = 8'd44; // 중앙 초기화 (디폴트 설정)
    end

    // 방향키의 이전 상태 업데이트
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            right_prev <= 1'b0;
            left_prev <= 1'b0;
            up_prev <= 1'b0;
            down_prev <= 1'b0;
        end else begin
            right_prev <= right;
            left_prev <= left;
            up_prev <= up;
            down_prev <= down;
        end
    end

    // Current_pos 갱신 로직
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            Current_pos <= 8'd44; // 초기 위치로 리셋
        end else begin
            if (right && !right_prev && (Current_pos % (map_size-1) != (map_size-2))) begin
                Current_pos <= Current_pos + 8'd1; // 오른쪽 이동
            end else if (left && !left_prev && (Current_pos % (map_size-1) != 0)) begin
                Current_pos <= Current_pos - 8'd1; // 왼쪽 이동
            end else if (up && !up_prev && (Current_pos / (map_size-1) != 0)) begin
                Current_pos <= Current_pos - (map_size-1); // 위로 이동
            end else if (down && !down_prev && (Current_pos / (map_size-1) != (map_size-2))) begin
                Current_pos <= Current_pos + (map_size-1); // 아래로 이동
            end
        end
    end
endmodule
