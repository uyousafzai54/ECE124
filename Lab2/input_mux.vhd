library ieee; 
use ieee.std_logic_1164.all; 

entity input_mux is 
port(

	switcher	: in std_logic; 							-- determines whether or not the sum is outputted
	sum 		: in std_logic_vector(7 downto 0); 	-- the sum signal passed in
	full_hex : in std_logic_vector(7 downto 0);  -- the hex digits chosen by user passed in (concatenated)
	output_hex : out std_logic_vector(7 downto 0) -- the output that was chosen based on value of "switcher"
); 

end entity input_mux;

architecture sum_logic of input_mux is 

begin 

with switcher select 						
	output_hex <= sum when '0',			-- output the sum if push button is pressed (0)
					  full_hex when '1';    -- output the hex digits that were chosen by user if push button is not pressed (1)
					  
	
end sum_logic;
	
	