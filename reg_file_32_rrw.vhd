-------------------------------------
--     REGISTER FILE         --               
-- 2 read and 1 write port,   --
-- 32 32-bit registers           --
--------------------------------------	 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;
entity reg_file_32_rrw is
	port (a1 : in std_logic_vector(4 downto 0);
		q1 : out std_logic_vector(31 downto 0) ;
		en1 : in std_ulogic;
		a2 : in std_logic_vector(4 downto 0);
		q2 : out std_logic_vector(31 downto 0);
		en2 : in std_ulogic;
		a3 : in std_logic_vector(4 downto 0);
		d3 : in std_logic_vector(31 downto 0);
		en3 : in std_ulogic); 	
end reg_file_32_rrw;

library	cub;
use cub.Vcomponents.all; 
architecture structure of reg_file_32_rrw is	
	
	component latch_32 is
		port (d : in std_logic_vector(31 downto 0);
			q : out std_logic_vector(31 downto 0);
			en : in std_ulogic );
	end component;	 
	
	component mux32_32_1 is
		port (    m :in m32	   ;
			selct : in std_logic_vector(4 downto  0);
			outline : out std_logic_vector(31 downto 0));
	end component;	
	
	component buffer_32 is
		port (  a : in std_logic_vector(31 downto 0);
			b : out std_logic_vector(31 downto 0) ;
			en : in std_ulogic);
	end component;	
	
	component decoder5_32 is
		generic (Tpd :time:=unit_delay  );
		port (  code:  in std_logic_vector(4 downto 0);
			decode: out std_logic_vector(31 downto 0):=(others=>'0')
			);
	end component;  
	
	for all : decoder5_32 use entity work.decoder5_32(behavior);
	for all : buffer_32 use entity work.buffer_32(structure);
	for all : mux32_32_1 use entity work.mux32_32_1(structure);	
	for all : latch_32 use entity work.latch_32(structure);	
	for all : and2 use configuration	cub.cfg_and2_vital ;		
	
	signal	s_decode,s_and2,s_outmux1,s_outmux2 :std_logic_vector(31 downto 0); 
	signal s_latch_32_out : m32	  ;
	
	begin
	decoder : decoder5_32  generic map(tpd=>1 ns)
	port map(a3,s_decode);	
	
	genand2_latch32 : for i in 31 downto 0 generate
		and2: and2 port map(s_decode(i),en3,s_and2(i));	
		latches: latch_32 port map (d=>d3,q=>s_latch_32_out(i),en=>s_and2(i)) ;
	end generate;	  
	
	mux32_2 :  mux32_32_1 port map( s_latch_32_out,a2,s_outmux2);
	mux32_1 :  mux32_32_1 port map( s_latch_32_out,a1,s_outmux1) ;
	buf32_1 : buffer_32 port map  (s_outmux1,q1,en1);
	buf32_2 : buffer_32 port map  (s_outmux2,q2,en2);
	end  structure ; 
