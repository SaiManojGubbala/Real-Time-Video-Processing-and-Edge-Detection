`timescale 1ns / 1ps
`default_nettype none

module grayscale
    (   input wire         i_clk, 
        input wire         i_rstn, 
        
        input  wire [11:0] i_data,
        input  wire        i_data_valid, 
        
        output reg  [11:0] o_gray_data,
        output reg         o_gray_data_valid
    );
    
    wire [7:0] R;
    wire [7:0] G;
    wire [7:0] B;
    

    assign R = (i_data[11:8] << 4); 
    assign G = (i_data[7:4]  << 4);
    assign B = (i_data[3:0]  << 4);  
    
    always @(posedge i_clk)
    begin
        if(!i_rstn)
        begin
            o_gray_data       <= 0;
            o_gray_data_valid <= 0; 
        end
    else begin
        
        o_gray_data       <= 0;
        o_gray_data_valid <= 0; 
        
            if(i_data_valid)
            begin
                o_gray_data <= (R >> 2) + (R >> 5) +
                                (G >> 1) + (G >> 4) + 
                                (B >> 4) + (B >> 5); 
                o_gray_data_valid <= 1; 
            end 
        end
    end 
            
endmodule
