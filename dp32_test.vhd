 -------------------------------------------
 --  TOP LEVEL STRUCTURE   --
 --  clock,cpu and memory         --
 -------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;	
use work.dp32_types.all;
entity dp32_test is
end dp32_test;

architecture structure of dp32_test is
	
	component clock_gen	 
		generic (Tpw : Time; -- clock pulse width
			Tps : Time);     -- pulse separation between phases
		port (phi1, phi2 : out std_ulogic;
			reset : out std_ulogic);
	end component;
	
	component dp32
		generic( Tpd : Time);
		port (d_bus : inout std_logic_vector(31 downto 0);
			a_bus : out std_logic_vector(31 downto 0);
			read, write : out std_ulogic;
			fetch : out std_ulogic;
			ready : in  std_ulogic;
			phi1, phi2 : in  std_ulogic;
			reset : in  std_ulogic);
	end component;
	
	component memory  
		generic (Tpd ,tread,twrite: Time );
		port (d_bus : inout std_logic_vector(31 downto 0);
			a_bus : in std_logic_vector(31 downto 0);
			read, mwrite : in std_ulogic;
			ready : out std_ulogic);
	end component;
	
	signal d_bus : std_logic_vector(31 downto 0);
	signal a_bus : std_logic_vector(31 downto 0);
	signal read, write : std_ulogic;
	signal fetch : std_ulogic;
	signal ready : std_ulogic;
	signal phi1, phi2 : std_ulogic;
	signal reset : std_ulogic;
	
	for all : clock_gen use entity work.clock_gen(behavior)	; 
	for all : memory use entity work.memory(behavior) ;
	for all : dp32 use entity work.dp32(rtl)	 ;
	
	begin
	
	cg : clock_gen	
	generic map (Tpw => 8 ns, Tps => 2 ns) 		
	port map (phi1 => phi1, phi2 => phi2, reset => reset) ;
	
	proc : dp32	 
	generic map (Tpd => 1 ns)
	port map (d_bus => d_bus, a_bus => a_bus,
		read => read, write => write, fetch => fetch,
		ready => ready,
		phi1 => phi1, phi2 => phi2, reset => reset);
	
	mem : memory  
	generic map (Tpd=> 1 ns,tread=>24 ns ,twrite =>24 ns)
	port map (d_bus => d_bus, a_bus => a_bus,
		read => read, mwrite => write, ready => ready);
	
end structure;
