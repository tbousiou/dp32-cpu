---------------------------------------------
-- 32-bit two input LOGICAL XOR --
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity xor32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end xor32;

library	cub;
use cub.vcomponents.all;
architecture structure of xor32 is	
	for all :eo1 use configuration	cub.cfg_eo1_vital ;
	
	begin
	
	gen : for i in 31 downto 0 generate
		exorgates : eo1 port map (a(i),b(i),c(i));
	end generate;
end structure;
