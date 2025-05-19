MODELSIM = vsim
VLOG = vlog
SOURCES = fifo.sv mem.sv double_buffer.sv reorder_buffer.sv tb_reorder_buffer.sv
WORK_DIR = work
VCD_FILE = waveform.vcd

all:	compile simulate

compile:
	vlib $(WORK_DIR)
	$(VLOG) -sv -work $(WORK_DIR) $(SOURCES)

simulate:
	$(MODELSIM) -do "add wave -position insertpoint sim:/tb_reorder_buffer/*; run -a" -voptargs=+acc -wlf waves.wlf > sim.log \
	-work $(WORK_DIR) \
	tb_reorder_buffer \
	-l transcript.log

clean:
	rm -rf $(WORK_DIR) *.vcd transcript.log