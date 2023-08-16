library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.AUX_package.all;
--------------------------------------------------------------

entity forwarding_unit is
port( 
signal EX_instruction  : in std_logic_vector(31 downto 0);
signal  DM_regw, WB_regw : in std_logic;
signal  DM_muxAdress, WB_muxAdress : in	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal ALUop 		: in 	STD_LOGIC_VECTOR( ALU_OP_SIZE -1 DOWNTO 0 ); --EXE
signal MUX_A_INPUT,MUX_B_INPUT : out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
signal SW_MUX  : out STD_LOGIC_VECTOR( 1 DOWNTO 0 );
signal EX_MEMread , EX_MEMwrite : in std_logic;
signal clock, reset	: IN 	STD_LOGIC );
end forwarding_unit;

architecture forwarding_arc of forwarding_unit is
signal EX_rs, EX_rt : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal Rtype, IMM,shift, sw_lw, EX_addi : STD_LOGIC;
signal RAW_A_Mem, RAW_A_WB,RAW_B_Mem,RAW_B_WB, RAW_SW_Mem , RAW_SW_WB: STD_LOGIC;

begin

EX_addi <= '1' when EX_instruction(31 DOWNTO 26) = "001000" else '0';
EX_rs <= EX_instruction(25 DOWNTO 21);
EX_rt <= EX_instruction(20 DOWNTO 16);
shift <= ALUop(2);
Rtype <= ALUop(1) and not(shift);
sw_lw  <=  '1'  WHEN  (EX_MEMread or EX_MEMwrite)='1'  ELSE '0';
IMM <= '1' when ( ALUop(7) OR ALUop(5) OR ALUop(4) OR ALUop(3) or EX_addi) = '1' else '0';


process (IMM, Rtype, shift, DM_regw,WB_regw, DM_muxAdress,WB_muxAdress, EX_rs,EX_rt,sw_lw )---PROCESS AINPUT
begin
	IF((Rtype or IMM or sw_lw) = '1') then
		if (DM_regw ='1' AND DM_muxAdress = EX_rs) THEN 
			RAW_A_Mem <='1';
			RAW_A_WB <='0';
		ELSIF (WB_regw ='1' AND WB_muxAdress = EX_rs) THEN 
			RAW_A_Mem <='0';
			RAW_A_WB <='1';
		ELSE
			RAW_A_Mem <='0';
			RAW_A_WB <='0';
		END IF;
	elsif (shift = '1') then
		if (DM_regw ='1' AND DM_muxAdress = EX_rt) THEN 
			RAW_A_Mem <='1';
			RAW_A_WB <='0';
		ELSIF (WB_regw ='1' AND WB_muxAdress = EX_rt) THEN 
			RAW_A_Mem <='0';
			RAW_A_WB <='1';
		ELSE  
			RAW_A_Mem <='0';
			RAW_A_WB <='0';
		END IF;
	ELSE  
		RAW_A_Mem <='0';
		RAW_A_WB <='0';
	END IF;  

END process;

process (Rtype, DM_regw,WB_regw, DM_muxAdress,WB_muxAdress , EX_rt )---PROCESS BINPUT
begin
	IF( Rtype = '1') then
		if (DM_regw ='1' AND DM_muxAdress=EX_rt) THEN 
			RAW_B_Mem<='1';
			RAW_B_WB<='0';
		ELSIF (WB_regw ='1' AND WB_muxAdress=EX_rt) THEN 
			RAW_B_WB<='1';
			RAW_B_Mem<='0';
		ELSE 
			RAW_B_WB<='0';
			RAW_B_Mem<='0';
		END IF;
	ELSE
		RAW_B_Mem<='0';
		RAW_B_WB<='0';
	END IF; 

END process;


process (EX_MEMwrite, EX_rt, DM_regw, DM_muxAdress, WB_regw, WB_muxAdress)---PROCESS SW RAW----
begin
	IF( EX_MEMwrite = '1') then
		if (DM_regw ='1' AND DM_muxAdress=EX_rt) THEN 
			RAW_SW_Mem<='1';
			RAW_SW_WB<='0';
		ELSIF (WB_regw ='1' AND WB_muxAdress=EX_rt) THEN 
			RAW_SW_WB<='1';
			RAW_SW_Mem<='0';
		ELSE 
			RAW_SW_WB<='0';
			RAW_SW_Mem<='0';
		END IF;
	ELSE
		RAW_SW_WB<='0';
		RAW_SW_Mem<='0';
	END IF; 

END process;

MUX_B_INPUT <= "01" WHEN RAW_B_Mem='1' ELSE
		"10" WHEN RAW_B_WB='1' ELSE
		"00";
MUX_A_INPUT <= "01" WHEN RAW_A_Mem='1' ELSE
		"10" WHEN RAW_A_WB='1' ELSE
		"00";
SW_MUX <= "01" WHEN RAW_SW_Mem='1' ELSE
		"10" WHEN RAW_SW_WB='1' ELSE
		"00";

end forwarding_arc;