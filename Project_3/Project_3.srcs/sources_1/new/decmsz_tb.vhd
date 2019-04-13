library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

entity decmsz_tb is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	);
end entity decmsz_tb;

architecture a of decmsz_tb is
type t_mem_data is array(0 to 511) of std_logic_vector(7 downto 0);

-- Your program is entered here, as initialization values for the "mem_data" signal.
signal mem_data : t_mem_data := (0 => "11110000", -- CLR A (dummy first instruction)
                                 1 => "00000000", -- LOAD 14, A
                                 2 => "00001110", -- 0x0E
                                 3 => "00011000", -- BCD0 A       
                                 4 => "11111000", -- DECMSZ M
                                 5 => "00001110", -- 0x0E
                                 6 => "00000000", -- LOAD 14, A
                                 7 => "00001110", -- 0x0E
                                 8 => "00011000", -- BCD0 A
                                 9 => "11111000", -- DECMSZ M
                                 10 => "00001110", -- 0x0E
                                 11 => "00000000", -- LOAD 14, A
                                 12 => "00001110", -- 0x0E
	                             13 => "00011000", -- BCD0 A
	                             
	                             -- test data --
	                             14 => "00000010", -- 0x02
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