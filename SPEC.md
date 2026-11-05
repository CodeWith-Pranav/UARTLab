# UARTLab specification

## Protocol and timing

8 data bits, no parity, one stop bit (8N1), LSB first, idle high. All sequential logic uses the same rising clock edge. Reset is synchronous, active high; assert it for at least one rising edge. `CLKS_PER_BIT` is an integer constant >= 8, not a runtime register. `FIFO_DEPTH` >= 2; arbitrary integer depths are supported by explicit pointer wrap.

Choose `CLKS_PER_BIT = round(clock_hz / desired_baud)`. Actual baud is `clock_hz / CLKS_PER_BIT`. At 50 MHz and desired 115200 baud, choose 434: actual approximately 115207.37 baud (+0.0064%). At the supplied test clock of 100 MHz and CPB=32, baud is 3.125 Mbit/s; this accelerated simulation setting is not a hardware capability claim. One 8N1 frame uses 10 bits, so ideal payload capacity is baud/10 bytes/s. TX inserts one clock of idle between queued frames, giving actual sustained throughput clock_hz/(10*CPB+1) bytes/s.

## Top-level ports

| Port | Direction | Meaning |
|---|---|---|
| `clk`, `rst` | input | Clock and synchronous reset |
| `serial_rx` | input | Asynchronous receive line, idle high |
| `serial_tx` | output | Transmit line, idle high |
| `tx_data[7:0]`, `tx_valid` | input | Byte offered by producer |
| `tx_ready` | output | Transfer occurs on rising edge with valid AND ready |
| `rx_data[7:0]`, `rx_valid` | output | Queue head; data meaningful only while valid |
| `rx_ready` | input | Consume queue head on rising edge with valid AND ready |
| `clear_errors` | input | Clear sticky error flags; a simultaneous new error wins |
| `rx_overrun`, `frame_error` | output | Sticky overflow and invalid-stop flags |
| `tx_count`, `rx_count` | output | Occupancy width = $clog2(FIFO_DEPTH+1) |

The producer holds tx_valid and tx_data stable until accepted. The consumer samples rx_data on the handshake edge. Stalled RX data remains stable. FIFO counts omit a byte already transferred to the TX shift register. An empty queue cannot bypass a newly pushed byte directly to its consumer: it becomes available after the edge.

## FIFO corner policies

Pop on empty does nothing. Push on full is rejected unless an existing item is popped in that same edge. At full occupancy, simultaneous pop+push transfers the old head to the consumer and inserts the new tail, leaving occupancy unchanged. At empty, simultaneous pop+push stores one byte without a read. Reset flushes pointers/count, not RAM; invalid output memory contents must be ignored.

## Receive behavior

The synchronized low level starts detection. At half a bit period, RX checks start is still low. Eight samples follow at one-bit intervals, then a stop sample. A high stop emits a one-cycle valid pulse to the FIFO. A low stop emits framing_error and enters recovery until high. Invalid frames never enter the FIFO. If a completed good frame arrives to a full RX FIFO without a simultaneous pop, drop that newest byte and set overrun. Error flags clear only on reset or clear_errors. Counts and valid signals remain independent of sticky errors.

## Acceptance evidence

Run `make test`: FIFO reference comparison plus UART tests at CPB=32 and CPB=8 must finish without $fatal. Results include full byte range loopback, independent TX decoding and independent RX stimulus, overflow, false-start and bad-stop recovery, stalls, and active-frame reset. See docs/VERIFICATION.md for exact scope and limitations.
