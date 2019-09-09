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
