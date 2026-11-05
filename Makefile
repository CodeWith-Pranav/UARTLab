IVERILOG ?= iverilog
VVP ?= vvp
RTL = rtl/sync_fifo.sv rtl/uart_tx.sv rtl/uart_rx.sv rtl/uart_core.sv
.PHONY: test clean
test:
	mkdir -p build results
	$(IVERILOG) -g2012 -Wall -s tb_fifo -o build/fifo $(RTL) tb/tb_fifo.sv
	$(VVP) build/fifo
	$(IVERILOG) -g2012 -Wall -s tb_uart -o build/uart $(RTL) tb/tb_uart.sv
	$(VVP) build/uart
	$(IVERILOG) -g2012 -Wall -s tb_uart -Ptb_uart.CPB=8 -o build/uart8 $(RTL) tb/tb_uart.sv
	$(VVP) build/uart8
clean:
	rm -rf build results/*.vcd
