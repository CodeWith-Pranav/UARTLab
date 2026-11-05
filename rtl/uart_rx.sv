`timescale 1ns/1ps
module uart_rx #(parameter CLKS_PER_BIT=32)(
 input wire clk,rst,rx,
 output reg [7:0] data,
 output reg valid, framing_error
);
 // Only this two-flop synchronizer consumes the asynchronous input.
 (* ASYNC_REG="TRUE" *) reg rx_meta,rx_sync;
 reg [7:0] shift;
 localparam IDLE=0,START=1,DATA=2,STOP=3,RECOVER=4;
 reg [2:0] state;
 integer timer,bitno;
 initial if(CLKS_PER_BIT<8) $fatal(1,"CLKS_PER_BIT must be >=8");
 always @(posedge clk) begin
  if(rst) begin rx_meta<=1;rx_sync<=1;end
  else begin rx_meta<=rx;rx_sync<=rx_meta;end
 end
 always @(posedge clk) begin
  if(rst) begin state<=IDLE;timer<=0;bitno<=0;shift<=0;data<=0;valid<=0;framing_error<=0;end
  else begin
   valid<=0;framing_error<=0;
   case(state)
    IDLE: if(!rx_sync) begin timer<=CLKS_PER_BIT/2-1;state<=START;end
    START: if(timer!=0) timer<=timer-1;
     else if(rx_sync) state<=IDLE;
     else begin state<=DATA;timer<=CLKS_PER_BIT-1;bitno<=0;end
    DATA: if(timer!=0) timer<=timer-1;
     else begin
      shift[bitno]<=rx_sync;timer<=CLKS_PER_BIT-1;
      if(bitno==7) state<=STOP;else bitno<=bitno+1;
     end
    STOP: if(timer!=0) timer<=timer-1;
     else if(rx_sync) begin data<=shift;valid<=1;state<=IDLE;end
     else begin framing_error<=1;state<=RECOVER;end
    RECOVER: if(rx_sync) state<=IDLE;
    default:state<=IDLE;
   endcase
  end
 end
endmodule
