-------------------------------------------
-- 32 to 1,32-bit MULTIPLEXER --
-------------------------------------------

library	ieee;
use ieee.std_logic_1164.all; 
use work.dp32_types.all;
entity mux32_32_1 is
	port (m :in m32	   ;
		selct : in std_logic_vector(4 downto  0);
		outline : out std_logic_vector(31 downto 0));
end mux32_32_1;	

architecture structure of mux32_32_1 is
	
	signal m_temp: m32; 
	
	component mux1_32_1 is
		port (ivec: in std_logic_vector(31 downto 0);
			sel : in std_logic_vector(4 downto  0);
			outline: out std_ulogic);
	end component;
	
	for all :mux1_32_1 use entity work.mux1_32_1(structure);
	
	begin
	gen: for i in 0 to 31 generate
		muxs :mux1_32_1 port	map(m_temp(i),selct,outline(i));
	end generate; 
	
	process(m)
		begin
		for i in 0 to 31 loop
			for j in 0 to 31 loop
				m_temp(i)(j)<=m(j)(i);
			end loop; 
		end loop;
	end process;
end structure; 
