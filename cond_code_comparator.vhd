------------------------------------------------------
-- CONDITION CODE COMPARATOR --
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;
entity cond_code_comparator is
	port (cc : in CC_bits;
		cm : in cm_bits;
		result : out std_ulogic);
end cond_code_comparator;

library	cub;
use	cub.Vcomponents.all;
architecture structure of cond_code_comparator is

    for all : ao222 use configuration	cub.cfg_ao222_vital ;	
	for all : ao22  use configuration	cub.cfg_ao22_vital ;	
	for all : bu2   use configuration	cub.cfg_bu2_vital ;	
	for all : in1   use configuration	cub.cfg_in1_vital ;	
	
	signal	s_int,a,b,c,d : std_ulogic;
	begin
	comp_ao222 : ao222 port map (cc(2),cm(2),cc(1),cm(1),cc(0),cm(0),s_int);
	bu2_1 : bu2 port map(s_int,a);
	bu2_2 : bu2 port map (cm(3),b);
	inv1  :in1  port map (a,c);
	inv2  :in1  port map  (b,d);
	com_ao22 :ao22 port	map (a,b,c,d,result);
	
end structure;
