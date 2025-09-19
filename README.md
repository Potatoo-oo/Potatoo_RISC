# Potatoo_RISC
Title: Design of a RISC-V based processing system with AI acceleration-ready interface architecture

RISC-V softcore to be implemented with a CNN 

## Remark:
Softcore implemented without CSR, which means it does not have ECALL & EBREAK
CNN implemented is a minimal CNN which only does dot products between image (9x9) and kernel (3x3) matrices, future implementation on pooling and other functions



### SoftWare: 
1) Microsoft VSCode (Verilog Extension)
2) ModelSim (Simulation)
3) Quartus Prime (FPGA Implementation)

### HardWare:
1) Altera DE1 - SoC



## Phase 1

- Implemented the very basic blocks of the RISC-V core: if - id - ex 
- Done minimal pipelines
- Created memory blocks: regs / ROM
- Minimal instruction is added: ADDI / ADD / SUB
- Testbench for simulation in ModelSim is created



## Phase 2

- Added control unit for branch and jump
- complete Type I, R, Jump, Branch, U



## Phase 2.2

- Slight Optimization is made
- minimized adder used in ex.v



## Phase 3

- dual port - RAM created
- Load and Store instruction added
- Data hazard from RAM fixed
- FPGA implementation available
- Automated testing with pyscript + iverilog added



## Phase 3.5

- 7-segment decoder added
- output led registers for testers added



## Phase 4

**Incomplete
- UART debug added
- Flash instruction with UART to FPGA



## Phase 4.5

**Incomplete (Main Focus, 19/9/2025)
- Bus Decoder for memory mapping added
- Minimal CNN that does dot product added







## TO DO LIST

1) ADD R32M subset
2) give matrices, compare speed
