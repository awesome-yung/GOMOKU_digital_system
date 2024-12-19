`timescale 1ns / 1ps

module violation_checker(clk, rst, Current_pos, turn, board_state, violation_flag);
    parameter map_size = 11;
    input clk, rst;
    input [7:0] Current_pos;
    input [7:0] turn;
    input [(map_size-1)*(map_size-1)*2-1:0] board_state;
    output reg violation_flag;
    reg [7:0] cur_row, cur_col;
    reg [5:0] right_, left_, up_, down_, right_up, right_down, left_up, left_down;
    reg [1:0] cnt;
    reg r,l,u,d,r_u,r_d,l_u,l_d;
    
    initial begin
        violation_flag = 1'b0;
        cnt = 'b0;
        right_ = 'b0;
        left_ = 'b0;
        up_ = 'b0;
        down_ = 'b0;
        right_up = 'b0;
        left_up = 'b0;
        right_down = 'b0;
        left_down = 'b0;
        r = 0;
        l = 0;
        u = 0;
        d = 0;
        r_u = 0;
        l_u = 0;
        r_d = 0;
        l_d = 0;
    end

    always @(posedge clk) begin
        cur_row = Current_pos/10;
        cur_col = Current_pos%10;
        
        if(2<cur_row && cur_row<7 && 2<cur_col && cur_col<7) begin
            right_ = {board_state[(Current_pos+1)*2+:2],board_state[(Current_pos+2)*2+:2],board_state[(Current_pos+3)*2+:2]};
            left_ = {board_state[(Current_pos-3)*2+:2],board_state[(Current_pos-2)*2+:2],board_state[(Current_pos-1)*2+:2]};
            up_ = {board_state[(Current_pos-30)*2+:2],board_state[(Current_pos-20)*2+:2],board_state[(Current_pos-10)*2+:2]};
            down_ = {board_state[(Current_pos+10)*2+:2],board_state[(Current_pos+20)*2+:2],board_state[(Current_pos+30)*2+:2]};
            right_up = {board_state[(Current_pos-9)*2+:2],board_state[(Current_pos-18)*2+:2],board_state[(Current_pos-27)*2+:2]};
            right_down = {board_state[(Current_pos+11)*2+:2],board_state[(Current_pos+22)*2+:2],board_state[(Current_pos+33)*2+:2]};
            left_up = {board_state[(Current_pos-33)*2+:2],board_state[(Current_pos-22)*2+:2],board_state[(Current_pos-11)*2+:2]};
            left_down = {board_state[(Current_pos+27)*2+:2],board_state[(Current_pos+18)*2+:2],board_state[(Current_pos+9)*2+:2]};
            
            if((turn+1)%2==1) begin
                if(right_==6'b101000)begin    // black
                    r = 1;
                end
                else begin
                    r = 0;
                end
                if(left_==6'b001010)begin    // black
                    l = 1;
                end
                else begin
                    l = 0;
                end
                if(up_==6'b001010)begin    // black
                    u = 1;
                end
                else begin
                    u = 0;
                end
                if(down_==6'b101000)begin    // black
                    d = 1;
                end
                else begin
                    d = 0;
                end
                
                if(right_up==6'b101000)begin    // black
                    r_u = 1;
                end
                else begin
                    r_u = 0;
                end
                if(right_down==6'b101000)begin    // black
                    r_d = 1;
                end
                else begin
                    r_d = 0;
                end
                if(left_up==6'b101000)begin    // black
                    l_u = 1;
                end
                else begin
                    l_u = 0;
                end
                if(left_down==6'b101000)begin    // black
                    l_d = 1;
                end
                else begin
                    l_d = 0;
                end
            end
            
            else if((turn+1)%2==0) begin
                if(right_==6'b111100)begin    // white
                    r = 1;
                end
                else begin
                    r = 0;
                end 
                if(left_==6'b001111)begin    // white
                    l = 1;
                end
                else begin
                    l = 0;
                end
                if(up_==6'b001111)begin    // white
                    u = 1;
                end
                else begin
                    u = 0;
                end
                if(down_==6'b111100)begin    // white
                    d = 1;
                end
                else begin
                    d = 0;
                end
                
                if(right_up==6'b111100)begin    // white
                    r_u = 1;
                end
                else begin
                    r_u = 0;
                end
                if(right_down==6'b111100)begin    // white
                    r_d = 1;
                end
                else begin
                    r_d = 0;
                end
                if(left_up==6'b111100)begin    // white
                    l_u = 1;
                end
                else begin
                    l_u = 0;
                end
                if(left_down==6'b111100)begin    // white
                    l_d = 1;
                end
                else begin
                    l_d = 0;
                end
            end
        end
        
    end
    
    always @(posedge clk) begin
        cnt = l+r+u+d;
        if(cnt==2'd2 && l+r!=2'd2 && u+d!=2'd2) begin
            violation_flag = 1;
        end
        else begin
            violation_flag = 0;
        end
    end
endmodule



module game_logic(clk, rst, put, Current_pos, board_state, black_win, white_win);
    parameter map_size = 11;
    input clk, rst, put;
    input [7:0] Current_pos;
    input [(map_size-1)*(map_size-1)*2-1:0] board_state;
    output reg black_win, white_win;
    reg [2:0] black_count_h, black_count_v, black_count_dp, black_count_dn;  
    reg [2:0] white_count_h, white_count_v, white_count_dp, white_count_dn;
    integer i,j;
    
    initial begin
        black_count_h = 3'd1;
        black_count_v = 3'd1;
        black_count_dp = 3'd1;
        black_count_dn = 3'd1;
        white_count_h = 3'd1;
        white_count_v = 3'd1;
        white_count_dp = 3'd1;
        white_count_dn = 3'd1;
        black_win = 1'b0;
        white_win = 1'b0;
    end
    
    always @(posedge clk) begin
        if(rst) begin
            black_win <= 1'd0;
            white_win <= 1'd0;
            black_count_h <= 3'd1;
            black_count_v <= 3'd1;
            black_count_dp <= 3'd1;
            black_count_dn <= 3'd1;
            white_count_h <= 3'd1;
            white_count_v <= 3'd1;
            white_count_dp <= 3'd1;
            white_count_dn <= 3'd1;
        end
        
    // black_win
        // horizontal
        for(i=0; i<99; i=i+1) begin
            if(black_count_h==3'd5)begin
                black_win=1'd1;
            end
            else if(board_state[i*2 +:2] == 2'b10 && board_state[i*2 +2 +:2] == 2'b10 && (i+1)%10 != 0) begin  // if (i+1) is in the next row
                black_count_h = black_count_h+1;
            end
            else begin
                black_count_h = 1;
            end
        end
        // vertical
        for(i=0; i<10; i=i+1) begin
            for(j=i; j<90; j=j+10) begin
                if(black_count_v==3'd5)begin
                    black_win=1'd1;
                end
                else if(board_state[j*2 +:2] == 2'b10 && board_state[j*2 +20 +:2] == 2'b10 && (j+10) < 100) begin  // if (j+10) is in the next col
                    black_count_v = black_count_v+1;
                end
                else begin
                    black_count_v = 1;
                end
            end
        end
        //diagonal (/)
        for(i=4; i<10; i=i+1) begin
            for(j=1; j<i+1; j=j+1) begin
                if(black_count_dp==3'd5)begin
                    black_win=1'd1;
                end
                else if(i+(j+1)*9<100) begin // ensure the index does not exceed 100
                    if(board_state[(i+j*9)*2 +:2] == 2'b10 && board_state[(i+(j+1)*9)*2 +:2] == 2'b10 && (i+j*9) % 10 != 0) begin  // if current_pos is not in 0th col
                        black_count_dp = black_count_dp+1;
                    end
                end
                else begin
                    black_count_dp = 1;
                end
            end
        end
        for(i=9; i>4; i=i-1) begin
            for(j=0; j<i; j=j+1) begin
                if(black_count_dp==3'd5)begin
                    black_win=1'd1;
                end
                else if ((10-i)*10+9*(j+1+1)<100) begin // ensure the index does not exceed 100
                    if(board_state[((10-i)*10+9*(j+1))*2 +:2] == 2'b10 && board_state[((10-i)*10+9*(j+1+1))*2 +:2] == 2'b10 && ((10-i)*10+9*(j+1)) / 10 != 9) begin  // if current_pos is not in 9st row
                        black_count_dp = black_count_dp+1;
                    end
                end
                else begin
                    black_count_dp = 1;
                end
            end
        end
        //diagonal (\)
        for(i=4; i<10; i=i+1) begin
            for(j=1; j<i+1; j=j+1) begin
                if(black_count_dn==3'd5)begin
                    black_win=1'd1;
                end
                else if ((10-i)*10+9*(j+1+1)<100)begin  // ensure the index does not exceed 100
                    if(board_state[((10-i)*10+9*(j+1))*2 +:2] == 2'b10 && board_state[((10-i)*10+9*(j+1+1))*2 +:2] == 2'b10 && ((10-i)*10+9*(j+1)) % 10 != 9) begin  // if current_pos is not in 9th col
                        black_count_dn = black_count_dn+1;
                    end
                end
                else begin
                    black_count_dn = 1;
                end
            end
        end
        for(i=9; i>4; i=i-1) begin
            for(j=0; j<i; j=j+1) begin
                if(black_count_dn==3'd5)begin
                    black_win=1'd1;
                end
                else if((9-i)+11*(j+1)<100) begin
                    if(board_state[((9-i)+11*j)*2 +:2] == 2'b10 && board_state[((9-i)+11*(j+1))*2 +:2] == 2'b10 && ((9-i)+11*j) / 10 != 9) begin  // if current_pos is not in 9st row
                        black_count_dn = black_count_dn+1;
                    end
                end
                else begin
                    black_count_dn = 1;
                end
            end
        end
        
    // white_win
        // horizontal
        for(i=0; i<99; i=i+1) begin
            if(white_count_h==3'd5)begin
                white_win=1'd1;
            end
            else if(board_state[i*2 +:2] == 2'b11 && board_state[i*2 +2 +:2] == 2'b11 && (i+1)%10 != 0) begin  // if (i+1) is in the next row
                white_count_h = white_count_h+1;
            end
            else begin
                white_count_h = 1;
            end
        end
        // vertical
        for(i=0; i<10; i=i+1) begin
            for(j=i; j<90; j=j+10) begin
                if(white_count_v==3'd5)begin
                    white_win=1'd1;
                end
                else if(board_state[j*2 +:2] == 2'b11 && board_state[j*2 +20 +:2] == 2'b11 && (j+10) < 100) begin  // if (j+10) is in the next col
                    white_count_v = white_count_v+1;
                end
                else begin
                    white_count_v = 1;
                end
            end
        end
        //diagonal (/)
        for(i=4; i<10; i=i+1) begin
            for(j=1; j<i+1; j=j+1) begin
                if(white_count_dp==3'd5)begin
                    white_win=1'd1;
                end
                else if(i+(j+1)*9<100) begin // ensure the index does not exceed 100
                    if(board_state[(i+j*9)*2 +:2] == 2'b11 && board_state[(i+(j+1)*9)*2 +:2] == 2'b11 && (i+j*9) % 10 != 0) begin  // if current_pos is not in 0th col
                        white_count_dp = white_count_dp+1;
                    end
                end
                else begin
                    white_count_dp = 1;
                end
            end
        end
        for(i=9; i>4; i=i-1) begin
            for(j=0; j<i; j=j+1) begin
                if(white_count_dp==3'd5)begin
                    white_win=1'd1;
                end
                else if ((10-i)*10+9*(j+1+1)<100) begin // ensure the index does not exceed 100
                    if(board_state[((10-i)*10+9*(j+1))*2 +:2] == 2'b11 && board_state[((10-i)*10+9*(j+1+1))*2 +:2] == 2'b11 && ((10-i)*10+9*(j+1)) / 10 != 9) begin  // if current_pos is not in 9st row
                        white_count_dp = white_count_dp+1;
                    end
                end
                else begin
                    white_count_dp = 1;
                end
            end
        end
        //diagonal (\)
        for(i=4; i<10; i=i+1) begin
            for(j=1; j<i+1; j=j+1) begin
                if(white_count_dn==3'd5)begin
                    white_win=1'd1;
                end
                else if ((10-i)*10+9*(j+1+1)<100)begin  // ensure the index does not exceed 100
                    if(board_state[((10-i)*10+9*(j+1))*2 +:2] == 2'b11 && board_state[((10-i)*10+9*(j+1+1))*2 +:2] == 2'b11 && ((10-i)*10+9*(j+1)) % 10 != 9) begin  // if current_pos is not in 9th col
                        white_count_dn = white_count_dn+1;
                    end
                end
                else begin
                    white_count_dn = 1;
                end
            end
        end
        for(i=9; i>4; i=i-1) begin
            for(j=0; j<i; j=j+1) begin
                if(white_count_dn==3'd5)begin
                    white_win=1'd1;
                end
                else if((9-i)+11*(j+1)<100) begin
                    if(board_state[((9-i)+11*j)*2 +:2] == 2'b11 && board_state[((9-i)+11*(j+1))*2 +:2] == 2'b11 && ((9-i)+11*j) / 10 != 9) begin  // if current_pos is not in 9st row
                        white_count_dn = white_count_dn+1;
                    end
                end
                else begin
                    white_count_dn = 1;
                end
            end
        end


    end
endmodule

module text_lcd(clk, rst, black_win, white_win,turn, lcd_enb, lcd_rs, lcd_rw, lcd_data);
    input clk, rst, black_win, white_win;
    input [7:0] turn;
    output lcd_enb;
    output reg lcd_rs, lcd_rw;
    output reg [8-1:0] lcd_data;
    reg [3-1:0] state;
    parameter delay = 3'b000,
            function_set = 3'b001,
            entry_mode = 3'b010,
            display_onoff = 3'b011,
            line1 = 3'b100,
            line2 = 3'b101,
            delay_t = 3'b110,
            clear_display = 3'b111;

    integer counter;
    always @ (posedge clk or posedge rst) begin
        if (rst) counter = 0;
        else
            case (state)
                delay: begin
                    if (counter == 70) counter = 0;
                    else counter = counter + 1;
                end
                function_set: begin
                    if (counter == 30) counter = 0;
                    else counter = counter + 1;
                end
                display_onoff: begin
                    if (counter == 30) counter = 0;
                    else counter = counter + 1;
                end
                entry_mode: begin
                    if (counter == 30) counter = 0;
                    else counter = counter + 1;
                end
                line1: begin
                    if (counter == 20) counter = 0;
                    else counter = counter + 1;
                end
                line2: begin
                    if (counter == 20) counter = 0;
                    else counter = counter + 1;
                end
                delay_t: begin
                    if (counter == 400) counter = 0;
                    else counter = counter + 1;
                end
                clear_display: begin
                    if (counter == 200) counter = 0;
                    else counter = counter + 1;
                end
        endcase
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) state = delay;
        else
            case (state)
                delay: if (counter == 70) state = function_set;
                function_set: if (counter == 30) state = display_onoff;
                display_onoff: if (counter == 30) state = entry_mode;
                entry_mode: if (counter == 30) state = line1;
                line1: if (counter == 20) state = line2;
                line2: if (counter == 20) state = delay_t;
                delay_t: if (counter == 400) state = clear_display;
                clear_display: if (counter == 200) state = line1;
            endcase
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            lcd_rs = 1'b1;
            lcd_rw = 1'b1;
            lcd_data = 8'b0000_0000;
        end
        else if((turn%2 == 0) && (black_win!=1) && (white_win!=1))begin
            case (state)
                function_set: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0011_1100;
                end
                display_onoff: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_1100;
                end
                entry_mode: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0110;
                end
                line1: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        0: begin
                            lcd_rs = 1'b0; lcd_data = 8'b1000_0000; // 시작 위치(address) 설정
                        end
                        1: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        2: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0100_0010; // 출력할 글자 설정 ("B")
                        end
                        3: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1100; // 출력할 글자 설정 ("l")
                        end
                        4: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0001; // 출력할 글자 설정 ("a")
                        end
                        5: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0011; // 출력할 글자 설정 ("c")
                        end
                        6: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1011; // 출력할 글자 설정 ("k")
                        end
                        7: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        8: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0100; // 출력할 글자 설정 ("t")
                        end
                        9: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0101; // 출력할 글자 설정 ("u")
                        end
                        10: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0010; // 출력할 글자 설정 ("r")
                        end
                        11: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1110; // 출력할 글자 설정 ("n")
                        end
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                line2: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                delay_t: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0010;
                end
                clear_display: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0001;
                end
                default: begin
                    lcd_rs = 1'b1;
                    lcd_rw = 1'b1;
                    lcd_data = 8'b0000_0000;
                end
            endcase
        end
        else if((turn%2 == 1) && (black_win!=1) && (white_win!=1)) begin
            case (state)
                function_set: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0011_1100;
                end
                display_onoff: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_1100;
                end
                entry_mode: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0110;
                end
                line1: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        0: begin
                            lcd_rs = 1'b0; lcd_data = 8'b1000_0000; // 시작 위치(address) 설정
                        end
                        1: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        2: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0101_0111; // 출력할 글자 설정 ("W")
                        end
                        3: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1000; // 출력할 글자 설정 ("h")
                        end
                        4: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1001; // 출력할 글자 설정 ("i")
                        end
                        5: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0100; // 출력할 글자 설정 ("t")
                        end
                        6: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0101; // 출력할 글자 설정 ("e")
                        end
                        7: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        8: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0100; // 출력할 글자 설정 ("t")
                        end
                        9: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0101; // 출력할 글자 설정 ("u")
                        end
                        10: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0010; // 출력할 글자 설정 ("r")
                        end
                        11: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1110; // 출력할 글자 설정 ("n")
                        end
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                line2: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                delay_t: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0010;
                end
                clear_display: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0001;
                end
                default: begin
                    lcd_rs = 1'b1;
                    lcd_rw = 1'b1;
                    lcd_data = 8'b0000_0000;
                end
            endcase
        end
        else if(black_win==1) begin
            case (state)
                function_set: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0011_1100;
                end
                display_onoff: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_1100;
                end
                entry_mode: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0110;
                end
                line1: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        0: begin
                            lcd_rs = 1'b0; lcd_data = 8'b1000_0000; // 시작 위치(address) 설정
                        end
                        1: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        2: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0100_0111; // 출력할 글자 설정 ("G")
                        end
                        3: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0001; // 출력할 글자 설정 ("a")
                        end
                        4: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1101; // 출력할 글자 설정 ("m")
                        end
                        5: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0101; // 출력할 글자 설정 ("e")
                        end
                        6: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        7: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1111; // 출력할 글자 설정 ("o")
                        end
                        8: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0110; // 출력할 글자 설정 ("v")
                        end
                        9: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0101; // 출력할 글자 설정 ("e")
                        end
                        10: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0001; // 출력할 글자 설정 ("r")
                        end
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                line2: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        0: begin
                            lcd_rs = 1'b0; lcd_data = 8'b1100_0000; // 시작 위치(address) 설정
                        end
                        1: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        2: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0100_0010; // 출력할 글자 설정 ("B")
                        end
                        3: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1100; // 출력할 글자 설정 ("l")
                        end
                        4: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0001; // 출력할 글자 설정 ("a")
                        end
                        5: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0011; // 출력할 글자 설정 ("c")
                        end
                        6: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1011; // 출력할 글자 설정 ("k")
                        end
                        7: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        8: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0111; // 출력할 글자 설정 ("w")
                        end
                        9: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1001; // 출력할 글자 설정 ("i")
                        end
                        10: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1110; // 출력할 글자 설정 ("n")
                        end
                        11: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0001; // 출력할 글자 설정 ("!")
                        end
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                delay_t: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0010;
                end
                clear_display: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0001;
                end
                default: begin
                    lcd_rs = 1'b1;
                    lcd_rw = 1'b1;
                    lcd_data = 8'b0000_0000;
                end
            endcase
        end
        else if(white_win==1) begin
            case (state)
                function_set: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0011_1100;
                end
                display_onoff: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_1100;
                end
                entry_mode: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0110;
                end
                line1: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        0: begin
                            lcd_rs = 1'b0; lcd_data = 8'b1000_0000; // 시작 위치(address) 설정
                        end
                        1: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        2: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0100_0111; // 출력할 글자 설정 ("G")
                        end
                        3: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0001; // 출력할 글자 설정 ("a")
                        end
                        4: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1101; // 출력할 글자 설정 ("m")
                        end
                        5: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0101; // 출력할 글자 설정 ("e")
                        end
                        6: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        7: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1111; // 출력할 글자 설정 ("o")
                        end
                        8: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0110; // 출력할 글자 설정 ("v")
                        end
                        9: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0101; // 출력할 글자 설정 ("e")
                        end
                        10: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0001; // 출력할 글자 설정 ("r")
                        end
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                line2: begin
                    lcd_rw = 1'b0;
                    case (counter)
                        0: begin
                            lcd_rs = 1'b0; lcd_data = 8'b1100_0000; // 시작 위치(address) 설정
                        end
                        1: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        2: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0101_0111; // 출력할 글자 설정 ("W")
                        end
                        3: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1000; // 출력할 글자 설정 ("h")
                        end
                        4: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1001; // 출력할 글자 설정 ("i")
                        end
                        5: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0100; // 출력할 글자 설정 ("t")
                        end
                        6: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_0101; // 출력할 글자 설정 ("e")
                        end
                        7: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000; // 출력할 글자 설정 (" ")
                        end
                        8: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0111_0111; // 출력할 글자 설정 ("w")
                        end
                        9: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1001; // 출력할 글자 설정 ("i")
                        end
                        10: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0110_1110; // 출력할 글자 설정 ("n")
                        end
                        11: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0001; // 출력할 글자 설정 ("!")
                        end
                        default: begin
                            lcd_rs = 1'b1; lcd_data = 8'b0010_0000;
                        end
                    endcase
                end
                delay_t: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0010;
                end
                clear_display: begin
                    lcd_rs = 1'b0;
                    lcd_rw = 1'b0;
                    lcd_data = 8'b0000_0001;
                end
                default: begin
                    lcd_rs = 1'b1;
                    lcd_rw = 1'b1;
                    lcd_data = 8'b0000_0000;
                end
            endcase
        end
    end
    assign lcd_enb = clk;
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
    reg [8*20-1:0] stone_range;
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
            for (k=0;k<(map_size-1)*(map_size-1);k=k+1) begin
                if (Current_pos == k) begin
                    row = k/(map_size-1);
                    col = k%(map_size-1);
                    for(r=0;r<20;r=r+1)begin
                        x_min = 410 + 40 + col*40 - 10;
                        x_max = 410 + 40 + col*40 + 10;
                        if(counter_v == 42+40+row*40+(r-10) && x_min<=counter_h && counter_h<=x_max) begin
                            R = 8'h00;
                            G = 8'h00;
                            B = 8'hFF;
                        end
                    end                    
                end
            end
            
        end
    end
endmodule

module wood_board (clk, Current_pos, put, rst, violation_flag, black_win, white_win, turn, board_state);
    parameter map_size = 11;
    input clk;
    input [7:0] Current_pos;
    input put,rst;
    input violation_flag;
    input black_win, white_win;
    reg [(map_size-1)*(map_size-1)*2-1:0] board_state_mem;
    reg put_prev;
    output reg [7:0] turn;
    output [(map_size-1)*(map_size-1)*2-1:0] board_state;

    assign board_state = board_state_mem;

    initial begin
        board_state_mem = 'b0;
        turn = 0;
    end
    
    always @(posedge clk) begin
            put_prev <= put;
    end

    always @(posedge clk)begin
        if(put==1'b1 && put_prev==1'b0 && board_state_mem[Current_pos*2 +:2]==2'b00 && violation_flag != 1) begin
            turn = turn + 1;
            if (turn%2==8'b0)begin
                board_state_mem[Current_pos*2 +:2] <= 2'b11; // white stone
            end
            else begin
                board_state_mem[Current_pos*2 +:2] <= 2'b10; // black stone
            end
        end
        else if(rst==1 || black_win || white_win)begin
            board_state_mem <= 'b0;
            turn <= 0;
        end
    end
endmodule

module OMOK(left, right, up, down, put, rst, clk, R, G, B, den, hsync, vsync, dclk, disp_en, enb, rs, rw, data);
    parameter map_size = 11;
    input left, right, up, down;
    input put, rst, clk;
    output [8-1:0] R, G, B;
    output den, hsync, vsync, dclk, disp_en;
    output enb;
    output rs, rw;
    output [8-1:0] data;

    reg [7:0] Current_pos;
    reg right_prev, left_prev, up_prev, down_prev;
    wire [(map_size-1)*(map_size-1)*2-1:0] board_state;
    wire [7:0] turn;
    wire black_win, white_win;
    wire violation_flag;

    wood_board board(.clk(clk), .Current_pos(Current_pos), .put(put), .rst(rst), .violation_flag(violation_flag), .black_win(black_win), .white_win(white_win), .turn(turn), .board_state(board_state));
    tft_lcd lcd(.clk(clk), .rst(rst), .board_state(board_state), .Current_pos(Current_pos), .R(R), .G(G), .B(B), .den(den), .hsync(hsync), .vsync(vsync),.dclk(dclk), .disp_en(disp_en));
    game_logic logic(.clk(clk), .rst(rst), .put(put), .Current_pos(Current_pos), .board_state(board_state), .black_win(black_win), .white_win(white_win));
    text_lcd text(.clk(clk), .rst(rst), .black_win(black_win), .white_win(white_win), .turn(turn), .lcd_enb(enb), .lcd_rs(rs), .lcd_rw(rw), .lcd_data(data));
    violation_checker checker(.clk(clk), .rst(rst), .Current_pos(Current_pos), .turn(turn), .board_state(board_state), .violation_flag(violation_flag));

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
            Current_pos <= Current_pos + 8'd1;
        end
        else if(left == 1'b1 && left_prev == 1'b0 && Current_pos % (map_size-1) != 0) begin
            Current_pos <= Current_pos - 8'd1;
        end
        else if(up == 1'b1 && up_prev == 1'b0 && Current_pos / (map_size-1) != 0) begin
            Current_pos <= Current_pos - 8'd10;
        end
        else if(down == 1'b1 && down_prev == 1'b0 && Current_pos / (map_size-1) != 9) begin
            Current_pos <= Current_pos + 8'd10;
        end
        else if(rst==1) begin
            Current_pos <= 8'd44;
        end
    end
endmodule