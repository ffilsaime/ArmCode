----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Florebencia Fils-Aime
-- 
-- Create Date: 04/08/2020 10:05:47 PM
-- Design Name: 
-- Module Name: guess_the_num - Behavioral
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity guess_the_num is
    Port ( sw : in std_logic_vector(15 downto 0); -- controls the switches
           led : out std_logic_vector(15 downto 0); -- controls the LEDs
           seg: out std_logic_vector(6 downto 0); -- controls the seven segment displays
           an: out std_logic_vector(3 downto 0); -- control the four anodes
           clk: in std_logic; -- gets the clock
           btnC: in std_logic; -- gets the input of the center button
           btnU: in std_logic; -- gets the input of the up button
           btnD: in std_logic; -- gets the input of the down button
           btnR: in std_logic; -- gets the input of the right button
           btnL: in std_logic; -- gets the input of the left button
           dp: out std_logic); -- controls the decimal points
end guess_the_num;

architecture Behavioral of guess_the_num is
    signal guess, state, d3, d2, d1, d0: unsigned(3 downto 0) := "0000";
    signal switcher: unsigned(1 downto 0); -- controls which anodes are on
    signal fakeclk: std_logic := '1'; -- used for the slower clock
    -- used to determine the values for player 1 and player 2
    signal player1, player2, fourth, fth, third, t, second, s, first, fst: unsigned(15 downto 0); 
    -- counter is used for changing states and frequency is used for the slower clock
    signal counter, frequency: integer := 0;
    signal win, lose, toohi, toolow: boolean := false; -- these are used to change states
    signal dflipflop, dflipflop2, dflipflop3, result: std_logic := '0'; -- used for debouncing
 
begin

instructions: process(state)
-- show the instructions on the 7 segment display
    begin
        case state is
            when "0000" => seg <= "1000000"; -- this makes the 0
            when "0001" => seg <= "1111001"; -- this makes a 1
            when "0010" => seg <= "0100100"; -- this makes a 2
            when "0011" => seg <= "0110000"; -- this makes a 3
            when "0100" => seg <= "0011001"; -- this makes a 4
            when "0101" => seg <= "0010010"; -- this makes a 5 but it looks like an S
            when "0110" => seg <= "0001001"; -- this makes an H
            when "0111" => seg <= "1001111"; -- this makes an I
            when "1000" => seg <= "0000110"; -- this is E
            when "1001" => seg <= "0001100"; -- this is P
            when "1010" => seg <= "1000111"; -- this is L
            when "1011" => seg <= "1111111"; -- the rest of these cases only turn off the leds
            when "1100" => seg <= "1111111";
            when "1101" => seg <= "1111111";
            when "1110" => seg <= "1111111"; 
            when "1111" => seg <= "1111111";
        end case;
end process;

change7seg: process(switcher, counter,win,lose,toolow,toohi)
-- alternates between different 7 segment displays
-- shows the words "2 LO", "2 HI", "PL 2", "PL 1" and "LOSE" 
--it shows the number of guesses if you when
-- it lights dp based on how many guesses you have on the "PL 2" screen 
begin
    case switcher is 
        when "00" =>
            if(win) then
                an <= "1111"; -- turn off all the anodes
            elsif(lose) then
                an <= "1110"; -- turn on anode 0
                state <= "1000"; -- this is an E
            elsif(toolow) then
                an <= "1110"; -- turn on anode 0
                state <= "0000"; -- this is a zero or an O
            elsif(toohi) then
                an <= "1110"; -- turn on anode 0
                state <= "0111"; -- this is an I     
            elsif(counter = 0) then
                an <= "1110"; -- turn on anode 0
                state <= "0001"; -- makes a 1
            elsif(counter = 1) then   
                an <= "1110"; -- turn on anode 0 
                state <= "0010"; -- makes a 2
                if (guess >= "0001") then
                    dp <= '0';
                else 
                    dp <= '1';
                end if;         
            end if; --check if the user got the right answer
        when "01" =>
            if(lose) then
                an <= "1101"; -- turn on anode 1
                state <= "0101"; -- this is an 5 or an S
            elsif(toolow) then
                an <= "1101"; -- turn on anode 1
                state <= "1010"; -- this is an L
            elsif(toohi) then
                an <= "1101"; -- turn on anode 1
                state <= "0110"; -- this is an H
            elsif(counter <= 1 or win) then   
                an <= "1101"; -- turn on anode 1  
                state <= "1011"; -- turn off all led segments
                if (guess >= "0010") then
                    dp <= '0';
                else 
                    dp <= '1';
                end if;      
            end if; --check if the user got the right answer
        when "10" => 
            if(win or toolow or toohi) then
                an <= "1111"; -- turn off all the anodes
            elsif(lose) then
                an <= "1011"; -- turn on anode 2
                state <= "0000"; -- will make a zero or an O
            elsif(counter <= 1) then
                an <= "1011"; -- turn on anode 2
                state <= "1010"; -- makes a L
                if (guess >= "0011") then
                    dp <= '0';
                else 
                    dp <= '1';
                end if;
            end if; 
            
        when "11" => 
            if(win) then
                an <= "0111"; -- turn on anode 3
                state <= guess;
            elsif(lose) then
                an <= "0111"; -- turn on anode 3
                state <= "1010"; -- makes an L
            elsif(toohi or toolow) then
                an <= "0111"; -- turn on anode 3
                state <= "0010"; -- makes a 2
            elsif(counter <= 1) then
                an <= "0111"; -- turn on anode 3
                state <= "1001"; -- makes a P
                if (guess = "0100") then
                    dp <= '0';
                else 
                    dp <= '1';
                end if;
            end if; --check if the user got the right answer
    end case;
end process;

-- creates the slower clock
controlingeachanode: process(clk)
begin
    if(clk'event and rising_edge(clk)) then
		frequency <= frequency + 1;
		if(frequency = 100000) then
			switcher <= switcher + 1; -- will switch between anodes
			frequency <= 0;
			fakeclk <= not fakeclk;
		end if;
    end if; -- end of clk event and rising edge

end process;

-- controls the fourth digit in the seven segment display for player 1 and 2
-- latches the values 
rightbutton: process(clk)
begin
    if(rising_edge(clk)) then
        if(btnR = '1') then
            d3 <= unsigned(sw(3 downto 0)); -- get the first digit
            if(counter = 0) then
                fourth <= resize(d3,16);
            elsif(counter = 1) then
                fth <= resize(d3,16);
            end if;        
        end if; --end of right button pressed
    end if; -- end of rising edge if
end process;

-- controls the first digit in the seven segment display for player 1 and 2
-- latches the values 
leftbutton: process(clk)
begin
    if(rising_edge(clk)) then
        if(btnL = '1') then
            d0 <= unsigned(sw(3 downto 0)); -- get the first digit
            if(counter = 0) then
                first <= resize(d0,16);
            elsif(counter = 1) then
                fst <= resize(d0,16);
            end if;        
        end if; --end of right button pressed
    end if; -- end of rising edge if
end process;

-- controls the second digit in the seven segment display for player 1 and 2
-- latches the value
upbutton: process(clk)
begin
    if(rising_edge(clk)) then
        if(btnU = '1') then
            d1 <= unsigned(sw(3 downto 0)); -- get the first digit
            if(counter = 0) then
                second <= resize(d1,16);
            elsif(counter = 1) then
                s <= resize(d1,16);
            end if;        
        end if; --end of right button pressed
    end if; -- end of rising edge if
end process;

-- controls the third digit in the seven segment display for player 1 and 2
-- latches the values 
downbutton: process(clk)
begin
    if(rising_edge(clk)) then
        if(btnD = '1') then
            d2 <= unsigned(sw(3 downto 0)); -- get the first digit
            if(counter = 0) then
                third <= resize(d2,16);
            elsif(counter = 1) then
                t <= resize(d2,16);
            end if;        
        end if; --end of right button pressed
    end if; -- end of rising edge if
end process;

centerbutton: process(clk, btnC)
begin
    if(rising_edge(clk)) then
        if(btnC = '1') then
            if (counter = 0) then
                player1 <= shift_left(fourth,12) or shift_left(third,8) or shift_left(second,4) or first;
            elsif(counter = 1) then
                player2 <= shift_left(fth,12) or shift_left(t,8) or shift_left(s,4) or fst;             
            end if;
        end if;      
    end if;
end process;

debouncing: process (fakeclk, btnC)
begin
	if fakeclk'event and rising_edge(fakeclk) then
		dflipflop <= btnC; -- gets the input from the center button
		dflipflop2 <= dflipflop;
		dflipflop3 <= dflipflop2;
	end if;
	result <= dflipflop and dflipflop2 and dflipflop3; -- the debounced center button value
	if(falling_edge(result)) then
	   if(counter = 0) then
            counter <= 1; -- change the value of the seven segment into "PL 2"
       elsif(counter = 1) then
            counter <= 2; -- start comparing values of player 1 and player 2
            guess <= guess + 1; -- increment the guesses used
       end if;
    end if;
    if(toohi or toolow) then
        counter <= 1; -- change back to "PL 2"
    end if;
end process;


truthvalues: process(counter)
variable timer, secs: integer := 0;
begin
    -- checking if the player2 guessed the right number
    if(guess = "0100") then
        lose <= true; -- player 2 has lost
        toolow <= false;
        win <= false;
        toohi <= false;
    elsif(player1 = player2 and counter = 2) then
        win <= true; -- player 2 has just won
        lose <= false;
        toolow <= false;
        toohi <= false;
    elsif(player1 > player2 and counter = 2) then
        toolow <= true; -- the value player 2 used was too low
        win <= false;
        lose <= false;
        toohi <= false;
    elsif(player1 < player2 and counter = 2) then 
        toohi <= true; -- the value player 2 used was too hi
        toolow <= false;
        win <= false;
        lose <= false;
     elsif (toohi or toolow) then
     -- counts for 3 seconds
        if(rising_edge(clk)) then
            timer := timer + 1;
                if(timer = 100e6) then
                    timer := 0;
                    secs := secs + 1;
                if(secs = 3) then
                    secs := 0;
                    toohi <= false;
                    toolow <= false;
                end if;
            end if;
        end if;                     
    end if; -- end of testing if the number is right, too high or too low.
         
end process; 

lights: process(clk)
variable timer, secs: integer := 0;
begin
-- turns the LEDs on and off in 1 second intervals
    if(win) then
        if(rising_edge(clk)) then
            timer := timer + 1;
            if(timer = 100e6) then
                timer := 0;
                secs := secs + 1;
                if(secs mod 2 = 0) then
                    led(15 downto 0) <= "0000000000000000"; -- leds are off
                elsif(secs mod 2 = 1) then
                    led(15 downto 0) <= "1111111111111111"; -- leds are on
                end if;
            end if;
        end if;
    end if;
end process;

end Behavioral;
