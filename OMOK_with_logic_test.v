
   task check_double_3(
        input [(map_size-1)*(map_size-1)-1:0] state, 
        input integer pos, // 놓으려는 돌의 위치
        output reg invalid_move // 결과 플래그
    );
        integer threes; // 새로운 3 연속의 개수
        integer count;  // 각 방향에서의 연속된 돌 개수
        reg [(map_size-1)*(map_size-1)-1:0] temp_state; // 가상 상태
        begin
            threes = 0;
            invalid_move = 1'b0;

            // 임시로 돌을 배치
            temp_state = state;
            temp_state[pos] = 1'b1;

            // Check horizontal (delta = 1)
            check_line(temp_state, pos, 1, 3, count);
            if (count == 3) threes = threes + 1;

            // Check vertical (delta = map_size - 1)
            check_line(temp_state, pos, map_size - 1, 3, count);
            if (count == 3) threes = threes + 1;

            // Check diagonal (\) (delta = map_size)
            check_line(temp_state, pos, map_size, 3, count);
            if (count == 3) threes = threes + 1;

            // Check diagonal (/) (delta = map_size - 2)
            check_line(temp_state, pos, map_size - 2, 3, count);
            if (count == 3) threes = threes + 1;

            // Double 3 발생 여부 확인
            if (threes >= 2) begin
                invalid_move = 1'b1; // double 3 발생: 무효화
            end
        end
    endtask

module computer_player(
    input clk, rst,
    input [(11-1)*(11-1)-1:0] board_state, // Current state of the board
    output reg [7:0] move // AI's chosen position
    );
    parameter map_size = 11;
    reg [(map_size-1)*(map_size-1)-1:0] opponent_positions;
    reg found_move;

    task check_line(
        input [(map_size-1)*(map_size-1)-1:0] state, 
        input integer start_pos,
        input integer delta, // 방향 변화량 (e.g., +1 for horizontal, +map_size for vertical)
        input integer num,
        output integer count
    );
        integer i, current_pos;
        begin
            count = 0;
            for (i = -4; i <= 4; i = i + 1) begin
                current_pos = start_pos + i * delta;
                if (current_pos >= 0 && current_pos < (map_size-1)*(map_size-1)) begin
                    if (state[current_pos]) count = count + 1;
                    else count = 0;
                    if (count == num) begin
                        game_over = 1'b1;
                        disable check_line; // 승리 조건을 만족하면 종료
                    end
                end
            end
        end
    endtask

    parameter end_number = 5;

    always @(posedge clk) begin
        if (put && !invalid_move) begin
            check_line(board_state, Current_pos, 1, end_number, count_row); // Horizontal
            check_line(board_state, Current_pos, map_size - 1, end_number, count_col); // Vertical
            check_line(board_state, Current_pos, map_size, end_number, count_diag1); // Diagonal (\)
            check_line(board_state, Current_pos, map_size - 2, end_number, count_diag2); // Diagonal (/)
        end
    end

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