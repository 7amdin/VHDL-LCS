
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    04:32:23 04/23/2024 
-- Design Name: 
-- Module Name:    latch_sr8 - Behavioral 
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

entity latch_sr8 is
    Port ( set : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           q : inout  STD_LOGIC);
end latch_sr8;

architecture Behavioral of latch_sr8 is

signal qn : STD_LOGIC;




begin

process(set, reset, q, qn)
		begin
		
	q <= reset nor qn;
	qn <= set nor q;




end process;
end Behavioral;
