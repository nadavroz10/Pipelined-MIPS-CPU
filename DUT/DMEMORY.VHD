						--  Dmemory module (implements the data
						--  memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY dmemory IS
	generic (address_size : integer := 0);
	
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
END dmemory;

ARCHITECTURE behavior OF dmemory IS
SIGNAL write_clock : STD_LOGIC;
signal adress_tmp : std_logic_vector (7 + address_size downto 0 );
BEGIN
		
	

	data_memory : altsyncram
	GENERIC MAP  (
		operation_mode => "SINGLE_PORT",
		width_a => 32,
		widthad_a => (8 + address_size),
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\nadav\Desktop\MIPS single cycle Architecture-20230530T090204Z-001\MIPS single cycle Architecture\ModelSim\L1_Caches\asm_ver1\ourDmem7.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		wren_a => memwrite,
		clock0 => write_clock,
		address_a => adress_tmp ,
		data_a => write_data ,
		q_a => read_data	);
-- Load memory address register with write clock
		write_clock <= NOT clock;
		
		adress_tmp <= address & CONV_STD_LOGIC_VECTOR( 0, address_size );
		
END behavior;

