
DEVICE = hx4k
PACKAGE = tq144
PIN_DEF = ../pins-hx4k-all.pcf

TOP = fidget
LIBRARIES = \
	../libraries/usart/usart_echo.v \
	../libraries/usart/usart_tx.v \
	../libraries/usart/usart_rx.v \
	../libraries/utils/async_fifo.v \
	../libraries/utils/synchronizer.v


LIBRARIES_SYNTH = \
	../libraries/utils/dual_port_memory_ice40.v

LIBRARIES_TEST = \
	../libraries/utils/dual_port_memory.v

include ../common.mk

