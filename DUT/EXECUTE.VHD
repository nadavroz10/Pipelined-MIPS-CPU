--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
USE work.AUX_package.all;

ENTITY  Execute IS
	PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Read_data_2 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Sign_extend 	: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Function_opcode : IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
			ALUOp 			: IN 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 );
			ALUSrc 			: IN 	STD_LOGIC;
			RegDst 			: IN 	STD_LOGIC;
			Zero 			: OUT	STD_LOGIC;
			ALU_Result 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			rd, rt 	: IN 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			mux_address 	: out	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			A_input_mux, B_input_mux: in STD_LOGIC_VECTOR( 1 DOWNTO 0 );
			OPERAND_FROM_MEM, OPERAND_FROM_WB: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Ainput_out, Binput_out	: out STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock, reset	: IN 	STD_LOGIC );
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput, B_SIGNED_OR_REG		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL ALU_output_mux		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
SIGNAL Branch_Add 			: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
SIGNAL ALU_ctl				: STD_LOGIC_VECTOR( 3 DOWNTO 0 );
signal xori, ori , andi, lui, slti, mul : STD_LOGIC;
BEGIN
	Ainput <= OPERAND_FROM_MEM WHEN A_input_mux = "01" else
			  OPERAND_FROM_WB WHEN A_input_mux = "10" else
			  Read_data_1;
						-- ALU input mux
	B_SIGNED_OR_REG <= Read_data_2 --WHEN FORWARD_B = "00"
		WHEN ( ALUSrc = '0' ) 
  		ELSE  Sign_extend( 31 DOWNTO 0 );
	
	Binput <= OPERAND_FROM_MEM WHEN B_input_mux = "01" else
			  OPERAND_FROM_WB WHEN B_input_mux = "10" else
			  B_SIGNED_OR_REG;
		
						-- Generate ALU control bits
	ALU_ctl( 0 ) <= ( Function_opcode( 0 ) OR Function_opcode( 3 ) ) AND ALUOp(1 );
	ALU_ctl( 1 ) <= ( NOT Function_opcode( 2 ) ) OR (NOT ALUOp( 1 ) );
	ALU_ctl( 2 ) <= ( Function_opcode( 1 ) AND ALUOp( 1 )) OR ALUOp( 0 );
	ALU_ctl( 3 ) <=  ALUOp(2);
						-- Generate Zero Flag
	Zero <= '1' 
		WHEN ( ALU_output_mux( 31 DOWNTO 0 ) = X"00000000"  )
		ELSE '0';    
						-- Select ALU output        
	ALU_result <= X"0000000" & B"000"  & ALU_output_mux( 31 ) 
		WHEN  (ALU_ctl = "0111"  or slti = '1')
		ELSE  	ALU_output_mux( 31 DOWNTO 0 );
						-- Adder to compute Branch Address
	
		
	mux_address <=	rd WHEN RegDst = '1'  ELSE rt;
		

PROCESS ( ALU_ctl, Ainput, Binput,xori, ori , andi, lui, slti, mul )
	variable add_sig, xor_sig, and_sig, or_sig, sub_sig, lui_sig: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	variable mul_vector :STD_LOGIC_VECTOR( 63 DOWNTO 0 );
	BEGIN
	 lui_sig  := TO_STDLOGICVECTOR(TO_BITVECTOR(Binput) sll 16);
	 xor_sig := Ainput xor Binput;
	 and_sig := Ainput and Binput;
	 or_sig := Ainput or Binput;
	 mul_vector := Ainput * Binput;
	 if (mul = '1') then 
		sub_sig := mul_vector(31 downto 0);
	else
		sub_sig := Ainput - Binput;	
	end if;
	
	 if(xori = '1') then 
		add_sig := xor_sig;
	elsif(andi = '1') then  
		add_sig := and_sig;
	elsif(ori = '1') then 
		add_sig := or_sig;
	elsif(lui = '1') then 
		add_sig := lui_sig;
	elsif(slti = '1') then 
		add_sig := sub_sig;
	else
		add_sig := Ainput + Binput;
	end if;   
	
		-- Select ALU operation
 	CASE ALU_ctl IS
						-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= and_sig; 
						-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= or_sig;
						-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= add_sig;
						-- ALU performs ADD UNSIGNED
 	 	WHEN "0011" 	=>	ALU_output_mux <= unsigned(Ainput) + unsigned(Binput);
						-- ALU performs xor
 	 	WHEN "0100" 	=>	ALU_output_mux 	<= xor_sig;
						-- ALU performs ?
 	 	WHEN "0101" 	=>	ALU_output_mux 	<= X"00000000";
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= sub_sig;
						-- ALU performs SLT
  	 	WHEN "0111" 	=>	ALU_output_mux 	<= sub_sig ;
						-- ALU performs Shift left and lui
		WHEN "1010"		=>	ALU_output_mux 	<= TO_STDLOGICVECTOR(TO_BITVECTOR(Ainput) sll conv_integer(unsigned(Binput(10 downto 6))));
						-- ALU performs Shift right
		WHEN "1110"		=>	ALU_output_mux 	<= TO_STDLOGICVECTOR(TO_BITVECTOR(Ainput) srl conv_integer(unsigned(Binput(10 downto 6))));
 	 	WHEN OTHERS	=>	ALU_output_mux 	<= X"00000000" ;
  	END CASE;
  END PROCESS;
  
  
  mul  <= ALUOp(8);
  slti <= ALUOp(7);
  lui  <= ALUOp(6);
  andi <= ALUOp(5);
  xori <= ALUOp(4);
  ori  <= ALUOp(3);
  
 ---for outputs---
 Ainput_out <= Ainput;
 Binput_out <= Binput;
  
END behavior;

