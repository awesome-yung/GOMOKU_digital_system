`timescale 1ns / 1ps

// 4'h5: state_move <= 3'd0; // up
// 4'h7: state_move <= 3'd1; // left
// 4'h8: state_move <= 3'd2; // put
// 4'h9: state_move <= 3'd3; // right
//                           // undo
// 4'h0: state_move <= 3'd5; // down
// 4'hf: state_move <= 3'd6; //keypad_reset

// case (key_row)
//     4'b1000:
//     case (key_col)
//         3'b100: key_value = 4'h1;
//         3'b010: key_value = 4'h2;
//         3'b001: key_value = 4'h3;
//         default: key_value = 4'hf;
//     endcase
//     // Design your code!
//     4'b0100:
//     case (key_col)
//         3'b100: key_value = 4'h4;
//         3'b010: key_value = 4'h5;
//         3'b001: key_value = 4'h6;
//         default: key_value = 4'hf;
//     endcase
    
//     4'b0010:
//     case (key_col)
//         3'b100: key_value = 4'h7;
//         3'b010: key_value = 4'h8;
//         3'b001: key_value = 4'h9;
//         default: key_value = 4'hf;
//     endcase
    
//     4'b0001:
//     case (key_col)
//         3'b100: key_value = 4'hc;
//         3'b010: key_value = 4'h0;
//         3'b001: key_value = 4'hd;
//         default: key_value = 4'hf;
//     endcase
// endcase

module OMOK_tb();
    reg rst, clk;
    reg [2:0] key_col;
    wire [8-1:0] R, G, B;
    wire den, hsync, vsync, dclk, disp_en;
    wire [3:0] key_row;
    wire [10*10-1:0] test_out;
    wire [7:0] test_pos;

    OMOK omok (rst, clk, key_col, R, G, B, den, hsync, vsync, dclk, disp_en, key_row, test_out, test_pos);

    initial clk = 0;
    always #2 clk = ~clk; 


    initial begin

        rst = 1;          
        key_col = 3'b000; 
        #10 rst = 0;      

        // right
        wait (key_row == 4'b0010); 
        key_col = 3'b001;          
        #10 key_col = 3'b000;       
        #10;

        // up
        wait (key_row == 4'b0100); 
        key_col = 3'b010;         
        #10 key_col = 3'b000;       
        #10;

        // put
        wait (key_row == 4'b0010); 
        key_col = 3'b010;          
        #10 key_col = 3'b000;       
        #10;

        // left
        wait (key_row == 4'b0010); 
        key_col = 3'b100;          
        #10 key_col = 3'b000;       
        #10;
        
        // put
        wait (key_row == 4'b0010); 
        key_col = 3'b010;          
        #10 key_col = 3'b000;       
        #10;

        // down
        wait (key_row == 4'b0001); 
        key_col = 3'b010;          
        #10 key_col = 3'b000;       
        #10;

        rst = 1;  
        #4 rst = 0; 

        #20 $finish;
    end

endmodule