LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity mouse is
	port
	(
		clock : in std_logic;
		ps2_data 	:	inout	STD_LOGIC;
		ps2_clock	:	inout	STD_LOGIC;
		resetn	: in std_logic;
		entrada_mouse : in std_logic_vector(4 downto 0);
		position_x : out std_logic_vector(7 downto 0);
		position_y : out std_logic_vector(7 downto 0);
		comandos_mouse : out std_logic_vector(3 downto 0);
		endereco_ram : out std_logic_vector(1 downto 0);
		saida_ram : in std_logic_vector(5 downto 0);
		dado_ram : out std_logic_vector(5 downto 0);
		estado_mouse : in std_logic_vector(1 downto 0);
		ram_linha1	:	in std_logic_vector(5 downto 0);
		ram_linha2	:	in std_logic_vector(5 downto 0);
		ram_linha3	:	in std_logic_vector(5 downto 0)
	);
end;

architecture struct of mouse is
	component atualiza_posicao
		port(
			clock_50mhz	: 	in	STD_LOGIC;
			ps2_data 	:	inout	STD_LOGIC;
			ps2_clock	:	inout	STD_LOGIC;
			resetn	: in std_logic;
			position_x 	: 	out std_logic_vector(7 downto 0);
			position_y 	: 	out std_logic_vector(7 downto 0)
		);
	end component;
	component valida_clique
		port(
			clock_50mhz	: 	in	STD_LOGIC;
			ps2_data 	:	inout	STD_LOGIC;
			ps2_clock	:	inout	STD_LOGIC;
			resetn	: in std_logic;
			position_x : in std_logic_vector(7 downto 0);
			position_y : in std_logic_vector(7 downto 0);
			comando : out std_logic_vector(3 downto 0);
			endereco_ram : out std_logic_vector(1 downto 0);
			estado_mouse : in std_logic_vector(1 downto 0);
			ram_linha1	:	in std_logic_vector(5 downto 0);
			ram_linha2	:	in std_logic_vector(5 downto 0);
			ram_linha3	:	in std_logic_vector(5 downto 0)
		);
	end component;
	signal local_x, local_y : std_logic_vector(7 downto 0);
	signal endereco_valida : std_logic_vector(1 downto 0);
begin 	
	recebe_posicao : atualiza_posicao port map (clock, ps2_data, ps2_clock, resetn, local_x, local_y);
	acoes_clique : valida_clique port map (clock, ps2_data, ps2_clock, resetn, local_x, local_y, comandos_mouse, endereco_valida, estado_mouse, ram_linha1, ram_linha2, ram_linha3);
	position_x <= local_x;
	position_y <= local_y;
	
	process(clock)
		variable dado_tmp : std_logic_vector(5 downto 0);
		variable endereco_tmp : std_logic_vector(1 downto 0);
	begin
		if clock'event and clock = '1' then
			if estado_mouse = "00" then
				if entrada_mouse = "00001" then
					if saida_ram(5 downto 4) = "01" then
						dado_tmp := saida_ram;
					else
						dado_tmp := saida_ram XOR "110000";
					end if;
				else
					if entrada_mouse = "00011" then
						if saida_ram(3 downto 2) = "01" then
							dado_tmp := saida_ram;
						else
							dado_tmp := saida_ram XOR "001100";
						end if;
					else
						if entrada_mouse = "00010" then
							if saida_ram(5 downto 4) = "10" then
								dado_tmp := saida_ram;
							else
								dado_tmp := saida_ram XOR "110000";
							end if;
						else
							if entrada_mouse = "00100" then
								if saida_ram(3 downto 2) = "10" then
									dado_tmp := saida_ram;
								else
									dado_tmp := saida_ram XOR "001100";
								end if;
							else
								if entrada_mouse = "000" then
									dado_tmp := "111111";
								end if;
							end if;
						end if;
					end if;
				end if;
			else
				if estado_mouse = "01" then
					case entrada_mouse is
						when "11111" =>
							dado_tmp := ram_linha1 or "010000";
							endereco_tmp := "00";
						when "00001" =>
							dado_tmp := ram_linha1 or "100000";
							endereco_tmp := "00";
						when "00010" =>
							dado_tmp := ram_linha1 or "000100";
							endereco_tmp := "00";
						when "00011" =>
							dado_tmp := ram_linha1 or "001000";
							endereco_tmp := "00";
						when "00100" =>
							dado_tmp := ram_linha1 or "000001";
							endereco_tmp := "00";
						when "00101" =>
							dado_tmp := ram_linha1 or "000010";
							endereco_tmp := "00";
						when "01000" =>
							dado_tmp := ram_linha2 or "010000";
							endereco_tmp := "01";
						when "01001" =>
							dado_tmp := ram_linha2 or "100000";
							endereco_tmp := "01";
						when "01010" =>
							dado_tmp := ram_linha2 or "000100";
							endereco_tmp := "01";
						when "01011" =>
							dado_tmp := ram_linha2 or "001000";
							endereco_tmp := "01";
						when "01100" =>
							dado_tmp := ram_linha2 or "000001";
							endereco_tmp := "01";
						when "01101" =>
							dado_tmp := ram_linha2 or "000010";
							endereco_tmp := "01";
						when "10000" =>
							dado_tmp := ram_linha3 or "010000";
							endereco_tmp := "10";
						when "10001" =>
							dado_tmp := ram_linha3 or "100000";
							endereco_tmp := "10";
						when "10010" =>
							dado_tmp := ram_linha3 or "000100";
							endereco_tmp := "10";
						when "10011" =>
							dado_tmp := ram_linha3 or "001000";
							endereco_tmp := "10";
						when "10100" =>
							dado_tmp := ram_linha3 or "000001";
							endereco_tmp := "10";
						when "10101" =>
							dado_tmp := ram_linha3 or "000010";
							endereco_tmp := "10";
						when others =>
							dado_tmp := "111111";
							endereco_tmp := "00";
					end case;
				else
					if estado_mouse = "10" then
					end if;
				end if;
			end if;
			dado_ram <= dado_tmp;
			if estado_mouse = "00" then
				endereco_ram <= endereco_valida;
			else
				if estado_mouse = "01" then
					endereco_ram <= endereco_tmp;
				else
					if estado_mouse = "11" then
					end if;
				end if;
			end if;
		end if;
	end process;
end struct;
