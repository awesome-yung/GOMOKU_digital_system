// Register Module
module SR_Latch(S, R, Q, not_Q);
    input S, R;
    output Q, not_Q;
    
    nand(Q, S, not_Q);
    nand(not_Q, R, Q);
endmodule

module D_FF(clk, D, Q, not_Q);
    input   clk, D;
    output  Q, not_Q; 
    wire Q1, Q2, not_Q1, not_Q2, S;
    
    and(S, not_Q1, clk);
    
    SR_Latch SR0(not_Q2, clk, Q1, not_Q1);
    SR_Latch SR1(S, D, Q2, not_Q2);
    SR_Latch SR2(not_Q1, Q2, Q, not_Q);
endmodule

module Register (clk, D, Q);
    input clk;
    input D;
    output Q;
    D_FF DF(clk, D, Q, );
endmodule

module OMOK(left, right, up, down, put, rst, undo, clk, DATA_OUT,DATA_OUT2);
    input left, right, up, down, put, rst, undo, clk;
    parameter map_size = 5;
    wire [0:0] put_stone [map_size*map_size:0];
    reg [0:0] stone_pos [map_size*map_size:0]; 
    reg [8:0] Current_pos;
    integer i;
    output [8:0] DATA_OUT;
    output [24:0] DATA_OUT2;
    genvar j;
    generate
        for (j = 0; j < map_size*map_size; j = j + 1) begin : Reg_ARRAY
            Register record_pos (.clk(clk), .D(stone_pos[j]), .Q(put_stone[j]));
        end
    endgenerate
    
    assign DATA_OUT = Current_pos;
    generate
        for (j = 0; j < map_size*map_size; j = j + 1) begin : concat_gen
            assign DATA_OUT2[j] = stone_pos[j];
        end
    endgenerate
    
    initial begin
        Current_pos = 9'd5;
        for (i = 0; i < map_size*map_size; i = i + 1) begin
            stone_pos[i] = 1'bz;
        end
    end
    
    always @(posedge clk) begin
        if(right==1 && Current_pos % map_size != 3) begin
            Current_pos = Current_pos + 9'd1;
        end
        else if(left==1 && Current_pos % map_size != 0) begin
            Current_pos = Current_pos - 9'd1;
        end
        else if(up==1 && Current_pos / map_size != 0) begin
            Current_pos = Current_pos + 9'd5;
        end
        else if(down==1 && Current_pos / map_size != map_size) begin
            Current_pos = Current_pos - 9'd5;
        end
        else if(put==1'b1) begin
            stone_pos[Current_pos] = 1'b1;
        end
        else if(rst==1) begin
            for (i = 0; i < map_size*map_size; i = i + 1) begin
                stone_pos[i] = 1'bz;
            end
        end
    end
endmodule


