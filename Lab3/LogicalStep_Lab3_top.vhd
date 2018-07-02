library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LogicalStep_Lab3_top is port (
   clkin_50		: in	std_logic;
	pb				: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	
); 
end LogicalStep_Lab3_top;

architecture Energy_Monitor of LogicalStep_Lab3_top is
--
-- Components Used
------------------------------------------------------------------- 
component Compx4 port (
          A          : in  std_logic_vector(3 downto 0); 
			 B    		: in  std_logic_vector(3 downto 0);	
			 Greater		: out	std_logic;
			 Equal 		: out std_logic;
			 Lesser		: out	std_logic
			
	);
	end component;
		
component SevenSegment port (
   hex   		:  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   sevenseg 	:  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
   ); 
   end component;

	component segment7_mux port (
		clk 		: in std_logic := '0';
		DIN2		: in std_logic_vector(6 downto 0);
		DIN1		: in std_logic_vector(6 downto 0);
		DOUT		: out std_logic_vector(6 downto 0);
	   DIG2		: out std_logic;
		DIG1		: out std_logic
	);
	end component;
	
------------------------------------------------------------------
	
	
-- Create any signals, or temporary variables to be used

   signal seg7_A	 	: std_logic_vector(6 downto 0); -- right digit, current temp
	signal seg7_B     : std_logic_vector(6 downto 0); -- left digit, desired temp
	signal cur_grtr   : std_logic; -- current is greater than desired
	signal cur_equa   : std_logic; -- current is equal to desired
	signal cur_less   : std_logic; -- current is less than desired
	signal AC         : std_logic; -- State A/C
	signal FUR        : std_logic; -- State Furance 
	signal SYS        : std_logic; -- State System
	signal BLOW       : std_logic; -- State Blower ON
	
	
-- Here the circuit begins

begin
 
   INST1: Compx4 port map(sw(3 downto 0), sw(7 downto 4), cur_grtr, cur_equa, cur_less); -- comparing desired and current temps
 
   INST2: SevenSegment port map(sw(3 downto 0), seg7_A); 				-- display the current temp
	INST3: SevenSegment port map(sw(7 downto 4), seg7_B); 				-- display the  desired temp
	INST4: segment7_mux port map(clkin_50, seg7_A, seg7_B, seg7_data, seg7_char2, seg7_char1); 
 
 
   leds(4) <= Not pb(0); --Backdoor open
	leds(5) <= Not pb(1); -- window(s) open
	leds(6) <= Not pb(2); -- Frontdoor open
	
	AC <= cur_grtr AND pb(0) AND pb(1) AND pb(2); -- if all of the doors and windows are closed, and the current is greater than desired
	FUR <= cur_less AND pb(0) AND pb(1) AND pb(2); -- if all of the doors and windows are closed, and the current is less than desired
   SYS <= cur_equa;                               --System at temp if temps are equal
	BLOW <= pb(0) AND pb(1) AND pb(2) AND (cur_grtr OR cur_less); --IF A/C is on or Furance is on and all the window(s) are closed 
	
	leds(3) <= BLOW; --send signals to appropriate leds 
	leds(2) <= AC; 
	leds(1) <= SYS; 
	leds(0) <= FUR;
	
	
end Energy_Monitor;



