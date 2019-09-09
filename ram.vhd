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
