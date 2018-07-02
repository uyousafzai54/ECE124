library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity Mealy_SM IS Port
(
 clk_input, rst_n, X_Press, Y_Press, X_EQ, X_GT, X_LT, Y_EQ, Y_GT, Y_LT, ExtenderOut						   : IN std_logic;
 Error, Extender_Enable, XCount_Up, XCount_Enable, YCount_Up, YCount_Enable										: OUT std_logic
 );
END ENTITY;
 

 Architecture SM of Mealy_SM is
 

 
 TYPE STATE_NAMES IS (Not_moving, Moving, Extender_Out, Error_State);   -- list all the potential states 

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES
 SIGNAL X_Motion, Y_Motion				: std_logic;			-- Signals to determine whether or not we are moving in the x and/or y direction 
 
 
 BEGIN
	
	X_Motion <= (NOT X_Press) AND (NOT X_EQ);
	Y_Motion <= (NOT Y_Press) AND (NOT Y_EQ);
 
 --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS:
 
Register_Section: PROCESS (clk_input, rst_n, next_state)  -- this process synchronizes the activity to a clock
BEGIN
	IF (rst_n = '0') THEN
		current_state <= Not_moving; --Inital state is not moving
	ELSIF(rising_edge(clk_input)) THEN
		current_state <= next_State;
	END IF;
END PROCESS;


Transition_Section: PROCESS (X_Motion, Y_Motion, X_EQ, X_GT, X_LT, Y_EQ, Y_GT, Y_LT, ExtenderOut, current_state) 

BEGIN
     CASE current_state IS
         WHEN Not_moving =>										--When in Not_moving, next state is Not_moving if no x and y motion is present, goes to
				IF(ExtenderOut = '1') THEN							-- Extender_Out if extender is out, else goes to Moving		
					next_state <= Extender_Out; 
				ELsIF(X_Motion ='0' AND Y_Motion = '0' AND ExtenderOut = '0') THEN
					next_state <= Not_moving; 
				ELSE
					next_state <= Moving; 
				End if; 		
			
         WHEN Moving =>		
				IF(ExtenderOut = '1') THEN							 --When in Moving next state is Not_moving if no x and y motion is present, if extender is out goes to
					next_state <= Error_State; 					 --Error_State else stays in Moving
				ELsIF(X_Motion ='0' AND Y_Motion = '0' AND ExtenderOut = '0') THEN
					next_state <= Not_moving; 
				ELSE
					next_state <= Moving; 
				End if; 	

         WHEN Extender_Out =>										 --When in Extender_Out, stay in Extender_Out if we are not moving and extender is still out, go to   
				IF(ExtenderOut = '1' AND X_Motion = '0' AND Y_Motion = '0') THEN --Not_Moving if extender is no longer out and not moving, go to Moving if extender is 
					next_state <= Extender_Out; 												--out and moving in x or y, else Error_State 
				ELsIF(X_Motion ='0' AND Y_Motion = '0' AND ExtenderOut = '0') THEN
					next_state <= Not_moving; 
				ELSIF((X_MOTION = '1' OR Y_Motion = '1')	AND ExtenderOut = '0') Then 
					next_state <= Moving; 
				ELSE
					next_state <= Error_State; 
				End if; 	
			WHEN Error_State =>										--When in Error_State, stay in Error_State if extender is out, go to Not_moving if no motion in x and 	
				IF(ExtenderOut = '1') THEN							--y direction and extender is not out, else go to moving
					next_state <= Error_State; 
				ELsIF(X_Motion ='0' AND Y_Motion = '0' AND ExtenderOut = '0') THEN
					next_state <= Not_moving; 
				ELSE 
					next_state <= Moving; 
				END IF; 
 		END CASE;
 END PROCESS;
 
 
 Decoder_Section: PROCESS (X_Motion, Y_Motion, X_EQ, X_GT, X_LT, Y_EQ, Y_GT, Y_LT, ExtenderOut, current_state) 

BEGIN
	  CASE current_state IS
         WHEN Not_moving =>						--In Not_moving, there can never be an error, we look to see if we need to extender based on x and y position and  	
			Error <= '0';								-- count up/down/don't count based on x and y postion 
			Extender_Enable <= (X_EQ AND Y_EQ) ;
			XCount_Up <= X_GT;  
			XCount_Enable <= '0';
			
			YCount_Up <= Y_GT;  
			YCount_Enable <= '0'; 
			
         WHEN Moving =>								
			Error <= ExtenderOut; 					--In moving, there is an error if extender is out, and do not enable extender if moving  
			Extender_Enable <= (NOT X_Motion) AND (NOT Y_Motion) AND (NOT ExtenderOut) AND X_EQ AND Y_EQ;
			XCount_Up <= X_GT;  
			XCount_Enable <= Not X_EQ; 		
			
			YCount_Up <= Y_GT;  
			YCount_Enable <= NOT Y_EQ;
			
         WHEN Extender_Out =>		            --In Extender_Out if attempt to move while the extender is out, extender is always enabled when the extender is out
			Error <= (X_MOTION OR Y_Motion)	AND ExtenderOut;
			Extender_Enable <='1';
			
			XCount_Up <= '0';   
			XCount_Enable <= '0'; 
			
			YCount_Up <= '0';  
			YCount_Enable <= '0';
			
			WHEN Error_State =>  				-- All counting disabled when in Error_State and there will be an error as long as the extender is out 
			Error <= ExtenderOut; 
			Extender_Enable <= '1';
			
			XCount_Up <= '0';   
			XCount_Enable <= '0'; 
			
			YCount_Up <= '0'; 
			YCount_Enable <= '0';
			
	 END CASE;
 END PROCESS;

 END ARCHITECTURE SM;