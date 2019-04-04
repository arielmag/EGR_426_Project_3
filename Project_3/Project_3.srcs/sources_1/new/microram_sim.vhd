library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

entity microram_sim is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	);
end entity microram_sim;

architecture a of microram_sim is
type t_mem_data is array(0 to 511) of std_logic_vector(7 downto 0);

-- Your program is entered here, as initialization values for the "mem_data" signal.
signal mem_data : t_mem_data := (0 => "11110000", -- CLR A (dummy first instruction)
                                 1 => "10101000", -- DEB0 A     -- debounce and write to A
                                 2 => "00001000", -- OUT A      -- output A to Outport0
                                 3 => "00000000", -- LOAD 20, A  
                                 4 => x"14",      -- ADDRESS -> 20
	                             5 => "00011000", -- BCD OUT A  
	                             6 => "00000001", -- LOAD 21, B  
	                             7 => x"15",      -- ADDRESS -> 21
	                             8 => "00011001", -- BCD OUT B  
	                           	 9 => "10000000", -- ADD A 
	                             10 => "00011000", -- BCD OUT A
	                             11 => "00000000", -- LOAD 22, A
	                             12 => x"16",      -- ADDRESS -> 22
	                             13 => "11011100", -- CLRB 22, 4
	                             14 => "00000000", -- STOR B TO DO ----------
	                             15 => "00000000", -- 22 TODO ---------------
	                             16 => "00000000", -- placeholder
	                             17 => "00000000", -- placeholder
	                             18 => "00000000", -- placeholder
	                             19 => "00000000", -- placeholder
	                             -- test data ---
	                             20 => "00000111", -- 7
	                             21 => "00000011", -- 3
	                             22 => "00010000", -- 16      
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
