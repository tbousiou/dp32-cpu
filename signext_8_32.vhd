------------------------------------------------------
-- SIGN EXTENDING  32-bit BUFFER  --
-- (extends the bit7 of a input)                --
-------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all; 
entity signext_8_32 is
	port (a : in std_logic_vector(7 downto 0);
		b : out std_logic_vector(31 downto 0) ;
		en : in std_ulogic);
end signext_8_32;

library	cub;
use cub.Vcomponents.all;
architecture structure of signext_8_32 is	

    for all : in1  use configuration	cub.cfg_in1_vital ;	
	for all : it1  use configuration	cub.cfg_it1_vital ;
	for all : in8  use configuration	cub.cfg_in8_vital ;	
	for all : it14 use configuration	cub.cfg_it14_vital ;	
	
	
	signal s_int : std_logic_vector(7 downto 0);
	signal extension : std_logic;
	
	begin
	gen1 : for i in 0 to 6 generate 
		inverters1 : in1 port map (a(i),s_int(i));
		tristate1  : it1 port map  (s_int(i),en,b(i));
	end generate;
	
	invert8 : in8 port map (a(7),s_int(7));
	tristate1    : it1 port map  (s_int(7),en,b(7));  
	
	gen2 : for i in 0 to 5 generate	 
		ext_trist4 : it14 port map(s_int(7),en,extension);
	end generate;
	
	b(31)<=extension; b(25)<=extension; b(19)<=extension; b(13)<=extension;
	b(30)<=extension; b(24)<=extension; b(18)<=extension; b(12)<=extension;
	b(29)<=extension; b(23)<=extension; b(17)<=extension; b(11)<=extension;
	b(28)<=extension; b(22)<=extension; b(16)<=extension; b(10)<=extension;
	b(27)<=extension; b(21)<=extension; b(15)<=extension; b(9)<=extension;
	b(26)<=extension; b(20)<=extension; b(14)<=extension; b(8)<=extension;
end structure;	 
