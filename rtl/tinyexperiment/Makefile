
# PLATFORM can be "fidget" or "tinyfpga"
#PLATFORM = fidget
PLATFORM = tinyfpga

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
	../libraries/usart/usart_ctrl.sv \
	../libraries/usart/usart_tx.sv

LIBRARIES_SYNTH = \
	../libraries/computie_bus_device/computie_bus_ctrl.sv \
	../libraries/computie_bus_device/computie_bus_demux.sv

LIBRARIES_TEST = \


all: $(TOP).bin

##############
# Synthesis  #
##############

%.json: %.sv $(LIBRARIES) $(LIBRARIES_SYNTH)
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

%.sim: %.v $(LIBRARIES) $(LIBRARIES_TEST)
	iverilog -o $@ $^

%.sim: %.sv %_tb.sv $(LIBRARIES) $(LIBRARIES_TEST)
	iverilog -g2012 -o $@ $^


upload:
	tinyprog -p $(TOP).bin

clean:
	find . \( -name "*.vcd" -or -name "*.sim" -or -name "*.json" -or -name "*.blif" -or -name "*.rpt" -or -name "*.asc" -or -name "*.bin" \) -delete -print

.SECONDARY: # Make all targets secondary targets, so they won't be deleted

