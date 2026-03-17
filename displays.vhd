-- Controlador de displays para el medidor de temperatura 
--
-- Controla 8 displays de 7 segmentos multiplexandolos en el tiempo
-- Tiene 1  modos de funcionamiento
--
-- Los digitos no significativos de la temperatura (cuando es 0) no se visualizan.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity displays is port(
    clk               : in std_logic;
    nRst              : in std_logic;
    temp_BCD          : in std_logic_vector(11 downto 0); 
    temp_signo        : in std_logic;
    KFC               : in std_logic_vector(3 downto 0);  -- orden: c,k,f
    Cuatro_Seis_Ocho  : in std_logic_vector (3 downto 0); -- saber en que periodo estamos
    frec_tic          : in std_logic;
    mux_disp          : buffer std_logic_vector(7 downto 0);
    disp              : buffer std_logic_vector(7 downto 0)

    );  
end entity;

architecture rtl of displays iS

  --Timer_medida
   signal cnt_timer_2_5ms:   std_logic_vector(17 downto 0);
   signal  tic_2_5ms:        std_logic;

   constant fdc_timer_2_5ms: natural := 125000;--125.000 reales 
 --  constant fdc_timer_2_5ms: natural := 10;--125.000 reales 

  -- Multiplexacion de displays
   signal cnt_mux:           std_logic_vector(7 downto 0); -- contador  incrementa  cada ciclo de reloj para seleccionar display debe ser activado

  -- Segnales auxiliares (ceros no significativos y posicion bit de signo)
  signal cero_c:             std_logic;
  signal cero_d:             std_logic;

  -- Constantes decodificacion
  constant symb_menos:       std_logic_vector(3 downto 0) := "1111"; --F
  constant symb_apagado:     std_logic_vector(3 downto 0) := "1101"; --D
  constant symb_cero:        std_logic_vector(3 downto 0) := "0000"; --0 

  signal BCD:                std_logic_vector(3 downto 0);

 --Se�ales para 1seg segmento 7
   --constant cte_1seg:        natural := 150;           --para pruebas (tic cada 300)
   constant cte_1seg:        natural := 50000000;        --1 segundo
                                              
  -- signal cnt_1seg:          std_logic_vector (7 downto 0);    --8 bits para 150
   signal cnt_1seg:          std_logic_vector (25 downto 0);
   signal activo_seg7:       std_logic;                          --se�al habilitaci�n display 7

begin
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
--Timer 2.5 ms (clk = 50 MHz) Para multiplexaci�n 
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_timer_2_5ms <= (0 => '1', others => '0');

    elsif clk'event and clk = '1' then
      if tic_2_5ms = '1' then
        cnt_timer_2_5ms <= (0 => '1', others => '0');
		  
      else
        cnt_timer_2_5ms <= cnt_timer_2_5ms + 1;

      end if;
    end if;
  end process;
 
  tic_2_5ms <= '1' when cnt_timer_2_5ms = fdc_timer_2_5ms else
               '0';

  -- Control multiplexacion de displays
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_mux <= (0 => '1', others => '0');

    elsif clk'event and clk = '1' then
      if tic_2_5ms = '1' then      
        cnt_mux <= cnt_mux(6 downto 0)&cnt_mux(7);  -- seleccionar qu� display debe ser activado

      end if;
    end if;
  end process;

  -- Segnales de multiplexacion
    mux_disp <= not cnt_mux; -- Activas a nivel bajo


  -- Eliminacion de ceros no significativos
    cero_c <= '1' when temp_BCD(11 downto 8)=X"0" else             -- Se elimina el 0 de centenas 
              '0' ;                            
    cero_d <= cero_c when temp_BCD(7 downto 4) = X"0" else         -- Se elimina el cero de decenas cuando centenas 
              '0';                                                  -- y decenas son 0


  -- Mux decodificador BCD-7seg
  BCD <= KFC                   when cnt_mux = 1                          else  			   --segmento 0 (Estado K,F,C)
         symb_apagado          when cnt_mux = 2                          else                    --segmento 1 (Apagado)
         temp_BCD(3 downto 0)  when cnt_mux = 4                          else                      --segmento 2 (Unidades)
         temp_BCD(7 downto 4)  when cero_d    = '0'  and cnt_mux = 8     else  --segmento 3 (Decenas)
         symb_menos            when temp_signo= '1'  and cnt_mux = 8     else  
         symb_apagado          when cero_d    = '1'  and cnt_mux = 8     else
         temp_BCD(11 downto 8) when cero_c    = '0'  and cnt_mux = 16    else
         symb_menos            when temp_signo= '1'  and cero_d = '0' and cnt_mux = 16  else  --segmento 4 (centenas)
         symb_apagado          when cero_d    = '1'  and cero_c = '1' and cnt_mux = 16  else 
         Cuatro_Seis_Ocho      when cnt_mux = 64 else                       --segmento 6 (Periodo)
         symb_cero             when cnt_mux = 128  and  activo_seg7 = '1' else
         symb_apagado          when cnt_mux = 128  else 
         symb_apagado;                

 -- BCD a 7 segmentos
  process(BCD) --punto_abcdefg
  begin
    case(BCD) is
      when X"0" => disp <= "01111110";
      when X"1" => disp <= "00110000";
      when X"2" => disp <= "01101101";
      when X"3" => disp <= "01111001";
      when X"4" => disp <= "00110011";
      when X"5" => disp <= "01011011";
      when X"6" => disp <= "01011111";
      when X"7" => disp <= "01110000";
      when X"8" => disp <= "01111111";
      when X"9" => disp <= "01110011";
      when X"A" => disp <= "01000111"; -- F
      when X"B" => disp <= "01100011"; -- K (circulito)
      when X"C" => disp <= "01001110"; -- C
      when X"D" => disp <= "00000000"; --APAGAO
      when X"E" => disp <= "01001111"; -- Error 
      when X"F" => disp <= "00000001"; -- signo -
      when others => null;
    end case;
  end process;

-- proceso para 1 seg de 0 en disp 7 cada vez que se actualiza la medida
 process(clk, nRst)
  begin
    if nRst = '0' then
      activo_seg7 <= '0';
      cnt_1seg <= (others => '0');
		
    elsif clk'event and clk = '1' then
       if frec_tic = '1' then   --Inicia el timer de 1 seg
          cnt_1seg <= (others => '0'); -- Reinicia contador al iniciar
          activo_seg7 <= '1';
			
     
          elsif cnt_1seg = cte_1seg then
             activo_seg7 <= '0';
          else
             cnt_1seg <= cnt_1seg + 1;
       
       end if;
   end if;
end process;


end rtl;