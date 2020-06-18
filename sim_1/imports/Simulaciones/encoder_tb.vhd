library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity encoder_tb is
end entity;

architecture encoder_tb_arq of encoder_tb is
	
	constant debounce_time_tb: natural := 10;
	constant freq_clk_tb: natural := 50;
	constant N_tb: natural := 8;
	constant num_cycles: natural := 500;
	
	signal clk_tb: std_logic := '0';
	signal rst_tb: std_logic := '1';
	signal pos_tb: std_logic_vector(N_tb-1 downto 0);
	signal dir_tb: std_logic := '0';
	signal channel_A_tb: std_logic := '0';
	signal channel_B_tb: std_logic := '0';

begin
	
	clk_tb <= not clk_tb after 10 ns;
	rst_tb <= '0' after 100 us; --, '1' after 850 us, '0' after 851 us;
	
	-- simulacion Canal A
	process
		begin
		for i in 1 to num_cycles loop
			channel_A_tb <= not channel_A_tb;
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;        
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;
			wait for 26 us;
			
		end loop;
		wait for 30 us;
		for i in 1 to num_cycles loop
			channel_A_tb <= not channel_A_tb;
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;        
			wait for 1 us;
			channel_A_tb <= not channel_A_tb;
			wait for 26 us;
			
		end loop;
		wait;  
	end process;
	
	-- simulacion Canal B
	process
		begin
		wait for 15 us;
		for i in 1 to num_cycles loop
			channel_B_tb <= not channel_B_tb;
			wait for 1 us;
			channel_B_tb <= not channel_B_tb;
			wait for 1 us;
			channel_B_tb <= not channel_B_tb;
			wait for 28 us;
		end loop;
        
		for i in 1 to num_cycles loop
			channel_B_tb <= not channel_B_tb;
			wait for 1 us;
			channel_B_tb <= not channel_B_tb;
			wait for 1 us;
			channel_B_tb <= not channel_B_tb;
			wait for 28 us;
		end loop;
		wait;  
	end process;
	
	
	DUT: entity work.encoder
	generic map(
		debounce_time => debounce_time_tb,
		freq_clk => freq_clk_tb,
		--max_count => max_count_tb,
		N => N_tb
	)
	port map(
		clk_i	=> clk_tb,
		rst_i	=> rst_tb,
		channel_A_i	=> channel_A_tb,
		channel_B_i => channel_B_tb,
		pos_o => pos_tb,
		dir_o => dir_tb		
	);

end architecture;							