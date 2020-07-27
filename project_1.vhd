----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/24/2020 05:42:02 PM
-- Design Name: 
-- Module Name: project_1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_1 is
    Port (
     sw: in std_logic_vector (15 downto 0); -- controls the switches
     led: out std_logic_vector (15 downto 0); -- controls the leds
     seg: out std_logic_vector (6 downto 0); -- the seven segment display
     clk: in std_logic; -- the clock
     btnC: in std_logic; -- the center button
     an: out std_logic_vector (3 downto 0)); -- the different anodes
end project_1;

architecture Behavioral of project_1 is
    signal firstin: std_logic_vector(3 downto 0);
    signal fakeclk: std_logic := '1';
    signal divider : integer;
    signal counter : unsigned(1 downto 0);
    signal latch: std_logic_vector(15 downto 0);
begin
    led <= sw; -- the led is on when the switch is up
-- making my own clock
    changetheclock: process(clk)
      --  variable divider: integer := 0;
        begin
        -- setting up the clock
            if(clk'event and rising_edge(clk)) then
                divider <= divider + 1;
                if (divider = 100000) then
                    fakeclk <= not fakeclk;
                    divider <= 0;
                    counter <= counter + 1;
                end if; -- end of if with divider
            end if; -- end of if with clk event and rising edge
    end process; -- end of change clock

    changesevendisplay: process(firstin)
        begin  
        -- controls what is displayed on the seven segment
            case firstin is
                when "0000" => seg <= "1000000"; -- when the value is 0, then display a 0
                when "0001" => seg <= "1111001"; -- when the value is 1, display a 1
                when "0010" => seg <= "0100100";-- when the value is a 2, display a 2
                when "0011" => seg <= "0110000"; -- display 3
                when "0100" => seg <= "0011001"; -- display a 4
                when "0101" => seg <= "0010010"; -- display 5
                when "0110" => seg <= "0000010"; -- display 6
                when "0111" => seg <= "1111000"; -- display 7
                when "1000" => seg <= "0000000"; -- display 8
                when "1001" => seg <= "0010000"; -- display 9
                when "1010" => seg <= "0001000"; -- display A
                when "1011" => seg <= "0000011"; -- display a lowercase B or 11
                when "1100" => seg <= "1000110"; -- display a C aka 12
                when "1101" => seg <= "0100001"; -- display a lowercase D aka 13
                when "1110" => seg <= "0000110"; -- display an E aka 14
                when "1111" => seg <= "0001110"; -- display a F aka 15
             end case;
    end process;     

    changewhich7seg: process(firstin)
    begin
    -- alternates between different 7 segment displays
        case counter is
            when "00" =>
                an <= "1110"; -- turn on anode 0
                firstin <= latch(3 downto 0); -- the first 4 switches
            when "01" =>
                an <= "1101"; -- turn on anode 1
                firstin <= latch(7 downto 4); -- the second 4 switches

            when "10" =>
                an <= "1011"; -- turn on anode 2
                firstin <= latch(11 downto 8); -- the third 4 switches
    
            when "11" =>
                an <= "0111"; -- turn on anode 3
                firstin <= latch(15 downto 12); -- the fourth 4 switches
        end case;
    end process;
    
    workonlywithbutton: process(clk)
    begin
    -- this makes sure the button controls what's being shown on the seven segment display
        if (rising_edge(clk)) then
        -- if the button is pressed
            if (btnC = '1') then
                latch <= sw; -- latch saves the value of the switches
            end if;
        end if;
    end process;
end Behavioral;
