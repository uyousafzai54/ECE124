library ieee; 
use ieee.std_logic_1164.all; 

entity input_mux is 
port(

	switcher	: in std_logic; 							
	desired		: in std_logic_vector(3 downto 0); 	
	current 		: in std_logic_vector(3 downto 0);  
	output_hex : out std_logic_vector(3 downto 0)
); 

end entity input_mux;

architecture mux_logic of input_mux is 

begin 

with switcher select 						
	output_hex <= current when '0',		
					  desired when '1';   
					  
	
end mux_logic;
	
	