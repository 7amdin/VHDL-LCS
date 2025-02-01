----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    05:12:26 05/07/2024 
-- Design Name: 
-- Module Name:    controlador - Behavioral 
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

entity coletivo_seletivo is
    Port ( 
			  clk : in STD_LOGIC;
			  rq1  : in STD_LOGIC_VECTOR(11 downto 0);
              chamadas : in  STD_LOGIC_VECTOR (11 downto 0);
              contador1 : in integer;
			  pos_el1 : in STD_LOGIC_VECTOR( 11 DOWNTO 0);
			  comando_controle : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
			  );
			 
end coletivo_seletivo;

architecture Behavioral of coletivo_seletivo is

signal controle_s1 : STD_LOGIC_VECTOR(2 downto 0) := "000";
--signal rst, chamadas, rst_rq : STD_LOGIC_VECTOR(11 downto 0);
--signal contador1 : integer;
--signal request_andar1 : STD_LOGIC_VECTOR(7 downto 0);
--signal rq1 : STD_LOGIC_VECTOR(11 downto 0);
--signal pos_el1 : STD_LOGIC_VECTOR (11 downto 0);
signal menor_andar : std_logic_vector(11 downto 0) := "000000000000";
signal clk_2 : STD_LOGIC;
--Parte dos signal
type Switches is range 0 to 11;
signal highest_switch : natural;


	
									

begin








 process(Clk, pos_el1, controle_s1, chamadas, rq1) is
     begin
			



if(rising_edge(clk))then
	--latch start


		
	--elevator 1 // 
	--000 = parado
	--001 = subindo
	--010 = parado_transito
	--011 = descendo
	
		if ((chamadas /= "000000000000") and (chamadas < rq1 or rq1 = "000000000000"))then
   loop1 : for i in 0 to 11 loop
      menor_andar <= "000000000000";
		highest_switch <= i;
		exit loop1 when chamadas(i) = '1';
   end loop;


	else
   loop2 : for i in 0 to 11 loop
      menor_andar <= "000000000000";
		highest_switch <= i;
		exit loop2 when rq1(i) = '1';
   end loop;
   end if;

menor_andar(highest_switch) <= '1';
	
	
			if (((chamadas >= pos_el1(10 downto 0)&'0' or rq1 >= pos_el1(10 downto 0)&'0') or (pos_el1 = "000000000001"))and controle_s1 /= "011") then
                if(pos_el1 /= "100000000000" and (chamadas(contador1) = '0' and rq1(contador1) = '0'))then
				    controle_s1 <= "001";
				elsif(chamadas(contador1) = '1' or rq1(contador1) = '1')then
				    controle_s1 <= "010";
				elsif(pos_el1 = "100000000000" and (chamadas /= "000000000000" or rq1 /= "000000000000"))then
					if(chamadas(contador1) = '0' and rq1(contador1) = '0')then
					   controle_s1 <= "011";
				    elsif(chamadas(contador1) = '1' or rq1(contador1) = '1')then
					   controle_s1 <= "010";
					end if;
				end if;
			
			
			elsif((pos_el1 > menor_andar and menor_andar /= "000000000000")and (controle_s1 /= ("001" or "010")))then --and (chamadas(highest_switch) = '1' or rq1(highest_switch) = '1')) then			
					if(chamadas(contador1) = '0' and rq1(contador1) = '0')then
					   controle_s1 <= "011";
				    elsif(chamadas(contador1) = '1' or rq1(contador1) = '1')then
					   controle_s1 <= "010";
					end if;
				
			elsif(pos_el1 = menor_andar) then
                     if(chamadas(contador1) = '1' or rq1(contador1) = '1') then
                        controle_s1 <= "010";
                     elsif(chamadas(contador1) = '0' and rq1(contador1) = '0')then
                        controle_s1 <= "001";
                     end if;
                --end if;

		  end if;	
		  
		  
			
			if(chamadas = "000000000000" and rq1 = "000000000000")then
			    if(pos_el1 /= "000000000001")then
			    controle_s1 <= "011";
			    else
			    controle_s1 <= "000";
			    end if;
			end if;
			

    
			
			
			
	end if;
		
		
	


comando_controle <= controle_s1;


end process;
end Behavioral;
