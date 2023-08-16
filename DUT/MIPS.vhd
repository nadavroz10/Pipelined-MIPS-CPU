				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.AUX_package.all;
ENTITY MIPS IS
	generic (address_size : integer := 0);
	PORT( reset, clock					: IN 	STD_LOGIC; 
		-- Output important signals 
		--------- pipeline lvl0   IF---------
		IF_PC_out								: OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		IF_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		IF_PC_SRC_OUT							: OUT 	STD_LOGIC;
		--------- pipeline lvl1   ID---------
		ID_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_read_data_1_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_read_data_2_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_write_data_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_SIGN_EXT_OUT						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		ID_Regwrite_out						: OUT 	STD_LOGIC;
		--------- pipeline lvl2   EXE---------
		EXE_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_ALU_result_out					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_AINPUT_OUT						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_BINPUT_OUT						: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		EXE_MUX_AINPUT_OUT					: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		EXE_MUX_BINPUT_OUT					: OUT 	STD_LOGIC_VECTOR( 1 DOWNTO 0 );
		EXE_Zero_out						: OUT 	STD_LOGIC;
		EXE_MUX_ADRESS_OUT					: OUT 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		--------- pipeline lvl3   DMEM---------
		DM_INSTUCTION_out 					: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		DM_MEM_WRITE  						: OUT 	STD_LOGIC;
		DM_WRITE_DATA                       : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		DM_READ_DATA                        : OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		DM_MEM_ADDRESS						: OUT 	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		
		--------- pipeline lvl4   WB---------
		WB_INSTUCTION_out,WB_write_data_out	: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
		WB_REGWRITE							: OUT 	STD_LOGIC;
		WB_JAL_OUT							: OUT 	STD_LOGIC;
		
		---------hazards outputs-------------
		stall_out, flash_out                : OUT 	STD_LOGIC 
		
		-------------------------------------------------
		 );
END 	MIPS;

ARCHITECTURE structure OF MIPS IS

					-- declare signals used to connect VHDL components
	----------------------PIPLIE LEVEL 0 SIGNALS-------------------
	SIGNAL PC_plus_4_before_reg_0 ,  PC_plus_4_after_reg_0		: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL instruction_after_reg_0, Instruction_before_reg_0, instruction : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	----------------------PIPLIE LEVEL 1 SIGNALS-------------------
	SIGNAL read_data_1_before_reg_1,read_data_1_after_reg_1 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL read_data_2_before_reg_1,read_data_2_after_reg_1 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Sign_Extend_before_reg_1, Sign_Extend_after_reg_1  		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL  PC_plus_4_after_reg_1: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL rt, rd : STD_LOGIC_VECTOR( 4 DOWNTO 0 ); 
	signal  mux_address_before_reg_2  	: 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL instruction_after_reg_1 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	------- control vec-----------
	SIGNAL  EX_control_before_reg_1,EX_control_after_reg_1 :STD_LOGIC_VECTOR( 2+ ALU_OP_SIZE-1 DOWNTO 0 ); 
	SIGNAL  Mem_control_before_reg_1,Mem_control_after_reg_1 :STD_LOGIC_VECTOR( 3 DOWNTO 0 ); 
	SIGNAL  WB_control_before_reg_1,WB_control_after_reg_1 :STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	
	------- control sig-----------
	SIGNAL ALUSrc_before_reg_1, ALUSrc_after_reg_1		: STD_LOGIC;
	SIGNAL Branch_before_reg_1, Branch_after_reg_2		: STD_LOGIC;
	SIGNAL Branch_NE_before_reg_1, Branch_NE_after_reg_2 : STD_LOGIC;
	signal jump, jr, jal 								: STD_LOGIC;										
	SIGNAL RegDst_before_reg_1, RegDst_after_reg_1		: STD_LOGIC;
	SIGNAL Regwrite_before_reg_1, Regwrite_after_reg_3	: STD_LOGIC;
	SIGNAL MemWrite_before_reg_1, MemWrite_after_reg_2 	: STD_LOGIC;
	SIGNAL MemtoReg_before_reg_1, MemtoReg_after_reg_3		: STD_LOGIC;
	SIGNAL MemRead_before_reg_1 , MemRead_after_reg_2		: STD_LOGIC;
	SIGNAL ALUop_before_reg_1, ALUop_after_reg_1			: STD_LOGIC_VECTOR( ALU_OP_SIZE -1  DOWNTO 0 );
	
	----------------------PIPLIE LEVEL 2 SIGNALS-------------------
	SIGNAL  Mem_control_after_reg_2 :STD_LOGIC_VECTOR( 3 DOWNTO 0 ); 
	SIGNAL  WB_control_after_reg_2 :STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL Add_result	: STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	SIGNAL PC_plus_4_after_reg_2: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL ALU_result_before_reg_2, ALU_result_after_reg_2		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Zero_before_reg_2 , Zero_after_reg_2	: STD_LOGIC;
	signal write_data_after_reg_2 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal  mux_address_after_reg_2  	: 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL instruction_after_reg_2 : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal zero_vector_before_reg_2, zero_vector_after_reg_2: STD_LOGIC_VECTOR( 0 DOWNTO 0 );
	signal PCsrc : STD_LOGIC;
	----------------------PIPLIE LEVEL 3 SIGNALS-------------------
	SIGNAL  WB_control_after_reg_3 :STD_LOGIC_VECTOR( 2 DOWNTO 0 );
	SIGNAL  ALU_result_after_reg_3		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal  mux_address_after_reg_3  	: 	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
	SIGNAL  PC_plus_4_after_reg_3: STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL read_data_before_reg_3, read_data_after_reg_3,instruction_after_reg_3 	: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal jal_after_reg_3 : std_logic;
	-------flush & stall signals & forwarding ---
	signal stall_pc, stall_reg, flush ,control_mux  : STD_LOGIC;
	SIGNAL EXECUTE_REG_WRITE, MEM_REG_WRITE, EX_MEMREAD : STD_LOGIC;
	signal MUX_A_INPUT,MUX_B_INPUT,MUX_SW_INPUT :  STD_LOGIC_VECTOR( 1 DOWNTO 0 );
	signal EX_MEMwrite : std_logic;
	signal data_wb : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	signal actual_write_data : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	
	
BEGIN   

	
	----------------------- OUTPUT DECLARATIONS--------------------------------
	--lvl0
	IF_INSTUCTION_out <= Instruction_before_reg_0;
	-- pc declared in ifetch;
	IF_PC_SRC_OUT <=PCsrc;
	--lvl1
	ID_INSTUCTION_out <= instruction_after_reg_0;
	ID_read_data_1_out<= read_data_1_before_reg_1;
    ID_read_data_2_out <= read_data_2_before_reg_1;
    ID_write_data_out <= data_wb;
	ID_Regwrite_out <= RegWrite_after_reg_3;
	ID_SIGN_EXT_OUT <= Sign_Extend_before_reg_1;
	
	---lvl2
	EXE_INSTUCTION_out <= instruction_after_reg_1;
	EXE_ALU_result_out <= ALU_result_before_reg_2;
	EXE_MUX_AINPUT_OUT <= MUX_A_INPUT;
	EXE_MUX_BINPUT_OUT <= MUX_B_INPUT;
	EXE_Zero_out<= Zero_before_reg_2;
	EXE_MUX_ADRESS_OUT <= mux_address_before_reg_2;
	
	---lvl3
	DM_INSTUCTION_out <= instruction_after_reg_2;
	DM_MEM_WRITE  <= MemWrite_after_reg_2;
	DM_WRITE_DATA <= actual_write_data;
	DM_READ_DATA  <= read_data_before_reg_3;
	DM_MEM_ADDRESS	<= ALU_result_after_reg_2 (9 DOWNTO 2) & b"00";
	
	--lvl 4
	WB_INSTUCTION_out <= instruction_after_reg_3;
	WB_REGWRITE	<= RegWrite_after_reg_3;
	WB_JAL_OUT	<= jal_after_reg_3;
	WB_write_data_out <= data_wb;
	
	--hazards
	stall_out <= stall_reg or stall_pc;   --- actually they are the same 
	flash_out <= flush;
	
	---------------------------------------------------------------------------------

   data_wb  	<= read_data_after_reg_3 WHEN MemtoReg_after_reg_3 = '1' ELSE 
				B"0000000000000000000000" &PC_plus_4_after_reg_3 when jal_after_reg_3 ='1' else 
				ALU_result_after_reg_3;
					
  
--------------------- lvl0 -------------------------------------	  
  IFE : Ifetch generic map (address_size )
	PORT MAP (	Instruction 	=> Instruction_before_reg_0,
    	    	PC_plus_4_out 	=> PC_plus_4_before_reg_0,
				Add_result 		=> Add_result,
				jump 			=> jump,
				jr				=> jr,
				jal 			=> jal,
				PCsrc           => PCsrc,
				PC_out 			=> IF_PC_out,  
				IDecode_Sign_extend 	=> Sign_Extend_before_reg_1,	
				read_data_1 	=> read_data_1_before_reg_1,
				stall_pc        => stall_pc,
				clock 			=> clock,  
				reset 			=> reset );


--------------------- lvl0 registers------
reg0_IR      :if_reg generic map (32) port map(clock, reset,flush , stall_reg ,Instruction_before_reg_0,instruction_after_reg_0  );	
reg0_PC_PLUS4: if_reg generic map (10) port map(clock, reset,flush , stall_reg ,PC_plus_4_before_reg_0,PC_plus_4_after_reg_0  );	



   ID : Idecode 
   	PORT MAP (	read_data_1 	=> read_data_1_before_reg_1,
        		read_data_2 	=> read_data_2_before_reg_1,
        		Instruction 	=> instruction_after_reg_0,
        		data_wb			=> data_wb,
				RegWrite 		=> RegWrite_after_reg_3,
				shift			=> ALUop_before_reg_1(2),
				MemtoReg 		=> MemtoReg_after_reg_3,
				Sign_extend 	=> Sign_Extend_before_reg_1,
				PC_plus_4		=> PC_plus_4_after_reg_0,
				jr 				=> jr,
				jal_wb 			=> jal_after_reg_3,
				mux_address		=> mux_address_after_reg_3,
				Branch 			=> Branch_before_reg_1,
				Branch_NE 		=> Branch_NE_before_reg_1,
				PCsrc           => PCsrc,
				Add_Result 		=> ADD_result,
        		clock 			=> clock,  
				reset 			=> reset );


   CTL:   control
	PORT MAP ( 	Opcode 			=> instruction_after_reg_0( 31 DOWNTO 26 ),
				Function_opcode	=> instruction_after_reg_0( 5 DOWNTO 0 ),
				RegDst 			=> RegDst_before_reg_1,
				ALUSrc 			=> ALUSrc_before_reg_1,
				MemtoReg 		=> MemtoReg_before_reg_1,
				RegWrite 		=> RegWrite_before_reg_1,
				MemRead 		=> MemRead_before_reg_1,
				MemWrite 		=> MemWrite_before_reg_1,
				Branch 			=> Branch_before_reg_1,
				Branch_NE 		=> Branch_NE_before_reg_1,
				ALUop 			=> ALUop_before_reg_1,
				jump 			=> jump,
				jr 				=> jr,
				jal 			=> jal,
                clock 			=> clock,
				reset 			=> reset );

--------------------- lvl1 -------------------------------------				
------------------ control vectors--------
EXE_VEC:  EX_control_before_reg_1 <= RegDst_before_reg_1 & ALUSrc_before_reg_1 & ALUOp_before_reg_1 when control_mux = '0' else "00000000000";
Mem_vec:  Mem_control_before_reg_1<= MemRead_before_reg_1 & MemWrite_before_reg_1 & Branch_before_reg_1 & Branch_NE_before_reg_1 when control_mux = '0' else "0000"; 
WB_vec:   WB_control_before_reg_1 <= jal & MemtoReg_before_reg_1 & RegWrite_before_reg_1 when control_mux = '0' else "000";

--------------------- lvl1 registers------			
reg1_rt: REG generic map(5) port map (clock, reset, instruction_after_reg_0(20 downto 16), rt); 
reg1_rd: REG generic map(5) port map (clock, reset, instruction_after_reg_0(15 downto 11), rd); 
reg1_signExtended: REG generic map(32) port map (clock, reset, Sign_Extend_before_reg_1, Sign_Extend_after_reg_1); 
reg1_readData1: REG generic map (32) port map (clock, reset, read_data_1_before_reg_1, read_data_1_after_reg_1);
reg1_readData2: REG generic map (32) port map (clock, reset, read_data_2_before_reg_1, read_data_2_after_reg_1);
reg1_PC_plus_4: REG generic map (10) port map (clock, reset, PC_plus_4_after_reg_0, PC_plus_4_after_reg_1);
reg1_EX_control: REG generic map (11) port map (clock, reset, EX_control_before_reg_1, EX_control_after_reg_1);
reg1_MEM_control: REG generic map (4) port map (clock, reset,Mem_control_before_reg_1,Mem_control_after_reg_1);
reg1_WB_control: REG generic map (3) port map (clock, reset,WB_control_before_reg_1,WB_control_after_reg_1);
reg1_IR      :REG generic map (32) port map(clock, reset ,instruction_after_reg_0,instruction_after_reg_1  );	

--------------- control sig after reg-----
RegDst_after_reg_1<= EX_control_after_reg_1(10);
ALUSrc_after_reg_1<= EX_control_after_reg_1(9);
ALUop_after_reg_1<= EX_control_after_reg_1(8 downto 0);

EXECUTE_REG_WRITE <= WB_control_after_reg_1(0);
EX_MEMREAD <= Mem_control_after_reg_1(3);
EX_MEMwrite <= Mem_control_after_reg_1(2);

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1_after_reg_1,
             	Read_data_2 	=> read_data_2_after_reg_1,
				Sign_extend 	=> Sign_Extend_after_reg_1,
                Function_opcode	=> Sign_Extend_after_reg_1( 5 DOWNTO 0 ),
				ALUOp 			=> ALUop_after_reg_1,
				ALUSrc 			=> ALUSrc_after_reg_1,
				RegDst 			=> RegDst_after_reg_1,
				Zero 			=> Zero_before_reg_2,
                ALU_Result		=> ALU_result_before_reg_2,
				rd              => rd,
				rt				=> rt,
				mux_address		=> mux_address_before_reg_2,
				A_input_mux =>	MUX_A_INPUT,
				B_input_mux => MUX_B_INPUT,
				OPERAND_FROM_MEM=> ALU_result_after_reg_2,
				OPERAND_FROM_WB=> data_wb,
				Ainput_out      =>EXE_AINPUT_OUT,
				Binput_out      =>EXE_BINPUT_OUT,
                Clock			=> clock,
				Reset			=> reset );
				
--------------------- lvl2 -------------------------------------
reg2_WB: REG generic map (3) port map (clock, reset,WB_control_after_reg_1,WB_control_after_reg_2); 						
reg2_MEM: REG generic map (4) port map (clock, reset,Mem_control_after_reg_1,Mem_control_after_reg_2); 	
reg2_ALU_RES: REG generic map (32) port map (clock, reset,ALU_result_before_reg_2, ALU_result_after_reg_2); 
reg2_ZERO: REG generic map (1) port map (clock, reset,zero_vector_before_reg_2 , zero_vector_after_reg_2); 
reg2_WRITE_DATA: REG generic map (32) port map (clock, reset,actual_write_data, write_data_after_reg_2); 
reg2_WRITE_REG: REG generic map (5) port map (clock, reset,mux_address_before_reg_2, mux_address_after_reg_2); 
reg2_IR :REG generic map (32) port map(clock, reset ,instruction_after_reg_1,instruction_after_reg_2  );
reg2_PC_plus_4: REG generic map (10) port map (clock, reset, PC_plus_4_after_reg_1, PC_plus_4_after_reg_2);

--------------------- lvl2 control-------------------------------------
MemRead_after_reg_2<= Mem_control_after_reg_2(3);
MemWrite_after_reg_2<= Mem_control_after_reg_2(2);
Branch_after_reg_2<=   Mem_control_after_reg_2(1);
Branch_NE_after_reg_2<= Mem_control_after_reg_2(0);
zero_vector_before_reg_2(0) <= Zero_before_reg_2;
Zero_after_reg_2 <= zero_vector_after_reg_2(0);

MEM_REG_WRITE <= WB_control_after_reg_2(0);

---- sw forwarding mux in EX level:---
actual_write_data <= ALU_result_after_reg_2 WHEN MUX_SW_INPUT = "01" else
					 data_wb WHEN MUX_SW_INPUT = "10" else
					 read_data_2_after_reg_1 ;
---------------------------

   MEM:  dmemory generic  map (address_size )
	PORT MAP (	read_data 		=> read_data_before_reg_3,
				address 		=> ALU_result_after_reg_2 (9 DOWNTO 2),--jump memory address by 4
				write_data 		=> write_data_after_reg_2,
				MemRead 		=> MemRead_after_reg_2, 
				Memwrite 		=> MemWrite_after_reg_2, 
                clock 			=> clock,  
				reset 			=> reset );
--------------------- lvl3 ---------------------------------------------				
reg3_WB: REG generic map (3) port map (clock, reset,WB_control_after_reg_2,WB_control_after_reg_3); 
reg3_ALU_RES: REG generic map (32) port map (clock, reset,ALU_result_after_reg_2, ALU_result_after_reg_3); 
reg3_WRITE_REG: REG generic map (5) port map (clock, reset,mux_address_after_reg_2, mux_address_after_reg_3); 
reg3_IR :REG generic map (32) port map(clock, reset ,instruction_after_reg_2,instruction_after_reg_3  );
reg3_READ_DATA :REG generic map (32) port map(clock, reset ,read_data_before_reg_3, read_data_after_reg_3  );
reg3_PC_plus_4: REG generic map (10) port map (clock, reset, PC_plus_4_after_reg_2, PC_plus_4_after_reg_3);
--------------------- lvl3 control-------------------------------------
jal_after_reg_3 <= WB_control_after_reg_3(2);
MemtoReg_after_reg_3<= WB_control_after_reg_3(1);
RegWrite_after_reg_3<= WB_control_after_reg_3(0);


-------stalls and forwarding------------------------------------------------------------------------
HAZARD_DEC: hazard_unit PORT MAP(
	instruction_after_reg_0,
	EXECUTE_REG_WRITE,
	MEM_REG_WRITE,
	RegWrite_after_reg_3,
	mux_address_before_reg_2,
	mux_address_after_reg_2,
	mux_address_after_reg_3, 
	EX_MEMREAD, MemRead_before_reg_1 , MemWrite_before_reg_1,
	PCsrc,
	ALUOp_before_reg_1,
	jump,jr,jal,
	stall_pc, stall_reg, flush ,control_mux,
	clock,reset
 );

Forwarding_dec: forwarding_unit
port map( instruction_after_reg_1,
	  MEM_REG_WRITE,
	  RegWrite_after_reg_3,
	  mux_address_after_reg_2,
	  mux_address_after_reg_3, 
	  ALUOp_after_reg_1,
	  MUX_A_INPUT,
	  MUX_B_INPUT,
	  MUX_SW_INPUT,
	  EX_MEMREAD,
	  EX_MEMwrite,
	  clock, reset);

END structure;

