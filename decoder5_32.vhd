------------------------------
-- 5-bit DECODER     --
------------------------------

library	ieee;
use ieee.std_logic_1164.all; 
use ieee.std_logic_signed.conv_integer;
use work.dp32_types.all;

entity decoder5_32 is
	generic (Tpd : time );
	port (code:  in std_logic_vector(4 downto 0);
		decode: out std_logic_vector(31 downto 0)--):=(others=>'0');
 end decoder5_32  ;

architecture behavior of decoder5_32 is
	
	begin
	process	(code)
		variable temp : integer ;
		begin
		temp:=CONV_INTEGER(code);
		for i in 31 downto 0 loop
			if i=temp then decode(i)<='1' after tpd;
			else decode(i)<='0' after tpd;
			end if;
		end loop;
	end process;
end behavior;
