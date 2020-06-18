
-- TP Final Circuitos Logicos Programables - Ignacio Majul 10ma cohorte
	-- Codigo para manejo de un encoder rotativo incremental de 360 pulsos por revolucion.
	-- Modelo del encoder: LPD3806-360BM
	-- Placa FPGA: Arty Z7-10
	-- Interfaz de comunicacion: UART terminal
--

-- Interfaces I/O:
	-- ENTRADAS:
	-- 			Canal "A" del encoder -> channel_A_i
	--			Canal "B" del encoder -> channel_B_i
	--    		Reset asincronico     -> rst_i
	--      	Clock 50MHz			  -> clk_i
	-- SALIDAS:
	--			Posicion absoluta	  -> pos_o
	--  		Sentido de giro		  -> dir_o
--

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity encoder is
	
	generic( 
		debounce_time: natural := 10;				-- tiempo de debounce sobre cada canal, medido en us
		freq_clk: natural := 50; 					-- frecuencia del reloj, medida en MHz. Periodo = 20 ns
		N: natural := 8		                        -- tamaño del vector de salida
	);
	port(
		channel_A_i, channel_B_i: in std_logic;
		clk_i, rst_i: in std_logic;
        pos_o: out std_logic_vector(N-1 downto 0);
		dir_o: out std_logic
		--tx_pin: out std_logic				       -- pin de transmision de la UART
		
	);
end entity;

architecture encoder_arq of encoder is
	
	constant M : natural := 16;  -- tamanio del vector contador de pulsos
	constant debounce_counter : integer := freq_clk * debounce_time;  -- pulsos de espera para debounce
	constant debounce_counter_size : integer := integer(ceil(log2(real( debounce_counter )))); -- tamanio del vector que almacena el contador de pulsos
	
	-- signals auxiliares Canal A
	signal qdA_1: std_logic :='0';
	signal qdA_2: std_logic :='0';
	signal qdA_3: std_logic :='0';
	signal qdA_4: std_logic :='0';
	signal xorA_1: std_logic :='0';
	signal xorA_2: std_logic :='0';
	signal deb_met_A: std_logic :='0';
	signal not_deb_met_A: std_logic :='0';
	signal count_A: std_logic_vector (debounce_counter_size - 1 downto 0);
	
	-- signals auxiliares Canal B
	signal qdB_1: std_logic :='0';
	signal qdB_2: std_logic :='0';
	signal qdB_3: std_logic :='0';
	signal qdB_4: std_logic :='0';
	signal xorB_1: std_logic :='0';
	signal xorB_2: std_logic :='0';
	signal deb_met_B: std_logic :='0';
	signal not_deb_met_B: std_logic :='0';
	signal count_B: std_logic_vector (debounce_counter_size - 1 downto 0);
	
	-- signals auxiliares comunes
	signal xorAB_1: std_logic :='0';
	signal orAB: std_logic :='0';
	signal pos_aux: std_logic_vector(M-1 downto 0);
	signal pos_shift: std_logic_vector(N-1 downto 0);
	signal dir_aux: std_logic;
	type dir_type is (horario,antihorario,idle);
	signal sentido : dir_type;
	signal tx_aux: std_logic;
	
	COMPONENT ila_0 IS
    
    PORT (
        clk : IN STD_LOGIC;
	    probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
        probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe3 : IN STD_LOGIC_VECTOR(M-1 DOWNTO 0);
        probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
    END COMPONENT  ;

begin 
	
	-- asignacion de signals auxiliares
	not_deb_met_A <= not deb_met_A;
	deb_met_A <= '1' when unsigned(count_A) = (freq_clk * debounce_time ) - 1 else '0';
	xorA_1 <= qdA_1 xor qdA_2;
	xorA_2 <= qdA_3 xor qdA_4;
	
	not_deb_met_B <= not deb_met_B;
	deb_met_B <= '1' when unsigned(count_B) = (freq_clk * debounce_time ) - 1 else '0';
	xorB_1 <= qdB_1 xor qdB_2;
	xorB_2 <= qdB_3 xor qdB_4;
	
	xorAB_1 <= qdA_3 xor qdB_4;
	orAB <= xorA_2 or xorB_2;
	sentido <= horario when dir_aux = '1' else antihorario when dir_aux = '0' else idle ;

    -- divido la salida por 1440 para mostrar la cantidad de centimetros avanzados :
    --pos_o <= to_stdLogicVector(to_bitVector(pos_aux) sra 6);   -- shift aritmetico a derecha de dos bits, equivale a dividir por 4
    pos_o <= std_logic_vector(to_signed((to_integer(signed(pos_aux))/64), N));
   
    dir_o <= dir_aux;

	-- instancia de componentes del Canal A
	ffd_A1_inst: entity work.ffd
	port map(
		clk_i => clk_i,
		D_i => channel_A_i,
		Q_o => qdA_1 
	);
	
	ffd_A2_inst: entity work.ffd
	port map(
		clk_i => clk_i,
		D_i => qdA_1,
		Q_o => qdA_2
	);
	
	ffd_A3_inst: entity work.ffd_ena
	port map(
		clk_i => clk_i,
		ena_i => deb_met_A,
		D_i => qdA_2,
		Q_o => qdA_3
	);
	
	ffd_A4_inst: entity work.ffd
	port map(
		clk_i => clk_i,
		D_i => qdA_3,
		Q_o => qdA_4 
	);
	
	cont_N_bits_A_inst: entity work.contNbitsEstuct
	generic map(
		max_count => debounce_counter
	)
	port map(
		clk_i => clk_i,
		rst_i => xorA_1,
		ena_i => not_deb_met_A,
		Q_o => count_A
	);
	
	-- instancia de componentes del Canal B
	ffd_B1_inst: entity work.ffd
	port map(
		clk_i => clk_i,
		D_i => channel_B_i,
		Q_o => qdB_1 
	);
	
	ffd_B2_inst: entity work.ffd
	port map(
		clk_i => clk_i,
		D_i => qdB_1,
		Q_o => qdB_2
	);
	
	ffd_B3_inst: entity work.ffd_ena
	port map(
		clk_i => clk_i,
		ena_i => deb_met_B,
		D_i => qdB_2,
		Q_o => qdB_3
	);
	
	ffd_B4_inst: entity work.ffd
	port map(
		clk_i => clk_i,
		D_i => qdB_3,
		Q_o => qdB_4 
	);
	
	cont_N_bits_B_inst: entity work.contNbitsEstuct
	generic map(
		max_count => debounce_counter
	)
	port map(
		clk_i => clk_i,
		rst_i => xorB_1,
		ena_i => not_deb_met_B,
		Q_o => count_B
	);
	
	-- instancia de componentes comunes
	ffd_AB_inst: entity work.ffd_ena
	port map(
		clk_i => clk_i,
		ena_i => orAB,
		D_i => xorAB_1,
		Q_o => dir_aux
	);
	
	cont_bidir_inst: entity work.cont_bidir
	generic map(
		N => M
	)
	port map(
	    ena_i => orAB,
		clk_i => clk_i,
		rst_i => rst_i,
		dir_i => xorAB_1,
		Q_o => pos_aux
	);	
	
	ILA_inst : ila_0
    PORT MAP (
        clk => clk_i,
        probe0(0) => channel_A_i, 
        probe1(0) => channel_B_i,
        probe2(0) => dir_aux,
        probe3 => pos_aux,
        probe4(0) => rst_i
    );
	
--	UART_inst: entity work.uart
--	generic map(
--		clk_freq => 50_000_000,			-- frequency of system clock in hertz
--		baud_rate => 115_200,			-- data link baud rate in bits/second
--		os_rate => 16,					-- oversampling rate to find center of receive bits (in samples per baud period)
--		d_width => 8, 					-- data bus width
--		parity => 0,					-- 0 for no parity, 1 for parity
--		parity_eo => '0'				-- '0' for even, '1' for odd parity
--	)
--	port map(
--		clk => clk_i,					-- system clock
--		reset_n => '1',				-- ascynchronous reset
--		tx_ena => orAB,					-- initiate transmission
--		tx_data	=> pos_o,	 			-- data to transmit
--		rx => '0',						-- receive pin
--		rx_busy	=> open,				-- data reception in progress
--		rx_error => open,				-- start, parity, or stop bit error detected
--		rx_data	=> open,				-- data received
--		tx_busy	=> open,  				-- transmission in progress
--		tx => tx_aux					-- transmit pin
--	);
	
end architecture;

