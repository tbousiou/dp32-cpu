library	cub;
use cub.Vcomponents.all;
architecture structure of exor32 is	
	for all :eo1 use configuration	cub.cfg_eo1_vital ;
	
	begin
	
	gen : for i in 31 downto 0 generate
		exorgates : eo1 port map (b(i),s,bx(i));
	end generate;
end structure;



--------------------------------------------
--1-BIT PARTIAL FULL ADDER --
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity pfa is
	port(
		a : in std_ulogic;
		b : in std_ulogic;
		c : in std_ulogic;
		g : out std_ulogic;
		p : out std_ulogic;
		s : out std_ulogic
		);
end pfa; 

library cub;
use cub.vcomponents.all;
architecture structure of pfa is
	signal temp : std_ulogic ;
	
	---- configuration specifications for declared components 
    for all : and2 use configuration cub.cfg_and2_vital;
	for all : eo1 use configuration cub.cfg_eo1_vital;

	begin
	----  component instantiations  ----
	
	u0 : and2
	port map(a => a,b => b,q => g);
	
	u1 : eo1
	port map(a => a,b => b,q => temp);
	
	u2 : eo1
	port map(a => temp,b => c,q => s);
	
	-- output\buffer terminals
	p <= temp;
		
end structure;

----------------------------------------------
-- 4-BIT PARTIAL FULL ADDER  --
----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity pfa4 is
	port(
		c0 : in std_ulogic;c1 : in std_ulogic;c2 : in std_ulogic;c3 : in std_ulogic;
		a : in std_logic_vector (3 downto 0);b : in std_logic_vector (3 downto 0);
		g0 : out std_ulogic;g1 : out std_ulogic;g2 : out std_ulogic;g3 : out std_ulogic;
		p0 : out std_ulogic;p1 : out std_ulogic;p2 : out std_ulogic;p3 : out std_ulogic;
		s : out std_logic_vector (3 downto 0)
		);
end pfa4;

architecture structure of pfa4 is
        
	---- component declarations -----
	component pfa
		port (
			a : in std_ulogic;
			b : in std_ulogic;
			c : in std_ulogic;
			g : out std_ulogic;
			p : out std_ulogic;
			s : out std_ulogic
			);
	end component ;	
	---- configuration specifications for declared components 	 
		for all: pfa use entity work.pfa(structure)	;
	
	begin
	
	----  component instantiations  ----
	u0 : pfa
	port map(a => a(0),b => b(0),c => c0,g => g0,p => p0,s => s(0));
	u1 : pfa
	port map(a => a(1),b => b(1),c => c1,g => g1,p => p1,s => s(1));
	u2 : pfa
	port map(a => a(2),b => b(2),c => c2,g => g2,p => p2,s => s(2));
	u3 : pfa
	port map(a => a(3),b => b(3),c => c3,g => g3,p => p3,s => s(3));
	
end structure;



-------------------------------------------------
-- 4 CARRY, LOOKAHEAD LOGIC --
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity lookahead is
	port(
		c0 : in std_ulogic;
		g0 : in std_ulogic;
		g1 : in std_ulogic;
		g2 : in std_ulogic;
		g3 : in std_ulogic;
		p0 : in std_ulogic;
		p1 : in std_ulogic;
		p2 : in std_ulogic;
		p3 : in std_ulogic;
		c1 : out std_ulogic;
		c2 : out std_ulogic;
		c3 : out std_ulogic;
		g03 : out std_ulogic;
		p03 : out std_ulogic
		);
end lookahead;

library cub;
use cub.vcomponents.all;
architecture structure of lookahead is
	
	---- signal declarations used on the diagram ----
	signal net129 : std_ulogic ;signal net144 : std_ulogic ;signal net148 : std_ulogic ;
	signal net152 : std_ulogic ;signal net160 : std_ulogic ;signal net164 : std_ulogic ;
	signal net172 : std_ulogic ;signal net180 : std_ulogic ;signal net188 : std_ulogic ;
	
	---- configuration specifications for declared components 
	for all : and2 use configuration cub.cfg_and2_vital;
	for all : and3 use configuration cub.cfg_and3_vital;
	for all : and4 use configuration cub.cfg_and4_vital;	 
	for all : or2  use configuration cub.cfg_or2_vital;
	for all : or3  use configuration cub.cfg_or3_vital;
	for all : or4  use configuration cub.cfg_or4_vital;	 

	begin
	----  component instantiations  ----
	
	u0 : and2
	port map(a => p0,b => c0,q => net144);
	u1 : or2
	port map(a => g0,b => net144,q => c1);
	u2 : and2
	port map(a => p1,b => g0,q => net148);
	u3 : and3
	port map(a => p1,b => p0,c => c0,q => net129);
	u4 : or3
	port map(a => g1,b => net148,c => net129,q => c2);
	u5 : and2
	port map(a => p2,b => g1,q => net152);
	u6 : and3
	port map(a => p2,b => p1,c => g0,q => net160);
	u7 : and4
	port map(a => p2,b => p1,c => p0,d => c0,q => net164);
	u8 : or4
	port map(a => g2,b => net152,c => net160,d => net164,q => c3);
	u9 : and4
	port map(a => p3,b => p2,c => p1,d => p0,q => p03);
	u10 : and2
	port map(a => p3,b => g2,q => net188);
	u11 : and3
	port map(a => p3,b => p2,c => g1,q => net180);
	u12 : and4
	port map(a => p3,b => p2,c => p1,d => g0,q => net172);
    u13 : or4
	port map(a => g3,b => net188,c => net180,d => net172,q => g03);
		
end structure;


-------------------------------------------------
-- 2 CARRY, LOOKAHEAD LOGIC --
-------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity twolevel_lookahead is
	port(
		c0 : in std_ulogic;
		g0 : in std_ulogic;
		g1 : in std_ulogic;
		p0 : in std_ulogic;
		p1 : in std_ulogic;
		c1 : out std_ulogic;
		c2 : out std_ulogic
		);
end twolevel_lookahead;

library cub;
use cub.vcomponents.all;  
architecture structure of twolevel_lookahead is
	
	---- signal declarations used on the diagram ----
	signal net33 : std_ulogic ;
	signal net37 : std_ulogic ;
	signal net39 : std_ulogic ;
		
	---- configuration specifications for declared components 
	for all : and2 use configuration cub.cfg_and2_vital;
	for u3 : and3 use configuration cub.cfg_and3_vital;
    for u1 : or2 use configuration cub.cfg_or2_vital;
	for u4 : or3 use configuration cub.cfg_or3_vital;
	
	begin
	
	----  component instantiations  ----
	u0 : and2
	port map(a => p0,b => c0,q => net37);
	u1 : or2
	port map(a => g0,b => net37,q => c1);
	u2 : and2
	port map(a => p1,b => g0,q => net39);
	u3 : and3
	port map(a => p1,b => p0,c => c0,q => net33);
	u4 : or3
	port map(a => g1,b => net39,c => net33,q => c2);
	
end structure;


------------------------------------------------------------------------------
-- 32-BIT CARRY LOOKAHEAD ADDER-SUBTRACTOR --
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity adder32 is
	port(
		cin : in std_ulogic;
		a : in std_logic_vector (31 downto 0);
		b : in std_logic_vector (31 downto 0);
		v : out std_ulogic;
		cout : out std_ulogic;
		s : out std_logic_vector (31 downto 0)
		);
end adder32;

library cub;
use cub.vcomponents.all;
architecture structure of adder32 is
	
	---- signal declarations used on the diagram ----
	signal bx : std_logic_vector (31 downto 0);
	signal temp : std_ulogic ;
	signal
	  net1001 , net1009 , net1020, net1028 , net1039 , net1047 , net1059 
	, net1074 , net1082 , net1090 , net1098 , net1106 , net1120 
	, net1173 , net1185 , net1223 , net1234 , net1328 , net1358 , net1383 
	, net1396 , net1405 , net1418 , net1427 , net220  , net224  , net2258
	, net228 , net232 , net236 , net240 , net244 , net248 , net256 , net260 
	, net276 , net280 , net284 , net288 , net292 , net296 , net300 , net304 
	, net308 , net312 , net316 , net320 , net324 , net328 , net332 , net336 
	, net340 , net344 , net348 , net352 , net356 , net360 , net372 , net376
	, net380 , net384 , net388 , net392 , net396 , net400 , net404 , net408 
	, net412 , net416 , net420 , net424 , net428 , net432 , net436 , net440
	, net444 , net448 , net452 , net456 , net467 , net471 , net475 , net479 
	, net483 , net487 , net491 , net495 , net499 , net503 , net507 , net515 
	, net519 , net523 , net527 , net531 , net535 , net539 , net543 , net547 
	, net551 , net555 , net563 , net567 , net571 , net575 , net579 , net583 
	, net587 , net591 , net595 , net599 , net603  , net969 , net982 , net990 
			: std_ulogic ;

			---- component declarations -----
	component exor32
		port (b : in std_logic_vector (31 downto 0);
		      s : in std_ulogic;
			bx : out std_logic_vector (31 downto 0)
			);
	end component ;
	
	component lookahead
		port (
			c0 : in std_ulogic;
			g0 : in std_ulogic;
                                                 g1 : in std_ulogic;g2 : in std_ulogic;
                                                 g3 : in std_ulogic;
			p0 : in std_ulogic;p1 : in std_ulogic;
                                                p2 : in std_ulogic;p3 : in std_ulogic;
			c1 : out std_ulogic;c2 : out std_ulogic;
                                                 c3 : out std_ulogic;
			g03 : out std_ulogic;p03 : out std_ulogic
			);
	end component ;
	
	component pfa4
		port (
			a : in std_logic_vector (3 downto 0);
			b : in std_logic_vector (3 downto 0);
			c0 : in std_ulogic;
			c1 : in std_ulogic;
			c2 : in std_ulogic;
			c3 : in std_ulogic;
			g0 : out std_ulogic;
			g1 : out std_ulogic;
			g2 : out std_ulogic;
			g3 : out std_ulogic;
			p0 : out std_ulogic;
			p1 : out std_ulogic;
			p2 : out std_ulogic;
			p3 : out std_ulogic;
			s : out std_logic_vector (3 downto 0)
			);
	end component ;
	
	component twolevel_lookahead
		port (
			c0 : in std_ulogic;
			g0 : in std_ulogic;
			g1 : in std_ulogic;
			p0 : in std_ulogic;
			p1 : in std_ulogic;
			c1 : out std_ulogic;
			c2 : out std_ulogic
			);
	end component ;
	
	
	---- configuration specifications for declared components 
	
	for U20 : eo1 use configuration cub.cfg_eo1_vital;
	for U19 : exor32 use entity work.exor32(structure);	
	for all : lookahead use entity work.lookahead(structure);
	for U18 : twolevel_lookahead use entity work.twolevel_lookahead(structure);	
	for all : pfa4 use entity work.pfa4(structure);	
	begin
	
	----  component instantiations  ----
	
	u0 : pfa4
	port map(a(0) => a(28),a(1) => a(29),a(2) => a(30),a(3) => a(31),b(0) => bx(28),
		b(1) => bx(29),b(2) => bx(30),b(3) => bx(31),
		c0 => net1328,c1 => net228,
		c2 => net240,c3 => net2258,
		g0 => net224,g1 => net236,g2 => net248,g3 => net260,
		p0 => net220,p1 => net232,p2 => net244,p3 => net256,
		s(0) => s(28),s(1) => s(29),s(2) => s(30),s(3) => s(31));
	
	u1 : pfa4
	port map(
		a(0) => a(24),a(1) => a(25),a(2) => a(26),a(3) => a(27),
		b(0) => bx(24),b(1) => bx(25),b(2) => bx(26),b(3) => bx(27),
		c0 => net1358,c1 => net284,c2 => net296,c3 => net308,
		g0 => net280,g1 => net292,g2 => net304,g3 => net316,
		p0 => net276,p1 => net288,p2 => net300,p3 => net312,
		s(0) => s(24),s(1) => s(25),s(2) => s(26),s(3) => s(27));
	
	u2 : pfa4
	port map(
		a(0) => a(20),a(1) => a(21),a(2) => a(22),a(3) => a(23),
		b(0) => bx(20),b(1) => bx(21),b(2) => bx(22),b(3) => bx(23),
		c0 => net1383,c1 => net352,c2 => net340,c3 => net328,
		g0 => net356,g1 => net344,g2 => net332,g3 => net320,
		p0 => net360,p1 => net348,p2 => net336,p3 => net324,
		s(0) => s(20),s(1) => s(21),s(2) => s(22),s(3) => s(23));
	
	u3 : pfa4
	port map(
	    a(0) => a(16),a(1) => a(17),a(2) => a(18),a(3) => a(19),
	    b(0) => bx(16),b(1) => bx(17),b(2) => bx(18),b(3) => bx(19),
		c0 => net1427,c1 => net380,c2 => net392,c3 => net404,
		g0 => net376,g1 => net388,g2 => net400,g3 => net412,
		p0 => net372,p1 => net384,p2 => net396,p3 => net408,
		s(0) => s(16),s(1) => s(17),s(2) => s(18),s(3) => s(19));
	
	u4 : pfa4
	port map(
		a(0) => a(12),a(1) => a(13),a(2) => a(14),a(3) => a(15),
		b(0) => bx(12),b(1) => bx(13),b(2) => bx(14),b(3) => bx(15),
		c0 => net1418,c1 => net448,c2 => net436,c3 => net424,
		g0 => net452,g1 => net440,g2 => net428,g3 => net416,
		p0 => net456,p1 => net444,p2 => net432,p3 => net420,
		s(0) => s(12),s(1) => s(13),s(2) => s(14),s(3) => s(15));
	
	u5 : pfa4
	port map(
		a(0) => a(8),a(1) => a(9),a(2) => a(10),a(3) => a(11),
		b(0) => bx(8),b(1) => bx(9),b(2) => bx(10),b(3) => bx(11),
		c0 => net1405,c1 => net499,c2 => net487,c3 => net475,
		g0 => net503,g1 => net491,g2 => net479,g3 => net467,
		p0 => net507,p1 => net495,p2 => net483,p3 => net471,
		s(0) => s(8),s(1) => s(9),s(2) => s(10),s(3) => s(11));
	
	u6 : pfa4
	port map(
	    a(0) => a(4),a(1) => a(5),a(2) => a(6),a(3) => a(7),
	    b(0) => bx(4),b(1) => bx(5),b(2) => bx(6),b(3) => bx(7),
		c0 => net1396,c1 => net547,c2 => net535,c3 => net523,
		g0 => net551,g1 => net539,g2 => net527,g3 => net515,
		p0 => net555,p1 => net543,p2 => net531,p3 => net519,
		s(0) => s(4),s(1) => s(5),s(2) => s(6),s(3) => s(7));
	
	u7 : pfa4
	port map(
		a(0) => a(0),a(1) => a(1),a(2) => a(2),a(3) => a(3),
		b(0) => bx(0),b(1) => bx(1),b(2) => bx(2),b(3) => bx(3),
		c0 => cin,c1 => net595,c2 => net583,c3 => net571,
		g0 => net599,g1 => net587,g2 => net575,g3 => net563,
		p0 => net603,p1 => net591,p2 => net579,p3 => net567,
		s(0) => s(0),s(1) => s(1),s(2) => s(2),s(3) => s(3));
	
	u8 : lookahead
	port map(
		c0 => net1328,c1 => net228,c2 => net240,c3 => net2258,
		g0 => net224,g03 => net1120,g1 => net236,g2 => net248,g3 => net260,
		p0 => net220,p03 => net1106,p1 => net232,p2 => net244,p3 => net256);
	
	u9 : lookahead
	port map(
		c0 => net1358,c1 => net284,c2 => net296,c3 => net308,
		g0 => net280,g03 => net1098,g1 => net292,g2 => net304,g3 => net316,
		p0 => net276,p03 => net1090,p1 => net288,p2 => net300,p3 => net312);
	
	u10 : lookahead
	port map(
		c0 => net1383,c1 => net352,c2 => net340,c3 => net328,
		g0 => net356,g03 => net1082,g1 => net344,g2 => net332,g3 => net320,
		p0 => net360,p03 => net1074,p1 => net348,p2 => net336,p3 => net324);
	
	u11 : lookahead
	port map(
		c0 => net1427,c1 => net380,c2 => net392,c3 => net404,
		g0 => net376,g03 => net1059,g1 => net388,g2 => net400,g3 => net412,
		p0 => net372,p03 => net1047,p1 => net384,p2 => net396,p3 => net408);
	
	u12 : lookahead
	port map(
	    c0 => net1418,c1 => net448,c2 => net436,c3 => net424,
	    g0 => net452,g03 => net1028,g1 => net440,g2 => net428,g3 => net416,
		p0 => net456,p03 => net1039,p1 => net444,p2 => net432,p3 => net420);
	
	u13 : lookahead
	port map(
		c0 => net1405,c1 => net499,c2 => net487,c3 => net475,
		g0 => net503,g03 => net1020,g1 => net491,g2 => net479,g3 => net467,
		p0 => net507,p03 => net1009,p1 => net495,p2 => net483,p3 => net471);
	
	u14 : lookahead
	port map(
	    c0 => net1396,c1 => net547,c2 => net535,c3 => net523,
	    g0 => net551,g03 => net1001,g1 => net539,g2 => net527,g3 => net515,
		p0 => net555,p03 => net990,p1 => net543,p2 => net531,p3 => net519);
	
	u15 : lookahead
	port map(
		c0 => cin,c1 => net595,c2 => net583,c3 => net571,
		g0 => net599,g03 => net982,g1 => net587,g2 => net575,g3 => net563,
		p0 => net603,p03 => net969,p1 => net591,p2 => net579,p3 => net567);
	
	u16 : lookahead
	port map(
	c0 => net1427,c1 => net1383,c2 => net1358,c3 => net1328,
	g0 => net1059,g03 => net1234,g1 => net1082,g2 => net1098,g3 => net1120,
	p0 => net1047,p03 => net1223,p1 => net1074,p2 => net1090,p3 => net1106);
	
	u17 : lookahead
	port map(
		c0 => cin,c1 => net1396,c2 => net1405,c3 => net1418,
		g0 => net982,g03 => net1185,g1 => net1001,g2 => net1020,g3 => net1028,
		p0 => net969,p03 => net1173,p1 => net990,p2 => net1009,p3 => net1039);
	
	u18 : twolevel_lookahead
	port map(
		c0 => cin,c1 => net1427,c2 => temp,g0 => net1185,g1 => net1234,p0 => net1173,p1 => net1223);
	
	u19 : exor32
	port map(b => b,bx => bx,s => cin);
	
	u20 : eo1
	port map(a => net2258,b => temp,q => v);
	
	-- output\buffer terminals
	cout <= temp;
	
	
end structure;
