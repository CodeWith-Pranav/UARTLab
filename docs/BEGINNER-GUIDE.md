# Start from zero

## What you are building

UART is a circuit that turns a byte into a timed sequence of bits, and converts incoming bits back to a byte. It connects processors, sensors and modules. This project describes that digital circuit in SystemVerilog. Simulation runs the description on your laptop. It does not need a sensor, Arduino, FPGA, or physical wires.

This is a core digital-design project. It has no web frontend/backend or AI model. RTL is the circuit description. A testbench acts as the external world: it supplies clocks and bytes, then checks results. VCD is a file recording how signal values changed with simulated time. GTKWave opens that file.

## Learn these concepts first

- A clock creates regular rising edges; registers remember values between edges.
- A combinational expression responds to current inputs without remembering history.
- `always @(posedge clk)` describes clocked logic; `<=` schedules register updates together after the edge.
- A finite-state machine remembers which stage of a process it is in.
- A FIFO is a first-in, first-out queue. Pointers find its oldest and next free slots.
- Ready/valid means a byte moves only when both signals are high on the same rising edge.

## Your first run

Unzip UARTLab. Open a terminal in its folder, where Makefile and rtl/ are visible. Install the free tools using the README commands, then run `make test`. You should see the FIFO pass and two sets of UART pass messages. A failing test exits with $fatal. Do not ignore a failure merely because earlier cases passed.

Next run `gtkwave results/uart-cpb32.vcd`. In the hierarchy select tb_uart. Add serial_tx, serial_rx, tx_valid, tx_ready, rx_valid, rx_ready, rx_data, tc, rc, framing, overrun, and rst. Zoom near the first falling edge of serial_tx. The first byte is 0xA5. Its binary form written normally is 10100101; UART sends the least significant bit first, so read data left-to-right as 1,0,1,0,0,1,0,1. There is a low start before it and a high stop after it. Each bit lasts 320 ns in the CPB=32 test.

The included PNG already shows that exact first frame, extracted from the actual VCD. The test clock period is 10 ns; VCD timestamps use 1 ps, so 320 ns is 320000 timestamp units.

## Understand one file at a time

1. Open sync_fifo.sv. Trace put/take at empty, partially full and full. Explain why simultaneous put/take keeps count unchanged.
2. Open uart_tx.sv. Find the frame register, bit counter, and bit timer. Walk through transmitting 0x00 and 0xFF.
3. Open uart_rx.sv. Trace the five states. Explain why testing the start bit halfway through rejects a short glitch.
4. Open uart_core.sv. Follow a received byte into rq and an offered byte out of tq.
5. Read the testbench. Explain the expected-value array and where independent stimulus avoids relying on TX and RX sharing the same mistake.

## Make a change yourself

Change FIFO_DEPTH in the UART testbench from 4 to 8 only after updating occupancy wire widths and overflow expectations, then rerun. Alternatively add one independent receive case for a new byte. Before editing, predict the behavior; after editing, compare the waveform and test results. Revert or commit the change as a real development step.

## Errors you may encounter

`iverilog: command not found`: install Icarus inside the same environment where you run make. A Windows installation and WSL installation are separate.

`No rule to make target test`: your terminal is not in UARTLab's root directory.

No waveform: run make test from the project root; VCD paths are relative to that directory.

Unknown (`x`) rx_data when rx_valid is low: FIFO storage is not cleared. That data is invalid and should be ignored; reset clears occupancy.

## What to say about authorship

Describe this as a simulation project you implemented with AI assistance if asked. Learn each module before claiming independent design expertise. You may say you verified the documented cases once you personally run them and understand the checks. Do not claim FPGA implementation, timing closure, chip fabrication or physical testing.
