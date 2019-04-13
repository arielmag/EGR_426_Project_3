library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

entity clear_bit_tb is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	);
end entity clear_bit_tb;

architecture a of clear_bit_tb is
type t_mem_data is array(0 to 511) of std_logic_vector(7 downto 0);

-- Your program is entered here, as initialization values for the "mem_data" signal.
signal mem_data : t_mem_data := (0 => "11110000", -- CLR A (dummy first instruction)
                                 1 => "00000000", -- LOAD 9,A  
                                 2 => x"09",      -- ADDRESS -> 9
	                             3 => "00001000", -- OUT A  
	                             4 => "01101100", -- CLRB, 4 9  
	                             5 => x"09",      -- ADDRESS -> 9
	                             6 => "00000001", -- LOAD 9, B  
	                           	 7 => x"09",       -- ADDRESS -> 9
	                             8 => "00001001", -- OUT B         
	                    	 -- test data --
                                9 => "11111111", -- memory location 9 set to 7
                            others => "11110000"); -- all other memory locations set to CLR A instr

begin
RAM_Process : process(CLOCK)
variable memaddr : INTEGER range 0 to 511;
begin
  if(rising_edge(CLOCK)) then
     memaddr := CONV_INTEGER(ADDRESS);
     if(we='1') then
        mem_data(memaddr) <= DATAIN;
        DATAOUT <= DATAIN;
     else
        DATAOUT <= mem_data(memaddr);
     end if;
  end if;
end process;

end architecture a;
