# Data Cache and Controller
The project shows the design and implementation of a direct-mapped write-through cache and controller in verilog for a single-cycle processor system,
interfacing with an n-cycle latency main memory.

## Specifications
- Design contains 3 submodules: a) Cache controller with tag array b) Cache data array and c) Main memory
- Direct Mapped.
- Write Through,no write-allocate policy.
- Cache block size is 16 bytes / 128 bits.
- 4 cache line (parameterized)
- Processor data and address buses are 32 bits.
- Interleaved Memory that contains four 32-bit memory banks.

## Architecture
<img width="779" alt="Image" src="https://github.com/user-attachments/assets/6465912d-cb4f-4dd0-8515-33e92b48f211" />

## Simulation
A SystemVerilog testbench with muliptle test cases is used to verify the design in ModelSim.

<img width="1201" alt="Image" src="https://github.com/user-attachments/assets/479b8a48-0c46-4955-bdb3-858ee62eb660" />


## Next Steps
- Optimize the Verilog code.
- Design an n-way associative cache controller design.
