library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controlador_tb is
end controlador_tb;

architecture testbench of controlador_tb is

    component controlador is
        Port (
            clk             : in  STD_LOGIC;
            chamadas1       : in  STD_LOGIC_VECTOR(11 downto 0);
            request_andar1  : in  STD_LOGIC_VECTOR(11 downto 0);
            trig : in STD_logic;
            posicao_atual   : inout  STD_LOGIC_VECTOR(11 downto 0); -- Posição atual do elevador
            mode      : inout STD_LOGIC_VECTOR(1 downto 0); -- Saída do controle fuzzy
            posicao_elevador: out STD_LOGIC_VECTOR(11 downto 0);
            comando_controle: inout STD_LOGIC_VECTOR(2 downto 0);
            chamadas_real   : out STD_LOGIC_VECTOR(11 downto 0);
            request_real    : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;

    -- Inputs
    signal clk : std_logic := '1';
    signal rq1, ch1 : std_logic_vector(11 downto 0) := (others => '0');

    -- Outputs
    signal pos_el1, chamadas, requisicoes : std_logic_vector(11 downto 0);
    signal controle_s1 : std_logic_vector(2 downto 0);
    signal mode : std_logic_vector(1 downto 0);
    signal pos_at2 : std_logic_vector(11 downto 0);
    signal trig : STD_LOGIC := '0';

    -- Clock period definitions
    constant clk_period : time := 0.1 ms;

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: controlador PORT MAP (
        clk => clk,
        request_andar1 => rq1,
        chamadas1 => ch1,
        trig => trig,
        posicao_atual => pos_at2,
        mode => mode,
        posicao_elevador => pos_el1,
        comando_controle => controle_s1,
        chamadas_real => chamadas,
        request_real => requisicoes
    );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- ** PICO DE SUBIDA**
        trig <= '1';
        wait for 5 ms;
        ch1(0) <= '1'; -- Chamada no térreo (andar 0)
        wait for 1.2 ms;
        rq1(10) <= '1'; -- Destino: andar 10
        wait for 1.5 ms;
        ch1(2) <= '1'; -- Chamada no andar 2
        wait for 0.8 ms;
        rq1(9) <= '1'; -- Destino: andar 9
        wait for 1.8 ms;
        ch1(3) <= '1'; -- Chamada no andar 3
        rq1(7) <= '1'; -- Destino: andar 7

        -- ** INTERFLOOR  **
        wait for 5 ms;
        ch1(5) <= '1'; -- Chamada no andar 5
        wait for 0.6 ms;
        rq1(6) <= '1'; -- Destino: andar 6
        wait for 0.4 ms;
        ch1(6) <= '1'; -- Chamada no andar 6
        wait for 0.7 ms;
        rq1(4) <= '1'; -- Destino: andar 4
        wait for 0.5 ms;
        ch1(7) <= '1'; -- Chamada no andar 7
        rq1(8) <= '1'; -- Destino: andar 8

        -- *** Divisão da simulação - ponto para simulação parcial ***
        
        -- ** PICO DE DESCIDA  **
        
        wait for 5 ms;
        --trig <= '1';
        ch1(10) <= '1'; -- Chamada no andar 10
        wait for 1.0 ms;
        rq1(1) <= '1'; -- Destino: andar 1
        wait for 0.9 ms;
        ch1(8) <= '1'; -- Chamada no andar 8
        rq1(0) <= '1'; -- Destino: térreo (andar 0)
        wait for 1.3 ms;
        ch1(9) <= '1'; -- Chamada no andar 9
        rq1(2) <= '1'; -- Destino: andar 2

        wait; -- Fim da simulação
    end process;

END;
