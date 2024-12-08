`timescale 1ns / 1ps

module OMOK15_tb();
    reg put, rst, undo, clk;
    reg left, right, up, down;
    wire [8-1:0] R, G, B;
    wire den, hsync, vsync, dclk, disp_en;
    wire [(11-1)*(11-1)*2-1:0] test_out;
    wire [3:0] test_h, test_v;
    wire [2:0] rst_test;
    wire [7:0] turn_test;
    wire [7:0] test_1, test_2, test_3;
    OMOK omok (left, right, up, down, put, rst, undo, clk, R, G, B, den, hsync, vsync, dclk, disp_en, test_out, test_h, test_v, rst_test, turn_test, test_1, test_2, test_3);
    
    initial begin
        clk = 0;
        put = 0;
        left = 0;
        right = 0;
        up = 0;
        down = 0;
        rst = 0;
        undo = 0;
        #50 rst = 1;
        #50 rst = 0;
        
        #2 put = 1;
        #80 put = 0;
        #5 right = 1;
        #5 right = 0;
        #2 put = 1;
        #60 put = 0;
        #5 down = 1;
        #10 down = 0;
//        #5 left = 1;
//        #5 left = 0;
//        #5 left = 1;
//        #5 left = 0;
        
        #2 put = 1;
        #80 put = 0;
        #5 right = 1;
        #5 right = 0;
        #2 put = 1;
        #60 put = 0;
        #5 down = 1;
        #10 down = 0;
//        #5 left = 1;
//        #5 left = 0;
//        #5 left = 1;
//        #5 left = 0;
        
        #2 put = 1;
        #80 put = 0;
        #5 right = 1;
        #5 right = 0;
        #2 put = 1;
        #60 put = 0;
        #5 down = 1;
        #10 down = 0;
//        #5 left = 1;
//        #5 left = 0;
//        #5 left = 1;
//        #5 left = 0;
        
        #2 put = 1;
        #80 put = 0;
        #5 right = 1;
        #5 right = 0;
        #2 put = 1;
        #60 put = 0;
        #5 down = 1;
        #10 down = 0;
//        #5 left = 1;
//        #5 left = 0;
//        #5 left = 1;
//        #5 left = 0;
        
        #2 put = 1;
        #80 put = 0;
        #5 right = 1;
        #5 right = 0;
        #2 put = 1;
        #60 put = 0;
        #5 down = 1;
        #10 down = 0;
//        #5 left = 1;
//        #5 left = 0;
//        #5 left = 1;
//        #5 left = 0;
        
        
    end
    
    always begin
        #2 clk = ~clk;
    end
endmodule