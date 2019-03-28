library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_sevenseg is
    Port (LED_Number : in STD_LOGIC_VECTOR(3 downto 0);
          Seg_out : out STD_LOGIC_VECTOR (6 downto 0));
end bcd_sevenseg;

architecture Behavioral of bcd_sevenseg is

begin

process(LED_Number)
begin
    case LED_Number is
    when "0000" => Seg_out <= "0000001"; -- 0     
    when "0001" => Seg_out <= "1001111"; -- 1 
    when "0010" => Seg_out <= "0010010"; -- 2 
    when "0011" => Seg_out <= "0000110"; -- 3 
    when "0100" => Seg_out <= "1001100"; -- 4 
    when "0101" => Seg_out <= "0100100"; -- 5 
    when "0110" => Seg_out <= "0100000"; -- 6 
    when "0111" => Seg_out <= "0001111"; -- 7 
    when "1000" => Seg_out <= "0000000"; -- 8     
    when "1001" => Seg_out <= "0000100"; -- 9
    when others => Seg_out <= "1111110"; -- -
    end case;
end process;

end Behavioral;
