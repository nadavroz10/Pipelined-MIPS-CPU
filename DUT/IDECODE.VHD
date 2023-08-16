						--  Idecode module (implements the register file for
LIBRARY IEEE; 			-- the MIPS computer)
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Idecode IS
	  PORT(	read_data_1	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			read_data_2	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Instruction : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			data_wb	    : IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			RegWrite 	: IN 	STD_LOGIC;
			shift 	: IN 	STD_LOGIC;
			MemtoReg 	: IN 	STD_LOGIC;
			Sign_extend : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			PC_plus_4 	: in	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			jr	    : in 	STD_LOGIC;
			jal_wb	    : in 	STD_LOGIC;
			mux_address 	: in	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			Branch          : in    STD_LOGIC;
			Branch_NE       : in    STD_LOGIC;
			PCsrc			: OUT    STD_LOGIC;
			Add_result		: out    STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			clock,reset	: IN 	STD_LOGIC );
END Idecode;


ARCHITECTURE behavior OF Idecode IS
TYPE register_file IS ARRAY ( 0 TO 31 ) OF STD_LOGIC_VECTOR( 31 DOWNTO 0 );

	SIGNAL register_array				: register_file;
	SIGNAL write_register_address 		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_1_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL read_register_2_address		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_1		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL write_register_address_0		: STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL Instruction_immediate_value	: STD_LOGIC_VECTOR( 15 DOWNTO 0 );
	signal areEqual						: STD_LOGIC;
	signal read_data_1_temp, read_data_2_temp,Sign_extend_temp: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	

BEGIN
	read_register_1_address 	<= Instruction( 25 DOWNTO 21 ) when shift = '0' else Instruction( 20 DOWNTO 16 );
   	read_register_2_address 	<= Instruction( 20 DOWNTO 16 );
   	write_register_address_1	<= Instruction( 15 DOWNTO 11 );
   	write_register_address_0 	<= Instruction( 20 DOWNTO 16 );
   	Instruction_immediate_value <= Instruction( 15 DOWNTO 0 );
					-- Read Register 1 Operation
	read_data_1_temp <= register_array( 
			      CONV_INTEGER( read_register_1_address ) );
					-- Read Register 2 Operation		 
	read_data_2_temp <= register_array( 
			      CONV_INTEGER( read_register_2_address ) );
						
				    -- COMPARTOR for branch
	areEqual    <= '1' when read_data_1_temp = read_data_2_temp  else '0';
	PCsrc <= ( ( Branch  AND  areEqual ) or ( Branch_NE  AND not(areEqual ))) ;
	Add_result 	<= PC_plus_4( 9 DOWNTO 2 ) +  Sign_extend_temp( 7 DOWNTO 0 ) ;
	
				
	
					--read data and sign extend outputs--
	read_data_1 <= read_data_1_temp;
	read_data_2 <= read_data_2_temp;
	Sign_extend <= Sign_extend_temp;
	
					-- Mux for Register Write Address
   write_register_address <=  "11111" when jal_wb = '1' else mux_address;
			
					-- Mux to bypass data memory for Rformat instructions
					-- Sign Extend 16-bits to 32-bits
    	Sign_extend_temp <= X"0000" & Instruction_immediate_value
		WHEN Instruction_immediate_value(15) = '0'
		ELSE	X"FFFF" & Instruction_immediate_value;

PROCESS
	BEGIN
		WAIT UNTIL clock'EVENT AND clock = '0';
		IF reset = '1' THEN
					-- Initial register values on reset are register = reg#
					-- use loop to automatically generate reset logic 
					-- for all registers
			FOR i IN 0 TO 31 LOOP
				register_array(i) <= CONV_STD_LOGIC_VECTOR( 0, 32 );
 			END LOOP;
			register_array(29) <= CONV_STD_LOGIC_VECTOR( 128, 32 );
					-- Write back to register - don't write to register 0
  		ELSIF (RegWrite = '1' or jal_wb = '1') AND write_register_address /= 0 THEN
		      register_array( CONV_INTEGER( write_register_address)) <= data_wb;
		END IF;
	END PROCESS;
END behavior;


