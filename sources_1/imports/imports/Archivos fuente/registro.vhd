library IEEE;
use IEEE.std_logic_1164.all;

entity registro is
	generic(
		N: natural := 8
	);
	port(
		clk_i: in std_logic;
		D_i: in std_logic_vector(N-1 downto 0);
		Q_o: out std_logic_vector(N-1 downto 0)
	);
end;	

architecture registro_arq of registro is
begin
	process(clk_i)
	begin
		if rising_edge(clk_i) then
			Q_o <= D_i;
		end if;
	end process;
end;
			