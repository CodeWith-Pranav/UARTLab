# UARTLab publication status — 2026-11-05

Completed: UART RTL and independent TX/RX FIFOs; self-checking SystemVerilog testbenches; local verification; actual VCD evidence and waveform plot; interactive JavaScript teaching demo; beginner/interview guides; public GitHub source; read-only automated simulation workflow; Vercel production project connected to main.

Public demo: https://uartlab.vercel.app/
Public repository: https://github.com/CodeWith-Pranav/UARTLab

Local evidence: 6,000 seeded FIFO cycles and seven UART scenario groups at each of CPB=32 and CPB=8 passed. Browser model checks passed for all 256 bytes, baud rounding, invalid inputs and FIFO boundary cases. CI and Vercel publication status can be checked at the linked repository Actions page and live demo.

Scope: simulation-only, no FPGA synthesis, timing closure or hardware measurements. The browser explorer is a teaching model; downloadable VCDs are real Icarus output. Future main pushes run CI and deploy on Vercel independently; CI is not a deployment gate.

See docs/VERIFICATION.md for test limits. Resume from this checkpoint; preserve completed RTL and recorded evidence. The initial source archive in history was a publication staging step, not artificial development history.

Publication checks completed: public Vercel page opened successfully, interactive frame and FIFO cases passed, actual waveform download completed, and GitHub Actions run 41962964919 passed (4a069c0 checkpoint). The temporary source archive was removed from main after normal source-file publication. Final documentation and license changes are followed by normal automated CI and deployment.
