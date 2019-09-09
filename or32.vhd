--------------------------------------------
-- 32-bit two input LOGICAL OR --
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity or32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end or32;

library	cub;
use cub.vcomponents.all;
architecture structure of or32 is	
	
	for all :or2 use configuration	cub.cfg_or2_vital ;
	
	begin
	gen : for i in 31 downto 0 generate
		orgates : or2 port map (a(i),b(i),c(i));
	end generate;
end structure;

library ieee;
use ieee.std_logic_1164.all;

entity to1 is
	port(
		number : in std_logic_vector(31 downto 0);
		one : out std_logic_vector(31 downto 0);
		t1 : in std_ulogic );
end to1;

architecture behavior of to1 is
	begin
	one <= X"00000001" when t1='1' else
	number  ;
end behavior;  
