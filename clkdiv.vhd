library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_unsigned.all;

entity clkdiv is
port( 
   mclk : in STD_LOGIC;
	clr  : in STD_LOGIC;
	clkout : out STD_LOGIC);

end clkdiv;

architecture clkdiv of clkdiv is
signal q: STD_LOGIC_VECTOR(23 DOWNTO 0);
begin
-- clock divider
process (mclk,clr)
begin 
   if clr = '1' then 
	   q <= X"000000";
	elsif mclk'event and mclk = '1' then 
	   q <= q+1;
	end if;
end process;

clkout <= q(0);

end clkdiv;