-- uart.vhd: UART controller - receiving part
-- Author(s): Tadeas Kachyna xkachy00
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK      : in std_logic;
	RST      : in std_logic;
	DIN      : in std_logic;
	DOUT     : out std_logic_vector(7 downto 0);
	DOUT_VLD : out std_logic
);
end UART_RX;   

-------------------------------------------------
architecture behavioral of UART_RX is
signal cnt        : std_logic_vector(4 downto 0):= "00001" ;
signal cnt_bits   : std_logic_vector(3 downto 0):= "0000" ;
signal cnt_stop   : std_logic_vector(3 downto 0):= "0000" ;
signal dt_vld     : std_logic := '0';
signal receiver   : std_logic := '0';
signal counters_on: std_logic := '0';
signal DVLD       : std_logic := '0';
begin
  
  -- entity mapping
  FSM: entity work.UART_FSM(behavioral)
    port map (
        CLK 	         => CLK,  -- clock
        RST 	         => RST,  -- reset 
        DIN 	         => DIN,  -- input
        COUNTER       => cnt,  -- counter 
        CNTBITS       => cnt_bits, -- counter = counts bits
        CNTSTOP       => cnt_stop, -- counter = counts to stop_bit
        DT_VLD        => dt_vld, -- checks data
        RECEIVER      => receiver, 
        COUNTERSON    => counters_on
    );
  
    
    process(CLK) begin
      if rising_edge(CLK) then
        
        -- by default set dout_vld to '0'
        DOUT_VLD <= DVLD;
        
        -- counts CLK between each bit
        if counters_on = '1' then 
          cnt <= cnt + "1";  
        else
          cnt <= "00001";  
        end if;
        
        -- by default set dout to "00000000"
        if rst = '1' then
          DOUT <= "00000000"; 
        end if;
        
         if dt_vld = '0' then
          dt_vld <= '1'; 
        end if;
        
        -- start counting to "stop_bit" when read last bit
        if cnt_bits = "1000" then
           cnt_stop <= cnt_stop + "1";
        end if;
     
        -- when stop bit, set dout_vld to '1' and reset all counters to zero
        if cnt_stop = "1000" then
            DOUT_VLD <= '1';
            cnt_bits <= "0000";
            cnt_stop <= "0000";
        end if;
       
        -- reading data a sending them to DOUT
        if receiver = '1' then
          
          if cnt(4) = '1' then
            
            cnt <= "00001"; 
            
            case cnt_bits is
              
              when "0000" => DOUT(0) <= DIN; 
              when "0001" => DOUT(1) <= DIN; 
              when "0010" => DOUT(2) <= DIN; 
              when "0011" => DOUT(3) <= DIN; 
              when "0100" => DOUT(4) <= DIN; 
              when "0101" => DOUT(5) <= DIN;  
              when "0110" => DOUT(6) <= DIN; 
              when "0111" => DOUT(7) <= DIN;  
              when others => null;
            end case;
            
            -- increment every time when read a bit
            cnt_bits <= cnt_bits + "1";   
            
          end if;    
          
      end if;
      
  end if;
  
end process;

end behavioral;
