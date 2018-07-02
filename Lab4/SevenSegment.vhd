library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------
-- 7-segment display driver. It displays a 4-bit number on a 7-segment
-- This is created as an entity so that it can be reused many times easily
--

entity SevenSegment is port (
   
   hex	         :  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   clk, flash 		:  in std_logic; 
   sevenseg       :  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
); 
end SevenSegment;

architecture Behavioral of SevenSegment is

-- 
-- The following statements convert a 4-bit input, called dataIn to a pattern of 7 bits
-- The segment turns on when it is '1' otherwise '0'
--

signal blinker 		 : std_logic_vector(6 downto 0); --"filter"
signal sevenseghelper : std_logic_vector(6 downto 0); --intended output 
signal flash_notclock : std_logic; 							--conditon to flash digits in error state 
begin
		
	flash_notclock <= flash AND (NOT clk);  	--Determine if we should flash screen or not
	 
	WITH flash_notclock Select 				--Determine filter 
		blinker <= "0000000" when '1',
					  "1111111" when others; 
	

   with hex select						     --GFEDCBA        3210      -- data in   
	sevenseghelper 				    			   <= "0111111" when "0000",    -- [0]
										 "0000110" when "0001",    -- [1]
										 "1011011" when "0010",    -- [2]      +---- a -----+
										 "1001111" when "0011",    -- [3]      |            |
										 "1100110" when "0100",    -- [4]      |            |
										 "1101101" when "0101",    -- [5]      f            b
										 "1111101" when "0110",    -- [6]      |            |
										 "0000111" when "0111",    -- [7]      |            |
										 "1111111" when "1000",    -- [8]      +---- g -----+
										 "1100111" when "1001",    -- [9]      |            |
										 "1110111" when "1010",    -- [A]      |            |
										 "1111100" when "1011",    -- [b]      e            c
										 "1011000" when "1100",    -- [c]      |            |
										 "1011110" when "1101",    -- [d]      |            |
										 "1111001" when "1110",    -- [E]      +---- d -----+
										 "1110001" when "1111",    -- [F]
										 "0000000" when others;    -- [ ]

										--Apply filter by anding each bit with the intended output with each bit of blinker 
										
										sevenseg(0) <= blinker(0) AND sevenseghelper(0);	
										sevenseg(1) <= blinker(1) AND sevenseghelper(1);
										sevenseg(2) <= blinker(2) AND sevenseghelper(2);
										sevenseg(3) <= blinker(3) AND sevenseghelper(3);
										sevenseg(4) <= blinker(4) AND sevenseghelper(4);
										sevenseg(5) <= blinker(5) AND sevenseghelper(5);
										sevenseg(6) <= blinker(6) AND sevenseghelper(6);
																				 
end architecture Behavioral; 
----------------------------------------------------------------------
