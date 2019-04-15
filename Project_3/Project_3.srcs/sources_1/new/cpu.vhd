library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

LIBRARY IEEE;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity cpu is
PORT(clk, clk_100Mhz : in STD_LOGIC;
    reset : in STD_LOGIC;
    Inport0, Inport1 : in STD_LOGIC_VECTOR(7 downto 0);
    Outport0, Outport1	: out STD_LOGIC_VECTOR(7 downto 0);
    Anode_out : out STD_LOGIC_VECTOR (3 downto 0);
    Seg_out : out STD_LOGIC_VECTOR (6 downto 0)
	 );
end cpu;

architecture a of cpu is
-- ----------- Declare the ALU component ----------
component alu is
port(A, B : in SIGNED(7 downto 0);
        F : in STD_LOGIC_VECTOR(2 downto 0);
        Y : out SIGNED(7 downto 0);
    N,V,Z : out STD_LOGIC);
end component;
-- ------------ Declare signals interfacing to ALU -------------
signal ALU_A, ALU_B : SIGNED(7 downto 0);
signal ALU_FUNC : STD_LOGIC_VECTOR(2 downto 0);
signal ALU_OUT : SIGNED(7 downto 0);
signal ALU_N, ALU_V, ALU_Z : STD_LOGIC;

-- ------------ Declare Clear-Bit Component --------------------
component Clear_bit is
    port(
            CLK : in STD_LOGIC;
            BitX : in STD_LOGIC_VECTOR(2 downto 0);     -- bit to clear
            MemIn : in STD_LOGIC_VECTOR(7 downto 0);    -- memory data
            MemOut : out STD_LOGIC_VECTOR(7 downto 0)   -- result
        );
end component;

-- ------------ Declare signals for clear-bit component --------
signal bitToClear : STD_LOGIC_VECTOR(2 downto 0);
signal memData : STD_LOGIC_VECTOR(7 downto 0);
signal bitCleared : STD_LOGIC_VECTOR(7 downto 0);

-- ------------ Declare Seven-Segment BCD Component -------------
component bcd_sevenseg is
    Port (LED_Number : in STD_LOGIC_VECTOR(3 downto 0);
          Seg_out : out STD_LOGIC_VECTOR (6 downto 0));
end component;


-- ------------ Declare signals interfacing to Seven-Segment BCD -------------

-- ------------ Declare Clock Divider Component -------------
component clk_divider is
    Port (clk,reset : in STD_LOGIC; clkout : out STD_LOGIC);
end component;

-- ------------ Declare Seven-Segment MUX Component -------------
component sevenseg_mux is
    Port (left_seg, right_seg: in STD_LOGIC_VECTOR(6 downto 0);
          clk,reset : in STD_LOGIC;
          anode_out : out STD_LOGIC_VECTOR(3 downto 0);
          seg_out : out STD_LOGIC_VECTOR(6 downto 0));
end component;

-- ------------ Declare the 512x8 RAM component --------------
--component microram is
--port (  CLOCK   : in STD_LOGIC ;
--		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
--		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
--		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
--		WE	: in STD_LOGIC 
--	 );
--end component;

component bcd_tb is
port (  CLOCK   : in STD_LOGIC ;
		ADDRESS	: in STD_LOGIC_VECTOR (8 downto 0);
		DATAOUT : out STD_LOGIC_VECTOR (7 downto 0);
		DATAIN  : in STD_LOGIC_VECTOR (7 downto 0);
		WE	: in STD_LOGIC 
	 );
end component;
-- ---------- Declare signals interfacing to RAM ---------------
signal RAM_DATA_OUT : STD_LOGIC_VECTOR(7 downto 0);  -- DATAOUT output of RAM
signal ADDR : STD_LOGIC_VECTOR(8 downto 0);	         -- ADDRESS input of RAM
signal RAM_WE : STD_LOGIC;

-- ---------- Declare the state names and state variable -------------
type STATE_TYPE is (Fetch, Operand, Memory, Execute, Memory2, Execute2);
signal CurrState : STATE_TYPE;
-- ---------- Declare the internal CPU registers -------------------
signal PC : UNSIGNED(8 downto 0);
signal IR : STD_LOGIC_VECTOR(7 downto 0);
signal MDR : STD_LOGIC_VECTOR(7 downto 0);
	
signal A,B : SIGNED(7 downto 0);
signal N,Z,V : STD_LOGIC;
-- ---------- Declare the common data bus ------------------
signal DATA : STD_LOGIC_VECTOR(7 downto 0);

-- -----------------------------------------------------
-- This function returns TRUE if the given op code is a
-- 4-phase instruction rather than a 2-phase instruction
-- -----------------------------------------------------	
function Is4Phase(constant DATA : STD_LOGIC_VECTOR(7 downto 0)) return BOOLEAN is
variable MSB5 : STD_LOGIC_VECTOR(4 downto 0);
variable RETVAL : BOOLEAN;
begin
  MSB5 := DATA(7 downto 3);
  if(MSB5 = "00000") then
	 RETVAL := true;
  else
	 RETVAL := false;
  end if;
 return RETVAL;
end function;

-- -----------------------------------------------------
-- This function returns TRUE if the given op code is a
-- 6-phase instruction
-- -----------------------------------------------------	
function Is6Phase(constant DATA : STD_LOGIC_VECTOR(7 downto 0)) return BOOLEAN is
variable MSB5 : STD_LOGIC_VECTOR(4 downto 0);
variable RETVAL : BOOLEAN;
begin
  MSB5 := DATA(7 downto 3);
  if(MSB5 = "01101") or (MSB5 = "01101") or (MSB5 = "11111") then
	 RETVAL := true;
  else
	 RETVAL := false;
  end if;
 return RETVAL;
end function;

	
-- --------- Declare variables that indicate which registers are to be written --------
-- --------- from the DATA bus at the start of the next Fetch cycle. ------------------
signal Exc_RegWrite : STD_LOGIC;        -- Latch data bus in A or B
signal Exc_CCWrite : STD_LOGIC;         -- Latch ALU status bits in CCR
signal Exc_IOWrite : STD_LOGIC;         -- Latch data bus in I/O
signal Exc_BCDWrite : STD_LOGIC;         -- Latch data bus in BCD
signal Exc_CLRBit : STD_LOGIC;          -- Latch data bus in ClrBit
signal Exc_SkipIns : STD_LOGIC;

signal clk_divide : STD_LOGIC;
signal left_seg, right_seg : STD_LOGIC_VECTOR (6 downto 0);
signal left_data, right_data : STD_LOGIC_VECTOR (3 downto 0);

-- ---------- flag ----------
signal flag6 : STD_LOGIC := '0';            -- flag for if it is 6 phase or not
signal memFlag : STD_LOGIC := '0';          -- flag for execute again or not
--signal exCount : integer := 0;              -- counts number of executes gone through

-- ---------- DEB -----------
constant COUNT_MAX : integer := 3;          -- 3 sec
signal COUNT0 : integer := COUNT_MAX;       -- current count on 0 bit
signal COUNT1 : integer := COUNT_MAX;       -- current count on 1 bit


begin
-- ------------ Instantiate the Seven-Segment BCD Component -------------
BCD1 : bcd_sevenseg PORT MAP (LED_Number => left_data, Seg_out => left_seg);
BCD2 : bcd_sevenseg PORT MAP (LED_Number => right_data, Seg_out => right_seg);

MUX1: sevenseg_mux PORT MAP (left_seg => left_seg, right_seg => right_seg, clk => clk_divide, 
    reset => reset, anode_out => anode_out, seg_out => seg_out);

C1: clk_divider PORT MAP (clk => clk_100Mhz, reset => reset, clkout => clk_divide);

-- ------------ Instantiate Clear Bit component -------------
CLRB : clear_bit PORT MAP (CLK => CLK, BITX => IR(2 downto 0), MemIn => DATA(7 downto 0), MemOut => bitCleared);
    
-- ------------ Instantiate the ALU component ---------------
U1 : alu PORT MAP (ALU_A, ALU_B, ALU_FUNC, ALU_OUT, ALU_N, ALU_V, ALU_Z);
			
-- ------------ Drive the ALU_FUNC input ----------------
ALU_FUNC <= IR(6 downto 4);
	
-- ------------ Instantiate the RAM component -------------
--U2 : microram PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

U2 : bcd_tb PORT MAP (CLOCK => clk, ADDRESS => ADDR, DATAOUT => RAM_DATA_OUT, DATAIN => DATA, WE => RAM_WE);

-- ---------------- Generate RAM write enable ---------------------
-- The address and data are presented to the RAM during the Memory phase, 
-- hence this is when we need to set RAM_WE high.
process (CurrState,IR)
begin
  -- STOR or CLRB second memory access
  if ((CurrState = Memory and IR(7 downto 2) = "000001") or (IR(7 downto 3) = "01101" and CurrState = Memory2) or
        (IR(7 downto 3) = "11111" and CurrState = Memory2)) then
	  RAM_WE <= '1';
  else
	  RAM_WE <= '0';
  end if;
end process;
	
-- ---------------- Generate address bus --------------------------
with CurrState select
	 ADDR <= STD_LOGIC_VECTOR(PC) when Fetch,
			 STD_LOGIC_VECTOR(PC) when Operand,  -- really a don't care
			 IR(1) & MDR when Memory,
			 STD_LOGIC_VECTOR(PC) when Execute,
			 IR(1) & MDR when Memory2,
			 STD_LOGIC_VECTOR(PC) when Execute2,
			 STD_LOGIC_VECTOR(PC) when others;   -- just to be safe
				
-- --------------------------------------------------------------------
-- This is the next-state logic for the 4-phase state machine.
-- --------------------------------------------------------------------
process (clk,reset)
variable temp : integer;
begin
  if(reset = '1') then
	 CurrState <= Fetch;
	 PC <= (others => '0');
	 IR <= (others => '0');
	 MDR <= (others => '0');
	 A <= X"01";
	 B <= (others => '0');
	 N <= '0';
	 Z <= '0';
	 V <= '0';
	 Outport0 <= (others => '0');
	 Outport1 <= (others => '0');
	 temp := 0;
	 left_data <= (others => '0');
	 right_data <= (others => '0');
  elsif(rising_edge(clk)) then
	 case CurrState is
		  when Fetch => IR <= DATA;
		                if (Exc_SkipIns = '1') then
		                  if (Is4Phase(DATA) or Is6Phase(DATA)) then
		                      PC <= PC + 2;
		                      temp := temp + 2;
		                  else
		                      PC <= PC + 1;
		                      temp := temp + 1;
		                  end if;
		                  CurrState <= Fetch;
		                elsif(Is4Phase(DATA)) then
						   PC <= PC + 1;
						   temp := temp + 1;
						   CurrState <= Operand;
						elsif(Is6Phase(DATA)) then
						   PC <= PC + 1;
						   temp := temp + 1;
						   CurrState <= Operand;
						   flag6 <= '1';
					    else
						   CurrState <= Execute;
					    end if;

		 when Operand => MDR <= DATA;
					     CurrState <= Memory;

		 when Memory => CurrState <= Execute;
		 
		 when Memory2 => CurrState <= Execute2;
		 
		 when Execute2 => if(temp = 2) then 
                              PC <= "000000010";
                           else
                              PC <= PC + 1;
                              temp := temp +1;
                           end if;
                           
                           CurrState <= Fetch;
                           
                           if(Exc_CCWrite = '1') then    -- Updating flag bits
                               V <= ALU_V;
                               N <= ALU_N;
                               Z <= ALU_Z;
                           end if;                           
					
		 when Execute =>    
					     if (flag6 = '1') then     -- if 6 phase go to mem state
					       CurrState <= Memory2;
					       flag6 <= '0';
					     else
                             if(temp = 2) then 
                                 PC <= "000000010";
                              else
                                 PC <= PC + 1;
                                 temp := temp +1;
                              end if;
					       CurrState <= Fetch;
					     end if;
					
					     if(Exc_RegWrite = '1') then   -- Writing result to A or B
                            if(IR(0) = '0') then
                               A <= SIGNED(DATA);
                            else
                               B <= SIGNED(DATA);
                            end if;
					     end if;
					
					     if(Exc_CCWrite = '1') then    -- Updating flag bits
                            V <= ALU_V;
                            N <= ALU_N;
                            Z <= ALU_Z;
					     end if;

					     if(Exc_IOWrite = '1') then    -- Write to Outport0 or OutPort1
						    if(IR(1) = '0') then
							   Outport0 <= DATA;
						    else
							   Outport1 <= DATA;
						    end if;
					     end if;
					     
					     if(Exc_BCDWrite = '1') then   -- Write to Outport0 and OutPort1 and display on seven segment
                               left_data <= DATA(7 downto 4);
                               right_data <= DATA(3 downto 0);
                         end if;
                         
                         if (Exc_ClrBit = '1') then -- Clear bit
                            A <= SIGNED(bitCleared);        -- data out read into A
                         end if;
                         
					
			when Others => CurrState <= Fetch;
		end case;
	end if;
end process;
	
process (CurrState,RAM_DATA_OUT,A,B,ALU_OUT,Inport0,Inport1,IR) 
begin
-- Set these to 0 in each phase unless overridden, just so we don't
-- generate latches (which are unnecessary).
Exc_RegWrite <= '0';
Exc_CCWrite <= '0';
Exc_IOWrite <= '0';
Exc_BCDWrite <= '0';
Exc_ClrBit <= '0';

-- Same idea
ALU_A <= A;
ALU_B <= B;

-- Same idea
DATA <= RAM_DATA_OUT;

case CurrState is
	 when Fetch | Operand =>
	                       Exc_SkipIns <= '0';
	                       DATA <= RAM_DATA_OUT;
						
	 when Memory | Memory2 => if(IR(0) = '0') then
					   DATA <= STD_LOGIC_VECTOR(A);
				    else
					   DATA <= STD_LOGIC_VECTOR(B);
				    end if;
	
	 when Execute2 => case IR(7 downto 1) is
	                      when "0110100" | "0110101" | "0110110" | "0110111" =>
                              --DATA <= "10101010";
                              Exc_CCWrite <= '1';             -- update flags accordingly
                              DATA <= STD_LOGIC_VECTOR(A);    -- STOR A
                          when "1111100" =>
                              if (DATA = "00000000") then
                                Exc_SkipIns <= '1';
                              else
                                Exc_SkipIns <= '0';
                              end if;
                          when others => null;
                          end case;
				
	 when Execute => case IR(7 downto 1) is
					      when "1000000" 			-- ADD R
						     | "1001000"			-- SUB R
						     | "1100000"			-- XOR R
						     | "1111000" =>			-- CLR R
						        DATA <= STD_LOGIC_VECTOR(ALU_OUT);
						        Exc_RegWrite <= '1';
                                Exc_CCWrite <= '1';
						
					      when "1010000"			-- LSL R
						     | "1011000"			-- LSR R
						     | "1101000"			-- COM R
						     | "1110000" =>			-- NEG R
						        if(IR(0) = '0') then
						 	       ALU_A <= A;
						        else
						 	       ALU_A <= B;
						        end if;
						        DATA <= STD_LOGIC_VECTOR(ALU_OUT);
						        Exc_RegWrite <= '1';
						        Exc_CCWrite <= '1';

					      when "0000100"|"0000101" =>          -- OUT R,P
						        if(IR(0) = '0') then
							       DATA <= STD_LOGIC_VECTOR(A);
						        else
							       DATA <= STD_LOGIC_VECTOR(B);
						        end if;
						        Exc_IOWrite <= '1';
						
					      when "0001100" =>          -- BCD R,P
                                if(IR(0) = '0') then
                                    DATA <= STD_LOGIC_VECTOR(A);
                                else
                                    DATA <= STD_LOGIC_VECTOR(B);
                                end if;
                                Exc_BCDWrite <= '1';
                          						
					      when "0000110"|"0000111" =>	         -- IN P,R
						        if(IR(1) = '0') then
							       DATA <= Inport0;
						        else
							       DATA <= Inport1;
						        end if;
						        Exc_RegWrite <= '1';
						
					      when "0000000"|"0000001" =>          -- LOAD M,R
						        DATA <= RAM_DATA_OUT;         -- mem in location
						        Exc_RegWrite <= '1';
						
					      when "0000010"|"0000011" =>	       -- STOR R,M
                                if(IR(0) = '0') then
                                      DATA <= STD_LOGIC_VECTOR(A);
                                  else
                                      DATA <= STD_LOGIC_VECTOR(B);
                                  end if;
                                
                            -- opcode 01101XXX
                          when "0110100" | "0110101" | "0110110" | "0110111" => -- CLR Bit
                            if (memFlag = '0') then
                                DATA <= RAM_DATA_OUT;
                                Exc_ClrBit <= '1';                  
                            end if;
                            
                          when "1111100" =>                         -- DECMSZ
                            if (memFlag = '0') then
                                DATA <= SIGNED(RAM_DATA_OUT) - 1;
                                Exc_RegWrite <= '1';                -- write it to A
                            end if;
                          							
                          when "1010100" | "1010101" =>        -- DEB R, M
                            if IR(1) = '0' and COUNT0 = 0 then
                              DATA <= "00000001";
                            elsif IR(1) = '1' and COUNT1 = 0 then
                              DATA <= "00000001";
                            else
                              DATA <= "00000000";
                            end if;
                            Exc_RegWrite <= '1';
								
								
					      when others => null;
				    end case;
		end case;	
end process;

-- for debounce --
process(CLK, RESET)
begin
    if RESET = '1' then
        COUNT0 <= COUNT_MAX;
        COUNT1 <= COUNT_MAX;
    elsif rising_edge(CLK) then
        -- debounce bit 0
        if Inport0(0) = '1' then
            COUNT0 <= COUNT_MAX;
        else
            if COUNT0 = 0 then
                COUNT0 <= 0;
            else
                COUNT0 <= COUNT0 - 1;
            end if;
        end if;
        
        -- debounce bit 1
        if Inport0(1) = '1' then
            COUNT1 <= COUNT_MAX;
        else
            if COUNT1 = 0 then
                COUNT1 <= 0;
            else
                COUNT1 <= COUNT1 - 1;
            end if;
        end if;
   end if;
end process;


end a;
