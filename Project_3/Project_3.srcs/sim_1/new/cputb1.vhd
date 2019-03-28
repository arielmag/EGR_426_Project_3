library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
entity cputb1 is
end cputb1;
 
architecture behavior of cputb1 is 
-- Component Declaration for the Unit Under Test (UUT)
component cpu
    PORT(
        clk, clk_100Mhz : in STD_LOGIC;
        reset : in STD_LOGIC;
        Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
        Outport0, Outport1    : out STD_LOGIC_VECTOR(7 downto 0);
        Anode_out : out STD_LOGIC_VECTOR (3 downto 0);
        Seg_out : out STD_LOGIC_VECTOR (6 downto 0)
        );
end component;

--Inputs
signal clk : std_logic := '0';
signal clk_100Mhz : std_logic := '0';
signal reset : std_logic := '1';
signal Inport0 : std_logic_vector(7 downto 0) := (others => '0');
signal Inport1 : std_logic_vector(7 downto 0) := (others => '0');

--Outputs
signal Outport0 : std_logic_vector(7 downto 0);
signal Outport1 : std_logic_vector(7 downto 0);
signal Anode_out : STD_LOGIC_VECTOR (3 downto 0);
signal Seg_out : STD_LOGIC_VECTOR (6 downto 0);

-- Clock period definitions
constant clk_period : time := 10ns;

constant clk_100Mhz_period : time := 5ns;
 
begin
-- Instantiate the Unit Under Test (UUT)
C1 : cpu PORT MAP (clk => clk, clk_100Mhz => clk_100Mhz, reset => reset, Inport0 => Inport0, Inport1 => Inport1,
                   Outport0 => Outport0, Outport1 => Outport1, Anode_out => Anode_out, Seg_out => Seg_out);

-- Clock process 
clk_process : process begin
              clk <= '0'; wait for clk_period/2;
		      clk <= '1'; wait for clk_period/2;
              end process;

-- Clock process 
clk_100Mhz_process : process begin
              clk_100Mhz <= '0'; wait for clk_100Mhz_period/2;
		      clk_100Mhz <= '1'; wait for clk_100Mhz_period/2;
              end process;

-- Stimulus process
stim_proc : process begin		
            wait for 100ns;     -- hold reset state for 100ns.
            reset <= '0';
            wait;
            end process;

end;
