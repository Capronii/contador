library ieee;
use ieee.std_logic_1164.all;

entity CPU is
  -- Total de bits das entradas e saidas
  port   (
	 Wr : out std_logic;
	 Rd : out std_logic;
    ROM_Address : out std_logic_vector(8 downto 0);
    Instruction_IN: in std_logic_vector(12 downto 0);
	 Data_IN: in std_logic_vector(7 downto 0);
    Data_OUT: out std_logic_vector(7 downto 0);
    Data_Address: out std_logic_vector(8 downto 0);
	 Clock: in std_logic
  );
end entity;


architecture arquitetura of CPU is

-- Faltam alguns sinais:
  signal chavesX_ULA_B : std_logic_vector (7 downto 0);
  signal DataIn : std_logic_vector (7 downto 0);
  signal MUX_REG1 : std_logic_vector (7 downto 0);
  signal DadoOut : std_logic_vector (7 downto 0);
  signal Saida_ULA : std_logic_vector (7 downto 0);
  signal Sinais_Controle : std_logic_vector (11 downto 0);
  signal Endereco : std_logic_vector (8 downto 0);
  signal proxPC : std_logic_vector (8 downto 0);
  signal Mux_PC : std_logic_vector (8 downto 0);
  signal Chave_Operacao_ULA : std_logic;
  signal CLK : std_logic;
  signal SelMUX : std_logic;
  signal Habilita_A : std_logic;
  signal Reset_A : std_logic;
  signal Operacao_ULA : std_logic_vector (1 downto 0);
  signal Memoria_Decoder: std_logic_vector (12 downto 0);
  signal JMP: std_logic;
  signal flagSaidaUla: std_logic;
  signal SaidaRegFlag: std_logic;
  signal JEQ: std_logic;
  signal habFlagIgual: std_logic;
  signal saidaDesv: std_logic_vector (1 downto 0);
  signal saidaRET: std_logic_vector (8 downto 0);
  signal habEscritaRetorno: std_logic;
  signal RET: std_logic;
  signal JSR: std_logic;
  

begin

-- Instanciando os componentes:
CLK <= Clock;
-- Para simular, fica mais simples tirar o edgeDetector
Memoria_Decoder <= Instruction_IN;
-- O port map completo do MUX.
MUX1 :  entity work.muxGenerico2x1  generic map (larguraDados => 8)
        port map( entradaA_MUX => DataIn,
                 entradaB_MUX =>  Memoria_Decoder (7 downto 0),
                 seletor_MUX => SelMUX,
                 saida_MUX => MUX_REG1);

MUX2 : entity work.muxGenerico4x1  generic map (larguraDados => 9)
        port map(entrada0_MUX => proxPC,
                 entrada1_MUX => Memoria_Decoder (8 downto 0),
					  entrada2_MUX => saidaRET,
					  entrada3_MUX => "000000000", 
                 seletor_MUX => saidaDesv,
                 saida_MUX => Mux_PC);

-- O port map completo do Acumulador.
REGA : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => Saida_ULA, DOUT => DadoOut, ENABLE => Habilita_A, CLK => CLK, RST => '0');
			 
ENDRET : entity work.registradorGenerico   generic map (larguraDados => 9)
          port map (DIN => proxPC, DOUT => saidaRET, ENABLE => habEscritaRetorno, CLK => CLK, RST => '0');

-- O port map completo do Program Counter.3	
PC : entity work.registradorGenerico   generic map (larguraDados => 9)
          port map (DIN => Mux_PC, DOUT => Endereco, ENABLE => '1', CLK => CLK, RST => '0');

incrementaPC :  entity work.somaConstante  generic map (larguraDados => 9, constante => 1)
        port map( entrada => Endereco, saida => proxPC);


-- O port map completo da ULA:
ULA1 : entity work.ULASomaSub  generic map(larguraDados => 8)
          port map (entradaA =>DadoOut, entradaB => MUX_REG1, saida => Saida_ULA, flagZero => flagSaidaUla  ,seletor => Operacao_ULA);

-- Falta acertar o conteudo da ROM (no arquivo memoriaROM.vhd)
			 
DECO : entity work.decoderInstru 
          port map (opcode => Memoria_Decoder(12 downto 9), saida => Sinais_Controle);


FLAG1 : entity work.FlipFlop
		  port map (DIN => flagSaidaUla,
					   DOUT => SaidaRegFlag,
					   ENABLE => habFlagIgual,
						CLK => CLK,
						RST => '0');
				 
DESVIO : entity work.logicaDesvia 
			port map( JEQ => JEQ,
						 Flag_Igual  => SaidaRegFlag,
						 JMP => JMP,
						 RET => RET,
						 JSR => JSR,
						 saida => saidaDesv
  );

  
Wr <= Sinais_Controle(0);
Rd <= Sinais_Controle(1);
ROM_Address <= Endereco;
DataIn <= Data_IN;
Data_OUT <= DadoOut;
Data_Address <= Memoria_Decoder(8 downto 0);

habEscritaRetorno <= Sinais_controle(11);
JMP <= Sinais_Controle(10);
RET <= Sinais_Controle(9);
JSR <= Sinais_Controle(8);
JEQ <= Sinais_controle(7);
selMUX <= Sinais_Controle(6);
Habilita_A <= Sinais_Controle(5);
Operacao_ULA <= Sinais_Controle(4 downto 3);
habFlagIgual <= Sinais_Controle(2);




end architecture;