`timescale 1ns / 1ps
`default_nettype none 

module vga_top
    (   input wire          i_clk25m,
        input wire          i_rstn_clk25m,

        output wire [9:0]   o_VGA_x,
        output wire [9:0]   o_VGA_y, 
        output wire         o_VGA_vsync,
        output wire         o_VGA_hsync, 
        output wire         o_VGA_video,
        output reg  [3:0]   o_VGA_r,
        output reg  [3:0]   o_VGA_g,
        output reg  [3:0]   o_VGA_b, 

        input  wire [7:0]  i_pix_data, 
        output reg  [18:0] o_pix_addr
    );
    
    vga_driver
    #(  .hDisp(640              ), 
        .hFp(16                 ), 
        .hPulse(96              ), 
        .hBp(48                 ), 
        .vDisp(480              ), 
        .vFp(10                 ), 
        .vPulse(2               ),
        .vBp(33)                )
    vga_timing_signals
    (   .i_clk(i_clk25m         ),
        .i_rstn(i_rstn_clk25m   ),
        .o_x_counter(o_VGA_x    ),
        .o_y_counter(o_VGA_y    ),
        .o_video(o_VGA_video    ), 
        .o_vsync(o_VGA_vsync    ),
        .o_hsync(o_VGA_hsync    )
    );
    

    reg [1:0]   r_SM_state;
    localparam [1:0]    WAIT_1  = 0,
                        WAIT_2  = 'd1,  
                        READ    = 'd2;
                          
    always @(posedge i_clk25m or negedge i_rstn_clk25m)
    if(!i_rstn_clk25m)
    begin
        r_SM_state <= WAIT_1;
        o_pix_addr <= 0; 
    end
    else
        case(r_SM_state)
        

        WAIT_1: r_SM_state <= (o_VGA_x == 640 && o_VGA_y == 480) ? WAIT_2 : WAIT_1;
        WAIT_2: r_SM_state <= (o_VGA_x == 640 && o_VGA_y == 480) ? READ : WAIT_2; 
        
        READ: begin
            if((o_VGA_y < 480) && (o_VGA_x < 639))
                o_pix_addr <= (o_pix_addr == 307199) ? 0 : o_pix_addr + 1'b1;
            else begin           
                if( (o_VGA_x == 799) && ( (o_VGA_y == 524) || (o_VGA_y < 480) ) )
                    o_pix_addr <= o_pix_addr + 1'b1; 
                else if(o_VGA_y >= 480)
                    o_pix_addr <= 0;
            end
        end 
        
        endcase
    

    always @(*)
        begin
            if(o_VGA_video)
                begin
                    o_VGA_r = (i_pix_data[3:0]); 
                    o_VGA_g = (i_pix_data[3:0]);
                    o_VGA_b = (i_pix_data[3:0]);
                end
            else begin
                    o_VGA_r = 0; 
                    o_VGA_g = 0;
                    o_VGA_b = 0;
            end
        end 
    
endmodule
