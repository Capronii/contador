library ieee;
use ieee.std_logic_1164.all;

entity decoderInstru is
  port ( opcode : in std_logic_vector(3 downto 0);
         saida : out std_logic_vector(13 downto 0)
  );
end entity;

architecture comportamento of decoderInstru is

  constant NOP  : std_logic_vector(3 downto 0) := "0000";
  constant LDA  : std_logic_vector(3 downto 0) := "0001";
  constant SOMA : std_logic_vector(3 downto 0) := "0010";
  constant SUB  : std_logic_vector(3 downto 0) := "0011";
  constant LDI	 : std_logic_vector(3 downto 0) := "0100";
  constant STA	 : std_logic_vector(3 downto 0) := "0101";
  constant JMP : std_logic_vector(3 downto 0) := "0110";
  constant JEQ : std_logic_vector(3 downto 0) := "0111";
  constant CEQ : std_logic_vector(3 downto 0) := "1000";
  constant JSR : std_logic_vector(3 downto 0) := "1001";
  constant RET : std_logic_vector(3 downto 0) := "1010";
  constant GT : std_logic_vector(3 downto 0) := "1011";
  constant JGT : std_logic_vector(3 downto 0) := "1100";
  
  alias habEscritaMEM : std_logic is saida(0);
  alias habLeituraMEM : std_logic is saida(1);
  alias habFlagIgual : std_logic is saida(2);
  alias operacao : std_logic_vector is saida(4 downto 3);
  alias habilitaA : std_logic is saida(5);
  alias selMUX : std_logic is saida(6);
  alias jeq2 : std_logic is saida(7);
  alias jsr2 : std_logic is saida(8);
  alias ret2 : std_logic is saida(9);
  alias jmp2 : std_logic is saida(10);
  alias habEscritaRet : std_logic is saida(11);
  alias gt2 : std_logic is saida(12);
  alias jgt2 : std_logic is saida(13);

  begin
		habEscritaMEM <= '1' when (opcode = STA) else '0';
		habLeituraMEM <= '1' when (opcode = LDA) or (opcode = SOMA) or (opcode = SUB) or (opcode = CEQ) or (opcode = GT) else '0';
		habFlagIgual  <= '1' when (opcode = CEQ) else '0';
		operacao 	  <= "10" when (opcode = LDA) or (opcode = LDI) else "01" when (opcode = SOMA) else "00";
		habilitaA     <= '1' when (opcode = LDA) or (opcode = SOMA) or (opcode = SUB) or (opcode = LDI) else '0';
		selMUX        <= '1' when (opcode = LDI) else '0';
		jeq2			  <= '1' when (opcode = JEQ) else '0';
		jsr2			  <= '1' when (opcode = JSR) else '0';
		ret2			  <= '1' when (opcode = RET) else '0';
		jmp2			  <= '1' when (opcode = JMP) else '0';
		habEscritaRet <= '1' when (opcode = JSR) else '0';
		gt2				  <= '1' when (opcode = GT) else '0';
		jgt2			  <= '1' when (opcode = JGT) else '0';
  
  
--saida <= "00000000000000" when opcode = NOP else
--         "00000000110010" when opcode = LDA else
--         "00000000101010" when opcode = SOMA else
--         "00000000100010" when opcode = SUB else
--         "00000001110000" when opcode = LDI else
--			"00000000000001" when opcode = STA else
--			"00010000000000" when opcode = JMP else
--			"00000010000000" when opcode = JEQ else
--			"00000000000110" when opcode = CEQ else
--			"00100100000000" when opcode = JSR else
--			"00001000000000" when opcode = RET else	
--			"01000000010010" when opcode = GT else
--			"10000000000000" when opcode = JGT else
--         "00000000000000";  -- NOP para os opcodes Indefinidos
end architecture;