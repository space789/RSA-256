# RSA-256 FPGA Implementation

## Overview
This project implements a 256-bit RSA encryption and decryption system using hardware acceleration on the PYNQ-Z2 FPGA board. The RSA algorithm is a cornerstone of modern cryptography, relying on the difficulty of prime factorization. This implementation optimizes the modular exponentiation process by designing a three-level 256-bit carry-skip adder, improving efficiency while ensuring flexibility and scalability.

## Features
- **256-bit RSA Encryption & Decryption**: Supports large prime number key generation and modular arithmetic.
- **Optimized Hardware Design**: Implements a three-layer carry-skip adder using ripple carry adders.
- **FPGA-Based Acceleration**: Designed for PYNQ-Z2 FPGA, achieving an operational frequency of 18.52 MHz.
- **Low Power Consumption**: Consumes only 11mW on the FPGA board.
- **Verified Performance**: Pre-simulation and post-simulation testing ensure accuracy and stability.

## Hardware Design
- **Key Components**:
  - Modular exponentiation using an optimized Montgomery multiplication algorithm.
  - Carry-Save Adder (CSA) for efficient modular arithmetic.
  - Hardware-optimized modular multiplication and modular reduction.
- **Resource Utilization**:
  - 3592 LUTs (Look-Up Tables)
  - 1885 Flip-Flops (FFs)
  - Power consumption: 11mW

## Installation & Setup
### Prerequisites
- **Hardware**: PYNQ-Z2 FPGA Board (Zynq-7000 xc7z020clg400-2)
- **Software**:
  - Xilinx Vivado 2020.2
  - Python (for key generation using SymPy library)
  - Verilog for FPGA programming

### Setup Instructions
1. **Clone the Repository**:
   ```sh
   git clone https://github.com/your-username/RSA-256-FPGA.git
   cd RSA-256-FPGA
   ```
2. **Synthesize and Implement in Vivado**:
   - Open Vivado and import the project files.
   - Run synthesis, implementation, and bitstream generation.
3. **Upload to PYNQ-Z2**:
   - Load the bitstream onto the FPGA.
   - Use Python scripts to interface with the FPGA for encryption/decryption.

## Usage
### Key Generation
Use the provided Python script to generate RSA keys:
```sh
python keygen.py
```

### Encryption
```sh
python encrypt.py --message "Hello, FPGA!"
```

### Decryption
```sh
python decrypt.py --cipher "output_ciphertext.txt"
```

## Simulation & Verification
### Pre-Simulation Testing
- Verified using a testbench written in Verilog.
- Ensured correctness by comparing encrypted and decrypted values.

### Post-Simulation Testing
- Implemented on PYNQ-Z2 FPGA.
- Verified using timing analysis and power consumption measurements.

## Performance Analysis
| Bit Length | Execution Time |
|------------|---------------|
| 256-bit    | ~5.3 ms       |
| 128-bit    | ~2.7 ms       |
| 64-bit     | ~1.3 ms       |

## Future Improvements
- **Pipeline Optimization**: Implement a pipelined architecture to increase processing speed.
- **Higher Frequency Operation**: Improve timing constraints to achieve a higher clock frequency.
- **Scalability**: Extend to support larger key sizes beyond 256-bit.

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.
