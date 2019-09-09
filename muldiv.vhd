------------------------------------------------------------
-- 32-bit two input MULTIPLIER/DIVIDER    --
------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity muldiv is
	port(
		am : in std_logic_vector(31 downto 0);
		bm : in std_logic_vector(31 downto 0);
		ad : in std_logic_vector(31 downto 0);
		bd : in std_logic_vector(31 downto 0);
		m : out std_logic_vector(31 downto 0);
		d : out std_logic_vector(31 downto 0);
		en :in std_ulogic 
		);
end muldiv;

library ieee; 
use work.dp32_types.int_to_bits;
use ieee.std_logic_signed.conv_integer;
architecture behavior of muldiv is
	
	begin 
	
	process(am,bm,ad,bd,en)
		variable multemp,divtemp :bit_vector(31 downto 0);
		variable i: integer;
		begin
		if en='1' then	
			int_to_bits(conv_integer(am)*conv_integer(bm),multemp) ;
			m<=to_stdlogicvector(multemp) after 3 ns;
			i:=conv_integer(bd);
			if i/=0 then 
				int_to_bits((conv_integer(ad)/i),divtemp) ;
				d<=to_stdlogicvector(divtemp) after 3 ns ;
			else   
				assert i=0
				report "zero on division nooulas" ;
			end if;
		end if;
	end process;
end behavior;
