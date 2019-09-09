-----------------------------------------
-- 2 to 1, 5-bit MULTIPLEXER --
------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all; 
entity mux5_2_1 is
	port (i0, i1 : in std_logic_vector(4 downto 0);
		y : out std_logic_vector(4 downto 0);
		sel : in std_ulogic);
end mux5_2_1;

architecture behavior of mux5_2_1 is
	begin
	process (i0,i1,sel)
		begin
		if sel='0' then
			y<=i0;
		elsif sel='1' then
			y<=i1 ;
		end if;
		
	end process;		
end behavior;

library	cub;
use cub.Vcomponents.all;
architecture structure of mux5_2_1 is	
	
	for all : mu2 use configuration	cub.cfg_mu2_vital ;
	
	begin
	mux_gen :for i in 4 downto 0 generate
		multiplexers : mu2 port map(i0(i),i1(i),y(i),sel); 	
	end generate;
end structure ;	
