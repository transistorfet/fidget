
DEVICE = hx4k
PACKAGE = tq144
PIN_DEF = ../pins-hx4k-all.pcf

TOP = fidget
LIBRARIES = \
	busdebugger_serial.v \
	../libraries/computie_bus/computie_bus_snooper.v \
	../libraries/computie_bus/computie_bus_dumper.v \
	../libraries/usart/usart_tx.v \
	../libraries/usart/usart_rx.v \
	../libraries/utils/async_fifo.v \
	../libraries/utils/synchronizer.v


LIBRARIES_SYNTH = \
	../libraries/utils/dual_port_memory_ice40.v
	#../libraries/utils/dual_port_memory.v

LIBRARIES_TEST = \
	../libraries/utils/dual_port_memory.v

include ../common.mk

