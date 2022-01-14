-- uart_fsm.vhd: UART controller - finite state machine
-- Author(s): Tadeas Kachyna -- xkachy00
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK        : in std_logic;
   RST        : in std_logic;
   DIN        : in std_logic;
   COUNTER    : in std_logic_vector(4 downto 0);
   CNTBITS    : in std_logic_vector(3 downto 0);
   CNTSTOP    : in std_logic_vector(3 downto 0);
   DT_VLD     : out std_logic;
   RECEIVER   : out std_logic;
   COUNTERSON : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type STATE_TYPE is (START, FIRST_BIT, RECEIVE_DATA, STOP_BIT, VALIDATION);
signal state : STATE_TYPE := START;
begin 
  
  RECEIVER <= '1' when state = RECEIVE_DATA 
  else '0';
  DT_VLD <= '1' when state = VALIDATION 
  else '0';
  COUNTERSON <= '1' when state = FIRST_BIT or state = RECEIVE_DATA 
  else '0';

  

  process (CLK) begin 
    if rising_edge(CLK) then
      if RST = '1' then
        
        state <= START;
  
      else
          case state is
          
          -- FIRST STATE --------------------------------------------------------
          
          when START => if DIN = '0' then
                                    state <= FIRST_BIT;
                                  end if;
                                
          -- SECOND STATE --------------------------------------------------------                       
        
          when FIRST_BIT => if COUNTER = "10110" then
                                    state <= RECEIVE_DATA;
                                  end if;
                                
          -- THIRD STATE --------------------------------------------------------                        
                                
          when RECEIVE_DATA => if CNTBITS = "1000" then
                                    state <= STOP_BIT;
                                  end if;
          -- FOURTH STATE --------------------------------------------------------                        
                                
          when STOP_BIT  => if CNTSTOP = "1000" then
                                  state <= VALIDATION; 
                                  end if;
                                
          -- FIFTH STATE --------------------------------------------------------  
                                
          when VALIDATION  => state <= START;               
           
           
           -- SIXTH STATE --------------------------------------------------------  
                                
          when others          => null;
          end case; 
      end if;
    end if;
  end process;
end behavioral;