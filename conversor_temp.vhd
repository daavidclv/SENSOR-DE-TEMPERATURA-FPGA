--Conversor de temperatura en binario
-- a grados centigrados Kelvin y Fahrenheit

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity conversor_temp is
   port(clk         :in std_logic;
        nRst        :in std_logic;
        K1_down     :in std_logic; 
        temp_final  :in std_logic_vector(8 downto 0); --salida del registro (ambiar a temp_reg)
        temp_signo  :buffer std_logic;
        KFC         :buffer std_logic_vector(3 downto 0);
        temp_BCD    :buffer std_logic_vector(11 downto 0) --BCD
    );
 end entity;
   
 architecture rtl of conversor_temp is
      type  t_estado is (C,K,F);
      signal estado_KFC : t_estado;

      signal temp_out:  std_logic_vector(9 downto 0); --10 bits ; salida de la temperatura en las unidades elegidas
           
       --senales para calculo unidades F
      signal aux1_F:   std_logic_vector(13 downto 0); -- 9 + 6 bits
      signal aux2_F:   std_logic_vector(8 downto 0);

      signal temp_bin: std_logic_vector(8 downto 0);

      signal t_centenas_BCD: std_logic_vector(3 downto 0);
      signal t_decenas_BCD:  std_logic_vector(3 downto 0);
      signal t_unidades_BCD: std_logic_vector(3 downto 0);

      signal t_DU:          std_logic_vector(8 downto 0); --suma unidades y decenas
      signal t_sum_bin_1:   std_logic_vector(4 downto 0);
      signal t_carry_BCD:   std_logic_vector(1 downto 0);

begin


--FSM DEL PULSADOR
  process(clk,nRst)
  begin	
	if nRst = '0' then 
		estado_KFC <= C ;
	elsif clk'event and clk = '1' then 
		case estado_KFC is
		   when C =>
			if K1_down = '1' then 
		 	  estado_KFC <= K;
		        end if;
		   when K =>
		        if K1_down = '1' then 
			  estado_KFC <= F;
			end if;
				
		   when F =>
			if K1_down = '1' then 
			  estado_KFC <= C;
			end if;
		    end case;
        end if;
  end process;

  KFC <= X"C" when estado_KFC = C else
         X"B" when estado_KFC = K else
         X"A" when estado_KFC = F else
         X"E" ;  --error; 


--MAQUINA DE ESTADOS CONVERSION
  process(clk,nRst)
  begin
         if nRst='0' then
           temp_out <= (others => '0');

         elsif clk'event and clk='1' then
           case estado_KFC is

             when C => --Centigrados
                temp_out <= temp_final(8)&temp_final;

             when K => --Kelvin
                if temp_final(8) = '1' then                  -- si es negativo 
                  temp_out <= 273 + ("11"&temp_final(7 downto 0));          
                else                                         -- si es positivo
                  temp_out <= ("00"& temp_final(7 downto 0)) + 273;
                end if;

             when F => --FahrFahrenheitenheit  
               --(multiplicacion por 1.8 es igua aprox 115/64)
               -- 115 es 2^6 + 2^5 + 2^4 + 2 + 1  
               -- 64 es 2^6
               if temp_final(8) = '1' then                   -- si es negativo 
                  aux1_F <= (temp_final(7 downto 0)&"000000")+ ('1'&temp_final(7 downto 0)&"00000") + 
			  ("11"&temp_final(7 downto 0)&"0000") + ("11111"&temp_final(7 downto 0)&'0' )+ 
			   ("111111"&temp_final(7 downto 0));            
                  temp_out <= (aux1_F(13)&aux1_F(13)& aux1_F (13 downto 6) )+ 32; 

                else                                         -- si es positivo
                  aux1_F <= (temp_final(7 downto 0)&"000000")+ (temp_final(7 downto 0)&"00000") + 
			  (temp_final(7 downto 0)&"0000") + (temp_final(7 downto 0)&'0' )+ 
			   temp_final(7 downto 0);   
                  temp_out <= ("00"& aux1_F (13 downto 6) )+ 32;
                end if;

	     when others =>
                temp_out <= (others => '0');

            end case;
          end if;
       
  end process;
  
--CALCULO TEMP EN BCD

  temp_signo  <= temp_out(9);          -- 0: positivo, 1: negativo
  temp_bin <= temp_out(8 downto 0) when temp_signo = '0' else
              (not temp_out(8 downto 0) + 1 );         --valor absoluto   

 
  t_centenas_BCD <= "0100" when temp_bin(8 downto 0) >= 400 else --4 en centenas                 
                    "0011" when temp_bin(8 downto 0) >= 300 else --3 en centenas
                    "0010" when temp_bin(8 downto 0) >= 200 else --2 en centenas
                    "0001" when temp_bin(8 downto 0) >= 100 else --1 en centenas
                    "0000";                                      --0 en centenas

  t_DU <= temp_bin(8 downto 0) - 400 when t_centenas_BCD = "100" else
          temp_bin(8 downto 0) - 300 when t_centenas_BCD = "011" else
          temp_bin(8 downto 0) - 200 when t_centenas_BCD = "010" else
          temp_bin(8 downto 0) - 100 when t_centenas_BCD = "001" else
          temp_bin(8 downto 0);

  t_sum_bin_1 <= ('0' & t_DU(3) & t_DU(6) & t_DU(1 downto 0)) + ("00" & t_DU(4) & t_DU(4) & '0') + ("00" & t_DU(2) & t_DU(5) & '0') +("00" & t_DU(7) & t_DU(8) & '0');

  t_carry_BCD <= "00" when t_sum_bin_1 < 10 else  -- Menor a 10 no genera acarreo
                 "01" when t_sum_bin_1 < 20 else  -- Menor a 20 genera acarreo de 1
                 "10";                          -- Menor a 30 genera acarreo de 2

  t_unidades_BCD <= t_sum_bin_1(3 downto 0)      when t_carry_BCD = "00" else
                    t_sum_bin_1(3 downto 0) + 6  when t_carry_BCD = "01" else
                    t_sum_bin_1(3 downto 0) + 12;

  t_decenas_BCD <= ('0' & t_DU(6) & t_DU(6) & t_DU(4)) +  -- bits para el valor de decenas (64, 16)
                   ("00" & t_DU(5) & t_DU(5)) +            -- bits para el valor de decenas (32)
                   t_carry_BCD;                            -- acarreo de las unidades

-- Resultado final: puedes usar un bit extra para el signo
  temp_BCD <= t_centenas_BCD & t_decenas_BCD & t_unidades_BCD;

end rtl;
