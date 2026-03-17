--Acumula los datos de entrada de SIO y selecciona los que tienen la informacion
--de la temperatura en binario

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity reg_spi is
    port (
        clk              :in  std_logic;
        nRst             :in  std_logic;
        SC               :in std_logic;
        rst_reg          :in  std_logic;
        carga_reg        :in  std_logic;
        SIO              :in  std_logic; 			-- Entrada serie desde sensor
        SPI_completado   :in std_logic;
        cnt_bits         :in std_logic_vector(4 downto 0);
        temp_final       :Buffer std_logic_vector(8 downto 0)  -- Salida: 8 bits + signo (resolucion 1C) 
       );
end reg_spi;

architecture rtl of reg_spi is
    signal dato_out: std_logic_vector(15 downto 0);
	 signal dato_aux: std_logic;
begin

  ---Registro de desplazamiento
  process(clk, nRst)
  begin
    if nRst = '0' then
       dato_out    <= (others => '0'); 
    elsif clk'event and clk = '1' then
       if rst_reg = '1' then
          dato_out <= (others => '0');
			 
      elsif carga_reg = '1' and SPI_completado = '0'  and cnt_bits > 1 then --capturamos
		 
          dato_out <= dato_out(14 downto 0) & SIO;
       end if;

       end if;
    end process;

 ---Salida de Temperatura Final
 process(clk, nRst)
  begin
    if nRst = '0' then
       temp_final    <= (others => '0');

    elsif clk'event and clk = '1' then
        if SPI_completado = '1'  then --capturamos
		
             temp_final <= dato_out(15 downto 7);
	    --temp_final <= "111011000"; --prueba -40
        end if;

    end if;
  end process;

   
end rtl;

