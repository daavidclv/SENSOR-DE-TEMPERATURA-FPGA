--Filtrador de rebotes para pulsadores

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity filtro_pulsadores is
port(clk           :in     std_logic;
     nRst          :in     std_logic;
     K1            :in     std_logic; 
     K0            :in     std_logic;
     K1_filtrado   :buffer std_logic; -- a nivel alto si ocurre una p�lsacion
     K0_filtrado   :buffer std_logic
    );
end entity;

architecture rtl of filtro_pulsadores is


  signal K1_in_T:   std_logic_vector(4 downto 1);   -- Rango con referencias               
  signal K1_T_0:    std_logic;                      -- Simplificacion del codigo
  signal K1_T0_1:   std_logic;
  signal K1_T0_2:   std_logic;
  signal K1_T0_3:   std_logic;

  signal K0_in_T:   std_logic_vector(4 downto 1);   -- Rango con referencias               
  signal K0_T_0:    std_logic;                      -- Simplificacion del codigo
  signal K0_T0_1:   std_logic;
  signal K0_T0_2:   std_logic;
  signal K0_T0_3:   std_logic;

begin


--GLITCHES K1
  process(clk, nRst)                                                            
  begin
  
    if nRst = '0' then
      K1_T0_1 <= '1';

    elsif clk'event and clk = '1' then
	    K1_T0_1 <= K1;
	
	end if;
  end process;
  
  process(clk, nRst)                                                           
  begin
    if nRst = '0' then
      K1_T0_2 <= '1';

    elsif clk'event and clk = '1' then
	  K1_T0_2 <= K1_T0_1;
	end if;
  end process;

process(clk, nRst)                                                           
  begin
    if nRst = '0' then
      K1_T0_3 <= '1';

    elsif clk'event and clk = '1' then
	  K1_T0_3 <= K1_T0_2;
	end if;
  end process;
                   

--GLITCHES K0
  process(clk, nRst)                                                            
  begin
    if nRst = '0' then
      K0_T0_1 <= '1';

    elsif clk'event and clk = '1'   then
	  K0_T0_1 <= K0;
	end if;
  end process;
  
  process(clk, nRst)                                                           
  begin
    if nRst = '0' then
      K0_T0_2 <= '1';

    elsif clk'event and clk = '1' then
	  K0_T0_2 <= K0_T0_1;
	end if;
  end process;

process(clk, nRst)                                                           
  begin
    if nRst = '0' then
      K0_T0_3 <= '1';

    elsif clk'event and clk = '1' then
	  K0_T0_3 <= K0_T0_2;
	end if;
  end process;

  process(clk, nRst)                                
  begin
    if nRst = '0' then
      K1_in_T <= (others => '1');
 
    elsif clk'event and clk = '1' then
      if (K1_in_T(4) = (K1_T0_3)) and (K1_in_T(3 downto 1) /= (K1_T0_3)&(K1_T0_3)&(K1_T0_3)) then 
        K1_in_T(3 downto 1) <= (K1_T0_3)&(K1_T0_3)&(K1_T0_3); 
  
      else
        K1_in_T <= K1_in_T(3 downto 1)&(K1_T0_3); 
  
      end if;
    end if;
  end process;


 process(clk, nRst)                                
  begin
    if nRst = '0' then
      K0_in_T <= (others => '1');

    elsif clk'event and clk = '1' then
      if (K0_in_T(4) = (K0_T0_3)) and (K0_in_T(3 downto 1) /= (K0_T0_3)&(K0_T0_3)&(K0_T0_3)) then 
        K0_in_T(3 downto 1) <= (K0_T0_3)&(K0_T0_3)&(K0_T0_3); 
  
      else
        K0_in_T <= K0_in_T(3 downto 1)&(K0_T0_3); 
  
      end if;
    end if;
  end process;

  K1_filtrado <= K1_in_T(4);
  K0_filtrado <= K0_in_T(4);
 
end rtl;
