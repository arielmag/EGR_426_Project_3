library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Clear_bit is
    port(
            CLK : in STD_LOGIC;
            BitX : in STD_LOGIC_VECTOR(2 downto 0);     -- bit to clear
            MemIn : in STD_LOGIC_VECTOR(7 downto 0);    -- memory data
            MemOut : out STD_LOGIC_VECTOR(7 downto 0)   -- result
        );
end Clear_bit;

architecture Behavioral of Clear_bit is

signal toAnd : STD_LOGIC_VECTOR(7 downto 0);
signal tmp : STD_LOGIC_VECTOR(7 downto 0);

begin

process(BitX, MemIn, CLK)
begin
        case BitX is
            when "000" => toAnd <= "11111110";
            when "001" => toAnd <= "11111101";
            when "010" => toAnd <= "11111011";
            when "011" => toAnd <= "11110111";
            when "100" => toAnd <= "11101111";
            when "101" => toAnd <= "11011111";
            when "110" => toAnd <= "10111111";
            when "111" => toAnd <= "01111111";
            when others => toAnd <= "11111111";
        end case;
end process;

process (toAnd, MemIn, CLK) is
begin
    for I in 7 downto 0 loop
        tmp(I) <= toAnd(I) and MemIn(I);
    end loop;
    MemOut <= tmp;
end process;

end Behavioral;
