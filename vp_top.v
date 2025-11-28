`timescale 1ns / 1ps
`default_nettype none

module vp_top
    #(  parameter DW = 8,
        parameter RL = 640 )
    (
        input wire i_clk,
        input wire i_rstn,

        input wire [7:0] i_threshold,

        output reg          o_data_ready,
        input wire          i_data_valid,
        input wire [11:0]   i_data,       

        input wire           i_data_ready,
        output wire          o_data_valid,
        output wire [DW-1:0] o_data         
    );
   
    wire [11:0]     w_gray_data;
    wire [DW-1:0]   w_gray_byte;
    wire            w_gray_data_valid; 

    wire [9*DW-1:0] w_vp_control_data;
    wire            w_vp_control_valid;
    
    wire [DW-1:0]   w_sobel_data;
    wire            w_sobel_data_valid;
    wire            w_fifo_AF; 
    wire            w_fifo_AE; 
    
    
    localparam IDLE = 0,
                TRANSFER = 1;
    
    reg state; 
    reg r_data_valid;
    
    always @(posedge i_clk)
    begin
        if(!i_rstn)
        begin
            state        <= IDLE; 
            o_data_ready <= 0;
            r_data_valid <= 0; 
        end
    else begin
            case(state)
            IDLE: begin
            
                r_data_valid <= 0;
                o_data_ready <= 0; 
                
                if(i_data_valid)
                begin
                    o_data_ready <= (!w_fifo_AF);
                    state        <= TRANSFER;  
                end
            end
            TRANSFER: begin
            
                r_data_valid <= o_data_ready;
                o_data_ready <= 0; 
                state <= IDLE; 
                
            end
            endcase  
        end
    end  
    
   grayscale
    vp_gray
    (
        .i_clk(i_clk                            ), 
        .i_rstn(i_rstn                          ),
        
        .i_data(i_data                          ), 
        .i_data_valid(r_data_valid              ),
        
        .o_gray_data(w_gray_data                ), 
        .o_gray_data_valid(w_gray_data_valid    )
    );
    
    assign w_gray_byte = w_gray_data[11:4]; 
    
    vp_control
    #(  .DW(DW                               ),  
        .RL(RL)                              )
    vp_lb
    (
        .i_clk(i_clk                         ),
        .i_rstn(i_rstn                       ),

        .i_pixel_data(w_gray_byte            ), 
        .i_pixel_data_valid(w_gray_data_valid),

        .o_pixel_data(w_vp_control_data      ),
        .o_pixel_valid(w_vp_control_valid    )
    );
    conv
    #(  .DW(DW)                     )
    vp_sobel
    (   
        .i_clk(i_clk                ),
        .i_rstn(i_rstn              ),  

        .i_sobel_thresh(i_threshold ),

        .i_data(w_vp_control_data   ),
        .i_valid(w_vp_control_valid ), 
        
        .o_data(w_sobel_data        ), 
        .o_valid(w_sobel_data_valid ) 
    );
    
   sync_fifo
    #(  .DW(DW                      ),
        .AW(10                      ),
        .AFW(9                      ),
        .AEW(1)                     )
    vp_outputFIFO
    (
        .i_clk(i_clk                ),
        .i_rstn(i_rstn              ),

        .i_wr(w_sobel_data_valid    ),
        .i_data(w_sobel_data        ),
        .o_full(                    ), 
        .o_almost_full(w_fifo_AF    ),

        .i_rd(i_data_ready          ),
        .o_data(o_data              ),
        .o_empty(                   ),
        .o_almost_empty(w_fifo_AE   ),      

        .o_fill(                    )
    );

    assign o_data_valid = !w_fifo_AE;

endmodule