----------------------------------------------------------
-- COMMAND DECODER FOR THE ALU --
-----------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.dp32_types.all;
entity command_decoder is
	port(
		command : in alu_command;
		en : out std_ulogic;
		incr : out std_ulogic;
		addsub : out std_ulogic;
		mul : out std_ulogic;
		div : out std_ulogic;
		land : out std_ulogic;
		lor : out std_ulogic;
		lxor : out std_ulogic;
		lmask : out std_ulogic;
		pass : out std_ulogic;
		sub : out std_ulogic
		);
end command_decoder;

architecture behavior of command_decoder is
	
	begin
	
	process	(command)
		begin	
		incr<='0';sub<='0';   addsub<='0';mul<='0';div<='0';land<='0';lor<='0';lxor<='0';lmask<='0';pass<='0';
		case command is 
		when disable  => en <='0' after 1 ns;	-- disable	alu
		when incr1    => incr<='1' ; addsub<='1'; en<='1';   --incr1
			when add      =>  addsub<='1' ;sub<='0';en<='1'; --add
			when multiply => mul<= '1' ;	en<='1';	 --multiply
			when divide   => div<= '1' ;en<='1';	--divide
			when log_and  => land <='1' ;	en<='1';	 --log_and
			when log_or   => lor <='1' ;en<='1';	  --log_or
			when log_xor  => lxor <='1' ;	en<='1';	 --log_xor
			when log_mask => lmask <='1' ;en<='1';	 --log_mask
			when pass1    => pass<='1' ;	en<='1';	 -- pass
			when subtract => addsub<='1' ; sub<='1';en<='1'; --subtract	   
			
		end case ; 
	end process	;
end behavior;
