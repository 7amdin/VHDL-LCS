
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:34:40 04/12/2024 
-- Design Name: 
-- Module Name:    state_machine - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity state_machine2 is
    Port ( clk : in STD_LOGIC;
			chamadas1 : in  STD_LOGIC_VECTOR (11 downto 0);
         request_andar : in  STD_LOGIC_VECTOR (11 downto 0);
			entrada_controlador : in STD_LOGIC_VECTOR(2 downto 0);
         position_att1 : out  STD_LOGIC_VECTOR (11 downto 0);
			reset_chamadas : out STD_LOGIC_VECTOR (11 downto 0);
			reset_request: out STD_LOGIC_VECTOR (11 downto 0);
			count : out integer);
end state_machine2;

architecture Behavioral of state_machine2 is

 type t_State is (reset, parado, subindo, parado_transito, descendo);
    signal State : t_State;
	 signal contador : integer := 0;
	 signal position_att : STD_LOGIC_VECTOR(11 downto 0) := "000000000001";
	 signal rst_ch, rst_rq : STD_LOGIC_VECTOR (11 downto 0);


begin



 process(Clk, entrada_controlador, position_att, contador, rst_ch, rst_rq) is
    begin
	 
	if(rising_edge(clk))then
	
		--latch start

		

		
		case state is


		when reset => 
			if(rst_ch = "UUUUUUUUUUUU")then
				rst_ch <= not(chamadas1);
			else
				rst_ch <= "000000000000";
			end if;
			if(rst_rq = "UUUUUUUUUUUU")then
				rst_rq <= not(request_andar);
			else
				rst_rq <= "000000000000";
			end if;
			if (rst_rq = "000000000000")then
				if(rst_ch ="000000000000")then
				state <= parado;
				end if;
			end if;
		
		when parado =>
			contador <= 0;
			position_att <= position_att;
		if (entrada_controlador = "001") then
			state <= subindo;
		elsif(entrada_controlador = "010")then
		     state <= parado_transito;
		end if;
		
		when subindo =>
		if (entrada_controlador = "010") then
			state <= parado_transito;
		elsif (entrada_controlador = "001") then
			position_att <= position_att(10 downto 0)&'0';
			contador <= contador + 1;
		elsif (entrada_controlador = "011") then
			state <= descendo;
		end if;
		
		
		when descendo =>
			if (entrada_controlador = "010") then
				state <= parado_transito;
			elsif(entrada_controlador = "011") then
				position_att <= '0' & position_att(11 downto 1);
				contador <= contador - 1;
			elsif(entrada_controlador = "000") then
				state <= parado;
			elsif(entrada_controlador = "001") then
				state <= subindo;
			end if;


		
		
		when parado_transito =>
			position_att <= position_att;
			if(chamadas1(contador) = '1' and request_andar(contador) = '1')then
			 rst_ch(contador) <= '1';
			 rst_rq(contador) <= '1';
			elsif(chamadas1(contador) = '1' and request_andar(contador) = '0')then
			 rst_ch(contador) <= '1';
			elsif(chamadas1(contador) = '0' and request_andar(contador) = '1')then
			 rst_rq(contador) <= '1';
			end if;
		if(entrada_controlador = "011") then
			state <= descendo;
		elsif(entrada_controlador = "001") then
			state <= subindo;
		elsif(entrada_controlador = "000") then
			state <= parado;
		end if;
			

	end case;
end if;	

	position_att1 <= position_att;
	count <= contador;
	reset_chamadas <= rst_ch;
	reset_request <= rst_rq;
	
end process;


end Behavioral;