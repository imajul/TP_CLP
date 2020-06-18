library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity cont_bidir is
	generic(
		N: natural
	);
	port(
		clk_i: in std_logic;
		rst_i: in std_logic;
		dir_i: in std_logic;
		ena_i: in std_logic;
		Q_o: out std_logic_vector(N-1 downto 0)
	);
end;	

architecture cont_bidir_arq of cont_bidir is
	
	constant min: std_logic_vector(N-1 downto 0) := ("1000000000000000"); 
	constant max: std_logic_vector(N-1 downto 0) := ("0111111111111111"); 
	signal muxRst, muxDir: std_logic_vector(N-1 downto 0);
	signal salComp, salOr: std_logic;
	signal salInc, salDec, Qaux: std_logic_vector(N-1 downto 0);
	
begin

	reg_inst: entity work.registro_dec
		generic map(
			N => N
		)
		port map(
			clk_i	=> clk_i,
			D_i		=> muxRst,
			Q_o		=> Qaux,
			ena_i   => ena_i,
			rst_i   => rst_i
		);
		
	muxRst <= (N-1 downto 0 => '0') when salComp = '1' else muxDir;
	muxDir <= salInc when dir_i = '1' else salDec;
	
	salInc <= std_logic_vector(signed(Qaux) + 1);
	salDec <= std_logic_vector(signed(Qaux) - 1);
	
	salComp <= '1' when Qaux = max or Qaux = min else '0';
	
	Q_o <= Qaux;
	--Q_o <= to_stdLogicVector(to_bitVector(Qaux) sra 2);   -- shift aritmetico a derecha de dos bits, equivale a dividir por 4
	--Q_o <= std_logic_vector(to_signed(to_integer(signed(Qaux)) / 90, N));   -- divido por 90 la salida

end;