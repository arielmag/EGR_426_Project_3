library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity clk_divider is
    Port (clk,reset : in STD_LOGIC; clkout : out STD_LOGIC);
end clk_divider;

architecture Behavioral of clk_divider is

signal count: STD_LOGIC_VECTOR(27 downto 0) := x"0000000";
signal temp: STD_LOGIC := '0';

begin

process(clk,reset)
begin 
    if(reset='1') then
        count <= (others => '0');
        temp <= '0';
    elsif(rising_edge(clk)) then
    
        if(count >= x"186A0") then
            count <= (others => '0');
            temp <= '1';
        else
            count <= count + 1;
            temp <= '0';
        end if;
    end if;
end process;

clkout <= temp;

end Behavioral;
