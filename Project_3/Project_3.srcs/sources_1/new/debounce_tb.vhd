library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

entity debounce_tb is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	);
end entity debounce_tb;

architecture a of debounce_tb is
type t_mem_data is array(0 to 511) of std_logic_vector(7 downto 0);

-- Your program is entered here, as initialization values for the "mem_data" signal.
signal mem_data : t_mem_data := (0 => "11110000", -- CLR A (dummy first instruction)
                                 1 => "00000000", -- LOAD 12, A
                                 2 => "00001100", -- 0x0C
                                 3 => "00001000", -- OUT A, 0
                                 4 => "10101000", -- DEB0 A            -- Expecting 1    
                                 5 => "00001000", -- OUT A, 0
                                 
                                 6 => "11110001", -- CLR B (dummy first instruction)
                                 7 => "00000001", -- LOAD 13, B
                                 8 => "00001101", -- 0x0D
                                 9 => "00001011", -- OUT B, 1
                                 10 => "10101011", -- DEB1 B            -- Expecting 0    
                                 11 => "00001011", -- OUT B, 1
                                 -- MEM ---------------
                                 12 => "00000111", -- 7
                                 13 => "01000000", -- 64
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