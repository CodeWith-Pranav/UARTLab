`timescale 1ns/1ps
module uart_core #(parameter CLKS_PER_BIT=32, FIFO_DEPTH=8)(
 input wire clk,rst,serial_rx,
 output wire serial_tx,
 input wire [7:0] tx_data,
 input wire tx_valid,
 output wire tx_ready,
 output wire [7:0] rx_data,
 output wire rx_valid,
 input wire rx_ready,
 input wire clear_errors,
 output reg rx_overrun,frame_error,
 output wire [$clog2(FIFO_DEPTH+1)-1:0] tx_count,rx_count
);
 wire tx_full,tx_empty,tx_engine_ready;
 wire [7:0] tx_head,received;
 wire received_valid,bad_stop,rx_full,rx_empty;
 wire tx_pop=tx_engine_ready && !tx_empty;
 wire rx_pop=rx_ready && !rx_empty;
 // Ready permits replacement at full occupancy when the old head is consumed.
 assign tx_ready=!tx_full || tx_pop;
 assign rx_valid=!rx_empty;
 sync_fifo #(.DEPTH(FIFO_DEPTH)) tq(clk,rst,tx_valid && tx_ready,tx_pop,tx_data,tx_head,tx_full,tx_empty,tx_count);
 sync_fifo #(.DEPTH(FIFO_DEPTH)) rq(clk,rst,received_valid,rx_pop,received,rx_data,rx_full,rx_empty,rx_count);
 uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) transmitter(clk,rst,!tx_empty,tx_head,tx_engine_ready,serial_tx);
 uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) receiver(clk,rst,serial_rx,received,received_valid,bad_stop);
 always @(posedge clk) begin
  if(rst) begin rx_overrun<=0;frame_error<=0;end
  else begin
   if(clear_errors) begin rx_overrun<=0;frame_error<=0;end
   // A new error on the clear cycle wins, so it cannot be lost.
   if(received_valid && rx_full && !rx_pop) rx_overrun<=1;
   if(bad_stop) frame_error<=1;
  end
 end
endmodule
