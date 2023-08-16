		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.AUX_package.all;

ENTITY control IS
   PORT( 	
	Opcode,Function_opcode 		: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 ); 
	RegDst 		: OUT 	STD_LOGIC; --exec
	ALUSrc 		: OUT 	STD_LOGIC;  --exec
	MemtoReg 	: OUT 	STD_LOGIC;	--WB
	RegWrite 	: OUT 	STD_LOGIC;	--WB
	MemRead 		: OUT 	STD_LOGIC;  --MEM
	MemWrite 	: OUT 	STD_LOGIC; --MEM
	Branch 		: OUT 	STD_LOGIC;  --MEM
	Branch_NE   : OUT 	STD_LOGIC; --MEM
	ALUop 		: OUT 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 ); --EXE
	jump	    : OUT 	STD_LOGIC;  --WB
	jr	    : OUT 	STD_LOGIC; --WB
	jal	    : OUT 	STD_LOGIC; --WB
	clock, reset	: IN 	STD_LOGIC );

END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format, Lw, Sw, Beq, Beq_ne,shift, imm, xori, ori, andi, lui , mul, slti, addu	: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  ELSE '0';
	jal 		<=  '1'  WHEN  Opcode = "000011"  ELSE '0';
	jump 		<=  '1'  WHEN  Opcode = "000010"  ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  ELSE '0';
   	Beq         <=  '1'  WHEN  Opcode = "000100"  ELSE '0';
	Beq_ne		  <=  '1'  WHEN  Opcode = "000101"  ELSE '0';
	xori         <=  '1'  when  Opcode = "001110"  ELSE '0';
	mul         <=  '1'  when  Opcode = "011100"  ELSE '0';
	ori         <=  '1'  when  Opcode = "001101"  ELSE '0';
	andi         <=  '1'  when  Opcode = "001100"  ELSE '0';
	lui         <=  '1'  when  Opcode = "001111"  ELSE '0';
	slti		 <=  '1'  when  Opcode = "001010"  ELSE '0';
	shift		<=  '1'	 when  R_format = '1' and (Function_opcode="000000" or Function_opcode="000010") else '0';
  	imm			<=  '1'	 when  Opcode = "001000" or Opcode = "001100" or Opcode = "001101" 
							or Opcode = "001110" or Opcode = "001111" or Opcode = "001010" else '0';
	jr 			<= '1' when R_format='1' and (Function_opcode = "001000") else '0';
	RegDst    	<=  R_format or mul;
 	ALUSrc  	<=  Lw OR Sw OR shift OR imm;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw OR imm or mul;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
 	Branch      <=  Beq;
	Branch_NE   <= Beq_ne;
	
	ALUOp(8)	<=  mul;
	ALUOp(7)	<=  slti;
	ALUOp(6)	<=  lui;
	ALUOp(5)	<=  andi;
	ALUOp(4)	<=  xori;
	ALUOp(3)	<=  ori;
	ALUOp(2)    <=  shift;
	ALUOp( 1 ) 	<=  R_format or mul;
	ALUOp( 0 ) 	<=  Beq or beq_ne; 

   END behavior;


