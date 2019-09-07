------------------------------------------------------
-- package with types for all the model --
------------------------------------------------------

Library IEEE;
use IEEE.STD_LOGIC_1164.all; 
package dp32_types is 
	
	type m32 is array(31 downto 0) of std_logic_vector(31 downto 0);
	type ALU_command is (disable, pass1, incr1,
	add, subtract, multiply, divide,
	log_and, log_or, log_xor, log_mask);
	constant unit_delay : Time := 1 ns;
	type bool_to_bit_table is array (boolean) of bit;
	constant bool_to_bit : bool_to_bit_table;
	subtype bit_32 is bit_vector(31 downto 0);
	type bit_32_array is array (integer range <>) of bit_32;
	
	subtype bit_8 is std_logic_vector(7 downto 0);	
	subtype bit_5 is std_logic_vector(4 downto 0);
	subtype CC_bits is std_logic_vector(2 downto 0);
	subtype cm_bits is std_logic_vector(3 downto 0);
	constant op_add : bit_8 := X"00";
	constant op_sub : bit_8 := X"01";
	constant op_mul : bit_8 := X"02";
	constant op_div : bit_8 := X"03";
	constant op_addq : bit_8 := X"10";
	constant op_subq : bit_8 := X"11";
	constant op_mulq : bit_8 := X"12";
	constant op_divq : bit_8 := X"13";
	constant op_land : bit_8 := X"04";
	constant op_lor : bit_8 := X"05";
	constant op_lxor : bit_8 := X"06";
	constant op_lmask : bit_8 := X"07";
	constant op_ld : bit_8 := X"20";
	constant op_st : bit_8 := X"21";
	constant op_ldq : bit_8 := X"30";
	constant op_stq : bit_8 := X"31";
	constant op_br : bit_8 := X"40";
	constant op_brq : bit_8 := X"50";
	constant op_bi : bit_8 := X"41";
	constant op_biq : bit_8 := X"51";
                function bits_to_int (bits : in bit_vector) return integer;
	

end dp32_types;	 

package body dp32_types is
	constant bool_to_bit : bool_to_bit_table :=
	(false => '0', true => '1');
	
	function bits_to_int (bits : in bit_vector) return integer is
		variable temp : bit_vector(bits'range);
		variable result : integer := 0;
		begin
		if bits(bits'left) = '1' then -- negative number
			temp := not bits;
		else
			temp := bits;
		end if;
		for index in bits'range loop -- sign bit of temp = '0'
			result := result * 2 + bit'pos(temp(index));
		end loop;
		if bits(bits'left) = '1' then
			result := (-result) - 1;
		end if;
		return result;
	end bits_to_int;
	
end dp32_types;





-----------------------------------
-- CLOCK GENERATOR --
-----------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity clock_gen is
	generic (Tpw : Time; -- clock pulse width
		Tps : Time); -- pulse separation between phases
	port (phi1, phi2 : out std_ulogic;
		reset : out std_ulogic);
end clock_gen;

architecture behavior of clock_gen is
	constant clock_period : Time := 2*(Tpw+Tps);
	begin
	reset_driver :
	reset <= '1', '0' after 2*clock_period+Tpw;
	clock_driver : process
		begin
		phi1 <= '1', '0' after Tpw;
		phi2 <= '1' after Tpw+Tps, '0' after Tpw+Tps+Tpw;
		wait for clock_period;
	end process clock_driver;
end behavior;



-------------------------------------
-- RAM MEMORY MODEL –
-------------------------------------

library IEEE,STD;
use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_SIGNED.CONV_INTEGER; 
use std.textio.all;
use work.dp32_types.all;
entity memory is
	generic (Tpd ,tread,twrite: Time );
	port (d_bus : inout  std_logic_vector(31 downto 0);
		a_bus : in std_logic_vector(31 downto 0);
		read, mwrite : in std_ulogic;
		ready : out std_ulogic);
end memory;

architecture behavior of memory is
	begin
	process
		constant low_address : integer := 0;
		constant high_address : integer :=65535	; --  (real is 4294967295)
		type memory_array is
		array (integer range low_address to high_address) of std_logic_vector(31 downto 0);

------------------------------ TEST PROGRAMMS FOR DP32  ------------------------		
--                                                                                                                     --
-- notice that :                                                                                                 --
-- R0 is always 0                                                                                            --
-- memory address must not exceed the limit of 65535 (16 line address)     --		
-- all code and data are in hexademical format                                             --
-----------------------------------------------------------------------------------------------------

-------------------TEST PROGRAMM for LOAD and STORE insructions  ---------------
	
--    variable mem : memory_array:=(
--    0=>X"10050002",                -- ADDq (R5,R0,02)    R5<=R0+02=02
--	1=>X"3006052A",                -- LDq  (R6,R5,2A)   R6<=M[R5+2A]=M[2C]
--	2=>X"20070500",3=>X"00002AAA", -- LD   (R7,R5,2AAA) R7<=M[R5+2AAA]=M[2AAC]
--    4=>X"10050501",                -- ADDq (R5,R5,01)    R5<=R5+01=03
--	5=>X"3106052A",                -- STq  (R6,R5,2A)    M[R5+2A]=M[2D]<=R6
--	6=>X"21070500",7=>X"00002AAA", -- ST   (R7,R5,2AAA) M[R5+2AAA]=M[2AAD]<=R7
--
--			44=>X"80000000",    -- M[2C]   
--			10924=>X"FFFFFFFF", -- M[2AAC]    
--			others=>X"00000000");
--------------------------------------------------------------------------------

----------- TEST PROGRAMM for ARITHMETIC and LOGICAL operations  ---------------
--									   
--	  variable mem : memory_array:=(
--          0=>X"30010014",  --  LDq  (R1,R0,14)  R1<=M[14]=A		
--			1=>X"30020015",	 --  LDq  (R2,R0,15)  R2<=M[15]=2		
--			2=>X"00030102",	 --  ADD  (R3,R1,R2)  R3<=R1+R2=C
--			3=>X"01030102",	 --  SUB  (R3,R1,R2)  R3<=R1-R2=8
--			4=>X"02030102",	 --  MUL  (R3,R1,R2)  R3<=R1*R2=14
--			5=>X"03030102",	 --  DIV  (R3,R1,R2)  R3<=R1/R2=5
--			6=>X"10030105",	 --  ADDq (R3,R1,05)  R3<=R1+05=F
--			7=>X"11030105",	 --  SUBq (R3,R1,05)  R3<=R1-05=05
--			8=>X"12030105",	 --  MULq (R3,R1,05)  R3<=R1*05=32
--			9=>X"13030105",	 --  DIVq (R3,R1,05)  R3<=R1/05=2
--			10=>X"06030102", --  LXOR (R3,R1,R2)  R3<=R1xorR2=8
--			11=>X"05030102", --  LOR  (R3,R1,R2)  R3<=R1orR2=A
--			12=>X"04030102", --  LAND (R3,R1,R2)  R3<=R1andR2=2
--			13=>X"07030102", --  LMASK(R3,R1,R2)  R3<=R1and not(R2)=8
--			
--			20=>X"0000000A", --  M[14]=A
--			21=>X"00000002", --  M[15]=2
--			others=>X"00000000");
--------------------------------------------------------------------------------  

------------------------------ TEST PROGRAMM for BRANCH instructions  ----------
--   variable mem : memory_array:=(
--   0=>X"00010000",                 -- L0: ADD (R1,R0,R0)               R1<=0
--   1=>X"500100FF",                 --     BRq (if not zero) 
--   2=>X"400E0000",3=>X"00000005",  -- L1: BR  (if neg.or overf.) L4
--   4=>X"510A00FF",                 --     BIq (if negative)
--   5=>X"410C0000",6=>X"00000000",  -- L3: BI  (if overflow) L0
--   7=>X"11010101",                 --     SUB (R1,R1,01)          R1<=R1-1=-1
--   8=>X"500A00F9",                 --     BRQ (if negative) L1 
--   9=>X"3002000F",                 -- L4  LDq (R2,R0,0F)    R2<=M[R0+0F]=M[0F]
--   10=>X"00010102",                --     ADD (R1,R1,R2)           R1<=R1+R2
--   11=>X"510C0005",                --     BIq (if overflow) L3
--			
--			15=>X"80000000",   --M[0F]
--			others=>X"00000000");
------------------------------------------------------------------------------------------------------------								

--------------------------------  GENERAL TEST PROGRAMM 1 ---------------------- 
-- this proram calculates the mean value of 8 numbers that are placed in memory --  positions 21-28 
--		variable mem : memory_array:=(  
--          0=>X"00030000", --     ADD  (R3,R0,R0)  R3<=R0+R0=0
--		1=>X"30010008", --     LDq  (R1,R0,08)  R1<=M[R0+08]=M[08]
--		2=>X"30020114", -- L1: LDq  (R2,R1,14)  R2<=M[R1+14]
--		3=>X"00030302", --     ADD  (R3,R3,R2)  R3<=R3+R2
--		4=>X"11010101", --     SUBq (R1,R1,01)  R1<=R1-1
--		5=>X"500100FC", --     BRq  (if not zero)  L1 
--		6=>X"13030308", --     DIVq (R3,R3,08)  R3<=R3/8
--		7=>X"31030014", --     STq  (R3,R0,14)  M[R0+14]=M[14]<=R3
--				
--				8=>X"00000008", 
--				21=>X"00000008",
--				22=>X"00000007",
--				23=>X"00000006",
--				24=>X"00000005",
--				25=>X"00000008",
--				26=>X"00000003",
--				27=>X"00000002",
--				28=>X"00000001",
--				others=>X"00000000" ); 
--------------------------------------------------------------------------------									
			
--------------------------------  GENERAL TEST PROGRAMM 2 ---------------------- --	
--R1 list length
--R2 list starting addres      
--R3 upper limit
--R4 down limit
--R5 current element
--R6 temporary storage
--R7 index register
--R10 sum
--R11 N
--R12 mean
variable mem : memory_array:=(
0=>X"20010000",1=>X"00000200",--  LD R1 [R0,200]  R1<=M[R0+200]=M[200]   2=>X"1002007F",               --  ADDq R2,R0,7F   R2<=R0+7F=7F   mask 
3=>X"04010102",               --  LAND R1,R1,R2    R1<=R1&R2take the 7 lsb of R1
4=>X"20020000",5=>X"00000201",--  LD R2 [R0,201]    R2<=M[R0+201]=M[201]
                                                     R2=starting address
6=>X"20030000",7=>X"00000202",--   LD R3 [R0,202]    R3<=M[R0+202]=M[202] 
                                                           R3=up  limit
8=>X"20040000",9=>X"00000203",--  LD R4 [R0,203]    R4<=M[R0+203]=M[203]
                                                           R4=down limit
 10=>X"000A0000",               --  ADD R10,R0,R0     R10=0      sum=0
 11=>X"000B0000",               --  ADD R11,R0,R0     R11=0       N=0
 12=>X"00070200",               --  ADD R7,R2,R0      R7<=R2  
 13=>X"30050200",         -- LBL2:  LDq R5 [R2,00]    R5<=M[R2+00]=M[R2]load
                                                                   element
 14=>X"01060305",          --       SUB R6,R3,R5      R6<=R3-R5           
 15=>X"500A0006",           --      BRq (if neg) LBL1 +6
 16=>X"01060504",            --     SUB R6,R5,R4      R6<=R5-R4
 17=>X"500A0004",             --    BRQ (if neg) LBL1 +4
 18=>X"000A0A05",              --   ADD R10,R10,R5    R10<=R10+R5  current sum
 19=>X"100B0B01",               --  ADDq R11,R11,01   R11<=R11+1  increment N
 20=>X"31050700",               --  STq R5 [R7,00]    M[R7]<=R5    store element
 21=>X"10070701",               --  ADDq R7,R7,01     R7<=R7+1   increment R7
 22=>X"10020201",       --  LBL1:   ADDq R2,R2,01     R2<=R2+1   increment R2
 23=>X"11010101",         --        SUBq R1,R1,01     R1<=R1-1   decrement R1
 24=>X"500100F4",           --      BRq if not zero LBL2 -12
 25=>X"030C0A0B",             --    DIV R12,R10,R11  R12<=R10/R11
 26=>X"210A0000",27=>X"00000204", --   ST R10 [204]
 28=>X"210B0000",29=>X"00000205",  --  ST R11 [205]
 30=>X"210C0000",31=>X"00000206",  --  ST R12 [206]

256=>X"00000004", --100    elements
257=>X"00000009",
258=>X"0000000E",
259=>X"0000000A",
260=>X"00000002",
261=>X"00000001",
262=>X"00000003",

512=>X"00000007",     --200   "list length"
513=>X"00000100",    --201   "starting address
514=>X"00000009",        --202   "up limit"
515=>X"00000003",      --203   "down limit"
			others=>X"00000000");

		variable address : integer;	
		
		variable i: integer;
		variable out_line,out_line2  : line ;
		file outfile : Text  is 
		out "c:\My documents\outfile1.txt";
		file outfile2 : Text  is 
		out "c:\My documents\outfile2.txt";
		
		begin		 
				 
		d_bus <= (others=>'Z')after Tpd;
		ready <= '0' after Tpd;
		--
		-- wait for a command
		--
		wait until (read = '1') or (mwrite = '1');
		--
		-- dispatch read or write cycle
		--
		address :=CONV_INTEGER(a_bus)  ;
		
		write(out_line,address);
		writeline(outfile, out_line);
		
		if address >= low_address and address <= high_address then
			-- address match for this memory
			if mwrite = '1' then
				wait for twrite;
				mem(address) := d_bus ;
				ready <= '1';
				wait until mwrite = '0'; -- wait until end of write    
                                                                    cycle
			
				i:=CONV_INTEGER(mem(address));
				write(out_line2,i);
				writeline(outfile2, out_line2);
				
			else -- read = '1'
				wait for tread ;
				d_bus <= mem(address)  ; -- fetch data
				ready <= '1' ;
				wait until read = '0'; -- hold for read cycle
			end if;
		end if;	
		
	end process;
end behavior;


-----------------------------------------
-- 32-bit TRISTATE BUFFER --
-----------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
entity buffer_32 is
	port (a : in std_logic_vector(31 downto 0);
		b : out std_logic_vector(31 downto 0) ;
		en : in std_ulogic);
end buffer_32;

library	cub;
use cub.Vcomponents.all ;
architecture structure of buffer_32 is
	for all : it1 use configuration	cub.cfg_it1_vital;
	for all : in1 use configuration	cub.cfg_in1_vital;
	signal   invout  :std_logic_vector(31 downto 0);
	
	begin 
	iobufer_gen : for i in 31 downto 0 generate
		inverters            : in1 port	map (a(i),invout(i) ); 
		inv_tristate_buffers : it1 port	map (invout(i),en,b(i) );
	end generate ;			
end structure;
	 

--------------------------------
-- 32-bit REGISTER    --
--------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all; 
entity latch_32 is
	port (d : in std_logic_vector(31 downto 0);
		  q : out std_logic_vector(31 downto 0);
		 en : in std_ulogic );
end latch_32;

library	cub;
use cub.Vcomponents.all;
architecture structure of latch_32 is
	
	for all : in8 use configuration	cub.cfg_in8_vital ;	
	for all : bu4 use configuration	cub.cfg_bu4_vital ;	
	for all : dl8 use configuration	cub.cfg_dl8_vital ;	
	
	signal s_en :std_ulogic;	  
	signal s_qn :std_logic_vector(31 downto 0);
	signal s_gn :std_logic_vector(3 downto 0);
	begin  
	en_buf4 : bu4 port map (en,s_en);  
	
	gen1 : for i in 3 downto 0 generate
		invert8 :in8 port map (s_en,s_gn(i));
	end generate;	
	
	gen2 : for i in 31 downto 0 generate 
		dlatches : dl8 port map (d(i),s_gn(i mod 4),q(i),s_qn(i));
	end generate;	
	
end structure;

architecture behavior of latch_32 is
	begin
	process (d, en)
		begin
		if en = '1' then
			q <= d after 1 ns ;
		end if;
	end process;
end behavior;	


-------------------------------
-- 3-bit REGISTER     -- 
-------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
entity latch_3 is
	port (d : in std_logic_vector(2 downto 0);
		  q : out std_logic_vector(2 downto 0);
		 en : in std_ulogic );
end latch_3;   

library	cub;
use cub.Vcomponents.all;
architecture structure of latch_3 is
	
	for all : in3 use configuration	cub.cfg_in3_vital ;	
	for all : bu3 use configuration	cub.cfg_bu3_vital ;	
	for all : dl8 use configuration	cub.cfg_dl8_vital ;	
	
	signal s_en :std_ulogic;	  
	signal s_qn :std_logic_vector(2 downto 0);
	signal s_gn :std_ulogic ;
	begin  
	en_buf3 : bu3 port map (en,s_en);  
	inverter3 : in3 port map(s_en,s_gn);
	
	gen : for i in 2 downto 0 generate 
		dlatches : dl8 port map (d(i),s_gn,q(i),s_qn(i));
	end generate;	
	
end structure;	
 

-----------------------------------------
-- 32-bit LATCHING BUFFER --
------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;
entity latch_buffer_32 is
	port (d : in std_logic_vector(31 downto 0);
		q : out std_logic_vector(31 downto 0) ;
		latch_en : in std_ulogic;
		out_en : in std_ulogic);
end latch_buffer_32;

library	cub;
use cub.Vcomponents.all;
architecture structure of latch_buffer_32 is
	
	for all : in8 use configuration	 cub.cfg_in8_vital ;
	for all : bu4 use configuration	 cub.cfg_bu4_vital ;
	for all : dl8z use configuration cub.cfg_dl8z_vital ;	 
	
	signal s_en,s_out_en :std_ulogic;	  
	signal s_gn :std_logic_vector(3 downto 0);
	
	begin  	 
	out_en_inv:in8 port map (out_en,s_out_en);
	en_buf4 : bu4 port map (latch_en,s_en);  
	
	gen1 : for i in 3 downto 0 generate
		invert8 :in8 port map (s_en,s_gn(i));
	end generate;	
	
	gen2 : for i in 31 downto 0 generate 
		dlatches : dl8z port map (d(i),s_out_en,s_gn(i mod 4),q(i));
	end generate;	
	
end structure;	
  

------------------------------------------------------
-- SIGN EXTENDING  32-bit BUFFER  --
-- (extends the bit7 of a input)                --
-------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all; 
entity signext_8_32 is
	port (a : in std_logic_vector(7 downto 0);
		b : out std_logic_vector(31 downto 0) ;
		en : in std_ulogic);
end signext_8_32;

library	cub;
use cub.Vcomponents.all;
architecture structure of signext_8_32 is	

    for all : in1  use configuration	cub.cfg_in1_vital ;	
	for all : it1  use configuration	cub.cfg_it1_vital ;
	for all : in8  use configuration	cub.cfg_in8_vital ;	
	for all : it14 use configuration	cub.cfg_it14_vital ;	
	
	
	signal s_int : std_logic_vector(7 downto 0);
	signal extension : std_logic;
	
	begin
	gen1 : for i in 0 to 6 generate 
		inverters1 : in1 port map (a(i),s_int(i));
		tristate1  : it1 port map  (s_int(i),en,b(i));
	end generate;
	
	invert8 : in8 port map (a(7),s_int(7));
	tristate1    : it1 port map  (s_int(7),en,b(7));  
	
	gen2 : for i in 0 to 5 generate	 
		ext_trist4 : it14 port map(s_int(7),en,extension);
	end generate;
	
	b(31)<=extension; b(25)<=extension; b(19)<=extension; b(13)<=extension;
	b(30)<=extension; b(24)<=extension; b(18)<=extension; b(12)<=extension;
	b(29)<=extension; b(23)<=extension; b(17)<=extension; b(11)<=extension;
	b(28)<=extension; b(22)<=extension; b(16)<=extension; b(10)<=extension;
	b(27)<=extension; b(21)<=extension; b(15)<=extension; b(9)<=extension;
	b(26)<=extension; b(20)<=extension; b(14)<=extension; b(8)<=extension;
end structure;	 



------------------------------------------------------
-- CONDITION CODE COMPARATOR --
------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;
entity cond_code_comparator is
	port (cc : in CC_bits;
		cm : in cm_bits;
		result : out std_ulogic);
end cond_code_comparator;

library	cub;
use	cub.Vcomponents.all;
architecture structure of cond_code_comparator is

    for all : ao222 use configuration	cub.cfg_ao222_vital ;	
	for all : ao22  use configuration	cub.cfg_ao22_vital ;	
	for all : bu2   use configuration	cub.cfg_bu2_vital ;	
	for all : in1   use configuration	cub.cfg_in1_vital ;	
	
	signal	s_int,a,b,c,d : std_ulogic;
	begin
	comp_ao222 : ao222 port map (cc(2),cm(2),cc(1),cm(1),cc(0),cm(0),s_int);
	bu2_1 : bu2 port map(s_int,a);
	bu2_2 : bu2 port map (cm(3),b);
	inv1  :in1  port map (a,c);
	inv2  :in1  port map  (b,d);
	com_ao22 :ao22 port	map (a,b,c,d,result);
	
end structure;


------------------------------------------------
-- 32 -bit PROGRAMM COUNTER --
------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;
entity PC_reg is
	port (d : in std_logic_vector(31 DOWNTO 0);
		q : out STD_LOGIC_VECTOR(31 DOWNTO 0):=X"00000000";
		latch_en : in STD_ULOGIC;
		out_en : in STD_ULOGIC;
		reset : in STD_ULOGIC);
end PC_reg;

library	cub;
use cub.Vcomponents.all;
architecture structure of  PC_reg  is	
	
	for all : in1 use configuration	cub.cfg_in1_vital ;		
	for all : dla use configuration	cub.cfg_dla_vital ;	
	for all : it1 use configuration	cub.cfg_it1_vital ;
	for all : bu1 use configuration	cub.cfg_bu1_vital ;	
	
	signal srn : std_ulogic;
	signal sq1,sqn1,sq2,sqn2,sgn1,sgn2 : std_ulogic_vector (31 downto 0) ;
	begin
	
		inverter1 : in1 port map(reset,srn);
		pc_gen : for i in 31 downto 0 generate
			
		dla_latches1 : dla port map ( d=>d(i),gn=>sgn1(i),rn=>srn,q=>sq1(i),qn=>sqn1(i) )	;
		dla_latches2 : dla port map ( d=>sq1(i),gn=>sgn2(i),rn=>srn,q=>sq2(i),qn=>sqn2(i) )	;
		inverters  : in1  port map (a=>latch_en,q=>sgn1(i));
		buffers :  bu1	port map   (a=> latch_en ,q=>sgn2(i));
		inv_tristates : it1 port map  ( a=>sqn2(i),e=>out_en,q=>q(i) ) ;
	end generate;
end structure;

-----------------------------------------
-- 2 to 1, 5-bit MULTIPLEXER --
------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all; 
entity mux5_2_1 is
	port (i0, i1 : in std_logic_vector(4 downto 0);
		y : out std_logic_vector(4 downto 0);
		sel : in std_ulogic);
end mux5_2_1;

architecture behavior of mux5_2_1 is
	begin
	process (i0,i1,sel)
		begin
		if sel='0' then
			y<=i0;
		elsif sel='1' then
			y<=i1 ;
		end if;
		
	end process;		
end behavior;

library	cub;
use cub.Vcomponents.all;
architecture structure of mux5_2_1 is	
	
	for all : mu2 use configuration	cub.cfg_mu2_vital ;
	
	begin
	mux_gen :for i in 4 downto 0 generate
		multiplexers : mu2 port map(i0(i),i1(i),y(i),sel); 	
	end generate;
end structure ;	


-------------------------------------------
-- 32 to 1, 1-bit MULTIPLEXER --
-------------------------------------------

library	ieee;
use ieee.std_logic_1164.all;
entity mux1_32_1 is
	port (ivec : in std_logic_vector(31 downto 0);
		sel : in std_logic_vector(4 downto 0);
		outline: out std_ulogic);
end mux1_32_1;

library	cub;
use cub.Vcomponents.all;
architecture structure of mux1_32_1 is	  
	for all : mu4 use configuration	cub.cfg_mu4_vital ;
	for all : mu8 use configuration	cub.cfg_mu8_vital ;
	
	signal	s_mu8out : std_logic_vector(3 downto 0);
	begin
	gen :for i in 0 to 3 generate
		mux8: mu8 port map(ivec(8*i),ivec(8*i+1),ivec(8*i+2),ivec(8*i+3),
			ivec(8*i+4),ivec(8*i+5),ivec(8*i+6),ivec(8*i+7),
			s_mu8out(i),sel(0),sel(1),sel(2));
	end generate;
	mux4 : mu4 port map (s_mu8out(0),s_mu8out(1),s_mu8out(2),s_mu8out(3),outline,sel(3),sel(4));
end structure;







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
---------------------------------------------
-- this circuit is the interface for   --
--  input B in order to achive        --
-- two's complement subtraction  --	
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity exor32 is
		port (b : in std_logic_vector (31 downto 0);
		      s : in std_ulogic;
			bx : out std_logic_vector (31 downto 0)
			);

end exor32;	 

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







-----------------------------------------------
-- 32-bit two input LOGICAL AND  --
-----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity and32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end and32;

library	cub;
use cub.vcomponents.all;
architecture structure of and32 is	
	for all :and2 use configuration	cub.cfg_and2_vital ;
	
	begin
	
	gen : for i in 31 downto 0 generate
		andgates : and2 port map (a(i),b(i),c(i));
	end generate;
end structure; 


library ieee;
use ieee.std_logic_1164.all;
entity mask32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end mask32;

library	cub;
use cub.vcomponents.all;
architecture structure of mask32 is
	signal notb : std_logic_vector(31 downto 0) ;  
	
	for all :and2 use configuration	cub.cfg_and2_vital ;
	for all :in1 use configuration	cub.cfg_in1_vital ;
	begin
	
	gen : for i in 31 downto 0 generate
		andgates : and2 port map (a(i),notb(i),c(i));
		notgates : in1 port map  (b(i),notb(i))	  ;
		
	end generate; 
	
end structure; 


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


--------------------------------------------
-- 32-bit two input LOGICAL OR --
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity or32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end or32;

library	cub;
use cub.vcomponents.all;
architecture structure of or32 is	
	
	for all :or2 use configuration	cub.cfg_or2_vital ;
	
	begin
	gen : for i in 31 downto 0 generate
		orgates : or2 port map (a(i),b(i),c(i));
	end generate;
end structure;

library ieee;
use ieee.std_logic_1164.all;

entity to1 is
	port(
		number : in std_logic_vector(31 downto 0);
		one : out std_logic_vector(31 downto 0);
		t1 : in std_ulogic );
end to1;

architecture behavior of to1 is
	begin
	one <= X"00000001" when t1='1' else
	number  ;
end behavior;   








---------------------------------------------
-- 32-bit two input LOGICAL XOR --
---------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity xor32 is
	port(
		a : in std_logic_vector(31 downto 0);
		b : in std_logic_vector(31 downto 0);
		c : out std_logic_vector(31 downto 0)
		);
end xor32;

library	cub;
use cub.vcomponents.all;
architecture structure of xor32 is	
	for all :eo1 use configuration	cub.cfg_eo1_vital ;
	
	begin
	
	gen : for i in 31 downto 0 generate
		exorgates : eo1 port map (a(i),b(i),c(i));
	end generate;
end structure;


----------------------------------------------------------------
-- 32-bit ZERO DETECTOR for the ALU result --
----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
entity zero_detector is
	port(
		res : in std_logic_vector(31 downto 0);
		zflag : out std_ulogic
		);
end zero_detector;


library cub;
use cub.vcomponents.all;
architecture structure of zero_detector is
	signal st : std_ulogic_vector(3 downto 0);	 
	for all : no8 use configuration	cub.cfg_no8_vital; 
	for all : and4 use configuration	cub.cfg_and4_vital;
	begin
	
	andgates : for i in 3 downto 0 generate 
		no8gates : no8 port map(res(i*8),res(i*8+1),res(i*8+2),res(i*8+3),
			res(i*8+4),res(i*8+5),res(i*8+6),res(i*8+7),st(i));
	end generate ;
	and4gate : and4 port map (st(0),st(1),st(2),st(3),zflag);  
	
end structure;	 


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




-------------------------------------
--         DP32 	          --
-- datapath and control      --
-------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.dp32_types.all;

entity dp32 is
	generic (Tpd : Time:= 1 ns );
	port (  d_bus : inout std_logic_vector(31 downto 0) ;
		a_bus : out std_logic_vector(31 downto 0);
		read, write : out std_ulogic;
		fetch : out std_ulogic;
		ready : in std_ulogic;
		phi1, phi2 : in std_ulogic;
		reset : in std_ulogic);
end dp32;

architecture RTL of dp32 is
	component reg_file_32_rrw
		port (a1 : in std_logic_vector(4 downto 0);
			q1 : out std_logic_vector(31 downto 0) ;
			en1 : in std_ulogic;
			a2 : in std_logic_vector(4 downto 0);
			q2 : out std_logic_vector(31 downto 0);
			en2 : in std_ulogic;
			a3 : in std_logic_vector(4 downto 0);
			d3 : in std_logic_vector(31 downto 0);
			en3 : in std_ulogic);
	end component;
	
	
	component PC_reg 
			port (d : in std_logic_vector(31 downto 0);
			q : out std_logic_vector(31 downto 0);
			latch_en : in std_ulogic;
			out_en : in std_ulogic;
			reset : in std_ulogic);
	end component;
	
	component alu32 is
		port(
			command : in ALU_command;
			operand1 : in STD_LOGIC_VECTOR (31 downto 0);
			operand2 : in STD_LOGIC_VECTOR (31 downto 0);
			cond_code : out std_logic_vector (2 downto 0);
			result : out STD_LOGIC_VECTOR (31 downto 0)
			);
	end component;
	
	component cond_code_comparator
		port (cc : in CC_bits;
			cm : in cm_bits;
			result : out std_ulogic);
	end component;
	
	component buffer_32
		port (a : in std_logic_vector(31 downto 0);
			b : out std_logic_vector(31 downto 0) ;
			en : in std_ulogic);
	end component;
	
	component latch_32 
		port (d : in std_logic_vector(31 downto 0);
			q : out std_logic_vector(31 downto 0);
			en : in std_ulogic );
	end component;
	
	component latch_3 
		port (d : in std_logic_vector(2 downto 0);
			q : out std_logic_vector(2 downto 0);
			en : in std_ulogic );
	end component;   
	
	component latch_buffer_32
			port (d : in std_logic_vector(31 downto 0);
			q : out std_logic_vector(31 downto 0) ;
			latch_en : in std_ulogic;
			out_en : in std_ulogic);
	end component;
	
	component signext_8_32
		port (a : in std_logic_vector(7 downto 0);
			b : out std_logic_vector(31 downto 0) ;
			en : in std_ulogic);
	end component;	
	
	component mux5_2_1 is
		port (i0, i1 : in std_logic_vector(4 downto 0);
			y : out std_logic_vector(4 downto 0);
			sel : in std_ulogic);
	end component;	 
	
	
	signal op1_bus :  std_logic_vector(31 downto 0);
	signal op2_bus : std_logic_vector(31 downto 0);
	signal r_bus :   std_logic_vector(31 downto 0);
	signal ALU_CC :  CC_bits;
	signal CC : CC_bits;
	signal current_instr :  std_logic_vector(31 downto 0);
	alias instr_a1 : bit_5 is current_instr(12 downto 8);   
	alias instr_a2 : bit_5 is current_instr(4 downto 0);    
	alias instr_a3 : bit_5 is current_instr(20 downto 16);  
	alias instr_op : bit_8 is current_instr(31 downto 24);
	alias instr_cm : cm_bits is current_instr(19 downto 16);
	signal reg_a2 :  std_logic_vector(4 downto 0);
	signal reg_result :  std_logic_vector(31 downto 0);
	signal addr_latch_en : std_ulogic;
	signal disp_latch_en : std_ulogic;
	signal disp_out_en : std_ulogic;
	signal d2_en : std_ulogic;
	signal dr_en : std_ulogic;
	signal instr_latch_en : std_ulogic;
	signal immed_signext_en : std_ulogic;
	signal ALU_op : ALU_command;
	signal CC_latch_en : std_ulogic;
	signal CC_comp_result : std_ulogic;
	signal PC_latch_en : std_ulogic;
	signal PC_out_en : std_ulogic;
	signal reg_port1_en : std_ulogic;
	signal reg_port2_en : std_ulogic;
	signal reg_port3_en : std_ulogic;
	signal reg_port2_mux_sel : std_ulogic;
	signal reg_res_latch_en : std_ulogic; 
	signal immed_sign_dum : std_logic_vector(2 downto 0);
	
	for all: reg_file_32_rrw use entity work.reg_file_32_rrw(structure) ;	
	for all: PC_reg          use entity work.PC_reg(structure)	;
	for all: ALU32          use entity work.ALU32(structure)	;
	for all: cond_code_comparator  use entity 
                           work.cond_code_comparator(structure);	
	for all: buffer_32       use entity work.buffer_32(structure)	;
	for all: latch_32        use entity work.latch_32(structure)	; 
	for all: latch_3         use entity work.latch_3(structure);
	for all: latch_buffer_32       use entity work.latch_buffer_32(structure)	; 	   
	for all: signext_8_32          use entity work.signext_8_32(structure)	;  
	for all: mux5_2_1        use entity work.mux5_2_1(structure)	;  
	
	
	
	begin -- architecture RTL of dp32
	
	reg_file : reg_file_32_RRW
	
	port map (a1 => instr_a1, q1 => op1_bus, en1 => reg_port1_en,
		a2 => reg_a2, q2 => op2_bus, en2 => reg_port2_en,
		a3 => instr_a3, d3 => reg_result, en3 => reg_port3_en);
	
	reg_port2_mux : mux5_2_1
	port map (i0 => instr_a2, i1 => instr_a3, y => reg_a2,
		sel => reg_port2_mux_sel);
	
	reg_res_latch : latch_32
	
	port map (d => r_bus, q => reg_result, en => reg_res_latch_en);
	
	PC : PC_reg	 
	
	port map ( d => r_bus, q => op1_bus,
		latch_en => PC_latch_en, out_en => PC_out_en,
		reset => reset)			;
	
	ALU : ALU32
	
	port map (operand1 => op1_bus, operand2=> op2_bus,
		result => r_bus,cond_code => ALU_CC,
		command => ALU_op);
	
	CC_reg : latch_3
	
	port map (d => ALU_CC, q => CC, en => CC_latch_en);
	
	CC_comp : cond_code_comparator 
	
	port map (cc => CC, cm => instr_cm, result => CC_comp_result);
	
	dr_buffer : buffer_32
	
	port map (a => d_bus, b => r_bus, en => dr_en);
	
	d2_buffer : buffer_32
	port map (a=> op2_bus, b => d_bus, en => d2_en);
	
	disp_latch : latch_buffer_32
	
	port map (d => d_bus, q => op2_bus,
		latch_en => disp_latch_en, out_en => disp_out_en);
	
	addr_latch : latch_32
	
	port map (d => r_bus, q => a_bus, en => addr_latch_en);
	
	instr_latch : latch_32
	port map (d => r_bus, q => current_instr, en => instr_latch_en);
	
	immed_signext : signext_8_32
	port map (a=>current_instr(7 downto 0), b => op2_bus, en => immed_signext_en);
	
	controller : block
		port (phi1, phi2 : in std_ulogic;
			reset : in std_ulogic;
			opcode : in bit_8;
			read, write, fetch : out std_ulogic;
			ready : in std_ulogic;
			addr_latch_en : out std_ulogic;
			disp_latch_en : out std_ulogic;
			disp_out_en : out std_ulogic;
			d2_en : out std_ulogic;
			dr_en : out std_ulogic;
			instr_latch_en : out std_ulogic;
			immed_signext_en : out std_ulogic;
			ALU_op : out ALU_command;
			CC_latch_en : out std_ulogic;
			CC_comp_result : in std_ulogic;
			PC_latch_en : out std_ulogic;
			PC_out_en : out std_ulogic;
			reg_port1_en : out std_ulogic;
			reg_port2_en : out std_ulogic;
			reg_port3_en : out std_ulogic;
			reg_port2_mux_sel : out std_ulogic;
			reg_res_latch_en : out std_ulogic);
		port map (phi1 => phi1, phi2 => phi2,
                                                reset => reset,
                                                opcode => instr_op,
			read => read, write => write, 
                                                fetch => fetch,ready => ready,
			addr_latch_en => addr_latch_en,
                                                 disp_latch_en => disp_latch_en,
			disp_out_en => disp_out_en,
			d2_en => d2_en,dr_en => dr_en,
			instr_latch_en => instr_latch_en,
                                                immed_signext_en => immed_signext_en,
                                                 ALU_op => ALU_op,
			CC_latch_en => CC_latch_en,
                                                 CC_comp_result => CC_comp_result,
			PC_latch_en => PC_latch_en,
                                                PC_out_en => PC_out_en,
			reg_port1_en => reg_port1_en,
                                                reg_port2_en => reg_port2_en,
                                                reg_port3_en => reg_port3_en,
			reg_port2_mux_sel => reg_port2_mux_sel,
                                                reg_res_latch_en => reg_res_latch_en);
		
		begin -- block controller
		state_machine: process
			type controller_state is
			(resetting, fetch_0, fetch_1, fetch_2, decode,
			disp_fetch_0, disp_fetch_1, disp_fetch_2,
			execute_0, execute_1, execute_2);
			variable state, next_state : controller_state;
			variable write_back_pending : boolean;
			variable initr0 :boolean :=true ;
			type ALU_op_select_table is
			array (natural range 0 to 255) of ALU_command;
			constant ALU_op_select : ALU_op_select_table :=
			(16#00# => add,
                                                 16#01# => subtract,
                                                 16#02# => multiply,
                                                 16#03# => divide,
			16#10# => add,
                                                16#11# => subtract,
                                                16#12# => multiply,
                                                 16#13# => divide,
			16#04# => log_and,
                                                16#05# => log_or,
                                                 16#06# => log_xor,
                                                16#07# => log_mask,
			others => disable);
			
			begin -- process state_machine
			-- start of clock cycle
			
			wait until phi1 = '1';
			-- check for reset
		
			if reset = '1' then
				state := resetting;
				-- reset external bus signals
				read <= '0' after Tpd;
				fetch <= '0' after Tpd;
				write <= '0' after Tpd;
				
				-- reset dp32 internal control signals

				addr_latch_en <= '0' after Tpd;disp_latch_en <= '0' after Tpd;
				disp_out_en <= '0' after Tpd;d2_en <= '0' after Tpd;
				dr_en <= '0' after Tpd;instr_latch_en <= '0' after Tpd;
				immed_signext_en <= '0' after Tpd;
				ALU_op <= disable after Tpd;
				CC_latch_en <= '0' after Tpd;
				PC_latch_en <= '0' after Tpd;PC_out_en <= '0' after Tpd;
				reg_port1_en <= '0' after Tpd;reg_port2_en <= '0' after Tpd;
                                                                 reg_port3_en <= '0' after Tpd;
				reg_port2_mux_sel <= '0' after Tpd;reg_res_latch_en <= '0' after Tpd;
				--
				-- clear write-back flag
				--
				write_back_pending := false;
				
				if initr0=true then     -- INITIALIZE RO refister to zero -------
					wait for 2 ns ;					  	
					pc_out_en<='1';						
					alu_op<=pass1;						
					reg_res_latch_en <= '1';  				
					instr_latch_en <= '1';					
					wait for 2 ns;						
					alu_op<=disable;											reg_res_latch_en <= '0';  									                              instr_latch_en <= '0';										
					wait for 2 ns;											pc_out_en<='0';											               reg_port3_en <= '1';										
					wait for 2 ns;	  										reg_port3_en <= '0';										                                 initr0:=false;											                 end if;                                                      ------------------ 
			else -- reset = '0'
				state := next_state;
			end if;
			
			-- dispatch action for current state
			--
			case state is
				when resetting =>
				--
				-- check for reset going inactive at end of clock cycle
				--
				wait until phi2 = '0';
				if reset = '0' then
					next_state := fetch_0;
				else
					next_state := resetting;
				end if;
				--
				when fetch_0 =>
				--
				-- clean up after previous execute cycles
				--
				reg_port1_en <= '0' after Tpd;
				reg_port2_mux_sel <= '0' after Tpd;
				reg_port2_en <= '0' after Tpd;
				immed_signext_en <= '0' after Tpd;
				disp_out_en <= '0' after Tpd;
				dr_en <= '0' after Tpd;
				read <= '0' after Tpd;
				d2_en <= '0' after Tpd;
				write <= '0' after Tpd;
				--
				-- handle pending register write-back
				--
				if write_back_pending then
					reg_port3_en <= '1' after Tpd;
				end if;
				--
				-- enable PC via ALU to address latch
				--
				PC_out_en <= '1' after Tpd; -- enable PC onto op1_bus
				ALU_op <= pass1 after Tpd; -- pass PC to r_bus
				--
				wait until phi2 = '1';
				addr_latch_en <= '1' after Tpd; -- latch instr address
				wait until phi2 = '0';
				addr_latch_en <= '0' after Tpd;
				--
				next_state := fetch_1;
				--
				when fetch_1 =>
				--
				-- clear pending register write-back
				--
				if write_back_pending then
					reg_port3_en <= '0' after Tpd;
					write_back_pending := false;
				end if;
				--
				-- increment PC & start bus read
				--
				ALU_op <= incr1 after Tpd; -- increment PC onto r_bus
				fetch <= '1' after Tpd;
				read <= '1' after Tpd;
				--
				wait until phi2 = '1';
				PC_latch_en <= '1' after Tpd; -- latch incremented PC
				wait until phi2 = '0';
				PC_latch_en <= '0' after Tpd;
				--
				next_state := fetch_2;
				--
				when fetch_2 =>
				--
				-- cleanup after previous fetch_1
				--
				PC_out_en <= '0' after Tpd; -- disable PC from op1_bus
				ALU_op <= disable after Tpd; -- disable ALU from r_bus
				--
				-- latch current instruction
				--
				dr_en <= '1' after Tpd; -- enable fetched instr onto
                                                                   r_bus
				--
				wait until phi2 = '1';
				instr_latch_en <= '1' after Tpd; -- latch fetched inst from r_bus
				wait until phi2 = '0';
				instr_latch_en <= '0' after Tpd;
				--
				if ready = '1' then
					next_state := decode;
				else
					next_state := fetch_2; -- extend bus read
				end if;
				
				when decode =>
				--
				-- terminate bus read from previous fetch_2
				--
				fetch <= '0' after Tpd;
				read <= '0' after Tpd;
				dr_en <= '0' after Tpd; -- disable fetched instr from r_bus

				--
				-- delay to allow decode logic to settle
				--
				wait until phi2 = '0';
				--
				-- next state based on opcode of currect instruction
				--
				case opcode is
					when op_add | op_sub | op_mul | op_div
					| op_addq | op_subq | op_mulq | op_divq
					| op_land | op_lor | op_lxor | op_lmask
					| op_ldq | op_stq =>
					next_state := execute_0;
					when op_ld | op_st =>
					next_state := disp_fetch_0; -- fetch offset
					when op_br | op_bi =>
					if CC_comp_result = '1' then -- if branch taken
						next_state := disp_fetch_0; -- fetch displacement
					else -- else
						next_state := execute_0; -- increment PC
						-- past displacement
					end if;

					when op_brq | op_biq =>
					if CC_comp_result = '1' then -- if branch taken
						next_state := execute_0; -- add immed displacement to PC
					else -- else
						next_state := fetch_0; -- no action needed
					end if;
					when others =>
					assert false report "illegal instruction" severity  warning;
					next_state := fetch_0; -- ignore and carry on
				end case; -- op
				
				when disp_fetch_0 =>
				--
				-- enable PC via ALU to address latch
				--
				PC_out_en <= '1' after Tpd; -- enable PC onto op1_bus
				ALU_op <= pass1 after Tpd; -- pass PC to r_bus
				--
				wait until phi2 = '1';
				addr_latch_en <= '1' after Tpd; -- latch displacement
                                                                     address
				wait until phi2 = '0';
				addr_latch_en <= '0' after Tpd;
				--
				next_state := disp_fetch_1;
				--
				when disp_fetch_1 =>
				--
				-- increment PC & start bus read
				--
				ALU_op <= incr1 after Tpd; -- increment PC onto r_bus
				fetch <= '1' after Tpd;
				read <= '1' after Tpd;
				--
				wait until phi2 = '1';
				PC_latch_en <= '1' after Tpd; -- latch incremented PC
				wait until phi2 = '0';
				PC_latch_en <= '0' after Tpd;
				--
				next_state := disp_fetch_2;
				--
				when disp_fetch_2 =>
				--
				-- cleanup after previous disp_fetch_1
				--
				PC_out_en <= '0' after Tpd; -- disable PC from op1_bus
				ALU_op <= disable after Tpd; -- disable ALU from r_bus
				--
				-- latch displacement
				--
				wait until phi2 = '1';
				disp_latch_en <= '1' after Tpd; -- latch fetched disp
                                                              from r_bus
				wait until phi2 = '0';
				disp_latch_en <= '0' after Tpd;
				--
				if ready = '1' then
					next_state := execute_0;
				else
					next_state := disp_fetch_2; -- extend bus read
				end if;
				
				when execute_0 =>
				--
				-- terminate bus read from previous disp_fetch_2
				--
				fetch <= '0' after Tpd;
				read <= '0' after Tpd;
				--
				case opcode is
					when op_add | op_sub | op_mul | op_div
					| op_addq | op_subq | op_mulq | op_divq
					| op_land | op_lor | op_lxor | op_lmask =>
					-- enable r1 onto op1_bus
					reg_port1_en <= '1' after Tpd;
					if opcode = op_addq or opcode = op_subq
						or opcode = op_mulq or opcode = op_divq then
						-- enable i8 onto op2_bus
						immed_signext_en <= '1' after Tpd;
					else
						-- select a2 as port2 address
						reg_port2_mux_sel <= '0' after Tpd;
						-- enable r2 onto op2_bus
						reg_port2_en <= '1' after Tpd;
					end if;
					-- select ALU operation
					ALU_op <=ALU_op_select(bits_to_int(to_bitvector(opcode))) after Tpd; 
					--	ALU_op <=  pass1;
					--
					wait until phi2 = '1';
					-- latch cond codes from ALU
					CC_latch_en <= '1' after Tpd;
					-- latch result for reg write
					reg_res_latch_en <= '1' after Tpd;
					wait until phi2 = '0';
					CC_latch_en <= '0' after Tpd;
					reg_res_latch_en <= '0' after Tpd;
					--
					next_state := fetch_0; -- execution complete
					write_back_pending := true; -- register write_back
                                                                      required
					--
					when op_ld | op_st | op_ldq | op_stq =>
					-- enable r1 to op1_bus
					reg_port1_en <= '1' after Tpd;
					if opcode = op_ld or opcode = op_st then
						-- enable displacement to op2_bus
						disp_out_en <= '1' after Tpd;
					else
						-- enable i8 to op2_bus
						immed_signext_en <= '1' after Tpd;
					end if;
					ALU_op <= add after Tpd; -- effective address to
                                                 		 r_bus
					--
					wait until phi2 = '1';
					addr_latch_en <= '1' after Tpd; -- latch effective
                                                                      address
					wait until phi2 = '0';
					addr_latch_en <= '0' after Tpd;
					--
					next_state := execute_1;
					--
					
					when op_br | op_bi | op_brq | op_biq =>
					if CC_comp_result = '1' then
						if opcode = op_br then
							PC_out_en <= '1' after Tpd;
							disp_out_en <= '1' after Tpd;
						elsif opcode = op_bi then
							reg_port1_en <= '1' after Tpd;
							disp_out_en <= '1' after Tpd;
						elsif opcode = op_brq then
							PC_out_en <= '1' after Tpd;
							immed_signext_en <= '1' after Tpd;
						else -- opcode = op_biq
							reg_port1_en <= '1' after Tpd;
							immed_signext_en <= '1' after Tpd;
						end if;
						ALU_op <= add after Tpd;
					else
						assert opcode = op_br or opcode = op_bi
						report "reached state execute_0 "
						& "when brq or biq not taken"
						severity error;
						PC_out_en <= '1' after Tpd;
						ALU_op <= incr1 after Tpd;
					end if;
					--
					wait until phi2 = '1';
					PC_latch_en <= '1' after Tpd; -- latch incremented
                                                                            PC
					wait until phi2 = '0';
					PC_latch_en <= '0' after Tpd;
					--
					next_state := fetch_0;
					--
					when others =>
					null;
				end case; -- op
				--
				when execute_1 =>
				--
				-- opcode is load or store instruction.
				-- cleanup after previous execute_0
				--
				reg_port1_en <= '0' after Tpd;
				if opcode = op_ld or opcode = op_st then
					-- disable displacement from op2_bus
					disp_out_en <= '0' after Tpd;
				else
					-- disable i8 from op2_bus
					immed_signext_en <= '0' after Tpd;
				end if;
				ALU_op <= disable after Tpd; -- disable ALU from r_bus
				--
				-- start bus cycle
				--
				if opcode = op_ld or opcode = op_ldq then
					fetch <= '0' after Tpd; -- start bus read
					read <= '1' after Tpd;
				else -- opcode = op_st or opcode = op_stq
					reg_port2_mux_sel <= '1' after Tpd; -- address a3
                                                                      to port2
					reg_port2_en <= '1' after Tpd; -- reg port2 to
                                                                   op2_bus
					d2_en <= '1' after Tpd; -- enable op2_bus to d_bus
                                                                         buffer
					write <= '1' after Tpd; -- start bus write
				end if;
				--
				next_state := execute_2;
				--
				when execute_2 =>
				--
				-- opcode is load or store instruction.
				-- for load, enable read data onto r_bus
				--
				if opcode = op_ld or opcode = op_ldq then
					dr_en <= '1' after Tpd; -- enable data to r_bus
					wait until phi2 = '1';
					-- latch data in reg result latch
					reg_res_latch_en <= '1' after Tpd;
					wait until phi2 = '0';
					reg_res_latch_en <= '0' after Tpd;
					write_back_pending := true; -- write-back pending
				end if;
				--
				if ready ='1' then
				   next_state := fetch_0;
				else next_state :=execute_2;
				end if;
				--
			end case; -- state
		end process state_machine;
	end block controller;
end RTL;

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