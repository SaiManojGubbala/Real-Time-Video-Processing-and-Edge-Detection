`timescale 1ns / 1ps 
`default_nettype none 


module sync_fifo
    #(	parameter DW = 8,    
        parameter AW = 4,
        parameter AFW = 2,
        parameter AEW = 2 )
    (
        input wire          i_clk,
        input wire          i_rstn,
    

        input wire          i_wr,
        input wire [DW-1:0] i_data,
        output reg          o_full, 
        output reg          o_almost_full,
                
        input wire          i_rd,
        output reg [DW-1:0] o_data,
        output reg          o_empty,
        output reg          o_almost_empty,      
    
        output reg [AW:0]   o_fill
    );

	reg [DW-1:0] mem [0: (1<<AW)-1];
    
    reg [AW:0]   wptr;
    reg [AW:0]   rptr;
    reg [AW-1:0] rptr_nxt; 

    wire w_rd = i_rd && !o_empty;
    wire w_wr = i_wr && !o_full;

    always @(posedge i_clk)
        if(w_wr)
            mem[wptr[AW-1:0]] <= i_data;
    

    always @(posedge i_clk) 
        o_data <= mem[ (w_rd) ? rptr_nxt : rptr[AW-1:0] ];


    always @(posedge i_clk or negedge i_rstn)
    begin
        if(!i_rstn)
        begin
            wptr <= 0;
            rptr <= 0;
        end
        else begin
            if(w_wr)
                wptr <= wptr + 1'b1;
            if(w_rd)
                rptr <= rptr + 1'b1;
        end
    end


    always @(*)
        rptr_nxt = rptr[AW-1:0] + 1'b1;


    always @(posedge i_clk or negedge i_rstn)
    begin
        if(!i_rstn) 
        begin
            o_fill         <= 0;
            o_full         <= 0;
            o_almost_full  <= 0; 
            o_almost_empty <= 1'b1;
            o_empty        <= 1'b1; 
        end 
        else begin
            
            if(w_rd && (!w_wr))
                o_fill <= o_fill - 1'b1;
            else if((!w_rd) && w_wr)
                o_fill <= o_fill + 1'b1;
            
            if((o_fill > 1) || ((o_fill == 1) && (!w_rd)))
                o_empty <= 0;
            else
                o_empty <= 1'b1;
            
            if((o_fill > (1<<AEW)) || ((o_fill == (1<<AEW)) && (!w_rd))) 
                o_almost_empty <= 0;
            else
                o_almost_empty <= 1'b1;

            if((o_fill < { 1'b0, {(AW){1'b1}}}) || ((o_fill == { 1'b0, {(AW){1'b1}}}) && (!w_wr)))
                o_full <= 0;
            else
                o_full <= 1'b1;
                
            if((o_fill < { 1'b0, {(AW-AFW){1'b0}}, {(AFW){1'b1}}}) || ((o_fill == { 1'b0, {(AW-AFW){1'b0}}, {(AFW){1'b1}}}) && (!w_wr)))
                o_almost_full <= 0;
            else
                o_almost_full <= 1'b1; 
        end
    end

endmodule
