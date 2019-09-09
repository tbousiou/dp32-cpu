-----------------------
-- 8-bit CODER --
-----------------------

library ieee;
use ieee.std_logic_1164.all;
entity coder83 is
	port(
		b : in std_ulogic;
		c : in std_ulogic;
		e : in std_ulogic;
		f : in std_ulogic;
		g : in std_ulogic;
		h : in std_ulogic;
		a : in std_ulogic;
		d : in std_ulogic;
		d0 : out std_ulogic;
		d1 : out std_ulogic;
		d2 : out std_ulogic
		);
end coder83;

architecture behavior of coder83 is
	signal sd : std_ulogic_vector(2 downto 0);
	begin
	
	sd<= "000" when a='1' else 
	"001" when b='1' else 
	"010" when c='1' else
	"011" when d='1' else 
	"100" when e='1' else
	"101" when f='1' else
	"110" when g='1' else	 
	"111" when h='1' ;		
	d0<=sd(0) ; d1<=sd(1) ; d2<=sd(2);
end behavior;
