library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE work.AUX_package.all;
--------------------------------------------------------------

entity hazard_unit is
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
end hazard_unit;

architecture hazard_arc of hazard_unit is
signal ID_rs, ID_rt : STD_LOGIC_VECTOR( 4 DOWNTO 0 );
signal Rtype, IMM,shift, sw_lw, branches : STD_LOGIC;
signal RAW_B, RAW_LW, nop : STD_LOGIC;

begin
nop <= '1' when ID_instruction = CONV_STD_LOGIC_VECTOR( 0, 32 ) else '0';
ID_rs <= ID_instruction(25 DOWNTO 21);
ID_rt <= ID_instruction(20 DOWNTO 16);
Rtype <= ALUop(1);
shift <= ALUop(2);
branches <= ALUop(0);
sw_lw  <=  '1'  WHEN  (ID_memread or ID_memwrite) = '1'  ELSE '0';
IMM <= '1' when ( ALUop(7) OR ALUop(5) OR ALUop(4) OR ALUop(3)) = '1' else '0';
flush <= '1' when ((pcSRC or jal or jr or jump) = '1') and (RAW_B = '0') else '0';

process(jr, branches, EX_regw , EX_muxAdress, DM_regw, DM_muxAdress)
begin
if (jr = '1') then 
	if ( EX_regw ='1' and (EX_muxAdress = ID_rs)) THEN 
		RAW_B <='1';
	ELSIF ( DM_regw ='1' and (DM_muxAdress = ID_rs)) THEN 
		RAW_B <='1';
	ELSE  
		RAW_B <='0';
		
	END IF;
ELSIF (branches='1' ) then
	if ( EX_regw ='1' and (EX_muxAdress = ID_rs OR EX_muxAdress=ID_rt)) THEN 
		RAW_B <='1';
	ELSIF ( DM_regw ='1' and (DM_muxAdress = ID_rs OR DM_muxAdress=ID_rt)) THEN 
		RAW_B <='1';
	ELSE  
		RAW_B <='0';
	END IF;
ELSE  
	RAW_B <='0';
END IF;

END process;

process (EX_memread, IMM, Rtype, shift, EX_regw, EX_muxAdress )
begin
if (EX_memread ='1') then 
	IF( Rtype = '1') then
		if ( EX_regw ='1' and (EX_muxAdress = ID_rs OR EX_muxAdress=ID_rt)) THEN 
		RAW_LW <='1';
		ELSE  
		RAW_LW <='0';
		END IF;
	elsif ((IMM or sw_lw)= '1') then
		if ( EX_regw ='1' and (EX_muxAdress = ID_rs)) THEN 
		RAW_LW <='1';
		ELSE  
		RAW_LW <='0';
		END IF;
	elsif (shift = '1') then
		if ( EX_regw ='1' and (EX_muxAdress = ID_rt)) THEN 
		RAW_LW <='1';
		ELSE  
		RAW_LW <='0';
		END IF;
	ELSE  
		RAW_LW <='0';
	END IF; 
ELSE  
	RAW_LW <='0';
END IF; 

END process;




stall_pc <= RAW_B OR RAW_LW;
stall_reg <= RAW_B OR RAW_LW;
control_mux<= RAW_LW or nop;

end hazard_arc;