--PROTOTIPO DISE�O GENERADOR D SENALES PARA SENSOR DE TEMPERATURA

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity gen_sc is
port(clk           :in     std_logic;
     nRst          :in     std_logic;
     ena_tx        :in     std_logic;       --activa segun el periodo de medida (2s 4s...)
     CS            :buffer std_logic;
     SC            :buffer std_logic;
     SC_down         :buffer std_logic    
    );
end entity;

architecture rtl of gen_sc is

-- Reloj de 50 MHz
--constante periodo del sensor = 6,25Mhz cada periodo (160 ns)

 signal cnt_SC: std_logic_vector (4 downto 0); --contador 4 cilos para reloj SC
signal n_ctrl_SC: std_logic; 
 

begin

--PROCESO 1: GENERACION PERIODO SC 
process(clk, nRst)
  begin
    if nRst = '0' then
      cnt_SC <= (0 => '1',others => '0'); 
      n_ctrl_SC <= '1';			
      
    elsif clk'event and clk = '1' then
      if ena_tx = '1' then   -- se activa la habilitacion de transferencia
   
      	if cnt_SC = 10 then  -- Cuando llega a 8, reseteamos a 1
        	cnt_SC <= (0 => '1', others => '0'); -- 1 en posici�n 0
       		 n_ctrl_SC <= '1';
        else
      	 -- Asignacion de SC senal el valor del contador
       		 if cnt_SC > 5 then
       		   n_ctrl_SC <= '1';  
       		 else
        	      n_ctrl_SC <= '0'; 
     	       end if;

        cnt_SC <= cnt_SC + 1;

       end if;
      
     else      --ena_SC a 0, no transmitiendo
        
      n_ctrl_SC <= '1'; 
      cnt_SC <= (others => '0');

     end if;
    end if;
 end process;


--PROCESO 2: GENERACION SENAL CS 

process(clk, nRst)
begin
  if nRst = '0' then
    CS <= '1'; -- reposo

  elsif clk'event and clk = '1' then
   
     if ena_tx = '1' then
        CS <= '0'; -- activo
     else
        CS <= '1';
     end if;

  end if;
end process;


-----GENERACION SALIDAS Y SENALES-----------------
 --Flanco de bajada de SC, captura del bit de SIO
  SC_down <= '1' when cnt_SC = 2 and ena_tx= '1' and CS = '0' else '0';
 
  -- SC sale en activo bajo
  SC <= n_ctrl_SC when CS = '0' and ena_tx = '1' else 'Z';

end rtl;
