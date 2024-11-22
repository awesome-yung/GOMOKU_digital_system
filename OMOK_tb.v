`timescale 1ns / 1ps

module OMOK_tb();
    reg left,right,up,down,rst,put,undo,clk;
    wire [8:0] DATA_OUT;
    wire [24:0] DATA_OUT2;
    OMOK omok(left,right,up,down,put,rst,undo,clk,DATA_OUT,DATA_OUT2);
    
    initial begin
        clk = 0;
        put = 0;
        left = 0;
        right = 0;
        up = 0;
        down = 0;
        rst = 0;
        undo = 0;
        
        #4 right = 1;
        #4 right = 0;
        #4 up = 1;
        #4 up = 0;
        #4 left = 1;
        #4 left = 0;
        #4 put = 1;
        #4 put = 0;
        #4 left = 1;
        #4 left = 0;
        #4 down = 1;
        #4 down = 0;
        #4 right = 1;
        #4 right = 0;
        #4 put = 1;
        #4 put = 0;
        #4 rst = 1;
    end
    
    always begin
        #2 clk = ~clk;
    end
endmodule