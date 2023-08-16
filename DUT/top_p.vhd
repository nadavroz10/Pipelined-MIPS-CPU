LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE work.AUX_package.all;
----------------------------------------------------
--------------------------------------------------------------------------
			--!!!!!!!!!!!!!!!!!!!!!!!!!!!--
					--REMINDER--
			-- GENERIC MAP 0 FOR MODELSIM
			-- GENERIC MAP 2 FOR QUARTUS

--------------------------------------------------------------------------
ENTITY top_p IS
port (
		BPADD     : in std_logic_vector(7 downto 0);
		reset,clock : in std_logic;
		CLKCNT    : OUT std_logic_vector(15 downto 0);
		STCNT, FHCNT   : OUT std_logic_vector(7 downto 0);
		ST_TRIGGER	   : OUT std_logic;
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
		WB_JAL_OUT							: OUT 	STD_LOGIC
		-------------------------------------------------
);
END top_p;

architecture top_p_arch of top_p is
component MIPS IS
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
END 	component;
signal stall, flush, st: std_logic;
signal IF_PC, BREAKPOINT : std_logic_vector(9 downto 0);
begin
BREAKPOINT <= BPADD & "00";

process(clock, IF_PC, reset)
--variable trigged : std_logic := '0';
begin
  IF (reset = '1') then
	st <= '0';
	ST_TRIGGER <= '0';
  elsIF (clock'event and clock='1') then
		
	IF (IF_PC = BREAKPOINT and (IF_pc /= "0000000000")) then
		st <= '1';
		ST_TRIGGER <= '1';
		end if;
	end if;

end process;

process(clock )
variable clk_cnt: std_logic_vector(15 downto 0) :="0000000000000000";
begin
	IF (clock'event and clock='1' and st ='0') then
		clk_cnt := CONV_STD_LOGIC_VECTOR( conv_integer(unsigned(clk_cnt)) + 1, 16 );
	end if;
	CLKCNT <= clk_cnt;
end process;

process(clock, stall)

variable  stall_cnt: std_logic_vector(7 downto 0) :="00000000";
begin
IF (clock'event and clock='1') then
	IF (stall = '1' and st ='0' ) then
		stall_cnt  :=   CONV_STD_LOGIC_VECTOR( conv_integer(unsigned(stall_cnt)) + 1, 8 );
	end if;
end if;
	STCNT <= stall_cnt;
end process;

process(clock, flush)
variable flushcnt: std_logic_vector(7 downto 0) :="00000000";
begin
IF (clock'event and clock='1') then
	IF (flush = '1' and st ='0' ) then
		flushcnt  :=  CONV_STD_LOGIC_VECTOR(conv_integer(unsigned(flushcnt)) + 1, 8 );
	end if;
end if;
	FHCNT <= flushcnt; 
end process;


mips_cpu: MIPS generic map(0) port map( reset, clock,
		-- Output important signals 
		--------- pipeline lvl0   IF---------
		IF_PC,								
		IF_INSTUCTION_out,
		IF_PC_SRC_OUT,
		--------- pipeline lvl1   ID---------
		ID_INSTUCTION_out,
		ID_read_data_1_out,
		ID_read_data_2_out,
		ID_write_data_out,
		ID_SIGN_EXT_OUT,
		ID_Regwrite_out,
		--------- pipeline lvl2   EXE---------
		EXE_INSTUCTION_out,
		EXE_ALU_result_out,
		EXE_AINPUT_OUT,
		EXE_BINPUT_OUT,
		EXE_MUX_AINPUT_OUT,
		EXE_MUX_BINPUT_OUT,
		EXE_Zero_out,
		EXE_MUX_ADRESS_OUT,
		--------- pipeline lvl3   DMEM---------
		DM_INSTUCTION_out,
		DM_MEM_WRITE,
		DM_WRITE_DATA,
		DM_READ_DATA,
		DM_MEM_ADDRESS,
		
		--------- pipeline lvl4   WB---------
		WB_INSTUCTION_out,WB_write_data_out,
		WB_REGWRITE,
		WB_JAL_OUT,
		stall, flush);
		
	IF_PC_out <= IF_PC;
end top_p_arch;