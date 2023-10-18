library ieee;
use ieee.std_logic_1164.all;

entity Contador is
  -- Total de bits das entradas e saidas
  generic ( larguraDados : natural := 8;
        larguraEnderecos : natural := 9;
        simulacao : boolean := TRUE -- para gravar na placa, altere de TRUE para FALSE
  );
  port   (
	 CLOCK_50 : in std_logic;
    KEY: in std_logic_vector(3 downto 0);
    SW: in std_logic_vector(9 downto 0);
	 FPGA_RESET_N: in std_logic;
    LEDR  : out std_logic_vector(9 downto 0);
	 HEX0, HEX1, HEX2, HEX3, HEX4, HEX5: out std_logic_vector(6 downto 0)
  );
end entity;


architecture arquitetura of Contador is

	--CPU
	signal wr: std_logic;
	signal rd: std_logic;
	signal pc_rom: std_logic_vector(8 downto 0);
	signal saida_rom: std_logic_vector(12 downto 0);
	signal dataIn: std_logic_vector(7 downto 0);
	signal saida_reg: std_logic_vector(7 downto 0);
	signal Data_Address: std_logic_vector(8 downto 0);

	--Displays 7seg
	signal saidaReg4_0: std_logic_vector(3 downto 0);
	signal saidaReg4_1: std_logic_vector(3 downto 0);
	signal saidaReg4_2: std_logic_vector(3 downto 0);
	signal saidaReg4_3: std_logic_vector(3 downto 0);
	signal saidaReg4_4: std_logic_vector(3 downto 0);
	signal saidaReg4_5: std_logic_vector(3 downto 0);
	signal habReg4_0: std_logic;
	signal habReg4_1: std_logic;
	signal habReg4_2: std_logic;
	signal habReg4_3: std_logic;
	signal habReg4_4: std_logic;
	signal habReg4_5: std_logic;


	--Decoders 
	signal saida_decBloco: std_logic_vector(7 downto 0);
	signal saida_decEndereco: std_logic_vector(7 downto 0);

	--FlipFlops
	signal saida_FF1: std_logic;
	signal saida_FF2: std_logic;
	signal habFF1: std_logic;
	signal habFF2: std_logic;

	--Registrador LEDS
	signal habRegLED: std_logic;
	signal saida_RegLED: std_logic_vector(7 downto 0);


	signal CLK: std_logic;
	

	--TriStates
	signal habTriSW: std_logic;
	signal habTriSW8: std_logic;
	signal habTriSW9: std_logic;
	signal habTriKey0: std_logic;
	signal habTriKey1: std_logic;
	signal habTriKey2: std_logic;
	signal habTriKey3: std_logic;
	signal habTriRe: std_logic;
	signal TriSW_out: std_logic_vector(7 downto 0);
	signal TriSW8_out: std_logic;
	signal TriSW9_out: std_logic;
	signal TriKey0_out: std_logic;
	signal TriKey1_out: std_logic;
	signal TriKey2_out: std_logic;
	signal TriKey3_out: std_logic;
	signal TriRe_out: std_logic;
	signal saidaEdge0: std_logic;
	signal saidaEdge1: std_logic;
	signal saidaEdgeRe: std_logic;
	signal saida_FFKEY0: std_logic;
	signal saida_FFKEY1: std_logic;
	signal saida_FFRe: std_logic;
	signal saidaLimpaKEY0: std_logic;
	signal saidaLimpaKEY1: std_logic;
	signal saidaLimpaRe: std_logic;
  

begin

-- Instanciando os componentes:

-- Para simular, fica mais simples tirar o edgeDetector
gravar:  if simulacao generate
CLK <= CLOCK_50;
else generate
detectorSub0: work.edgeDetector(bordaSubida)
        port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => CLK);
end generate;

CPU : entity work.CPU port map (Wr => wr,
								Rd => rd,
								ROM_Address => pc_rom,
								Instruction_IN => saida_rom,
								Data_IN => dataIn,
								Data_OUT => saida_reg,
								Data_Address => Data_Address,
								Clock => CLK);
										  									  
ROM : entity work.memoriaROM   generic map (dataWidth => 13, addrWidth => 9)
          port map (Endereco => pc_rom, 
		  			Dado => saida_rom);
			 

RAM : entity work.memoriaRAM   generic map (dataWidth => 8, addrWidth => 6)
          port map (addr => Data_address(5 downto 0),  we => wr, 
						  re => rd,
						  habilita => saida_decBloco(0),
						  clk => CLK,
						  dado_in => saida_reg,
						  dado_out => dataIn);
						  


										  
DecBloco : entity work.decoder3x8 port map( entrada => Data_Address (8 downto 6),
													  saida => saida_decBloco);
													  
DecEndereco : entity work.decoder3x8 port map( entrada => Data_Address (2 downto 0),
													  saida => saida_decEndereco);
													  
FF1: entity work.FlipFlop port map (DIN => saida_reg(0),
												DOUT => saida_FF1,
												ENABLE => habFF1,
											   CLK => CLK,
												RST => '0');
												
FF2: entity work.FlipFlop port map (DIN => saida_reg(0),
												DOUT => saida_FF2,
												ENABLE => habFF2,
											   CLK => CLK,
												RST => '0');
												
RegLED : entity work.registradorGenerico   generic map (larguraDados => 8)
          port map (DIN => saida_reg(7 downto 0), 
		  			DOUT => saida_RegLED, 
					ENABLE => habRegLED, 
					CLK => CLK, 
					RST => '0');
			 
REG4_0 : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => saida_reg(3 downto 0), 
		  			DOUT => saidaReg4_0, 
					ENABLE => habReg4_0, 
					CLK => CLK, 
					RST => '0');
	
REG4_1 : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => saida_reg(3 downto 0), 
		  			DOUT => saidaReg4_1, 
					ENABLE => habReg4_1, 
					CLK => CLK, 
					RST => '0');

REG4_2 : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => saida_reg(3 downto 0), 
		  			DOUT => saidaReg4_2, 
					ENABLE => habReg4_2, 
					CLK => CLK, 
					RST => '0');
			 
REG4_3 : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => saida_reg(3 downto 0), 
		  			DOUT => saidaReg4_3, 
					ENABLE => habReg4_3, 
					CLK => CLK, 
					RST => '0');

REG4_4 : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => saida_reg(3 downto 0), 
		  			DOUT => saidaReg4_4, 
					ENABLE => habReg4_4, 
					CLK => CLK,
					RST => '0');
			 
REG4_5 : entity work.registradorGenerico   generic map (larguraDados => 4)
          port map (DIN => saida_reg(3 downto 0), 
		  			DOUT => saidaReg4_5, 
					ENABLE => habReg4_5, 
					CLK => CLK, 
					RST => '0');

			 
display0 :  entity work.conversorHex7Seg
        port map(dadoHex => saidaReg4_0,
                 apaga =>  '0',
                 negativo => '0',
                 overFlow =>  '0',
                 saida7seg => HEX0);
					  
display1 :  entity work.conversorHex7Seg
        port map(dadoHex => saidaReg4_1,
                 apaga =>  '0',
                 negativo => '0',
                 overFlow =>  '0',
                 saida7seg => HEX1);
				
display2 :  entity work.conversorHex7Seg
        port map(dadoHex => saidaReg4_2,
                 apaga =>  '0',
                 negativo => '0',
                 overFlow =>  '0',
                 saida7seg => HEX2);
				
display3 :  entity work.conversorHex7Seg
        port map(dadoHex => saidaReg4_3,
                 apaga =>  '0',
                 negativo => '0',
                 overFlow =>  '0',
                 saida7seg => HEX3);
				
display4 :  entity work.conversorHex7Seg
        port map(dadoHex => saidaReg4_4,
                 apaga =>  '0',
                 negativo => '0',
                 overFlow =>  '0',
                 saida7seg => HEX4);
				
display5 :  entity work.conversorHex7Seg
        port map(dadoHex => saidaReg4_5,
                 apaga =>  '0',
                 negativo => '0',
                 overFlow =>  '0',
                 saida7seg => HEX5);

TriSW: entity work.buffer_3_state_8portas
        port map(entrada => "0000" & SW(3 downto 0), habilita =>  habTriSW, saida => dataIn);
		
TriSW8: entity work.buffer_3_state_8portas
        port map(entrada => "0000000" & SW(8), habilita =>  habTriSW8, saida => dataIn);

TriSW9: entity work.buffer_3_state_8portas
        port map(entrada => "0000000" & SW(9), habilita =>  habTriSW9, saida => dataIn);
		 
TriKey0: entity work.buffer_3_state_8portas
        port map(entrada => "0000000" & saida_FFKEY0, habilita =>  habTriKey0, saida => dataIn);
		 
TriKey1: entity work.buffer_3_state_8portas
        port map(entrada => "0000000" & saida_FFKEY1, habilita =>  habTriKey1, saida => dataIn);
		 
TriKey2: entity work.buffer_3_state_8portas
        port map(entrada => "0000000" & KEY(2), habilita =>  habTriKey2, saida => dataIn);
		  
TriKey3: entity work.buffer_3_state_8portas
        port map(entrada => "0000000" & KEY(3), habilita =>  habTriKey3, saida => dataIn);
		  
TriRe: entity work.buffer_3_state_8portas
        port map(entrada => "0000000" & saida_FFRe, habilita =>  habTriRe, saida => dataIn);
		  
FFKEY0: entity work.FlipFlop port map (DIN => '1',
												DOUT => saida_FFKEY0,
												ENABLE => '1',
											   CLK => saidaEdge0,
												RST => saidaLimpaKEY0);
												
FFKEY1: entity work.FlipFlop port map (DIN => '1',
												DOUT => saida_FFKEY1,
												ENABLE => '1',
											   CLK => saidaEdge1,
												RST => saidaLimpaKEY1);
												
FFRe: entity work.FlipFlop port map (DIN => '1',
												DOUT => saida_FFRe,
												ENABLE => '1',
											   CLK => saidaEdgeRe,
												RST => saidaLimpaRe);
												
edgeDecKey0: work.edgeDetector(bordaSubida)
        port map (clk => CLOCK_50, entrada => (not KEY(0)), saida => saidaEdge0);

edgeDecKey1: work.edgeDetector(bordaSubida)
        port map (clk => CLOCK_50, entrada => (not KEY(1)), saida => saidaEdge1);
		  
edgeDecRe: work.edgeDetector(bordaSubida)
        port map (clk => CLOCK_50, entrada => (not FPGA_RESET_N), saida => saidaEdgeRe);


habTriSW  <= rd and (not Data_Address(5)) and saida_decEndereco(0) and saida_decBloco(5);
habTriSW8 <= rd and (not Data_Address(5)) and saida_decEndereco(1) and saida_decBloco(5);
habTriSW9 <= rd and (not Data_Address(5)) and saida_decEndereco(2) and saida_decBloco(5);
habTriKey0 <= rd and Data_Address(5) and saida_decEndereco(0) and saida_decBloco(5);
habTriKey1 <= rd and Data_Address(5) and saida_decEndereco(1) and saida_decBloco(5);
habTriKey2 <= rd and Data_Address(5) and saida_decEndereco(2) and saida_decBloco(5);
habTriKey3 <= rd and Data_Address(5) and saida_decEndereco(3) and saida_decBloco(5);
habTriRe <= rd and Data_Address(5) and saida_decEndereco(4) and saida_decBloco(5);


saidaLimpaKEY0 <= wr and Data_Address(8) and Data_Address(7) and Data_Address(6) and Data_Address(5) and Data_Address(4) and Data_Address(3) and Data_Address(2)
                  and Data_Address(1) and Data_Address(0);
						
saidaLimpaKEY1 <= wr and Data_Address(8) and Data_Address(7) and Data_Address(6) and Data_Address(5) and Data_Address(4) and Data_Address(3) and Data_Address(2)
                  and Data_Address(1) and (not Data_Address(0));
						
saidaLimpaRe <= wr and Data_Address(8) and Data_Address(7) and Data_Address(6) and Data_Address(5) and Data_Address(4) and Data_Address(3) and Data_Address(2)
                  and (not Data_Address(1)) and Data_Address(0);
		  


					  

habReg4_5 <= saida_decEndereco(5) and Data_Address(5) and saida_decBloco(4) and wr;
habReg4_4 <= saida_decEndereco(4) and Data_Address(5) and saida_decBloco(4) and wr;
habReg4_3 <= saida_decEndereco(3) and Data_Address(5) and saida_decBloco(4) and wr;
habReg4_2 <= saida_decEndereco(2) and Data_Address(5) and saida_decBloco(4) and wr;
habReg4_1 <= saida_decEndereco(1) and Data_Address(5) and saida_decBloco(4) and wr;
habReg4_0 <= saida_decEndereco(0) and Data_Address(5) and saida_decBloco(4) and wr;
 			 
habRegLED <= saida_decBloco(4) and wr and saida_decEndereco(0) and (not Data_Address(5));			 
habFF2  <= saida_decBloco(4) and wr and saida_decEndereco(1) and (not Data_Address(5));			 
habFF1  <= saida_decBloco(4) and wr and saida_decEndereco(2) and (not Data_Address(5));
LEDR (9) <= saida_FF1;
LEDR (8) <= saida_FF2;
LEDR (7 downto 0) <= saida_RegLED;

end architecture;