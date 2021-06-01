 -- This module is designed for 640x480 with a 25 MHz input clock.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Pong_Pkg.all;

entity Pong_Ball_Ctrl is
  port (
    i_Clk           : in  std_logic;
	 rst             : in  std_logic;
	 st              : in  std_logic;
    i_Game_Active   : in  std_logic;
    i_Col_Count_Div : in  std_logic_vector(5 downto 0);
    i_Row_Count_Div : in  std_logic_vector(5 downto 0);
	 UpI             : in  std_logic;
	 UpD	 			  : in  std_logic; 
	 DownI           : in  std_logic;
	 DownD           : in  std_logic;
	 P1              : in  std_logic_vector(5 downto 0);
	 P2              : in  std_logic_vector(5 downto 0);	
	 o_ini           : out std_logic;
    --
    o_Draw_Ball     : out std_logic;
    o_Ball_X        : out std_logic_vector(5 downto 0);
    o_Ball_Y        : out std_logic_vector(5 downto 0);
	 o_GolIz         : out integer;
	 o_GolDer        : out integer
    );
end entity Pong_Ball_Ctrl;

architecture rtl of Pong_Ball_Ctrl is
  -- Integer representation of the above 6 downto 0 counters.
  -- Integers are easier to work with conceptually
  signal w_Col_Index : integer range 0 to 2**i_Col_Count_Div'length := 0;
  signal w_Row_Index : integer range 0 to 2**i_Row_Count_Div'length := 0;
  signal ini, DerStart, Der, DownDer, DownIz, UpDer,UpIz, Iz, stay : std_logic:='0';
  signal r_Ball_Count : integer range 0 to c_Ball_Speed5 := 0;
  signal IzStart: std_logic:='1';
  signal YRD, YRI : integer;
  -- X and Y location (Col, Row) for Pong Ball, also Previous Locations
  signal r_Ball_X      : integer range 0 to 2**i_Col_Count_Div'length := 0;
  signal r_Ball_Y      : integer range 0 to 2**i_Row_Count_Div'length := 0;
  signal r_Ball_X_Prev : integer range 0 to 2**i_Col_Count_Div'length := 0;
  signal r_Ball_Y_Prev : integer range 0 to 2**i_Row_Count_Div'length := 0;
  signal Toques, GolIz, GolDer : integer:=0;
  signal Speed : integer:=5000000;
  signal Flag, r_Draw_Ball : std_logic := '0';
  
begin

	o_GolIz  <= GolIz;
	o_GolDer <= GolDer;
	o_ini <= ini;
	
  YRD <= to_integer(unsigned(P2))+3;
  YRI <= to_integer(unsigned(P1))+3;

  w_Col_Index <= to_integer(unsigned(i_Col_Count_Div));
  w_Row_Index <= to_integer(unsigned(i_Row_Count_Div));  

    
  p_Move_Ball : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      -- If the game is not active, ball stays in the middle of the screen
      -- until the game starts.
      if (i_Game_Active = '0')then
        r_Ball_X      <= c_Game_Width/2;
        r_Ball_Y      <= c_Game_Height/2;
        r_Ball_X_Prev <= c_Game_Width/2 + 1; 
        r_Ball_Y_Prev <= c_Game_Height/2 - 1;
      else
        -- Update the ball counter continuously.  Ball movement update rate is
        -- determined by a constant in the package file.
        if(toques<6)then
			  if r_Ball_Count = c_Ball_Speed5 then
				 Flag<='1';
				 r_Ball_Count <= 0;
			  else
			    Flag<='0';
				 r_Ball_Count <= r_Ball_Count + 1;
			  end if;
		 elsif(toques>=6 AND toques<11) then
				if r_Ball_Count = c_Ball_Speed4 then
				 Flag<='1';
				 r_Ball_Count <= 0;
			  else
			    Flag<='0';
				 r_Ball_Count <= r_Ball_Count + 1;
			  end if;
		elsif(toques>=11 AND toques<16) then
				if r_Ball_Count = c_Ball_Speed3 then
				 Flag<='1';
				 r_Ball_Count <= 0;
			  else
			    Flag<='0';
				 r_Ball_Count <= r_Ball_Count + 1;
			  end if;
		elsif(toques>=16 AND toques<21) then
				if r_Ball_Count = c_Ball_Speed2 then
				 Flag<='1';
				 r_Ball_Count <= 0;
			  else
			    Flag<='0';
				 r_Ball_Count <= r_Ball_Count + 1;
			  end if;
		elsif(toques>=21) then
				if r_Ball_Count = c_Ball_Speed1 then
				 Flag<='1';
				 r_Ball_Count <= 0;
			  else
			    Flag<='0';
				 r_Ball_Count <= r_Ball_Count + 1;
			  end if;
	   end if;

        -----------------------------------------------------------------------
        -- Control X Position (Col)
        -----------------------------------------------------------------------
        if Flag='1' then
          
          -- Store Previous Location to keep track of ball movement
          r_Ball_X_Prev <= r_Ball_X;
          if(IzStart='1' OR Rst='1')then
				  r_Ball_X      <= c_Game_Width/2;
				  r_Ball_Y      <= c_Game_Height/2;
				  r_Ball_X_Prev <= c_Game_Width/2 + 1; 
				  r_Ball_Y_Prev <= c_Game_Height/2 - 1;
				  ini <= '1';
				  if(rst='1')then
					Upder<='0';
					UpIz<='0';
					DownDer<='0';
					DownIz<='0';
					DerStart<='0';
					Der<='0';
					Iz<='0';
					IzStart<='1';
					golDer<=0;
					golIz<=0;
				  end if;
				  if(upI='1' AND DownI='0')then
						IzStart<='0';
						UpDer<='1';
				  elsif(upI='0' AND DownI='1')then
						IzStart<='0';
						DownDer<='1';
				  end if;
			 elsif(Rst='0' AND DerStart='1')then
				  r_Ball_X      <= c_Game_Width/2;
				  r_Ball_Y      <= c_Game_Height/2;
				  r_Ball_X_Prev <= c_Game_Width/2 + 1; 
				  r_Ball_Y_Prev <= c_Game_Height/2 - 1;
				  ini <= '1';
				  if(upD='1' AND DownD='0')then
						DerStart<='0';
						UpIz<='1';
				  elsif(upD='0' AND DownD='1')then
						DerStart<='0';
						DownIz<='1';
				  end if;
			 elsif(st='0' AND Rst='0' AND UpDer='1')then
				r_Ball_X <= r_Ball_X + 1;
				r_Ball_Y <= r_Ball_Y - 1;
				ini <= '0';
				if(r_Ball_Y=1)then
					UpDer  <= '0';
					DownDer<= '1';
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD OR r_Ball_Y=YRD+1))then
					UpDer<='0';
					Iz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD-2 OR r_Ball_Y=YRD-1)) then
					UpDer<='0';
					UpIz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD+3 OR r_Ball_Y=YRD+2)) then
					UpDer<='0';
					DownIz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=38 AND (r_Ball_Y/=YRD OR r_Ball_Y/=(YRD+1) OR r_Ball_Y/=(YRD+2)OR r_Ball_Y/=(YRD-1)OR r_Ball_Y/=(YRD-2)OR r_Ball_Y/=(YRD+3))) then
					if(GolIz<9)then
						GolIz<=GolIz+1;
					else
						GolIz<=0;
					end if;
					UpDer<='0';
					DerStart <='1';
				end if;
			 elsif(st='0' AND Rst='0' AND UpIz='1')then
				r_Ball_X <= r_Ball_X - 1;
				r_Ball_Y <= r_Ball_Y - 1;
				ini <= '0';
				if(r_Ball_Y=1)then
					UpIz   <= '0';
					DownIz <= '1';
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI OR r_Ball_Y=(YRI+1)))then
					UpIz<='0';
					Der <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI-2 OR r_Ball_Y=YRI-1)) then
					UpIz<='0';
					UpDer <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI+2 OR r_Ball_Y=YRI+3)) then
					UpIz<='0';
					DownDer <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=1 AND (r_Ball_Y/=YRI OR r_Ball_Y/=(YRI+1) OR r_Ball_Y/=(YRI+2)OR r_Ball_Y/=(YRI-1)OR r_Ball_Y/=(YRI-2) OR r_Ball_Y/=(YRI+3))) then
					if(GolDer<9)then
						GolDer<=GolDer+1;
					else
						GolDer<=0;
					end if;
					UpIz<='0';
					IzStart <='1';
				end if;
			 elsif(st='0' AND Rst='0' AND DownDer='1')then
				r_Ball_X <= r_Ball_X + 1;
				r_Ball_Y <= r_Ball_Y + 1;
				ini <= '0';
				if(r_Ball_Y=28)then
					DownDer<='0';
					UpDer <='1';
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD-2 OR r_Ball_Y=YRD-1))then
					DownDer<='0';
					Iz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD-4 OR r_Ball_Y=YRD-3)) then
					DownDer<='0';
					UpIz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD+1 OR r_Ball_Y=YRD)) then
					DownDer<='0';
					DownIz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=38 AND (r_Ball_Y/=YRD OR r_Ball_Y/=(YRD+1) OR r_Ball_Y/=(YRD-4)OR r_Ball_Y/=(YRD-1)OR r_Ball_Y/=(YRD-2)OR r_Ball_Y/=(YRD-3))) then
					if(GolIz<9)then
						GolIz<=GolIz+1;
					else
						GolIz<=0;
					end if;
					DownDer<='0';
					DerStart <='1';
				end if;
			 elsif(st='0' AND Rst='0' AND DownIz='1')then
				r_Ball_X <= r_Ball_X - 1;
				r_Ball_Y <= r_Ball_Y + 1;
				ini <= '0';
				if(r_Ball_Y=28)then
					DownIz<='0';
					UpIz <='1';
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI-2 OR r_Ball_Y=(YRI-1)))then
					DownIz<='0';
					Der <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI-3 OR r_Ball_Y=YRI-4)) then
					DownIz<='0';
					UpDer <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI+1 OR r_Ball_Y=YRI)) then
					DownIz<='0';
					DownDer <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=1 AND (r_Ball_Y/=YRI OR r_Ball_Y/=(YRI+1) OR r_Ball_Y/=(YRI-4)OR r_Ball_Y/=(YRI-1)OR r_Ball_Y/=(YRI-2)OR r_Ball_Y/=(YRI-3))) then
					if(GolDer<9)then
						GolDer<=GolDer+1;
					else
						GolDer<=0;
					end if;
					DownIz<='0';
					IzStart <='1';
				end if;
			elsif(st='0' AND Rst='0' AND Der='1')then
				r_Ball_X <= r_Ball_X + 1;
				r_Ball_Y <= r_Ball_Y;
				if(r_Ball_X=37 AND (r_Ball_Y=YRD OR r_Ball_Y=YRD-1))then
					Der<='0';
					Iz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD-2 OR r_Ball_Y=YRD-3)) then
					Der<='0';
					UpIz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=37 AND (r_Ball_Y=YRD+1 OR r_Ball_Y=YRD+2)) then
					Der<='0';
					DownIz <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=38 AND (r_Ball_Y/=YRD OR r_Ball_Y/=(YRD+1) OR r_Ball_Y/=(YRD+2)OR r_Ball_Y/=(YRD-1)OR r_Ball_Y/=(YRD-2)OR r_Ball_Y/=(YRD-3))) then
					if(GolIz<9)then
						GolIz<=GolIz+1;
					else
						GolIz<=0;
					end if;
					Der<='0';
					DerStart <='1';
				end if;
			elsif(st='0' AND Rst='0' AND Iz='1')then
				r_Ball_X <= r_Ball_X - 1;
				r_Ball_Y <= r_Ball_Y;
				if(r_Ball_X=2 AND (r_Ball_Y=YRI OR r_Ball_Y=(YRI-1)))then
					Iz<='0';
					Der <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI-2 OR r_Ball_Y=YRI-3)) then
					Iz<='0';
					UpDer <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=2 AND (r_Ball_Y=YRI+1 OR r_Ball_Y=YRI+2)) then
					Iz<='0';
					DownDer <='1';
					Toques<=Toques + 1;
				elsif(r_Ball_X=1 AND (r_Ball_Y/=YRI OR r_Ball_Y/=(YRI+1) OR r_Ball_Y/=(YRI+2)OR r_Ball_Y/=(YRI-1)OR r_Ball_Y/=(YRI-2)OR r_Ball_Y/=(YRI-3))) then
					if(GolDer<9)then
						GolDer<=GolDer+1;
					else
						GolDer<=0;
					end if;
					Der<='0';
					IzStart <='1';
				elsif(st='1')then
					r_Ball_X <= r_Ball_X;
					r_Ball_Y <= r_Ball_Y;
				end if;
			 end if;
        end if;
      end if;                           -- w_Game_Active = '1'
    end if;                             -- rising_edge(i_Clk)
  end process p_Move_Ball;


  -- Draws a ball at the location determined by X and Y indexes.
  p_Draw_Ball : process (i_Clk) is
  begin
    if rising_edge(i_Clk) then
      if (w_Col_Index = r_Ball_X and w_Row_Index = r_Ball_Y) then
        r_Draw_Ball <= '1';
      else
        r_Draw_Ball <= '0';
      end if;
    end if;
  end process p_Draw_Ball;

  o_Draw_Ball <= r_Draw_Ball;
  o_Ball_X    <= std_logic_vector(to_unsigned(r_Ball_X, o_Ball_X'length));
  o_Ball_Y    <= std_logic_vector(to_unsigned(r_Ball_Y, o_Ball_Y'length));
  
  
end architecture rtl;