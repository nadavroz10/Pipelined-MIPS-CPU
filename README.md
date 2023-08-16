# Pipelined-MIPS-CPU

This readme provides an overview of the inner entities in the pipelined MIPS CPU system. These entities work together to execute MIPS assembly instructions and facilitate efficient and accurate processing.

1. Ifetch- 
The Ifetch unit is responsible for fetching instructions from memory. It retrieves the instruction stored at the program counter (PC) and sends it to the next stage for decoding and execution. it gets also the pcsrc signal for jumps and branches.

2. Idecode- 
The Idecode unit is responsible for decoding the fetched instruction. It interprets the instruction's opcode and extracts the necessary operands to the control unit, hazard unit and execute unit required for execution. it contanes the register file.

3. Control Unit- 
The Control Unit manages the control signals necessary for proper instruction execution. It receives inputs from the Idecode unit and generates control signals that determine the actions to be performed by other units, such as the ALU and memory units.

4. Execute- 
The Execute stage performs the actual execution of arithmetic, logical, and control operations based on the decoded instruction. It utilizes the ALU (Arithmetic Logic Unit) to perform various calculations and comparisons required by the instruction.

5. Dmemory- 
The Dmemory unit represents the data memory component. It is responsible for storing and retrieving data from memory locations based on the instruction requirements. It interacts with other units to read or write data to/from memory.

6. Writeback- 
The Writeback stage handles the writing of results back to the register file. After the execution of an instruction, the Writeback unit stores the computed results in the appropriate registers of the register file.

7. Hazard Unit- 
The Hazard Unit detects and handles hazards, which are situations where one instruction depends on the result of a previous instruction that is not yet available. It determines the appropriate actions to be taken to resolve hazards, such as stalling or inserting bubbles in the pipeline. it also flushs the ID/IF register when a jump or branch occures.

8. Forwarding Unit- 
The Forwarding Unit assists in resolving data hazards by forwarding the required data directly from the late execution stages to the dependent instruction in the ALU. bypassing the need to wait for the data to be written back to the register file. This improves performance by reducing stalls in the pipeline.

Conclusion- 

The described inner entities in the MIPS CPU system work collaboratively to execute MIPS instructions accurately and efficiently. Each entity performs a specific function, contributing to the overall functionality and performance of the CPU. Understanding these entities is essential for designing, implementing, and optimizing MIPS processors.
