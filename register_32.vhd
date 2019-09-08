--------------------------------
-- 32-bit REGISTER    --
--------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all; 
entity latch_32 is
	port (d : in std_logic_vector(31 downto 0);
		  q : out std_logic_vector(31 downto 0);
		 en : in std_ulogic );
end latch_32;

library	cub;
use cub.Vcomponents.all;
architecture structure of latch_32 is
	
	for all : in8 use configuration	cub.cfg_in8_vital ;	
	for all : bu4 use configuration	cub.cfg_bu4_vital ;	
	for all : dl8 use configuration	cub.cfg_dl8_vital ;	
	
	signal s_en :std_ulogic;	  
	signal s_qn :std_logic_vector(31 downto 0);
	signal s_gn :std_logic_vector(3 downto 0);
	begin  
	en_buf4 : bu4 port map (en,s_en);  
	
	gen1 : for i in 3 downto 0 generate
		invert8 :in8 port map (s_en,s_gn(i));
	end generate;	
	
	gen2 : for i in 31 downto 0 generate 
		dlatches : dl8 port map (d(i),s_gn(i mod 4),q(i),s_qn(i));
	end generate;	
	
end structure;

architecture behavior of latch_32 is
	begin
	process (d, en)
		begin
		if en = '1' then
			q <= d after 1 ns ;
		end if;
	end process;
end behavior;	
