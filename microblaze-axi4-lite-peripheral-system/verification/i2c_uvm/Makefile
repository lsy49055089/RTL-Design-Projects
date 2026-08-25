OUT_DIR  = out
WAVE_DIR = $(OUT_DIR)/wave
LOG_DIR  = $(OUT_DIR)/log
COV_DIR  = $(OUT_DIR)/cov

VCS_OPTS = -full64 -sverilog
VCS_OPTS += -ntb_opts uvm-1.2
VCS_OPTS += -timescale=1ns/1ps
VCS_OPTS += -debug_access+all -kdb -lca
VCS_OPTS += -f filelist.f

VCS_OUTPUT = -o simv

TEST ?= i2c_basic_test
SEED ?= 1
INFO_LEVEL ?= UVM_MEDIUM

SIMV_OPTS = +UVM_TESTNAME=$(TEST)
SIMV_OPTS += +UVM_VERBOSITY=$(INFO_LEVEL)
SIMV_OPTS += +ntb_random_seed=$(SEED)

COV_OPTS = -cm line+cond+fsm+tgl+branch+assert
COV_OPTS += -cm_dir $(COV_DIR)/i2c_cov.vdb
COV_OPTS += -cm_name i2c_cov

.PHONY: all compile sim cov verdi vdcov urg clean

all: sim

compile:
	mkdir -p $(WAVE_DIR) $(LOG_DIR) $(COV_DIR)
	vcs $(VCS_OPTS) $(VCS_OUTPUT) -l $(LOG_DIR)/compile.log
	@echo "VCS compile done"

sim: compile
	./simv $(SIMV_OPTS) -l $(LOG_DIR)/sim.log
	@echo "VCS simulation done"

cov:
	mkdir -p $(WAVE_DIR) $(LOG_DIR) $(COV_DIR)
	vcs $(VCS_OPTS) $(COV_OPTS) $(VCS_OUTPUT) -l $(LOG_DIR)/compile_cov.log
	./simv $(SIMV_OPTS) $(COV_OPTS) -l $(LOG_DIR)/sim_cov.log
	@echo "VCS coverage simulation done"

verdi:
	verdi -sv -f filelist.f -ssf i2c_tb.fsdb &

vdcov:
	verdi -cov -covdir $(COV_DIR)/i2c_cov.vdb &

urg:
	urg -dir $(COV_DIR)/i2c_cov.vdb -report $(COV_DIR)/urg_report

clean:
	rm -rf \
		simv simv.daidir simv.vdb \
		csrc \
		out \
		coverage.vdb \
		*.fsdb \
		novas* \
		verdiLog \
		vdCovLog \
		DVEfiles \
		ucli.key \
		vc_hdrs.h \
		*.log \
		*.key
	@echo "clean done"
