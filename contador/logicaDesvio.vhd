library ieee;
use ieee.std_logic_1164.all;

entity logicaDesvio is
	port (
		FLAG_EQ : in std_logic;
		JEQ : in std_logic;
		JSR: in std_logic;
		RET: in std_logic;
		JMP: in std_logic;
		Sel_MUX_PC: out std_logic_vector (1 downto 0)
	);
end entity;

architecture comportamento of logicaDesvio is
	begin
   Sel_MUX_PC <= "01" when (JMP ='1') or (JEQ='1' and FLAG_EQ = '1') or JSR='1'
						else "10" when (RET='1') else "00";
end architecture;