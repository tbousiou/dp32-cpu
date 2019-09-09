-----------------------------------
-- 8 to 1 MULTIPLEXER --
-----------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity mux81_32 is
	port(
		i1 : in std_logic_vector(31 downto 0);
		i2 : in std_logic_vector(31 downto 0);
		i3 : in std_logic_vector(31 downto 0);
		i4 : in std_logic_vector(31 downto 0);
		i5 : in std_logic_vector(31 downto 0);
		i6 : in std_logic_vector(31 downto 0);
		i7 : in std_logic_vector(31 downto 0);
		i0 : in std_logic_vector(31 downto 0);
		s0 : in std_ulogic;
		s1 : in std_ulogic;
		s2 : in std_ulogic;
		qmux : out std_logic_vector(31 downto 0)
		);
end mux81_32;

architecture behavior of mux81_32 is
	signal sel :std_ulogic_vector(2 downto 0)	 ;
	begin
	
	sel(0)<=s0 ; sel(1)<=s1 ; sel(2)<=s2 ;	 
	with sel select
	qmux<= i0 when "000",
	i1 when "001" ,
	i2 when "010",
	i3 when "011",
	i4 when "100",
	i5 when "101",
	i6 when "110",
	i7 when "111",
	x"00000000" when others ;
	
end behavior;  
