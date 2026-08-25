# I2C Master-Slave UVM verification

## Structure

- `rtl/`: I2C Master (`I2C_master_top.sv`), Slave (`I2C_slave_top.sv`), and top-level wire wrapper under test (`top_i2c.sv`).
- `tb/tb_top.sv`: Self-contained SystemVerilog/UVM testbench environment containing interface, configuration, sequence, driver, monitor, agent, scoreboard, env, test, and clock generation.
- `filelist.f`: VCS compile order and include directory.
- `Makefile`: compile, simulation, coverage, and Verdi debugging targets.

## Run

```sh
# Run simulation
make sim TEST=i2c_basic_test SEED=1

# Run with coverage metric collection
make cov TEST=i2c_basic_test SEED=1

# Clean compiled objects and wave databases
make clean
```

Pre-requisites: Synopsys VCS and UVM 1.2 tools configured in your environment. Output databases are generated under `out/` (and the `i2c_tb.fsdb` file) and are cleaned before source submission.
