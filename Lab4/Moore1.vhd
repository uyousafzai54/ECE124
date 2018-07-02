library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Moore1 IS Port
(
 clk_input, rst_n, Extender_Enable, Toggle							: IN std_logic;
 Extender_Out, Shift_Enable, Grappler_Enable, Up					: OUT std_logic
 );
END ENTITY;
 

 Architecture SM of Moore1 is
 

 
 TYPE STATE_NAMES IS (Start, Retracted, Extending1, Extending2, Extending3, Fully_Extended, Retracting3, Retracting2, Retracting1, Post); -- all the states
 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES


  BEGIN
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= Start;  --Initial State should always be Start
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS

Transition_Section: PROCESS (Extender_Enable, Toggle, current_state) 

BEGIN
     CASE current_state IS
         WHEN Start =>													-- Next State is retracted if extender enable is true and push button is pressed else stay in Start 
				IF(Toggle = '1' AND Extender_Enable = '1') THEN
					next_state <= Retracted;
				ELSE
					next_state <= Start;
				END IF; 
				
			When Retracted => 
				next_state <= Extending1; 
				
         WHEN Extending1 =>		
					next_state <= Extending2;

         WHEN Extending2 =>		
				next_state <= Extending3;
								
         WHEN Extending3 =>		
				next_state <= Fully_Extended;

         WHEN Fully_Extended =>									--Next State is Retracting3 if pushbutton is pressed and extender enable is true			
				IF (Toggle = '1' AND Extender_Enable = '1') THEN
					next_state <= Retracting3; 
				ELSE 	
					next_state <= Fully_Extended; 
				END IF;	
					
			WHEN Retracting3 =>		
					next_state <= Retracting2;
					
		   WHEN Retracting2 =>		
					next_state <= Retracting1;
					
		   WHEN Retracting1 =>		
					next_state <= Post;
					
			WHEN POST =>    
				next_state <= Start; 

     		END CASE;
 END PROCESS;

-- DECODER SECTION PROCESS

Decoder_Section: PROCESS (Extender_Enable, Toggle, current_state) 

BEGIN
     CASE current_state IS
	  
        WHEN Start =>				--Don't change posotions in start state 	
			Shift_Enable <= '0'; 
			Grappler_Enable <= '0'; 
			Extender_Out <= '0';
			Up <= '1';
		
			When Retracted => 		--Begin counting up
			Shift_Enable <= '1'; 
		   Grappler_Enable <= '0'; 
		   Extender_Out <= '1';
			Up <= '1'; 
			
        WHEN Extending1 =>		
		   Shift_Enable <= '1'; 
		   Grappler_Enable <= '0'; 
		   Extender_Out <= '1';
			Up <= '1';  	

        WHEN Extending2 =>		
			Shift_Enable <= '1';  
			Grappler_Enable <= '0'; 
			Extender_Out <= '1'; 
		  	Up <= '1';  
								
        WHEN Extending3 =>		
			Shift_Enable <= '1';  
			Grappler_Enable <= '0'; 
			Extender_Out <= '1'; 
		  	Up <= '1';  

        WHEN Fully_Extended =>		--Stop counting when fully extended
			Shift_Enable <= '0'; 
			Grappler_Enable <= '1'; 
			Extender_Out <=  '1'; 
		  	Up <= '0';  
					
		 WHEN Retracting3 =>				--Start counting down
			Shift_Enable <= '1'; 
			Grappler_Enable <= '0'; 
			Extender_Out <= '1'; 
		  	Up <= '0';  
					
		  WHEN Retracting2 =>		
			Shift_Enable <= '1'; 
			Grappler_Enable <= '0'; 
			Extender_Out <= '1';
		 	Up <= '0';   
				
		   WHEN Retracting1 =>		
			Shift_Enable <= '1'; 
			Grappler_Enable <= '0'; 
			Extender_Out <= '1'; 	
		 	Up <= '0';   
			
			WHEN Post => 				
			Shift_Enable <= '1'; 
			Grappler_Enable <= '0'; 
			Extender_Out <= '0'; 	
		 	Up <= '0'; 

	  END CASE;
 END PROCESS;

 END ARCHITECTURE SM;
