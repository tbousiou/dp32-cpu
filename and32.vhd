-----------------------------------------------
-- 32-bit two input LOGICAL AND  --
-----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity and32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end and32;

library	cub;
use cub.vcomponents.all;
architecture structure of and32 is	
	for all :and2 use configuration	cub.cfg_and2_vital ;
	
	begin
	
	gen : for i in 31 downto 0 generate
		andgates : and2 port map (a(i),b(i),c(i));
	end generate;
end structure; 


library ieee;
use ieee.std_logic_1164.all;
entity mask32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end mask32;

library	cub;
use cub.vcomponents.all;
architecture structure of mask32 is
	signal notb : std_logic_vector(31 downto 0) ;  
	
	for all :and2 use configuration	cub.cfg_and2_vital ;
	for all :in1 use configuration	cub.cfg_in1_vital ;
	begin
	
	gen : for i in 31 downto 0 generate
		andgates : and2 port map (a(i),notb(i),c(i));
		notgates : in1 port map  (b(i),notb(i))	  ;
		
	end generate; 
	
end structure; 
