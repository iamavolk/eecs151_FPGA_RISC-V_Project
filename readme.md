# Four-Stage RISC-V pipelined design
<br>

- Design features: 4 stages (IF, ID, X, MW), fully bypassed, early branch target resolution
- RTL: Verilog (IEEE-1364 syntax)
- Target platform: Xilinx Zynq 7020
- Verification: directed co-simulation with reference models, assembly tests, and riscv test suites
- I/O: UART tx/rx, synchronizer (async user input) + debouncer (pressing buttons on the board is an exciting activity)
- BIOS, asm and C test suites, CSRs
<br>

![pic](images/4-staged_RISCV.png)

Authors: Alex Volkov, Anastasia ~~Simonova~~ Chernikova

![pic](images/bear_the_risc_200x200.png)
