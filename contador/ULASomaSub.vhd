library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;    -- Biblioteca IEEE para funções aritméticas

entity ULASomaSub is
    generic ( larguraDados : natural := 8 );
    port (
      entradaA, entradaB:  in STD_LOGIC_VECTOR((larguraDados-1) downto 0);
      seletor:  in STD_LOGIC_VECTOR(1 downto 0);
		flagZero: out std_logic;
      saida:    out STD_LOGIC_VECTOR((larguraDados-1) downto 0)
    );
end entity;

architecture comportamento of ULASomaSub is
   signal soma :      STD_LOGIC_VECTOR((larguraDados-1) downto 0);
   signal subtracao : STD_LOGIC_VECTOR((larguraDados-1) downto 0);
	signal passa :     STD_LOGIC_VECTOR((larguraDados-1) downto 0);
	signal sai_inter : STD_LOGIC_VECTOR((larguraDados-1) downto 0); 
    begin
      soma      <= STD_LOGIC_VECTOR(unsigned(entradaA) + unsigned(entradaB));
      subtracao <= STD_LOGIC_VECTOR(unsigned(entradaA) - unsigned(entradaB));
		passa     <= entradaB;
		
      sai_inter <= soma when (seletor = "01") else 
					subtracao when (seletor = "00") else
					passa;
					
		flagZero <=  not (sai_inter(0) or sai_inter(1) or sai_inter(2) or sai_inter(3) or sai_inter(4) or sai_inter(5) or sai_inter(6) or 
											sai_inter(7));
		saida <= sai_inter;
		
end architecture;