------------------------------------------------
-- 32 -bit PROGRAMM COUNTER --
------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;
entity PC_reg is
	port (d : in std_logic_vector(31 DOWNTO 0);
		q : out STD_LOGIC_VECTOR(31 DOWNTO 0):=X"00000000";
		latch_en : in STD_ULOGIC;
		out_en : in STD_ULOGIC;
		reset : in STD_ULOGIC);
end PC_reg;

library	cub;
use cub.Vcomponents.all;
architecture structure of  PC_reg  is	
	
	for all : in1 use configuration	cub.cfg_in1_vital ;		
	for all : dla use configuration	cub.cfg_dla_vital ;	
	for all : it1 use configuration	cub.cfg_it1_vital ;
	for all : bu1 use configuration	cub.cfg_bu1_vital ;	
	
	signal srn : std_ulogic;
	signal sq1,sqn1,sq2,sqn2,sgn1,sgn2 : std_ulogic_vector (31 downto 0) ;
	begin
	
		inverter1 : in1 port map(reset,srn);
		pc_gen : for i in 31 downto 0 generate
			
		dla_latches1 : dla port map ( d=>d(i),gn=>sgn1(i),rn=>srn,q=>sq1(i),qn=>sqn1(i) )	;
		dla_latches2 : dla port map ( d=>sq1(i),gn=>sgn2(i),rn=>srn,q=>sq2(i),qn=>sqn2(i) )	;
		inverters  : in1  port map (a=>latch_en,q=>sgn1(i));
		buffers :  bu1	port map   (a=> latch_en ,q=>sgn2(i));
		inv_tristates : it1 port map  ( a=>sqn2(i),e=>out_en,q=>q(i) ) ;
	end generate;
end structure;
