# SPI AXI UVM verification

## Structure

- `../../hardware/ip/spi`: 검증 대상 AXI SPI RTL
- `model/spi_slave.sv`: testbench 전용 SPI slave response model
- `tb/`: AXI-Lite driver/monitor, SPI monitor, scoreboard, coverage, test
- `filelist.f`: VCS compile order와 include directory
- `Makefile`: compile, simulation, coverage, Verdi 실행 target

## Run

```sh
make sim TEST=spi_axi_test SEED=1
make cov TEST=spi_axi_test SEED=1
make clean
```

Synopsys VCS와 UVM 1.2 환경을 전제로 한다. 출력은 `out/` 아래에 생성되며
제출 소스에는 포함하지 않는다.
