`timescale 1ns/1ps
module uart_tx #(parameter CLKS_PER_BIT=32)(
 input wire clk,rst,valid,
 input wire [7:0] data,
 output wire ready,
 output reg tx
);
 reg busy;
 reg [9:0] frame;
 integer timer, bitno;
 assign ready=!busy;
 initial if(CLKS_PER_BIT<8) $fatal(1,"CLKS_PER_BIT must be >=8");
 always @(posedge clk) begin
  if(rst) begin tx<=1; busy<=0; timer<=0; bitno<=0; frame<=10'h3ff; end
  else if(!busy) begin
   tx<=1;
   if(valid) begin frame<={1'b1,data,1'b0}; tx<=0; busy<=1; timer<=CLKS_PER_BIT-1; bitno<=0; end
  end else if(timer==0) begin
   timer<=CLKS_PER_BIT-1;
   if(bitno==9) begin busy<=0; tx<=1; end
   else begin bitno<=bitno+1; tx<=frame[bitno+1]; end
  end else timer<=timer-1;
 end
endmodule
