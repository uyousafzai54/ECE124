
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50		: in	std_logic;
	rst_n			: in	std_logic;
	pb				: in	std_logic_vector(3 downto 0);
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the switch content
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
	
----------------------------------------------------------------------------------------------------
	CONSTANT	SIM							:  boolean := FALSE; 	-- set to TRUE for simulation runs otherwise keep at 0.
   CONSTANT CLK_DIV_SIZE				: 	INTEGER := 24;    -- size of vectors for the counters

   SIGNAL 	Main_CLK						:  STD_LOGIC; 			-- main clock to drive sequencing of State Machine

	SIGNAL 	bin_counter					:  UNSIGNED(CLK_DIV_SIZE-1 downto 0); -- := to_unsigned(0,CLK_DIV_SIZE); -- reset binary counter to zero
	
----------------------------------------------------------------------------------------------------

component Bidir_shift_reg port (
      CLK 					: in std_logic := '0'; 
		RESET_n 		      : in std_logic := '0'; 
		CLK_EN				: in std_logic := '0'; 
		LEFT0_RIGHT1		: in std_logic := '0'; 
		REG_BITS 			: out std_logic_vector(3 downto 0)
			
	);
	end component;

component Bin_Counter4bit port (
		Main_clk				: in std_logic := '0';
		rst_n 		      : in std_logic := '0'; 
		clk_en				: in std_logic := '0'; 
		up1_down0			: in std_logic := '0'; 
		counter_bits 		: out std_logic_vector(3 downto 0)
	);
	end component;
	
component Compx4 port (
          A          : in  std_logic_vector(3 downto 0); 
			 B    		: in  std_logic_vector(3 downto 0);	
			 Greater		: out	std_logic;
			 Equal 		: out std_logic;
			 Lesser		: out	std_logic
			
	);
	end component;
		
component SevenSegment port (
   hex	   		:  in  std_logic_vector(3 downto 0);   -- The 4 bit data to be displayed
   clk, flash 		:  in std_logic; 
   sevenseg			:  out std_logic_vector(6 downto 0)    -- 7-bit outputs to a 7-segment
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

component input_mux is port(

	switcher	 : in std_logic; 							
	desired		: in std_logic_vector(3 downto 0); 	
	current 		: in std_logic_vector(3 downto 0);  
	output_hex : out std_logic_vector(3 downto 0) 
); 
end component;	
	
component Mealy_SM port
(
 clk_input, rst_n, X_Press, Y_Press, X_EQ, X_GT, X_LT, Y_EQ, Y_GT, Y_LT, ExtenderOut						   : IN std_logic;
 Error, Extender_Enable, XCount_Up, XCount_Enable, YCount_Up, YCount_Enable		: OUT std_logic
 );
end component;

component Moore1 port
(
 clk_input, rst_n, Extender_Enable, Toggle							: IN std_logic;
 Extender_Out, Shift_Enable, Grappler_Enable, Up          		: OUT std_logic
 );
end component;

component Moore2 port
(
 clk_input, rst_n, Grappler_Enable, Toggle							: IN std_logic;
 isClosed																		: OUT std_logic
 );
end component;
 
	
	signal curposX : std_logic_vector(3 downto 0); --Current X Position
	signal curposY : std_logic_vector(3 downto 0); --Current Y Position
	signal x_eq, x_gt, x_lt  : std_logic; 			  -- Comparator results in X, ex. x_gt means desired is greater than current position    
	signal y_eq, y_gt, y_lt  : std_logic; 			  -- Comparator results in Y, ex. y_gt means desired is greater than current position
	signal extenderpos : std_logic_vector(3 downto 0); -- Extender Position	
	signal extend_out : std_logic;                     --Extender Out 
	signal extend_enable : std_logic;						--Signal that enables extender 
	signal xcountUp, ycountUp : std_logic;					-- Whether or not to increase/decrease x/y position
	signal xcountEN, ycountEN : std_logic;					-- enable counter 
	signal shiftEN, grapplerEN, shiftUp : std_logic;	--signals for the grappler and extender 	
	
	
	signal desposX : std_logic_vector(3 downto 0);		--Desired X Position
	signal desposY : std_logic_vector(3 downto 0);		--Desired Y Position
		
	signal outX : std_logic_vector(3 downto 0);			--Seg 7 display for X
	signal outY : std_logic_vector(3 downto 0);			--Seg 7 display for Y
	
	signal seg7_A	 	: std_logic_vector(6 downto 0); -- right digit
	signal seg7_B     : std_logic_vector(6 downto 0); -- left digit
	
	signal ERROR 		: std_logic;  						  -- Error State 
	
	
	 
BEGIN

INST1: Mealy_SM port map(Main_clk, rst_n, pb(3), pb(2), x_eq, x_gt, x_lt, y_eq, y_gt, y_lt, extend_out, ERROR,extend_enable,xcountUp, xcountEN, ycountUp, ycountEN);
INST2: Moore1 port map(Main_clk, rst_n, extend_enable, not pb(1), extend_out, shiftEN, grapplerEN, shiftUp);
INST3: Compx4 port map(desposX, curposX, x_gt, x_eq, x_lt);
INST4: Compx4 port map(desposY, curposY, y_gt, y_eq, y_lt);
INST5: Bin_Counter4bit port map(Main_clk, rst_n, xcountEN, xcountUp, curposX);
INST6: Bin_Counter4bit port map(Main_clk, rst_n, ycountEN, ycountUp, curposY);
INST7: Bidir_shift_reg port map(Main_clk, rst_n, shiftEN, shiftUp, extenderPos);

desposX <= sw(7 downto 4); 
desposY <= sw(3 downto 0);

INST8: SevenSegment port map(outX, Main_clk, ERROR, seg7_A); 		
INST9: SevenSegment port map(outY, Main_clk, ERROR, seg7_B); 				

INST10: input_mux port map (pb(3), desposX, curposX, outX);
INST11: input_mux port map (pb(2), desposY, curposY, outY);

INST12: segment7_mux port map(clkin_50, seg7_A, seg7_B, seg7_data, seg7_char1, seg7_char2);

leds(7 downto 4) <= extenderpos;
leds(0) <= ERROR; 
leds(2) <= x_eq; 
leds(1) <= y_eq; 

INST13: Moore2 port map(Main_clk, rst_n, grapplerEN, Not pb(0), leds(3));
 
-- CLOCKING GENERATOR WHICH DIVIDES THE INPUT CLOCK DOWN TO A LOWER FREQUENCY

BinCLK: PROCESS(clkin_50, rst_n) is
   BEGIN
		IF (rising_edge(clkin_50)) THEN -- binary counter increments on rising clock edge
         bin_counter <= bin_counter + 1;
      END IF;
   END PROCESS;

Clock_Source:
				Main_Clk <= 
				clkin_50 when sim = TRUE else				-- for simulations only
				std_logic(bin_counter(23));								-- for real FPGA operation
					
---------------------------------------------------------------------------------------------------

END SimpleCircuit;
