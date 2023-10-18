library ieee;
use ieee.std_logic_1164.all;

entity logicaDesvia is
  port ( JEQ        : in std_logic;
			Flag_Igual : in std_logic;
			JMP        : in std_logic;
			RET        : in std_logic;
			JSR        : in std_logic;
         saida : out std_logic_vector (1 downto 0)
  );
end entity;

architecture comportamento of logicaDesvia is

  begin
saida <= "01" when (JMP = '1') or (JEQ = '1' and Flag_igual = '1') or JSR = '1'
			else "10" when RET = '1' else "00";
end architecture;