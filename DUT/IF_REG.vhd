library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity if_reg is
generic(size: integer:= 16);
port( 
	  clk,reset : in std_logic;
	  flush     : in std_logic;
	  stall      : in std_logic;
	  input:in std_logic_vector(size-1 downto 0);
	  output:out std_logic_vector(size-1 downto 0)
);
end if_reg;
--------------------------------------------------------------
architecture if_reg_arc of if_reg is
signal data: std_logic_vector(size-1 downto 0);    -- Writing to register
begin			   
  process(clk, reset)
	begin
		if (reset  = '1') then
			data <= CONV_STD_LOGIC_VECTOR( 0, size );
		elsif (clk'event and clk='1') then
				if(flush = '1') then
					data <= CONV_STD_LOGIC_VECTOR( 0, size );
				elsif(stall = '0') then
					data <= input;
				end if;
		end if;
	end process;
	


output <= data;                                     -- reading from register

end if_reg_arc;
