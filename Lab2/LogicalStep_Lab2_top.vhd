library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LogicalStep_Lab2_top is port (
   clkin_50			: in	std_logic;
	pb					: in	std_logic_vector(3 downto 0);
 	sw   				: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds				: out std_logic_vector(7 downto 0); -- for displaying the switch content
   seg7_data 		: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  	: out	std_logic;				    		-- seg7 digit1 selector
	seg7_char2  	: out	std_logic				    		-- seg7 digit2 selector
	
); 
end LogicalStep_Lab2_top;

architecture SimpleCircuit of LogicalStep_Lab2_top is
--
-- Components Used ---
------------------------------------------------------------------- 
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
	
	--
	
	component input_mux port (
			switcher	: in std_logic; --pushbuttons
			sum 		: in std_logic_vector(7 downto 0); 
			full_hex : in std_logic_vector(7 downto 0); 
			output_hex : out std_logic_vector(7 downto 0) 
			
	);
	end component;
	
		
	
-- Create any signals, or temporary variables to be used
--
--  std_logic_vector is a signal which can be used for logic operations such as OR, AND, NOT, XOR
--
	signal seg7_A		: std_logic_vector(6 downto 0); -- first segment display on board
	signal hex_A		: std_logic_vector(3 downto 0); -- first hex digit from switches
	signal seg7_B     : std_logic_vector(6 downto 0); -- second segment display on board
	signal hex_B		: std_logic_vector(7 downto 4); -- second hex digit from switches
	
	--
	
	signal pushButton3 : std_logic;						  -- output of push button three
	signal sum 			: std_logic_vector(7 downto 0); -- the unsigned sum of the two hex values expressed as 8 bits
	signal fullHex    : std_logic_vector(7 downto 0); -- the concatenated version of hexA and hexB
	signal outputHex  : std_logic_vector(7 downto 0); -- the output that should be displayed to the seven segment displays
	
	signal result_A	: std_logic_vector(3 downto 0); -- the result that should display on the first seven segment
	signal result_B	: std_logic_vector(7 downto 4); -- the result that should display on the second seven segment
	
	signal logicResult : std_logic_vector(3 downto 0); -- the 4 bit result of the logical operations between hex_A and hex_B
	signal logicLong 	: std_logic_vector(7 downto 0);	-- the concatenated version of the result (8-bit)
	
	signal outputLED	: std_logic_vector(7 downto 0);  -- the result that should be outputted to the leds
	
	signal tempA		: std_logic_vector(7 downto 0);  -- temporary 8-bit version of hex_A for use in unsigned addition
	signal tempB		: std_logic_vector(7 downto 0);  -- temporary 8-bit version of hex_B for use in unsigned addition
	
	
-- Here the circuit begins

begin

	hex_A <= sw(7 downto 4); 		-- taking in inputs from the switches
	hex_B <= sw(3 downto 0);		-- we made it so that switches 0 to 3 corespond to the right 7-seg and 4 to 7 for the left one
	
	pushButton3 <= pb(3);			-- getting input from push button #3
	
	fullHex <= hex_A & hex_B;		-- concatenate the two hex values for use in the mux (needs to be 8-bit)
	
	tempA <= "0000" & hex_A;		-- concatenate zeros to make it 8-bit in order to add
	tempB <= "0000" & hex_B;
	sum <= std_logic_vector(unsigned(tempA) + unsigned(tempB)); -- add hexA and hexB in order to get a sum then cast it as an 8-bit signal
	
	with pb select 										-- change logical result base on the values of the push buttons
	logicResult <= hex_A AND hex_B when "1110",  -- if push button #0 is pressed then perform an AND between hexA and hexB
					   hex_A OR hex_B when "1101",   -- if push button #1 is pressed then perform an OR between hexA and hexB
						hex_A XOR hex_B when "1011",  -- if push button #2 is pressed then perform an xOR between hexA and hexB
						"0000" when others;				-- default
						
	logicLong <= "0000" & logicResult;		-- concatenate zeros to make it 8-bit for use in mux
	
	INST5: input_mux port map(pb(3), sum, logicLong, outputLED);  --new mux component, will output the sum if push button three is pressed, else the logical result chosen
	
	leds <= outputLED;			--display result of sum to leds
	
	INST4: input_mux port map(pb(3), sum, fullHex, outputHex); --new mux component, will output the sum if push button three is pressed, else the two hex digits (A, B)
	
	result_A <= outputHex(7 downto 4); -- take the first set of 4-bits (represnting the first number)
	result_B <= outputHex(3 downto 0); -- take the second set of 4-bits (representing the second number)
	
	INST1: SevenSegment port map(result_A, seg7_A); 				-- display the first set of 4-bits of result to segment A
	INST2: SevenSegment port map(result_B, seg7_B); 				-- display the second set of 4-bits of result to segment B
	INST3: segment7_mux port map(clkin_50, seg7_A, seg7_B, seg7_data, seg7_char1, seg7_char2); 
 
end SimpleCircuit;

