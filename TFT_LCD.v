parameter HSIZE = 11;
parameter VSIZE = 10;
parameter map_size = 11;
parameter map_v_size = 60;

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
    output reg [8-1:0] R, G, B,
    output den, hsync, vsync,
    output dclk, disp_en
    );
    wire [11-1:0] counter_h;
    wire [10-1:0] counter_v;
    wire [map_size*map_size-1:0] board_state;
    wire [9:0] row, col;
    integer i;

//    wood_board(.board_state(board_state));
    
    TFT_LCD_controller ctl(
        .clk(clk), .rst(rst),
        .counter_h(counter_h), .counter_v(counter_v),
        .disp_den(den), .disp_hsync(hsync), .disp_vsync(vsync),
        .disp_clk(dclk), .disp_enb(disp_en)
    );
    always @ (posedge rst or posedge clk) begin
        if (rst) begin
            R = 8'b0;
            G = 8'b0;
            B = 8'b0;
        end
        else begin
            for(i=0;i<map_size;i=i+1) begin
                if(42+40*i<=counter_v && counter_v<=42+40*(i+1) && 410<=counter_h && counter_h<=850) begin
                    R = 8'hCD;
                    G = 8'h85;
                    B = 8'h3F;
                    if((counter_v-42)%40 == 0 || (counter_h-410)%40 == 0) begin
                        R = 8'h00;
                        G = 8'h00;
                        B = 8'h00;
                    end
                end
            end
            
            if (counter_v<42 || 482<counter_v || counter_h<410 || 850<counter_h)begin
                R = 8'd0;
                G = 8'd255;
                B = 8'd0;
            end
        end   
    end
endmodule
