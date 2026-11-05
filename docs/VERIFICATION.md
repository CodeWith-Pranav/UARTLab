# Verification record

Actual run: 2026-11-05, Linux x86_64, Icarus Verilog 11.0, SystemVerilog 2012 mode. All three executables finished with exit code zero; compilation passed -Wall without warnings in the final run. Commands and PASS output are saved in results/test-log.txt. Temporary tool paths in that record describe this run only; portable commands are in Makefile.

| Check | Actual exercise |
|---|---|
| FIFO ordering and flags | 6,000 seeded cycles with a reference queue; depth 3 forces non-power-of-two wrapping; full replacement, empty behavior and reset |
| Independent TX decoder | Samples start, eight data bits and stop of 0xA5 at bit centers |
| All-byte loopback | Each of 256 byte values transmitted and compared in order, using enqueue backpressure |
| Independent RX | Directly drives serial frames without DUT TX; nominal 0x55 |
| Baud mismatch samples | CPB=32 RX receives 0xA6 at 33 clocks/bit and 0x39 at 31 clocks/bit |
| False start | Two-clock low pulse rejected |
| Invalid stop | Low stop rejected; sticky error, clear and next valid frame checked |
| FIFO overflow | Six incoming frames with four queue slots; keep first four, drop remaining frames, latch overrun |
| Consumer stall | Queued 0xC3 stays stable for 100 clocks before consumption |
| Mid-frame reset | Aborts active TX; later queue empty, line high and flags cleared |
| Parameter boundary | UART suite repeated at minimum supported CPB=8; baud mismatch cases intentionally skipped there |

15 printed PASS groups: one FIFO group and seven UART groups at each of two parameter values. These are scenario groups, not a formal coverage percentage. The printed baud-offset group at CPB=8 covers nominal RX only; the conditional test source is authoritative.

VCD files record the complete corresponding UART runs. `tools/plot_waveform.py` parses uart-cpb32.vcd to draw the initial actual TX frame. No artificial signal data is used. `waveform-metadata.json` records timestamp/clock units and the selected byte.

## Limits

The tests do not prove every possible input sequence, noise pattern, drift, phase or divider value. The independent RX tests drive on falling test-clock edges; arbitrary asynchronous phase/jitter is not swept. Offset tests are two samples, not a certified baud-tolerance bound. Simulated registers cannot reproduce analog metastability. No synthesis, CDC analysis, formal proof, FPGA timing closure, physical power or silicon measurements were performed. The public repository includes a CI workflow. Publication and remote-run outcomes are recorded separately in PROJECT-STATUS.md.

## Reference protocol reading

- Texas Instruments, UART protocol and error overview: https://www.ti.com/video/6313217959112
- Microchip, asynchronous receiver and sampling: https://onlinedocs.microchip.com/oxy/GUID-B822915F-C375-4172-91BD-AB6F326EB783-en-US-1/GUID-D742E4B3-493C-4FD7-8A7C-DE55893B1017.html

These describe general UART behavior; this project implements only the subset specified in SPEC.md. No vendor RTL was copied.

The repository stores VCDs losslessly compressed as .vcd.gz. Run make test to regenerate raw waveforms or node tools/build-site.mjs to decompress the recorded evidence into public/downloads. The browser explorer is a separately labeled JavaScript teaching model; its automated checks cover all 256 frame encodings, invalid inputs, the 50 MHz/115200 divider, and FIFO boundary behavior.
