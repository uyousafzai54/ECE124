library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Moore2 IS Port
(
 clk_input, rst_n, Grappler_Enable, Toggle							: IN std_logic;
 isClosed																		: OUT std_logic
 );
END ENTITY;
 

 Architecture SM of Moore2 is
 

 
 TYPE STATE_NAMES IS (Opened, Closed);   -- all STATE_NAMES 

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


  BEGIN
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= Opened;  --Initial state is Opened
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	

-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (Grappler_Enable, Toggle, current_state) 

BEGIN
     CASE current_state IS
			WHEN Opened =>													--If pushbutton is pressed and grappler enabled next state is closed, else opened 
				IF(Toggle = '1' AND Grappler_Enable = '1') THEN
					next_state <= Closed;
				ELSE
					next_state <= Opened;
				END IF; 
				
			When Closed => 												--If pushbutton is pressed and grappler enabled next state is opened, else closed
				IF(Toggle = '1' AND Grappler_Enable = '1') THEN
					next_state <= Opened;
				ELSE
					next_state <= Closed;
				END IF; 

     		END CASE;
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (Grappler_Enable, Toggle, current_state) 

BEGIN
     CASE current_state IS
	  
        WHEN opened =>		
			isClosed <= '0'; 	
		
			When Closed => 
			isClosed <= '1'; 

	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
