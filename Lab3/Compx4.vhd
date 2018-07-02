library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity Compx4 is
   port (
          A          : in  std_logic_vector(3 downto 0); --first four bit number 
			 B    		: in  std_logic_vector(3 downto 0);	-- second four bit number
			 Greater		: out	std_logic; --Possible States
			 Equal 		: out std_logic;
			 Lesser		: out	std_logic
        );
end entity Compx4;

architecture Comparison of Compx4 is 

component Compx1 port (
		    A          : in  std_logic; 
			 B    		: in  std_logic;
			 Greater		: out	std_logic; 
			 Equal 		: out std_logic;
			 Lesser		: out	std_logic
			
	);
	end component;
	
	signal E		: std_logic_vector(3 downto 0); --Equal to state (for each seperate bit)
	signal G 	: std_logic_vector(3 downto 0); -- Greater than state (for each seperate bit)
	signal L		: std_logic_vector(3 downto 0); -- Less than state (for each seperate bit)
	
begin 

   INST1: Compx1 port map(A(3), B(3), G(3), E(3), L(3)); -- initiating the four one bit comparators 
	INST2: Compx1 port map(A(2), B(2), G(2), E(2), L(2));
	INST3: Compx1 port map(A(1), B(1), G(1), E(1), L(1));
	INST4: Compx1 port map(A(0), B(0), G(0), E(0), L(0));

	Equal <= E(3) AND E(2) AND E(1) AND E(0);                                                             --logic behind all of the comparisons
   Greater <= G(3) OR (E(3) AND G(2)) OR (E(3) AND E(2) AND G(1)) OR (E(3) AND E(2) AND E(1) AND G(0));
	Lesser <= L(3) OR (E(3) AND L(2)) OR (E(3) AND E(2) AND L(1)) OR (E(3) AND E(2) AND E(1) AND L(0));	
						  
	
end Comparison;
	
	
	
	