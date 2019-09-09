----------------------------------------------------------------
-- 32-bit ZERO DETECTOR for the ALU result --
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity zero_detector is
	port(
		res : in std_logic_vector(31 downto 0);
		zflag : out std_ulogic
		);
end zero_detector;


library cub;
use cub.vcomponents.all;
architecture structure of zero_detector is
	signal st : std_ulogic_vector(3 downto 0);	 
	for all : no8 use configuration	cub.cfg_no8_vital; 
	for all : and4 use configuration	cub.cfg_and4_vital;
	begin
	
	andgates : for i in 3 downto 0 generate 
		no8gates : no8 port map(res(i*8),res(i*8+1),res(i*8+2),res(i*8+3),
			res(i*8+4),res(i*8+5),res(i*8+6),res(i*8+7),st(i));
	end generate ;
	and4gate : and4 port map (st(0),st(1),st(2),st(3),zflag);  
	
end structure;	
