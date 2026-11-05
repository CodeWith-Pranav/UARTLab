`timescale 1ns/1ps
module sync_fifo #(parameter WIDTH=8, DEPTH=8)(
 input wire clk, rst, push, pop,
 input wire [WIDTH-1:0] din,
 output wire [WIDTH-1:0] dout,
 output wire full, empty,
 output reg [$clog2(DEPTH+1)-1:0] count
);
 localparam PW=(DEPTH<=2)?1:$clog2(DEPTH);
 reg [WIDTH-1:0] mem[0:DEPTH-1];
 reg [PW-1:0] wr,rd;
 wire take=pop && !empty;
 wire put=push && (!full || take);
 assign full=(count==DEPTH);
 assign empty=(count==0);
 assign dout=mem[rd];
 initial if(DEPTH<2) $fatal(1,"DEPTH must be >=2");
 always @(posedge clk) begin
  if(rst) begin wr<=0; rd<=0; count<=0; end
  else begin
   if(put) begin mem[wr]<=din; wr<=(wr==DEPTH-1)?0:wr+1'b1; end
   if(take) rd<=(rd==DEPTH-1)?0:rd+1'b1;
   case({put,take})
    2'b10: count<=count+1'b1;
    2'b01: count<=count-1'b1;
    default: count<=count;
   endcase
  end
 end
endmodule
