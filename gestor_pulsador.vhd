--Gestor de la entrada sincrona de los pulsadores K1 y K0
--Detecta los flancos de subida de los pulsadores.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gestor_pulsadores is 
  Port (clk           : in std_logic;
	nRst          : in std_logic;
        K1_filtrado   : in std_logic;   -- a nivel alto cuando hay una opulsacion
        K0_filtrado   : in std_logic;
        K1_down       : buffer std_logic;
        K0_down       : buffer std_logic
   );
end entity;

architecture rtl of gestor_pulsadores is
  signal k1_anterior:   std_logic; --flanco actual
  signal K1_actual:     std_logic; --flanco anterior
  
  signal k0_anterior:   std_logic; --flanco actual
  signal K0_actual:     std_logic; --flanco anterior
  
  signal activa_k0: std_logic;
  signal activa_k1: std_logic;
	
-- gestion pulsacion K1
begin

process(clk, nRst) 
begin
  if nRst = '0' then
  
      K0_anterior <= '1';
      K0_actual <= '1';
      activa_k0 <= '0';
		
    elsif clk'event and clk = '1' then
	    K0_actual <= K0_filtrado;
		 K0_anterior <= K0_actual;
		 
		 if K0_actual = '1' and K0_anterior = '0' then
		 activa_k0 <= '1';
		 else 
		 activa_k0 <= '0';
		 end if;
		end if;

end process;

process(clk, nRst) 
begin
  if nRst = '0' then
      K1_anterior <= '1';
      K1_actual <= '1';
		activa_k1 <= '0';

    elsif clk'event and clk = '1' then
	    K1_actual <= K1_filtrado;
		 K1_anterior <= K1_actual;
		 
		 if K1_actual = '1' and K1_anterior = '0' then
		 activa_k1 <= '1';
		 else 
		 activa_k1 <= '0';
		 end if;
		end if;

end process;

K1_down <= activa_k1;
K0_down <= activa_k0;


end rtl;