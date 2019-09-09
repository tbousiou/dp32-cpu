-----------------------------------------------
-- ARITHMETIC LOGICAL UNIT   --
-----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.dp32_types.all;
entity alu32 is
	port(
		command : in alu_command;
		operand1 : in std_logic_vector (31 downto 0);
		operand2 : in std_logic_vector (31 downto 0);
		result : out std_logic_vector (31 downto 0)	;
		cond_code : out std_logic_vector(2 downto 0)
		);
end alu32;

library cub;
use cub.Vcomponents.or2;
architecture structure of alu32 is
	
	---- signal declarations used on the diagram ----
	
	signal tempres : std_logic_vector (31 downto 0);signal bus104 : std_logic_vector (31 downto 0);
	signal bus1069 : std_logic_vector (31 downto 0);signal bus112 : std_logic_vector (31 downto 0);
	signal bus1153 : std_logic_vector (31 downto 0);signal bus116 : std_logic_vector (31 downto 0);
	signal bus124 : std_logic_vector (31 downto 0);signal bus181 : std_logic_vector (31 downto 0);
	signal bus189 : std_logic_vector (31 downto 0);signal bus96 : std_logic_vector (31 downto 0);
	signal net1123 : std_ulogic ;signal net285 : std_ulogic ;signal net524 : std_ulogic ;
	signal net528 : std_ulogic ;signal net532 : std_ulogic ;signal net540 : std_ulogic ;
	signal net544 : std_ulogic ;signal net570 : std_ulogic ;signal net574 : std_ulogic ;
	signal net578 : std_ulogic ;signal net582 : std_ulogic ;signal net586 : std_ulogic ;
	signal net967 : std_ulogic ;signal net968 : std_ulogic ;
	signal		scarry_cond_code  : std_ulogic ;
	signal mul_div_en : std_ulogic ;
	
---- component declarations -----
	
	component and32
		port (
			a : in std_logic_vector (31 downto 0);
			b : in std_logic_vector (31 downto 0);
			c : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component coder83
		port (
			a : in std_ulogic;
			b : in std_ulogic;
			c : in std_ulogic;
			d : in std_ulogic;
			e : in std_ulogic;
			f : in std_ulogic;
			g : in std_ulogic;
			h : in std_ulogic;
			d0 : out std_ulogic;
			d1 : out std_ulogic;
			d2 : out std_ulogic
			);
	end component ;
	
	component command_decoder
		port (
			command : in alu_command;
			addsub : out std_ulogic;
			div : out std_ulogic;
			en : out std_ulogic;
			incr : out std_ulogic;
			land : out std_ulogic;
			lmask : out std_ulogic;
			lor : out std_ulogic;
			lxor : out std_ulogic;
			mul : out std_ulogic;
			pass : out std_ulogic;
			sub : out std_ulogic
			);
	end component ;
	
	component mask32
		port (
			a : in std_logic_vector (31 downto 0);
			b : in std_logic_vector (31 downto 0);
			c : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component muldiv
		port (
			ad : in std_logic_vector (31 downto 0);
			am : in std_logic_vector (31 downto 0);
			bd : in std_logic_vector (31 downto 0);
			bm : in std_logic_vector (31 downto 0);
			d : out std_logic_vector (31 downto 0);
			m : out std_logic_vector (31 downto 0);
			en : in std_ulogic
			);
	end component ;
	
	component mux81_32
		port (
			i0 : in std_logic_vector (31 downto 0);
			i1 : in std_logic_vector (31 downto 0);
			i2 : in std_logic_vector (31 downto 0);
			i3 : in std_logic_vector (31 downto 0);
			i4 : in std_logic_vector (31 downto 0);
			i5 : in std_logic_vector (31 downto 0);
			i6 : in std_logic_vector (31 downto 0);
			i7 : in std_logic_vector (31 downto 0);
			s0 : in std_ulogic;
			s1 : in std_ulogic;
			s2 : in std_ulogic;
			qmux : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component or32
		port (
			a : in std_logic_vector (31 downto 0);
			b : in std_logic_vector (31 downto 0);
			c : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component to1
		port (
			number : in std_logic_vector (31 downto 0);
			t1 : in std_ulogic;
			one : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component xor32
		port (
			a : in std_logic_vector (31 downto 0);
			b : in std_logic_vector (31 downto 0);
			c : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component zero_detector
		port (
			res : in std_logic_vector (31 downto 0);
			zflag : out std_ulogic
			);
	end component ;
	
	component buffer_32
		port (
			a : in std_logic_vector (31 downto 0);
			en : in std_ulogic;
			b : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component adder32
		port (
			a : in std_logic_vector (31 downto 0);
			b : in std_logic_vector (31 downto 0);
			cin : in std_ulogic;
			s : out std_logic_vector (31 downto 0);
			v : out std_ulogic;
			cout : out std_ulogic
			);
	end component ;
	
	
	---- configuration specifications for declared components 
	for u1 : and32 use entity work.and32(structure) ;
	for u4 : or32 use entity work.or32(structure);
	for u6 :xor32 use entity work.xor32(structure);
	for u7 : mask32 use entity work.mask32(structure);
	for u2 :muldiv  use entity work.muldiv(behavior);
	for u10 : to1 use entity work.to1(behavior);
	for u0 : adder32 use entity work.adder32(structure);
	for u3 : buffer_32 use entity work.buffer_32(structure);
	for u9 : command_decoder use entity work.command_decoder(behavior);
	for u12 : zero_detector use entity work.zero_detector(structure);
	for u11 : coder83 use entity work.coder83(behavior);
	for u8 : mux81_32 use entity work.mux81_32(behavior);
	for orgate : or2 use configuration cub.cfg_or2_vital;
	begin
	
	----  component instantiations  ----
	
	u0 : adder32
	port map(
		a => operand1,b => bus1153,s => bus96,
		v => cond_code(2),cin => net967,cout => scarry_cond_code);
	
	u1 : and32
	port map(
		a => operand1,b => operand2,c => bus104);
	
	u4 : or32
	port map(
		a => operand1,b => operand2,c => bus112);
	
	u6 : xor32
	port map(
		a => operand1,b => operand2,c => bus116);
	
	u7 : mask32
	port map(
	                a => operand1,b => operand2,c => bus124);
	
	u2 : muldiv
	port map(
		ad => operand1,am => operand1,bd => operand2,bm => operand2,
		d => bus189,m => bus181,en =>mul_div_en);
	
	u3 : buffer_32
	port map(
		a => bus1069,b => tempres,en => net285);
	
	u9 : command_decoder
	port map(
		addsub => net968,command => command,div => net544,en => net285,
		incr => net1123,and => net570,lmask => net582,lor => net574,lxor => net578,
		mul => net540,pass => net586,sub => net967);
	
	u10 : to1
	port map(
		number => operand2,one => bus1153,t1 => net1123);
	
	u12 : zero_detector
	port map(
		zflag => cond_code(0),res => tempres);
	
	u11 : coder83
	port map(
		a => net968,b => net540,c => net544,d => net570,d0 => net524,d1 => net528,
		d2 => net532,e => net574,f => net578,g => net582,h => net586);
	
	u8 : mux81_32
	port map(
		i0 => bus96,i1 => bus181,i2 => bus189,i3 => bus104,i4 => bus112,i5 => bus116,
		i6 => bus124,i7 => operand1,
		qmux => bus1069,
		s0 => net524,s1 => net528,s2 => net532);
		
	orgate : or2 
	port map (net540,net544,mul_div_en);
	
	cond_code(1) <= tempres(31);
	result <= tempres;
	
end structure;
