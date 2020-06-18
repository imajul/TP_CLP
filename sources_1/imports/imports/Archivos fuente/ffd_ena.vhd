-- FlipFlop D con enable

library IEEE;
use IEEE.std_logic_1164.all;

entity ffd_ena is
	port(
		clk_i: in std_logic;
		ena_i: in std_logic;
		D_i: in std_logic;
		Q_o: out std_logic
	);
end;	

architecture ffd_ena_arq of ffd_ena is
	begin
		process(clk_i)
			begin
			if (rising_edge(clk_i) and ena_i = '1') then
				Q_o <= D_i;
			end if;
		end process;
	end;
		