library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Debounce_Switch is
  generic (
    DEBOUNCE_LIMIT : integer := 250000);
  port (
    i_Clk    : in  std_logic;
    i_Switch : in  std_logic;
    o_Switch : out std_logic
    );
end entity Debounce_Switch;

architecture RTL of Debounce_Switch is

  signal r_Debounce_Count : integer range 0 to DEBOUNCE_LIMIT := 0;

  signal r_Switch_State : std_logic;

begin

  p_Debounce : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then

      -- Switch input is different than internal switch value, so an input is
      -- changing.  Increase the counter until it is stable for 10 ms.
      if (i_Switch /= r_Switch_State and
          r_Debounce_Count < DEBOUNCE_LIMIT) then
        r_Debounce_Count <= r_Debounce_Count + 1;

      -- End of counter reached, switch input is stable, register it.
      elsif r_Debounce_Count = DEBOUNCE_LIMIT then
        r_Switch_State <= i_Switch;
        
      -- Switches are the same state, reset the counter
      else
        r_Debounce_Count <= 0;

      end if;
    end if;
  end process p_Debounce;


  -- Assign internal register to output (debounced!)
  o_Switch <= r_Switch_State;


end architecture rtl;