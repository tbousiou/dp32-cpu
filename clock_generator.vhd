-----------------------------------
-- CLOCK GENERATOR --
-----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity clock_gen is
	generic (Tpw : Time; -- clock pulse width
		Tps : Time); -- pulse separation between phases
	port (phi1, phi2 : out std_ulogic;
		reset : out std_ulogic);
end clock_gen;

architecture behavior of clock_gen is
	constant clock_period : Time := 2*(Tpw+Tps);
	begin
	reset_driver :
	reset <= '1', '0' after 2*clock_period+Tpw;
	clock_driver : process
		begin
		phi1 <= '1', '0' after Tpw;
		phi2 <= '1' after Tpw+Tps, '0' after Tpw+Tps+Tpw;
		wait for clock_period;
	end process clock_driver;
end behavior;
