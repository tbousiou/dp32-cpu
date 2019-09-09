-------------------------------------------
-- 32 to 1, 1-bit MULTIPLEXER --
-------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
entity mux1_32_1 is
	port (ivec : in std_logic_vector(31 downto 0);
		sel : in std_logic_vector(4 downto 0);
		outline: out std_ulogic);
end mux1_32_1;

library	cub;
use cub.Vcomponents.all;
architecture structure of mux1_32_1 is	  
	for all : mu4 use configuration	cub.cfg_mu4_vital ;
	for all : mu8 use configuration	cub.cfg_mu8_vital ;
	
	signal	s_mu8out : std_logic_vector(3 downto 0);
	begin
	gen :for i in 0 to 3 generate
		mux8: mu8 port map(ivec(8*i),ivec(8*i+1),ivec(8*i+2),ivec(8*i+3),
			ivec(8*i+4),ivec(8*i+5),ivec(8*i+6),ivec(8*i+7),
			s_mu8out(i),sel(0),sel(1),sel(2));
	end generate;
	mux4 : mu4 port map (s_mu8out(0),s_mu8out(1),s_mu8out(2),s_mu8out(3),outline,sel(3),sel(4));
end structure;
