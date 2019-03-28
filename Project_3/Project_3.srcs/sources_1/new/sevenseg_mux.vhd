library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sevenseg_mux is
    Port (left_seg, right_seg: in STD_LOGIC_VECTOR(6 downto 0);
          clk,reset : in STD_LOGIC;
          anode_out : out STD_LOGIC_VECTOR(3 downto 0);
          seg_out : out STD_LOGIC_VECTOR(6 downto 0));
end sevenseg_mux;

architecture Behavioral of sevenseg_mux is
signal seg_select : STD_LOGIC := '0';

begin

process(clk)
begin
    if(rising_edge(clk)) then
        if(seg_select = '0') then
            Anode_out <= "1101"; 
            seg_out <= left_seg;
        else
            Anode_out <= "1110";
            seg_out <= right_seg; 
        end if;
        
        seg_select <= not seg_select;
    end if;
end process;

end Behavioral;
