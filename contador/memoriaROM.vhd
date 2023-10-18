library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaROM is
   generic (
          dataWidth: natural := 13;
          addrWidth: natural := 9
    );
   port (
          Endereco : in std_logic_vector (addrWidth-1 DOWNTO 0);
          Dado : out std_logic_vector (dataWidth-1 DOWNTO 0)
    );
end entity;

architecture assincrona of memoriaROM is
  
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


  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
  begin
      -- Palavra de Controle = SelMUX, Habilita_A, Reset_A, Operacao_ULA
      -- Inicializa os endereços:
tmp(0) := NOP & '0' & x"00";	-- NOP 
tmp(1) := LDI & '0' & x"00";	-- LDI $0    	#Início do Setup
tmp(2) := STA & '1' & x"20";	-- STA @288    	#Zerando hexas
tmp(3) := STA & '1' & x"21";	-- STA @289
tmp(4) := STA & '1' & x"22";	-- STA @290
tmp(5) := STA & '1' & x"23";	-- STA @291
tmp(6) := STA & '1' & x"24";	-- STA @292
tmp(7) := STA & '1' & x"25";	-- STA @293
tmp(8) := STA & '1' & x"00";	-- STA @256    	#Zerando leds
tmp(9) := STA & '1' & x"01";	-- STA @257
tmp(10) := STA & '1' & x"02";	-- STA @258
tmp(11) := STA & '0' & x"00";	-- STA @0    	#Armazenando 0 em unidade, dezena, centena, etc
tmp(12) := STA & '0' & x"01";	-- STA @1
tmp(13) := STA & '0' & x"02";	-- STA @2
tmp(14) := STA & '0' & x"03";	-- STA @3
tmp(15) := STA & '0' & x"04";	-- STA @4
tmp(16) := STA & '0' & x"05";	-- STA @5
tmp(17) := STA & '0' & x"06";	-- STA @6    	#Constante de comparacao (0)
tmp(18) := STA & '0' & x"0F";	-- STA @15   	#Flag que para contagem
tmp(19) := STA & '1' & x"FE";	-- STA @510
tmp(20) := STA & '1' & x"FF";	-- STA @511
tmp(21) := STA & '1' & x"FD";	-- STA @509
tmp(22) := LDI & '0' & x"01";	-- LDI $1
tmp(23) := STA & '0' & x"07";	-- STA @7    	#Constante de Incremento (1)
tmp(24) := LDI & '0' & x"0A";	-- LDI $10
tmp(25) := STA & '0' & x"08";	-- STA @8    	#Constante de limite no display (10)
tmp(26) := LDI & '0' & x"00";	-- LDI $0
tmp(27) := STA & '0' & x"09";	-- STA @9    	#Limite de contagem em unidade, dezena, centena, etc
tmp(28) := STA & '0' & x"0A";	-- STA @10  
tmp(29) := STA & '0' & x"0B";	-- STA @11
tmp(30) := STA & '0' & x"0C";	-- STA @12
tmp(31) := STA & '0' & x"0D";	-- STA @13
tmp(32) := STA & '0' & x"0E";	-- STA @14
tmp(33) := LDI & '0' & x"09";	-- LDI $9
tmp(34) := STA & '0' & x"10";	-- STA @16  	#Constante de limite de valor
tmp(35) := NOP & '0' & x"00";	-- NOP  	#Loop principal
tmp(36) := LDA & '1' & x"61";	-- LDA @353 	# Le o valor de KEY1
tmp(37) := CEQ & '0' & x"06";	-- CEQ @6 	# Compara o valor de KEY1 com 0
tmp(38) := JEQ & '0' & x"23";	-- JEQ @INICIOLOOP 	# Se for igual a 0, fica no aguardo para quando for 1
tmp(39) := JSR & '0' & x"3F";	-- JSR @CONFIGLIMITE 	# Se for diferente de 0, entra na sub rotina de configuracao de Limite
tmp(40) := NOP & '0' & x"00";	-- NOP
tmp(41) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(42) := STA & '1' & x"20";	-- STA @288 	# Zera o HEX1
tmp(43) := STA & '1' & x"21";	-- STA @289 	# Zera o HEX2
tmp(44) := STA & '1' & x"22";	-- STA @290 	# Zera o HEX3
tmp(45) := STA & '1' & x"23";	-- STA @291 	# Zera o HEX4
tmp(46) := STA & '1' & x"24";	-- STA @292 	# Zera o HEX5
tmp(47) := STA & '1' & x"25";	-- STA @293 	# Zera o HEX6
tmp(48) := STA & '1' & x"00";	-- STA @256 	# Zera os LEDS(7~0)
tmp(49) := STA & '1' & x"02";	-- STA @258 	# Zera os LED(9)
tmp(50) := STA & '1' & x"01";	-- STA @257 	# Zera os LED(8) 
tmp(51) := NOP & '0' & x"00";	-- NOP  	# Incrementa ate chegar no limite de contagem
tmp(52) := LDA & '1' & x"60";	-- LDA @352 	# Le o valor de KEY0
tmp(53) := CEQ & '0' & x"06";	-- CEQ @6   	# Compara o valor de KEY0 com 0
tmp(54) := JEQ & '0' & x"38";	-- JEQ @PULA1 	# Se for igual a 0, nao incrementa e atualiza os displays
tmp(55) := JSR & '0' & x"CE";	-- JSR @INCREMENTA 	# Se for diferente de 0, entra na sub rotina de incremento
tmp(56) := NOP & '0' & x"00";	-- NOP 
tmp(57) := JSR & '1' & x"0B";	-- JSR @ATUALIZA 	# Atualiza os displays
tmp(58) := JSR & '1' & x"19";	-- JSR @CHECALIMITE 	# Checa pra ver se passou do limite setado
tmp(59) := LDA & '0' & x"0F";	-- LDA @15 	# Le o valor da flag de inibir contagem
tmp(60) := CEQ & '0' & x"06";	-- CEQ @6 	# Compara com 0 a flag (flag com valor 1 -> ativa, flag com valor 0 -> desativada)
tmp(61) := JEQ & '0' & x"33";	-- JEQ @INCREMENTADOR 	#Se a flag for 0, pode continuar incrementando
tmp(62) := JMP & '1' & x"3C";	-- JMP @TRAVA 	# Se for 1, trava a contagem
tmp(63) := NOP & '0' & x"00";	-- NOP  	#Rotina de configuracao de limite
tmp(64) := LDI & '0' & x"01";	-- LDI $1 	# Carrega o valor 1
tmp(65) := STA & '1' & x"00";	-- STA @256 	# Bota no endereco dos LEDS(7-0)
tmp(66) := STA & '1' & x"FE";	-- STA @510 	#Limpa a leitura de KEY1
tmp(67) := NOP & '0' & x"00";	-- NOP 
tmp(68) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(69) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(70) := JGT & '0' & x"48";	-- JGT @VALORATUALIZADO 	#Se for maior que 9, atualiza os displays
tmp(71) := JMP & '0' & x"4A";	-- JMP @IGNORA
tmp(72) := NOP & '0' & x"00";	-- NOP 
tmp(73) := LDI & '0' & x"09";	-- LDI $9
tmp(74) := NOP & '0' & x"00";	-- NOP 
tmp(75) := STA & '1' & x"20";	-- STA @288 	# Hex 0
tmp(76) := LDA & '1' & x"61";	-- LDA @353 	# Le KEY1
tmp(77) := CEQ & '0' & x"06";	-- CEQ @6 	#Compara KEY1 com 0
tmp(78) := JEQ & '0' & x"43";	-- JEQ @ESPERAUNIDADE  	#Se for 0, ou seja, nao esta apertado, espera ate apertar
tmp(79) := STA & '1' & x"FE";	-- STA @510 	#Limpa a leitura de KEY1
tmp(80) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(81) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(82) := JGT & '0' & x"54";	-- JGT @VALORATUALIZADO2 	#Se for maior que 9, atualiza os displays
tmp(83) := JMP & '0' & x"56";	-- JMP @IGNORA2
tmp(84) := NOP & '0' & x"00";	-- NOP 
tmp(85) := LDI & '0' & x"09";	-- LDI $9
tmp(86) := NOP & '0' & x"00";	-- NOP 
tmp(87) := STA & '0' & x"09";	-- STA @9   	#Armazena o valor das chaves no limite das unidades
tmp(88) := NOP & '0' & x"00";	-- NOP 
tmp(89) := LDI & '0' & x"04";	-- LDI $4 	#Carrega o valor 4
tmp(90) := STA & '1' & x"00";	-- STA @256 	# Bota o valor nos LEDS
tmp(91) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(92) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(93) := JGT & '0' & x"5F";	-- JGT @VALORATUALIZADO3 	#Se for maior que 9, atualiza os displays
tmp(94) := JMP & '0' & x"61";	-- JMP @IGNORA3
tmp(95) := NOP & '0' & x"00";	-- NOP 
tmp(96) := LDI & '0' & x"09";	-- LDI $9
tmp(97) := NOP & '0' & x"00";	-- NOP 
tmp(98) := STA & '1' & x"21";	-- STA @289 	# Hex 1
tmp(99) := LDA & '1' & x"61";	-- LDA @353 	#Le o valor de KEY1 novamente
tmp(100) := CEQ & '0' & x"06";	-- CEQ @6 	#Compara com 0 o valor de KEY1 
tmp(101) := JEQ & '0' & x"58";	-- JEQ @ESPERADEZENA 	#Se for igual a 0, ficar em LOOP "esperando" o valor mudar
tmp(102) := STA & '1' & x"FE";	-- STA @510 	#Se for diferente de 0, Limpa a leitura de KEY1
tmp(103) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(104) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(105) := JGT & '0' & x"6B";	-- JGT @VALORATUALIZADO4 	#Se for maior que 9, atualiza os displays
tmp(106) := JMP & '0' & x"6D";	-- JMP @IGNORA4
tmp(107) := NOP & '0' & x"00";	-- NOP 
tmp(108) := LDI & '0' & x"09";	-- LDI $9
tmp(109) := NOP & '0' & x"00";	-- NOP 
tmp(110) := STA & '0' & x"0A";	-- STA @10 	#Armazena o valor das chaves no limte das dezenas
tmp(111) := NOP & '0' & x"00";	-- NOP 
tmp(112) := LDI & '0' & x"10";	-- LDI $16 	# Carrega o valor 16 no acumulador
tmp(113) := STA & '1' & x"00";	-- STA @256 	# Bota o valor nos LEDS
tmp(114) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(115) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(116) := JGT & '0' & x"76";	-- JGT @VALORATUALIZADO5 	#Se for maior que 9, atualiza os displays
tmp(117) := JMP & '0' & x"78";	-- JMP @IGNORA5
tmp(118) := NOP & '0' & x"00";	-- NOP 
tmp(119) := LDI & '0' & x"09";	-- LDI $9
tmp(120) := NOP & '0' & x"00";	-- NOP 
tmp(121) := STA & '1' & x"22";	-- STA @290 	# Hex 2
tmp(122) := LDA & '1' & x"61";	-- LDA @353 	#Le o valor de KEY1 novamente
tmp(123) := CEQ & '0' & x"06";	-- CEQ @6 	#Compara com 0 o valor de KEY1 
tmp(124) := JEQ & '0' & x"6F";	-- JEQ @ESPERACENTENA 	#Se for igual a 0, ficar em LOOP "esperando" o valor mudar
tmp(125) := STA & '1' & x"FE";	-- STA @510 	#Se for diferente de 0, Limpa a leitura de KEY1
tmp(126) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(127) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(128) := JGT & '0' & x"82";	-- JGT @VALORATUALIZADO6 	#Se for maior que 9, atualiza os displays
tmp(129) := JMP & '0' & x"84";	-- JMP @IGNORA6
tmp(130) := NOP & '0' & x"00";	-- NOP 
tmp(131) := LDI & '0' & x"09";	-- LDI $9
tmp(132) := NOP & '0' & x"00";	-- NOP 
tmp(133) := STA & '0' & x"0B";	-- STA @11 	#Armazena o valor das chaves no limite das centenas
tmp(134) := NOP & '0' & x"00";	-- NOP 
tmp(135) := LDI & '0' & x"20";	-- LDI $32 	# Carrega o valor 32 no acumulador
tmp(136) := STA & '1' & x"00";	-- STA @256 	# Bota o valor nos LEDS
tmp(137) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(138) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(139) := JGT & '0' & x"8D";	-- JGT @VALORATUALIZADO7 	#Se for maior que 9, atualiza os displays
tmp(140) := JMP & '0' & x"8F";	-- JMP @IGNORA7
tmp(141) := NOP & '0' & x"00";	-- NOP 
tmp(142) := LDI & '0' & x"09";	-- LDI $9
tmp(143) := NOP & '0' & x"00";	-- NOP 
tmp(144) := STA & '1' & x"23";	-- STA @291 	# Hex 3
tmp(145) := LDA & '1' & x"61";	-- LDA @353 	#Le o valor de KEY1 novamente
tmp(146) := CEQ & '0' & x"06";	-- CEQ @6 	#Compara com 0 o valor de KEY1
tmp(147) := JEQ & '0' & x"86";	-- JEQ @ESPERAUNIDADEMILHAR 	#Se for igual a 0, ficar em LOOP "esperando" o valor mudar
tmp(148) := STA & '1' & x"FE";	-- STA @510 	#Se for diferente de 0, Limpa a leitura de KEY1
tmp(149) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(150) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(151) := JGT & '0' & x"99";	-- JGT @VALORATUALIZADO8 	#Se for maior que 9, atualiza os displays
tmp(152) := JMP & '0' & x"9B";	-- JMP @IGNORA8
tmp(153) := NOP & '0' & x"00";	-- NOP 
tmp(154) := LDI & '0' & x"09";	-- LDI $9
tmp(155) := NOP & '0' & x"00";	-- NOP 
tmp(156) := STA & '0' & x"0C";	-- STA @12 	#Armazena o valor das chaves no limite das unidades de milhar
tmp(157) := NOP & '0' & x"00";	-- NOP 
tmp(158) := LDI & '0' & x"80";	-- LDI $128 	# Carrega o valor 128 no acumulador
tmp(159) := STA & '1' & x"00";	-- STA @256 	# Bota o valor nos LEDS
tmp(160) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(161) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(162) := JGT & '0' & x"A4";	-- JGT @VALORATUALIZADO9 	#Se for maior que 9, atualiza os displays
tmp(163) := JMP & '0' & x"A6";	-- JMP @IGNORA9
tmp(164) := NOP & '0' & x"00";	-- NOP 
tmp(165) := LDI & '0' & x"09";	-- LDI $9
tmp(166) := NOP & '0' & x"00";	-- NOP 
tmp(167) := STA & '1' & x"24";	-- STA @292 	# Hex 4
tmp(168) := LDA & '1' & x"61";	-- LDA @353 	#Le o valor de KEY1 novamente
tmp(169) := CEQ & '0' & x"06";	-- CEQ @6 	#Compara com 0 o valor de KEY1 
tmp(170) := JEQ & '0' & x"9D";	-- JEQ @ESPERADEZENAMILHAR 	#Se for igual a 0, ficar em LOOP "esperando" o valor mudar
tmp(171) := STA & '1' & x"FE";	-- STA @510 	#Se for diferente de 0, Limpa a leitura de KEY1
tmp(172) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(173) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(174) := JGT & '0' & x"B0";	-- JGT @VALORATUALIZADO10 	#Se for maior que 9, atualiza os displays
tmp(175) := JMP & '0' & x"B2";	-- JMP @IGNORA10
tmp(176) := NOP & '0' & x"00";	-- NOP 
tmp(177) := LDI & '0' & x"09";	-- LDI $9
tmp(178) := NOP & '0' & x"00";	-- NOP 
tmp(179) := STA & '0' & x"0D";	-- STA @13 	#Armazena o valor das chaves no limite das dezenas de milhar
tmp(180) := NOP & '0' & x"00";	-- NOP 
tmp(181) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(182) := STA & '1' & x"00";	-- STA @256 	# Zera o valor nos LEDS(7~0)
tmp(183) := LDI & '0' & x"01";	-- LDI $1 	# Carrega o valor 1 no acumulador
tmp(184) := STA & '1' & x"01";	-- STA @257 	# Bota o valor nos LEDS
tmp(185) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(186) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(187) := JGT & '0' & x"BD";	-- JGT @VALORATUALIZADO11 	#Se for maior que 9, atualiza os displays
tmp(188) := JMP & '0' & x"BF";	-- JMP @IGNORA11
tmp(189) := NOP & '0' & x"00";	-- NOP 
tmp(190) := LDI & '0' & x"09";	-- LDI $9
tmp(191) := NOP & '0' & x"00";	-- NOP 
tmp(192) := STA & '1' & x"25";	-- STA @293 	# Hex 5
tmp(193) := LDA & '1' & x"61";	-- LDA @353 	#Le o valor de KEY1 novamente
tmp(194) := CEQ & '0' & x"06";	-- CEQ @6 	#Compara com 0 o valor de KEY1
tmp(195) := JEQ & '0' & x"B4";	-- JEQ @ESPERACENTENAMILHAR 	#Se for igual a 0, ficar em LOOP "esperando" o valor mudar
tmp(196) := STA & '1' & x"FE";	-- STA @510 	#Se for diferente de 0, Limpa a leitura de KEY1
tmp(197) := LDA & '1' & x"40";	-- LDA @320 	#Le o valor das chaves SW(7~0)
tmp(198) := GT & '0' & x"10";	-- GT @16 	#Compara com 9
tmp(199) := JGT & '0' & x"C9";	-- JGT @VALORATUALIZADO12 	#Se for maior que 9, atualiza os displays
tmp(200) := JMP & '0' & x"CB";	-- JMP @IGNORA12
tmp(201) := NOP & '0' & x"00";	-- NOP 
tmp(202) := LDI & '0' & x"09";	-- LDI $9
tmp(203) := NOP & '0' & x"00";	-- NOP 
tmp(204) := STA & '0' & x"0E";	-- STA @14 	#Armazena o valor das chaves no limite das centenas de milhar
tmp(205) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(206) := NOP & '0' & x"00";	-- NOP 
tmp(207) := STA & '1' & x"FF";	-- STA @511 	#Limpa a leitura de KEY1
tmp(208) := NOP & '0' & x"00";	-- NOP 
tmp(209) := LDA & '0' & x"00";	-- LDA @0 	#Carrega o valor da unidade no acumulador
tmp(210) := SOMA & '0' & x"07";	-- SOMA @7     	#Incrementa 1 na unidade
tmp(211) := CEQ & '0' & x"08";	-- CEQ @8      	#Compara unidade com 10
tmp(212) := JEQ & '0' & x"D7";	-- JEQ @UNIDADEPASSOU  	#Se for igual a 10, incrementa a dezena
tmp(213) := STA & '0' & x"00";	-- STA @0 	#Se for diferente de 10, armazena o valor da unidade
tmp(214) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(215) := NOP & '0' & x"00";	-- NOP 
tmp(216) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(217) := STA & '0' & x"00";	-- STA @0 	#Zera a unidade
tmp(218) := LDA & '0' & x"01";	-- LDA @1 	#Carrega o valor da dezena no acumulador
tmp(219) := SOMA & '0' & x"07";	-- SOMA @7     	#Incrementa 1 na dezena 
tmp(220) := CEQ & '0' & x"08";	-- CEQ @8      	#Compara dezena com 10
tmp(221) := JEQ & '0' & x"E0";	-- JEQ @DEZENAPASSOU 	#Se for igual a 10, incrementa a centena
tmp(222) := STA & '0' & x"01";	-- STA @1 	#Se for diferente de 10, armazena o valor da dezena
tmp(223) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(224) := NOP & '0' & x"00";	-- NOP 
tmp(225) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(226) := STA & '0' & x"01";	-- STA @1 	#Zera a dezena
tmp(227) := LDA & '0' & x"02";	-- LDA @2 	#Carrega o valor da centena no acumulador
tmp(228) := SOMA & '0' & x"07";	-- SOMA @7     	#Incrementa 1 na centena
tmp(229) := CEQ & '0' & x"08";	-- CEQ @8      	#Compara centena com 10
tmp(230) := JEQ & '0' & x"E9";	-- JEQ @CENTENAPASSOU 	#Se for igual a 10, incrementa a unidade de milhar
tmp(231) := STA & '0' & x"02";	-- STA @2 	#Se for diferente de 10, armazena o valor da centena
tmp(232) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(233) := NOP & '0' & x"00";	-- NOP 
tmp(234) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(235) := STA & '0' & x"02";	-- STA @2 	#Zera a centena
tmp(236) := LDA & '0' & x"03";	-- LDA @3 	#Carrega o valor da unidade de milhar no acumulador
tmp(237) := SOMA & '0' & x"07";	-- SOMA @7 	#Incrementa 1 na unidade de milhar
tmp(238) := CEQ & '0' & x"08";	-- CEQ @8  	#Compara unidade de milhar com 10
tmp(239) := JEQ & '0' & x"F2";	-- JEQ @UNIDADEMILHARPASSOU 	#Se for igual a 10, incrementa a dezena de milhar
tmp(240) := STA & '0' & x"03";	-- STA @3 	#Se for diferente de 10, armazena o valor da unidade de milhar
tmp(241) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(242) := NOP & '0' & x"00";	-- NOP 
tmp(243) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(244) := STA & '0' & x"03";	-- STA @3 	#Zera a unidade de milhar
tmp(245) := LDA & '0' & x"04";	-- LDA @4 	#Carrega o valor da dezena de milhar no acumulador
tmp(246) := SOMA & '0' & x"07";	-- SOMA @7 	#Incrementa 1 na dezena de milhar
tmp(247) := CEQ & '0' & x"08";	-- CEQ @8  	#Compara dezena de milhar com 10
tmp(248) := JEQ & '0' & x"FB";	-- JEQ @DEZENAMILHARPASSOU 	#Se for igual a 10, incrementa a centena de milhar
tmp(249) := STA & '0' & x"04";	-- STA @4 	#Se for diferente de 10, armazena o valor da dezena de milhar
tmp(250) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(251) := NOP & '0' & x"00";	-- NOP 
tmp(252) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(253) := STA & '0' & x"04";	-- STA @4 	#Zera a dezena de milhar
tmp(254) := LDA & '0' & x"05";	-- LDA @5 	#Carrega o valor da centena de milhar no acumulador
tmp(255) := SOMA & '0' & x"07";	-- SOMA @7 	#Incrementa 1 na centena de milhar
tmp(256) := CEQ & '0' & x"08";	-- CEQ @8  	#Compara centena de milhar com 10
tmp(257) := JEQ & '1' & x"04";	-- JEQ @CENTENAMILHARPASSOU 	#Se for igual a 10, incrementa a unidade de milhao
tmp(258) := STA & '0' & x"05";	-- STA @5 	#Se for diferente de 10, armazena o valor da centena de milhar
tmp(259) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(260) := NOP & '0' & x"00";	-- NOP 
tmp(261) := LDA & '0' & x"06";	-- LDA @6 	#Carrega 0 no acumulador
tmp(262) := STA & '0' & x"05";	-- STA @5 	#Zera a centena de milhar
tmp(263) := LDI & '0' & x"01";	-- LDI $1 	#Carrega 1 no acumulador
tmp(264) := STA & '1' & x"02";	-- STA @258 	#Acende o LED(9)
tmp(265) := STA & '0' & x"0F";	-- STA @15 	#Ativa a flag de inibir incremento
tmp(266) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(267) := NOP & '0' & x"00";	-- NOP  	#Atualiza os valores dos HEX
tmp(268) := LDA & '0' & x"00";	-- LDA @0 	#Le o valor das unidades
tmp(269) := STA & '1' & x"20";	-- STA @288 	#Armazena o valor das unidades no HEX0
tmp(270) := LDA & '0' & x"01";	-- LDA @1 	#Le o valor das dezenas
tmp(271) := STA & '1' & x"21";	-- STA @289 	#Armazena o valor das dezenas no HEX1
tmp(272) := LDA & '0' & x"02";	-- LDA @2 	#Le o valor das centenas
tmp(273) := STA & '1' & x"22";	-- STA @290 	#Armazena o valor das centenas no HEX2
tmp(274) := LDA & '0' & x"03";	-- LDA @3 	#Le o valor das unidades de milhar
tmp(275) := STA & '1' & x"23";	-- STA @291 	#Armazena o valor das unidades de milhar no HEX3
tmp(276) := LDA & '0' & x"04";	-- LDA @4 	#Le o valor das dezenas de milhar
tmp(277) := STA & '1' & x"24";	-- STA @292 	#Armazena o valor das dezenas de milhar no HEX4
tmp(278) := LDA & '0' & x"05";	-- LDA @5 	#Le o valor das centenas de milhar
tmp(279) := STA & '1' & x"25";	-- STA @293 	#Armazena o valor das centenas de milhar no HEX5
tmp(280) := RET & '0' & x"00";	-- RET 	#Retorna para o LOOP principal
tmp(281) := NOP & '0' & x"00";	-- NOP 
tmp(282) := LDA & '0' & x"00";	-- LDA @0 	#Le o valor das unidades
tmp(283) := CEQ & '0' & x"09";	-- CEQ @9 	# Compara com o valor limite das unidades
tmp(284) := JEQ & '1' & x"1E";	-- JEQ @CHECADEZENA 	#Se for igual, checa se ocorre com as dezenas
tmp(285) := RET & '0' & x"00";	-- RET 	#Se for diferente, retorna para o LOOP principal
tmp(286) := NOP & '0' & x"00";	-- NOP 
tmp(287) := LDA & '0' & x"01";	-- LDA @1 	#Le o valor das dezenas
tmp(288) := CEQ & '0' & x"0A";	-- CEQ @10 	#Compara com o valor limite das dezenas
tmp(289) := JEQ & '1' & x"23";	-- JEQ @CHECACENTENA 	#Se for igual, checa se ocorre com as centenas
tmp(290) := RET & '0' & x"00";	-- RET 	#Se for diferente, retorna para o LOOP principal
tmp(291) := NOP & '0' & x"00";	-- NOP 
tmp(292) := LDA & '0' & x"02";	-- LDA @2 	#Le o valor das centenas
tmp(293) := CEQ & '0' & x"0B";	-- CEQ @11 	#Compara com o valor limite das centenas
tmp(294) := JEQ & '1' & x"28";	-- JEQ @CHECAUNIDADEMILHAR 	#Se for igual, checa se ocorre com as unidades de milhar
tmp(295) := RET & '0' & x"00";	-- RET 	#Se for diferente, retorna para o LOOP principal
tmp(296) := NOP & '0' & x"00";	-- NOP 
tmp(297) := LDA & '0' & x"03";	-- LDA @3 	# Le o valor das unidades de milhar
tmp(298) := CEQ & '0' & x"0C";	-- CEQ @12 	# Compara com o valor limite das unidades de milhar 
tmp(299) := JEQ & '1' & x"2D";	-- JEQ @CHECADEZENAMILHAR 	#Se for igual, checa se ocorre com as dezenas de milhar
tmp(300) := RET & '0' & x"00";	-- RET 	#Se for diferente, retorna para o LOOP principal
tmp(301) := NOP & '0' & x"00";	-- NOP 
tmp(302) := LDA & '0' & x"04";	-- LDA @4 	# Le o valor das dezenas de milhar
tmp(303) := CEQ & '0' & x"0D";	-- CEQ @13 	# Compara com o valor limite das dezenas de milhar 
tmp(304) := JEQ & '1' & x"32";	-- JEQ @CHECACENTENAMILHAR 	#Se for igual, checa se ocorre com as centenas de milhar
tmp(305) := RET & '0' & x"00";	-- RET 	#Se for diferente, retorna para o LOOP principal
tmp(306) := NOP & '0' & x"00";	-- NOP 
tmp(307) := LDA & '0' & x"05";	-- LDA @5 	# Le o valor das centenas de milhar
tmp(308) := CEQ & '0' & x"0E";	-- CEQ @14 	# Compara com o valor limite das centenas de milhar 
tmp(309) := JEQ & '1' & x"37";	-- JEQ @BATEUNOLIMITE 	#Se for igual, indica que o limite foi batido
tmp(310) := RET & '0' & x"00";	-- RET 	#Se for diferente, retorna para o LOOP principal
tmp(311) := NOP & '0' & x"00";	-- NOP 
tmp(312) := LDI & '0' & x"01";	-- LDI $1 	#Atribui o valor 1 no acumulador
tmp(313) := STA & '0' & x"0F";	-- STA @15 	#Ativa a flag de parar contagem
tmp(314) := STA & '1' & x"02";	-- STA @258 	#Ativa o LED de limite atingido 
tmp(315) := RET & '0' & x"00";	-- RET 	#Retorna pro LOOP principal
tmp(316) := NOP & '0' & x"00";	-- NOP  	#Trava a contagem
tmp(317) := LDI & '0' & x"01";	-- LDI $1
tmp(318) := STA & '1' & x"00";	-- STA @256
tmp(319) := LDA & '1' & x"64";	-- LDA @356 	#Le o valor do botao FPGA
tmp(320) := CEQ & '0' & x"06";	-- CEQ @6 	#Compara com 0 o botao FPGA
tmp(321) := JEQ & '1' & x"3C";	-- JEQ @TRAVA 	#Se for igual, continua travado
tmp(322) := JMP & '0' & x"00";	-- JMP @RESTART 	#Se for diferente, reinicia a contagem


        return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;