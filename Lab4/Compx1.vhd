library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Compx1 is
   port (
          A          : in  std_logic; -- first one bit number
			 B    		: in  std_logic; -- second one bit number
			 Greater		: out	std_logic; -- possible states
			 Equal 		: out std_logic;
			 Lesser		: out	std_logic
        );
end entity Compx1;

architecture Comparison of Compx1 is 

begin 

	Equal <= NOt (A XOR B); -- logic behind comparisons
   Lesser <= (NOT A) AND B;
   Greater <= A AND (Not B); 
						  
	
end Comparison;
	
	