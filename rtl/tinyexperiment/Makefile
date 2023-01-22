
# PLATFORM can be "fidget" or "tinyfpga"
PLATFORM = fidget
#PLATFORM = tinyfpga

ifeq ($(PLATFORM), fidget)
DEVICE = hx1k
PACKAGE = tq144
PIN_DEF = pins-fidget.pcf
else
DEVICE = lp8k
PACKAGE = cm81
PIN_DEF = pins-tinyfpga.pcf
endif

TOP = fidget
LIBRARIES = \
	../libraries/computie_bus_device/computie_bus_demux.sv \
	../libraries/computie_bus_device/computie_bus_ctrl.sv \
	../libraries/usart/usart_ctrl.sv \
	../libraries/usart/usart_tx.sv


all: $(TOP).bin

##############
# Synthesis  #
##############

%.json: %.sv $(LIBRARIES)
	yosys -p 'synth_ice40 -top $* -blif $*.blif -json $*.json' $^

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PIN_DEF) --json $*.json --asc $@ 

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

##############
# Simulation #
##############

%.wave: %.vcd
	gtkwave $<

%.vcd: %.sim
	vvp $<

%.sim: %.v
	iverilog -o $@ $^

%.sim: %.sv
	iverilog -g2012 -o $@ $^

clean:
	find . \( -name "*.vcd" -or -name "*.sim" -or -name "*.json" -or -name "*.blif" -or -name "*.rpt" -or -name "*.asc" -or -name "*.bin" \) -delete -print

.SECONDARY: # Make all targets secondary targets, so they won't be deleted

