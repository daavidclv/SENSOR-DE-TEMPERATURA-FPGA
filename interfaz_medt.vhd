--Interfaz completa del sistema

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity interfaz_medt is
    port (
        clk           : in  std_logic;
        nRst          : in  std_logic;
        SIO           : in  std_logic; 
        K1            : in std_logic ;
        K0            : in std_logic; 
        CS            : buffer std_logic;
        SC            : buffer std_logic;
        mux_disp      : buffer std_logic_vector(7 downto 0);
        disp          : buffer std_logic_vector(7 downto 0)
    );
end interfaz_medt;

architecture estructural of interfaz_medt is

    -- Se�ales internas

    signal SC_down:            std_logic;
    signal leer_bit:         std_logic;
    signal rst_reg:          std_logic;
    signal carga_reg:        std_logic;
    signal ena_tx:           std_logic;
    signal SPI_completado:   std_logic;
    signal K1_filtrado:      std_logic;
    signal K1_down:          std_logic;
    signal K0_filtrado:      std_logic;
    signal K0_down:          std_logic;
    signal temp_signo:       std_logic;
    signal frec_tic:         std_logic;
    signal cnt_bits:         std_logic_vector(4 downto 0); 
    signal KFC:              std_logic_vector(3 downto 0);
    signal Cuatro_Seis_Ocho: std_logic_vector(3 downto 0); 
    signal temp_final:       std_logic_vector(8 downto 0);
    signal temp_BCD:         std_logic_vector(11 downto 0);
        
begin

    -- gen_sc
    U1_gen_sc: entity work.gen_sc
    port map(
        clk      => clk,
        nRst     => nRst,
        ena_tx   => ena_tx,
        CS       => CS,
        SC       => SC,
	SC_down    => SC_down
    );

    -- control_spi
    U2_control_spi: entity work.control_spi
    port map(
        clk              => clk,
        nRst             => nRst,
	CS	         => CS,
        SC_down          => SC_down,
        K0_down          => K0_down,
        rst_reg          => rst_reg,
        carga_reg        => carga_reg,
        ena_tx           => ena_tx,
        cnt_bits         => cnt_bits,
        SPI_completado   => SPI_completado,
        Cuatro_Seis_Ocho => Cuatro_Seis_Ocho,
	frec_tic         => frec_tic 
    );

    -- reg_spi
    U3_reg_spi: entity work.reg_spi
    port map(
        clk             => clk,
        nRst            => nRst,
        rst_reg         => rst_reg,
        carga_reg       => carga_reg,
        cnt_bits        => cnt_bits,
        SIO             => SIO,
        SPI_completado  => SPI_completado,
        temp_final      => temp_final,
        SC              => SC 
    );

     --conversor_temp
    U4_conversor_temp: entity work.conversor_temp
    port map(
        clk          => clk,
        nRst         => nRst,
        K1_down      => K1_down,
        temp_final   => temp_final,
        temp_BCD     => temp_BCD,
        temp_signo   => temp_signo,
        KFC          => KFC
    );  

     --gestor_pulsador
    U5_gestor_pulsador: entity work.gestor_pulsadores
    port map(
        clk           => clk,
        nRst          => nRst,
        K1_filtrado   => K1_filtrado,
	K1_down       => K1_down,
        K0_filtrado   => K0_filtrado,
	K0_down       => K0_down
    );  
     --filtro_pulsadores
    U6_filtro_pulsadores: entity work.filtro_pulsadores
    port map(
        clk          => clk,
        nRst         => nRst,
        K1           => K1,
        K1_filtrado  => K1_filtrado,
        K0           => K0,
        K0_filtrado  => K0_filtrado

    );  

    --Display 
    U7_displays: entity work.displays
    port map(
        clk               => clk,
        nRst              => nRst,
        temp_BCD          => temp_BCD,
        temp_signo        => temp_signo,
        KFC               => KFC,
        Cuatro_Seis_Ocho  => Cuatro_Seis_Ocho,
        frec_tic          => frec_tic ,
        mux_disp          => mux_disp,
	disp              => disp
    );  

end estructural;

