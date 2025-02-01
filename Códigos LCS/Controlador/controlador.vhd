library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlador is
    Port (
        clk             : in  STD_LOGIC;
        chamadas1       : in  STD_LOGIC_VECTOR(11 downto 0);
        request_andar1  : in  STD_LOGIC_VECTOR(11 downto 0);
        trig : in STD_logic := '0';
        posicao_atual   : inout  STD_LOGIC_VECTOR(11 downto 0); -- Posição atual do elevador
        mode      : inout STD_LOGIC_VECTOR(1 downto 0); -- Saída do controle fuzzy
        posicao_elevador: out STD_LOGIC_VECTOR(11 downto 0);
        comando_controle: inout STD_LOGIC_VECTOR(2 downto 0);
        chamadas_real   : out STD_LOGIC_VECTOR(11 downto 0);
        request_real    : out STD_LOGIC_VECTOR(11 downto 0)
    );
end controlador;

architecture Behavioral of controlador is

    -- Sinais intermediários
    signal comando_inter_sc, comando_inter_cs, comando_inter_ss, comando_inter_cc, direcao_atual  : STD_LOGIC_VECTOR(2 downto 0);
   
    signal chamadas_requisicoes : STD_LOGIC_VECTOR(11 downto 0); -- Combinação de chamadas e requisições
    signal chamadas_total       : integer := 0; -- Total combinado de chamadas e requisições
    signal chamadas_dist        : integer := 0; -- Métrica de distribuição combinada
    signal direcao_predominante, maior_distancia, direcao_mais_distante, fuzzy_histerese : integer := 0; -- Métrica de direção predominante
    
    signal rst, chamadas, rst_rq, rq1 : STD_LOGIC_VECTOR(11 downto 0);
    signal contador1, contador2 : integer;
    signal clk_2 : STD_LOGIC;


    
   
   
   
    component clk_div is
	port ( clk: in std_logic;
	clock_out: out std_logic);
end component;
    
    component state_machine2 is
    Port (  clk : in STD_LOGIC;
			chamadas1 : in  STD_LOGIC_VECTOR (11 downto 0);
            request_andar : in  STD_LOGIC_VECTOR (11 downto 0);
			entrada_controlador : in STD_LOGIC_VECTOR(2 downto 0);
            position_att1 : out  STD_LOGIC_VECTOR (11 downto 0);
			reset_chamadas : out STD_LOGIC_VECTOR (11 downto 0);
			reset_request: out STD_LOGIC_VECTOR (11 downto 0);
			count : out integer);
end component; 
   
   
    -- Componentes dos controladores
    component seletivo_coletivo is
    Port ( 
			  clk : in STD_LOGIC;
			  rq1  : in STD_LOGIC_VECTOR(11 downto 0);
              chamadas : in  STD_LOGIC_VECTOR (11 downto 0);
              contador1 : in integer;
			  pos_el1 : in STD_LOGIC_VECTOR( 11 DOWNTO 0);
			  comando_controle : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
			  );
    end component;

    component coletivo_seletivo is
    Port ( 
			  clk : in STD_LOGIC;
			  rq1  : in STD_LOGIC_VECTOR(11 downto 0);
              chamadas : in  STD_LOGIC_VECTOR (11 downto 0);
              contador1 : in integer;
			  pos_el1 : in STD_LOGIC_VECTOR( 11 DOWNTO 0);
			  comando_controle : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
			  );
    end component;

    component seletivo_seletivo is
    Port ( 
			  clk : in STD_LOGIC;
			  rq1  : in STD_LOGIC_VECTOR(11 downto 0);
              chamadas : in  STD_LOGIC_VECTOR (11 downto 0);
              contador1 : in integer;
			  pos_el1 : in STD_LOGIC_VECTOR( 11 DOWNTO 0);
			  comando_controle : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
			  );
    end component;

    component coletivo_coletivo is
    Port ( 
			  clk : in STD_LOGIC;
			  rq1  : in STD_LOGIC_VECTOR(11 downto 0);
              chamadas : in  STD_LOGIC_VECTOR (11 downto 0);
              contador1 : in integer;
			  pos_el1 : in STD_LOGIC_VECTOR( 11 DOWNTO 0);
			  comando_controle : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
			  );
    end component;
    
    
    component latch_sr8 is
    Port ( set : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           q : inout  STD_LOGIC);
end component;

begin

en2 : for i in 0 to 11 generate

	srl08 : latch_sr8 port map( set => chamadas1(i),
										reset => rst(i),
										q => chamadas(i));
end generate;

en3 : for i in 0 to 11 generate

	srl08 : latch_sr8 port map( set => request_andar1(i),
										reset => rst_rq(i),
										q => rq1(i));
end generate;



clok_2 : clk_div port map(clk => clk,
								  clock_out => clk_2);


elevador1 : state_machine2 port map(clk => clk_2,
												chamadas1 => chamadas1,
												position_att1 => posicao_atual,
												request_andar => request_andar1,
												entrada_controlador => comando_controle,
												reset_chamadas => rst,
												reset_request => rst_rq,
												count => contador1);

  -- Instâncias dos algoritmos de escalonamento
    inst_seletivo_coletivo: seletivo_coletivo
        Port map (
			  clk => clk,
			  rq1  => rq1,
              chamadas => chamadas,
              contador1 => contador1,
			  pos_el1 => posicao_atual,
			  comando_controle => comando_inter_sc
        );

    inst_coletivo_seletivo: coletivo_seletivo
        Port map (
			  clk => clk,
			  rq1  => rq1,
              chamadas => chamadas,
              contador1 => contador1,
			  pos_el1 => posicao_atual,
			  comando_controle => comando_inter_cs
        );

    inst_seletivo_seletivo: seletivo_seletivo
        Port map (
			  clk => clk,
			  rq1  => rq1,
              chamadas => chamadas,
              contador1 => contador1,
			  pos_el1 => posicao_atual,
			  comando_controle => comando_inter_ss
        );

    inst_coletivo_coletivo: coletivo_coletivo
        Port map (
			  clk => clk,
			  rq1  => rq1,
              chamadas => chamadas,
              contador1 => contador1,
			  pos_el1 => posicao_atual,
			  comando_controle => comando_inter_cc
        );

    chamadas_requisicoes <= chamadas or rq1;

process(clk)
    variable chamadas_acima : integer := 0;
    variable chamadas_abaixo : integer := 0;
    variable chamadas_total : integer := 0;
    variable requisicoes_ativas : integer := 0;
    variable chamadas_ativas : boolean := false;
    variable total_acima : integer := 0;
    variable total_abaixo : integer := 0;
    variable centro_edificio : integer := 6;  -- Centro do edifício para o controle de estabilidade
begin
    if rising_edge(clk) then
        -- Reseta contadores a cada ciclo
        chamadas_acima := 0;
        chamadas_abaixo := 0;
        chamadas_ativas := false;
        chamadas_total := 0;
        requisicoes_ativas := 0;
        total_acima := 0;
        total_abaixo := 0;
        contador2 <= contador1 + 1;

        -- Identifica chamadas ativas e as classifica como acima ou abaixo
        for i in 0 to 11 loop
            if chamadas(i) = '1' then
                chamadas_ativas := true;
                if i > contador1 then
                    chamadas_acima := chamadas_acima + 1;
                    
                elsif i < contador1 then
                    chamadas_abaixo := chamadas_abaixo + 1;
                    
                end if;
            end if;
            

            -- Conta requisições ativas
            if chamadas_requisicoes(i) = '1' then
                requisicoes_ativas := requisicoes_ativas + 1;
                if i > centro_edificio then
                    total_acima := total_acima + 1;
                elsif i < centro_edificio then
                    total_abaixo := total_abaixo + 1;
                end if;
                
            end if;
        end loop;

-- Seleção do algoritmo de escalonamento quando há chamadas ativas
        if chamadas_ativas and trig = '0' then
            -- Caso com chamadas ativas e controle manual desativado
            if chamadas_abaixo = 0 and direcao_atual = "011" and posicao_atual(contador1) /= chamadas(contador1) then
                mode <= "11"; -- seletivo-seletivo (subindo)
            elsif chamadas_acima = 0 and direcao_atual = "001" and posicao_atual(contador1) /= chamadas(contador1) then
                -- Chamadas abaixo, mas elevador está subindo
                mode <= "11"; -- seletivo-seletivo até atingir o andar da chamada
            elsif chamadas_abaixo > 0 and direcao_atual = "011"then
                if posicao_atual(contador1) = chamadas(contador1) then
                    mode <= "00"; -- coletivo-coletivo ao atingir a chamada
                else
                     mode <= "11";
                end if;
            elsif chamadas_acima > 0 and direcao_atual = "001" then
                if posicao_atual(contador1) = chamadas(contador1) then
                    mode <= "00"; -- coletivo-coletivo ao atingir a chamada
                else
                     mode <= "11";
                end if;
            else
                mode <= "00"; -- coletivo-coletivo para chamadas no mesmo andar
            end if;
            else
        --posicao_atual(contador1) = chamadas(contador1
            -- Caso sem chamadas ativas ou controle manual ativado (trig = '1')

            if chamadas_ativas = false or trig = '1' then
                -- Controle baseado no centro do edifício para identificar melhores algoritmos
                if total_acima > total_abaixo then
                    mode <= "01"; -- coletivo-seletivo (melhor para picos de subida)
                elsif total_abaixo > total_acima then
                    mode <= "10"; -- seletivo-coletivo (melhor para picos de descida)
                else
                    -- Quando as chamadas estão equilibradas ao redor do centro do edifício (andar 5 ou 6)
                    if abs(contador1 - centro_edificio) <= 2 then
                        mode <= "00"; -- coletivo-coletivo (melhor para interfloor)
                    else
                        -- Prioriza chamadas/requisições do pico dependendo da direção
                        if contador1 > centro_edificio then
                            mode <= "10"; -- seletivo-coletivo (melhor para descida)
                        else
                            mode <= "01"; -- coletivo-seletivo (melhor para subida)
                        end if;
                    end if;
                end if;
            end if;
        end if;

        -- Controle com base no comando_controle
        case comando_controle is
            when "001" => -- Subindo
                direcao_atual <= "001";
            when "011" => -- Descendo
                direcao_atual <= "011";
            when "010" => -- Parado em trânsito
                direcao_atual <= direcao_atual; -- Mantém a direção atual
            when "000" => -- Parado no térreo
                direcao_atual <= "000";
            when others =>
                direcao_atual <= "000"; -- Parado por segurança
        end case;

        -- Envia o comando para o elevador com base no mode
    end if;
end process;






    -- Multiplexação com sincronização
    process(clk)
    begin
        if rising_edge(clk) then

                -- Operação normal
                case mode is
                    when "00" =>
                        posicao_elevador <= posicao_atual;
                        comando_controle <= comando_inter_cc;
                        chamadas_real    <= chamadas;
                        request_real     <= rq1;

                    when "01" =>
                        posicao_elevador <= posicao_atual;
                        comando_controle <= comando_inter_cs;
                        chamadas_real    <= chamadas;
                        request_real     <= rq1;

                    when "10" =>
                        posicao_elevador <= posicao_atual;
                        comando_controle <= comando_inter_sc;
                        chamadas_real    <= chamadas;
                        request_real     <= rq1;

                    when "11" =>
                        posicao_elevador <= posicao_atual;
                        comando_controle <= comando_inter_ss;
                        chamadas_real    <= chamadas;
                        request_real     <= rq1;

                    when others =>
                        posicao_elevador <= posicao_atual;
                        comando_controle <= (others => '0');
                        chamadas_real    <= (others => '0');
                        request_real     <= (others => '0');
                end case;
            end if;
    end process;

end Behavioral;
