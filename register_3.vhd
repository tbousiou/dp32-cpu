-------------------------------
-- 3-bit REGISTER     -- 
-------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity latch_3 is
	port (d : in std_logic_vector(2 downto 0);
		  q : out std_logic_vector(2 downto 0);
		 en : in std_ulogic );
end latch_3;   

library	cub;
use cub.Vcomponents.all;
architecture structure of latch_3 is
	
	for all : in3 use configuration	cub.cfg_in3_vital ;	
	for all : bu3 use configuration	cub.cfg_bu3_vital ;	
	for all : dl8 use configuration	cub.cfg_dl8_vital ;	
	
	signal s_en :std_ulogic;	  
	signal s_qn :std_logic_vector(2 downto 0);
	signal s_gn :std_ulogic ;
	begin  
	en_buf3 : bu3 port map (en,s_en);  
	inverter3 : in3 port map(s_en,s_gn);
	
	gen : for i in 2 downto 0 generate 
		dlatches : dl8 port map (d(i),s_gn,q(i),s_qn(i));
	end generate;	
	
end structure;	
