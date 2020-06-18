library IEEE;
use IEEE.std_logic_1164.all;

entity registro_dec is
	generic(
		N: natural := 4
	);
	port(
		clk_i, ena_i, rst_i: in std_logic;
		D_i: in std_logic_vector(N-1 downto 0);
		Q_o: out std_logic_vector(N-1 downto 0)
	);
end;	

architecture registro_dec_arq of registro_dec is
begin
	process(clk_i, rst_i)
	begin
	   if rst_i = '1' then
	       Q_o <= (N-1 downto 0 => '0');
	   else if falling_edge(clk_i) then
		       if ena_i = '1' then
			     Q_o <= D_i;
			   end if;
		   end if;
	   end if;
	end process;
end;
			