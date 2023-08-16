-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
	generic ( address_size : integer := 0);
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			signal jump, jr,jal	 			: in	STD_LOGIC;
        	signal PCsrc			: IN    STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			signal IDecode_Sign_extend       : in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );  -- for jump, jr or jal (from idcode)
			signal read_data_1	: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );    -- for jump, jr or jal   (from idcode)
			signal stall_pc : IN 	STD_LOGIC;  
			SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	signal instruction_temp  : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal adress_tmp : std_logic_vector (7 + address_size downto 0 );
BEGIN
						--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => 8 + address_size,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\nadav\Desktop\MIPS single cycle Architecture-20230530T090204Z-001\MIPS single cycle Architecture\ModelSim\L1_Caches\asm_ver1\ourexample12.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a 	=> adress_tmp, 
		q_a 			=> instruction_temp );
		
		
		
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		adress_tmp <= Next_PC & CONV_STD_LOGIC_VECTOR( 0, address_size );
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
       	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						-- Mux to select Branch Address or PC + 4        
		Next_PC  <= X"00" WHEN Reset = '1' ELSE
			PC(9 downto 2) WHEN PC(9 downto 2) ="11111111" or stall_pc = '1' ELSE
			Add_result  WHEN PCsrc = '1' else   -- branch taken
			read_data_1(9 downto 2) WHEN jr = '1' else
			IDecode_Sign_extend(7 downto 0) WHEN jump = '1'or jal='1' else
			PC_plus_4( 9 DOWNTO 2 );
		

	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC( 9 DOWNTO 2) <= "00000000" ; 
			ELSE 
				   PC( 9 DOWNTO 2 ) <= next_PC;
			END IF;
	END PROCESS;
	instruction <= instruction_temp;
END behavior;


