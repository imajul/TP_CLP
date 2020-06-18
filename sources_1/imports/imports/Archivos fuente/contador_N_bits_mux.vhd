library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity contNbitsEstuct is
	generic(
		max_count: natural
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		ena_i: in std_logic;
		Q_o: out std_logic_vector(integer(ceil(log2(real( max_count ))))-1 downto 0)
	);
end;	

architecture contNbitsEstuct_arq of contNbitsEstuct is

    constant N : integer := integer(ceil(log2(real( max_count ))));  -- tamanio del vector que almacena el contador de pulsos
	signal salMuxRst, salMuxEna: std_logic_vector(N-1 downto 0);
	signal salComp, salOr: std_logic;
	signal salInc, salReg: std_logic_vector(N-1 downto 0);
	
begin

	reg_inst: entity work.registro
		generic map(
			N => N
		)
		port map(
			clk_i	=> clk_i,
			D_i		=> salMuxRst,
			Q_o		=> salReg 
		);
		
	salMuxRst <= (N-1 downto 0 => '0') when salOr = '1' else salMuxEna;
	salMuxEna <= salInc when ena_i = '1' else salReg;
	
	salInc <= std_logic_vector(unsigned(salReg) + 1);
	
	salOr <= rst_i or salComp;
	
	salComp <= '1' when (unsigned(salReg) = max_count-1) else '0';
	
	Q_o <= salReg;

end;