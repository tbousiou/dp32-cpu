---------------------------------------------
-- this circuit is the interface for   --
--  input B in order to achive        --
-- two's complement subtraction  --	
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity exor32 is
		port (b : in std_logic_vector (31 downto 0);
		      s : in std_ulogic;
			bx : out std_logic_vector (31 downto 0)
			);

end exor32;	 

library	cub;
use cub.Vcomponents.all;
architecture structure of exor32 is	
	for all :eo1 use configuration	cub.cfg_eo1_vital ;
	
	begin
	
	gen : for i in 31 downto 0 generate
		exorgates : eo1 port map (b(i),s,bx(i));
	end generate;
end structure;
