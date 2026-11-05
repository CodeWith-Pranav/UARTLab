# Explain the project

## 45-second explanation

“I built and simulated an 8N1 UART in SystemVerilog with separate transmit and receive FIFOs. A ready/valid byte interface handles application backpressure, and the receive path reports framing errors and overflow. I used a reference-model FIFO test, an independent serial driver and decoder, exhaustive byte loopback, and fault injection to check behavior. I saved waveforms and made the runs reproducible with Icarus and a GitHub Actions workflow. It is simulation-only; I have not implemented it on an FPGA.”

Use this after you can explain and reproduce the work. Attribute AI assistance truthfully when asked.

## Questions to prepare

**Why FIFO?** Bytes may arrive in bursts while the serial link sends one bit at a time. A queue absorbs a limited burst. RX still overflows if its consumer stalls for too long.

**Why two registers on RX?** RX is asynchronous to the core clock. A two-register synchronizer reduces the likelihood of metastability propagating. It does not eliminate that probability; this simulation cannot measure it.

**How does the receiver find bit boundaries?** It detects low, checks the start halfway through a nominal bit interval, then samples every full bit interval. The transmitter and receiver must use sufficiently similar baud rates.

**Why test independently as well as loopback?** TX and RX could contain matching mistakes. A direct serial stimulus and decoder provide external expectations.

**What happens at full FIFO with simultaneous push/pop?** The old head is consumed, the new byte is stored, and count stays full. At empty, a new byte is stored but not immediately bypassed.

**What happens if the RX buffer is full?** The newest completed byte is dropped and overrun stays latched until cleared. Already queued bytes remain in order.

**Why sticky errors?** Software or another consumer might miss a one-cycle pulse. A sticky flag persists until explicitly cleared.

**What is framing error?** Stop was sampled low. The frame is rejected and RX waits for high before trying again.

**Why is this not a dual-clock FIFO?** All internal logic uses one core clock. Serial RX crosses through a synchronizer rather than through a second parallel clock domain.

**What would improve robustness?** Majority-vote oversampling, parity, more extensive asynchronous phase/noise tests, fractional baud generation and formal properties. Those are potential extensions, not implemented features.

**What is missing for an FPGA claim?** Choose a device; supply pin and clock constraints; synthesize; inspect resources; run timing/CDC checks; and test actual serial traffic on hardware. None is required for this laptop-only scope.

## Resume wording after personal review

“Implemented a simulation-only SystemVerilog UART with independent FIFOs, ready/valid interfaces, and sticky framing/overflow status; verified all 256 byte values, fault recovery and FIFO ordering with self-checking Icarus testbenches.”

Do not describe the 256-byte sweep as production reliability or the test cases as 100% functional coverage. Do not claim a measured hardware baud rate.
