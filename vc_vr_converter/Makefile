MODELSIM = vsim
VLOG = vlog
SOURCES = fifo.sv vc_vr_converter.sv tb_vc_vr_converter.sv
MEM_FILE = tv.hex
MEM_FILE_PATH = $(abspath $(MEM_FILE))
WORK_DIR = work
VCD_FILE = waveform.vcd

all: compile simulate

compile:
	vlib $(WORK_DIR)
	$(VLOG) -sv -work $(WORK_DIR) $(SOURCES)

simulate:
	$(MODELSIM) -c -do "run -all; quit" \
	-GMEM_FILE=\"$(MEM_FILE_PATH)\" \
	-work $(WORK_DIR) \
	tb_vc_vr_converter \
	-l transcript.log

clean:
	rm -rf $(WORK_DIR) *.vcd transcript.log