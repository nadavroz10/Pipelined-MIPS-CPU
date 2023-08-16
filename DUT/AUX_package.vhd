LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;


package aux_package is

constant ALU_OP_SIZE: integer := 9;

COMPONENT Ifetch
   	    generic ( address_size : integer := 0);
		PORT(	  
		    SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			signal jump, jr,jal	 			: in	STD_LOGIC;
        	signal PCsrc			: IN    STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
			signal IDecode_Sign_extend       : in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );  -- for jump, jr or jal (from idcode)
			signal read_data_1	: in 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );    -- for jump, jr or jal   (from idcode)
			signal stall_pc : IN 	STD_LOGIC;  
			SIGNAL clock, reset 	: IN 	STD_LOGIC);
	END COMPONENT; 

	COMPONENT Idecode
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
	END COMPONENT;

	COMPONENT control
	     PORT( 	Opcode,Function_opcode 				: IN 	STD_LOGIC_VECTOR( 5 DOWNTO 0 );
             	RegDst 				: OUT 	STD_LOGIC;
             	ALUSrc 				: OUT 	STD_LOGIC;
             	MemtoReg 			: OUT 	STD_LOGIC;
             	RegWrite 			: OUT 	STD_LOGIC;
             	MemRead 			: OUT 	STD_LOGIC;
             	MemWrite 			: OUT 	STD_LOGIC;
             	Branch 				: OUT 	STD_LOGIC;
				Branch_NE 			: OUT	STD_LOGIC;
             	ALUop 				: OUT 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 );
				jump	 			: OUT	STD_LOGIC;
				jr	 			: OUT	STD_LOGIC;
				jal	    : out 	STD_LOGIC;
             	clock, reset		: IN 	STD_LOGIC );
	END COMPONENT;

	COMPONENT  Execute
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
	END COMPONENT;


	COMPONENT dmemory
		generic ( address_size : integer := 0);
	   PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	   		MemRead, Memwrite 	: IN 	STD_LOGIC;
            clock,reset			: IN 	STD_LOGIC );
	END COMPONENT;


component reg is
generic(size: integer:= 32);
port( 
	  clk,reset : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  output:out std_logic_vector(size-1 downto 0)
);
end component;

component if_reg is
generic(size: integer:= 16);
port( 
	  clk,reset : in std_logic;
	  flush     : in std_logic;
	  stall      : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  output:out std_logic_vector(size-1 downto 0)
);
end component;

component hazard_unit is
port( 
signal ID_instruction  : in std_logic_vector(31 downto 0);
signal EX_regw, DM_regw, WB_regw : in std_logic;
signal EX_muxAdress, DM_muxAdress, WB_muxAdress : in	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal EX_memread,ID_memread,ID_memwrite : in std_logic;
signal pcSRC : in std_logic;
signal ALUop 		: in 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 ); --EXE
signal jump	    : in 	STD_LOGIC;  --WB
signal jr	    : in 	STD_LOGIC; --WB
signal jal	    : in 	STD_LOGIC; --WB
signal stall_pc, stall_reg, flush ,control_mux : out std_logic;
signal clock, reset	: IN 	STD_LOGIC );
end component;

component forwarding_unit is
port( 
signal EX_instruction  : in std_logic_vector(31 downto 0);
signal  DM_regw, WB_regw : in std_logic;
signal  DM_muxAdress, WB_muxAdress : in	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal ALUop 		: in 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 ); --EXE
signal MUX_A_INPUT,MUX_B_INPUT : out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
signal SW_MUX  : out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
signal EX_MEMread , EX_MEMwrite : in std_logic;
signal clock, reset	: IN 	STD_LOGIC );
end component;

end aux_package;