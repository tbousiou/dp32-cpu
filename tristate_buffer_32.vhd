-----------------------------------------
-- 32-bit TRISTATE BUFFER --
-----------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
entity buffer_32 is
	port (a : in std_logic_vector(31 downto 0);
		b : out std_logic_vector(31 downto 0) ;
		en : in std_ulogic);
end buffer_32;

library	cub;
use cub.Vcomponents.all ;
architecture structure of buffer_32 is
	for all : it1 use configuration	cub.cfg_it1_vital;
	for all : in1 use configuration	cub.cfg_in1_vital;
	signal   invout  :std_logic_vector(31 downto 0);
	
	begin 
	iobufer_gen : for i in 31 downto 0 generate
		inverters            : in1 port	map (a(i),invout(i) ); 
		inv_tristate_buffers : it1 port	map (invout(i),en,b(i) );
	end generate ;			
end structure;
