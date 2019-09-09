-----------------------------------------
-- 32-bit LATCHING BUFFER --
------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;
entity latch_buffer_32 is
	port (d : in std_logic_vector(31 downto 0);
		q : out std_logic_vector(31 downto 0) ;
		latch_en : in std_ulogic;
		out_en : in std_ulogic);
end latch_buffer_32;

library	cub;
use cub.Vcomponents.all;
architecture structure of latch_buffer_32 is
	
	for all : in8 use configuration	 cub.cfg_in8_vital ;
	for all : bu4 use configuration	 cub.cfg_bu4_vital ;
	for all : dl8z use configuration cub.cfg_dl8z_vital ;	 
	
	signal s_en,s_out_en :std_ulogic;	  
	signal s_gn :std_logic_vector(3 downto 0);
	
	begin  	 
	out_en_inv:in8 port map (out_en,s_out_en);
	en_buf4 : bu4 port map (latch_en,s_en);  
	
	gen1 : for i in 3 downto 0 generate
		invert8 :in8 port map (s_en,s_gn(i));
	end generate;	
	
	gen2 : for i in 31 downto 0 generate 
		dlatches : dl8z port map (d(i),s_out_en,s_gn(i mod 4),q(i));
	end generate;	
	
end structure;	
