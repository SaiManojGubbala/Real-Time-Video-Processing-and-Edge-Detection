`timescale 1ns / 1ps
`default_nettype none

module cam_capture
    (   input wire         i_pclk,
        input wire         i_rstn,
        input wire         i_vsync,
        input wire         i_href,    
        input wire  [7:0]  i_D,
        input wire         i_cam_done,
        output reg  [11:0] o_pix_data,      
        output reg         o_pix_valid                   
    );
    reg         r1_vsync,    r2_vsync; 
    wire        frame_start, frame_done;
    
    initial { r1_vsync, r2_vsync } = 0; 
    always @(posedge i_pclk or negedge i_rstn)
    if(!i_rstn) {r2_vsync, r1_vsync} <= 2'b00;
    else        {r2_vsync, r1_vsync} <= {r1_vsync, i_vsync}; 
  
    assign frame_start = (r1_vsync == 0) && (r2_vsync == 1);   
    assign frame_done  = (r1_vsync == 1) && (r2_vsync == 0);   
     

    localparam [1:0] WAIT   = 2'd0,
                     IDLE   = 2'd1,
                     CAPTURE = 2'd2;
    
    reg        r_half_data;             
    reg [1:0]  SM_state;
    reg [3:0]  pixel_data;
                                                                         
    always @(posedge i_pclk or negedge i_rstn)
    if(!i_rstn) 
    begin
        SM_state    <= WAIT;
        o_pix_valid <= 0;
        o_pix_data  <= 0; 
        r_half_data <= 0; 
    end    
    else
        begin
        
            r_half_data <= 0; 
            o_pix_valid <= 0;

            case(SM_state)
                WAIT: 
                    begin

                        SM_state   <= (frame_start && i_cam_done) ? IDLE : WAIT;
                    end
                IDLE:        
                    begin
                        SM_state   <= (frame_start) ? CAPTURE : IDLE;
                    end
                CAPTURE:
                    begin
                        SM_state   <= (frame_done) ? IDLE : CAPTURE;
                        
                        if(i_href)
                            begin 

                                 if(!r_half_data)   
                                    pixel_data <= i_D[3:0];      
                                 r_half_data    <= ~r_half_data;                       
                                 o_pix_valid    <= (r_half_data) ? 1'b1 : 1'b0;
                                 o_pix_data     <= (r_half_data) ? {pixel_data, i_D} : o_pix_data; 
                            end 
                    end  
            endcase
        end
             
endmodule