-- Control del modulo spi
-- genera las senales necesarias para el correcto funcionamiento de las 
--senales SC CS y SIO

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_spi is
    port (
        clk:              in  std_logic;
        nRst:             in  std_logic;
        SC_down:          in  std_logic;
	      CS:	  in  std_logic;
        K0_down:          in std_logic;
        rst_reg: 	  buffer std_logic;
        carga_reg: 	  buffer std_logic;
        ena_tx:		  buffer std_logic;
        SPI_completado:	  buffer std_logic;      --Indica que se completo la lectura, mas para la simulacion que otra cosa
	      cnt_bits:	  buffer std_logic_vector(4 downto 0);
        Cuatro_Seis_Ocho: buffer std_logic_vector (3 downto 0); -- saber en que periodo estamos
        frec_tic:         buffer std_logic
    );
end control_spi;


architecture rtl of control_spi is

  constant UnMillon: natural:=  999999 ; 	--999999 
  constant Cincuenta: natural:=      49 ; 		--99

--Para pruebas
-- constant UnMillon: natural:= 10 ; 	--999999 
-- constant Cincuenta: natural:= 3 ; 		--99

  type t_estado is (INI, TX);
  signal estado : t_estado;
  
  type t2_estado is (DOS, CUATRO, SEIS, OCHO);
  signal estado_frec : t2_estado;

--Se�ales para contadores 
signal cnt_1M:   	std_logic_vector(23 downto 0);
signal cout_1M:  	std_logic;
signal cnt_50:  	std_logic_vector(6 downto 0);
signal cout_50: 	std_logic;
signal cnt_4:    	std_logic_vector(2 downto 0);  
signal cnt_3:    	std_logic_vector(1 downto 0); 
signal SPI_2seg:	std_logic;
signal SPI_4seg:  	std_logic;
signal SPI_6seg:  	std_logic;
signal SPI_8seg:  	std_logic;
signal rst_temp: 	std_logic := '0';
signal cout_50_tic:	std_logic;
signal cout_50_next:	std_logic;
signal contador_seg : std_logic_vector(3 downto 0); 


begin

    process(clk, nRst)
    begin
        if nRst = '0' then
		  
            cnt_bits        <= (others => '0');
            rst_reg         <= '0';
            carga_reg       <= '0';
            ena_tx          <= '1';
            SPI_completado  <= '0';
			      estado          <= TX;

         elsif clk'event and clk = '1' then
            case estado is

                when INI =>
                    carga_reg <= '0';
                    ena_tx <= '0';
                    cnt_bits <= (others => '0');
                    
                    if frec_tic = '1' then  
                        ena_tx <= '1';
                        SPI_completado  <= '0';
                        rst_reg <= '1';
                        estado <= TX;
                    end if;

                when TX =>
			 rst_reg <= '0';
						  
                     if cnt_bits = 16 then 
                        SPI_completado <= '1';
                        estado <= INI;
                     else 
           
                        if SC_down = '1'  then
                            carga_reg <= '1';
                            cnt_bits <= cnt_bits + 1;
                           
                        else
                          carga_reg <= '0';
                        end if;

                     end if;

            end case;
        end if;
    end process;


---GENERACION DE RELOJES ---------
  
--Contador de un millon
  process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_1M <= (others => '0');
      
    elsif clk'event and clk = '1' then
	 if  rst_temp ='1'  then
	 cnt_1M <= (others => '0');
      elsif cout_1M = '1' then       
      cnt_1M <= (others => '0');
        
      else
      cnt_1M <= cnt_1M + 1;
      end if;
    end if;
  end process;
  
  cout_1M <= '1' when cnt_1M = UnMillon
               else '0';
 
--contador de cien 
  process(clk, nRst)
  begin
    if nRst = '0'   then
      cnt_50 <= (others => '0');
      
    elsif clk'event and clk = '1' then
	   if  rst_temp = '1'then 
		 cnt_50 <= (others => '0');
      elsif cout_1M = '1' then       
        if cout_50_next = '1' then       
          cnt_50 <= (others => '0');
        
        else
          cnt_50 <= cnt_50 + 1;
        end if;
      end if;
    end if;
  end process;

  cout_50_next  <= '1' when (cnt_50 = Cincuenta) and (cout_1M = '1') 
                else '0';

process(clk, nRst)
 begin
   if nRst = '0' then
     cout_50_tic <= '0';
   elsif clk'event and clk='1'then
     cout_50_tic <= cout_50_next;
   end if;
end process;


process(clk, nRst)
begin
  if nRst = '0' then
	 contador_seg <= (others =>'0');
	 frec_tic <= '1' ; 
	 
  elsif clk'event and clk='1'then
    if  rst_temp ='1' then 
	    contador_seg <= (others =>'0');
	    frec_tic <= '0' ; 
		 
	 elsif cout_50_tic = '1' then 
	   	if contador_seg = Cuatro_Seis_Ocho - 1  then 
		  	contador_seg <= (others =>'0');
		     frec_tic <= '1' ; 
	  	else 
			  contador_seg <= contador_seg +1 ;
		     frec_tic <= '0' ; 
		  end if ; 
          else 
            frec_tic <= '0' ;
         end if ; 
    end if;
end process;


---MAQUINA DE ESTADOS PARA FRECUENCIA MEDIDAS

   process(clk, nRst)
    begin
        if nRst = '0' then
            estado_frec <= CUATRO;

         elsif clk'event and clk = '1' then
            case estado_frec is

                when DOS =>
                    rst_temp <= '0';

                    if K0_down = '1' then 
                        rst_temp <= '1';
                        estado_frec <= CUATRO;
                    end if;

                 when CUATRO =>
                    rst_temp <= '0';

                    if K0_down = '1' then 
                         rst_temp <= '1';
                         estado_frec <= SEIS;
                    end if;

                when SEIS =>
                    rst_temp <= '0';
                  
                    if K0_down = '1' then  
                         rst_temp <= '1';
                         estado_frec <= OCHO;
                    end if;

                 when OCHO =>
                    rst_temp <= '0';
                  
                    if K0_down = '1' then  
                         rst_temp <= '1';
                         estado_frec <= DOS;
                    end if;


                when others =>
                    estado_frec <= CUATRO;
            end case;
        end if;
    end process;

--Periodo seleccionado por K0
 Cuatro_Seis_Ocho <= "0010" when  estado_frec = DOS    else    
                     "0100" when  estado_frec = CUATRO else
                     "0110" when  estado_frec = SEIS   else
                     "1000" when  estado_frec = OCHO   else 
                     "0000"; 



end rtl;


