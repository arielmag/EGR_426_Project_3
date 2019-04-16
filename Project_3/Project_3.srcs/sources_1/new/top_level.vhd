----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/15/2019 06:12:54 PM
-- Design Name: 
-- Module Name: top_level - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_level is
    port(
            clk, clk_100Mhz : in STD_LOGIC;
            reset : in STD_LOGIC;
            Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
            Outport0, Outport1    : out STD_LOGIC_VECTOR(7 downto 0);
            Anode_out : out STD_LOGIC_VECTOR (3 downto 0);
            Seg_out : out STD_LOGIC_VECTOR (6 downto 0)
        );
end top_level;

architecture Behavioral of top_level is

component cpu is
PORT(clk, clk_100Mhz : in STD_LOGIC;
    reset : in STD_LOGIC;
    Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
    Outport0, Outport1	: out STD_LOGIC_VECTOR(7 downto 0);
    Anode_out : out STD_LOGIC_VECTOR (3 downto 0);
    Seg_out : out STD_LOGIC_VECTOR (6 downto 0)
	 );
end component;

begin

U1 : cpu port map (CLK => CLK, CLK_100Mhz => CLK_100Mhz, RESET => RESET,
                    Inport0 => Inport0, Inport1 => Inport1, Outport0 => Outport0,
                        Anode_out => Anode_out, Seg_out => Seg_out);

end Behavioral;
