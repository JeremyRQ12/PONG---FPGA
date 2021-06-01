LIBRARY IEEE;
USE ieee.std_logic_1164.all;
-------------------------------------------------------------------------
ENTITY Convertidor IS
	GENERIC(MAX_WIDTH	:			INTEGER :=	4);
	PORT( 	Bin  : IN 	integer;
				Sseg : OUT  STD_LOGIC_VECTOR((2*MAX_WIDTH)-2 DOWNTO 0));
END ENTITY;
--------------------------------------------------------------------------
ARCHITECTURE Behaviour OF Convertidor IS
--------------------------------------------------------------------------
BEGIN 
		Sseg <=   "1000000" WHEN Bin = 0 ELSE
				    "1111001" WHEN Bin = 1 ELSE
				    "0100100" WHEN Bin = 2 ELSE
				    "0110000" WHEN Bin = 3 ELSE
				    "0011001" WHEN Bin = 4 ELSE
				    "0010010" WHEN Bin = 5 ELSE
				    "0000010" WHEN Bin = 6 ELSE
				    "1111000" WHEN Bin = 7 ELSE
				    "0000000" WHEN Bin = 8 ELSE
				    "0010000" WHEN Bin = 9 ELSE
				    "0111111" WHEN Bin = 10 ELSE
				    "1111111" WHEN Bin = 11 ELSE
				    "0000110";
END ARCHITECTURE Behaviour;
