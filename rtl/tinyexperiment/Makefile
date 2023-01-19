
PIN_DEF = pins.pcf
DEVICE = hx1k
PACKAGE = tq144
TOP = bus/computie_test

.SECONDARY: # Make all targets secondary targets, so they won't be deleted

all: $(TOP).bin

%.json: %.sv
	yosys -p 'synth_ice40 -top $* -blif $*.blif -json $*.json' $^

%.asc: $(PIN_DEF) %.json
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PIN_DEF) --json $*.json --asc $@ 

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<


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


