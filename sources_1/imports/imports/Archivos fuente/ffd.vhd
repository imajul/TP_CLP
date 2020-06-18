-- FlipFlop D

library IEEE;
use IEEE.std_logic_1164.all;

entity ffd is
	port(
		clk_i: in std_logic;
		D_i: in std_logic;
		Q_o: out std_logic
	);
end;	

architecture ffd_arq of ffd is
begin
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			Q_o <= D_i;
		end if;
	end process;
end;
			