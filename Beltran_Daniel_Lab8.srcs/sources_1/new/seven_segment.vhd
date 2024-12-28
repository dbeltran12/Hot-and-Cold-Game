-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 7
-- Project    : 
-------------------------------------------------------------------------------
-- File       : seven_segment.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-9-27
-- Last update: 2024-11-3
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity seven_segment is
    Port (
        clk             : in std_logic;
        reset           : in std_logic;
        key_data        : in integer range 0 to 15;
        seven_segments  : out std_logic_vector(7 downto 0);
        timer_expired   : out std_logic := '0'
     );
end seven_segment;

architecture Behavioral of seven_segment is
    -- Array to hold display value of ssd
    type integer_array is array (0 to 1) of integer range 0 to 9;
    signal display       :integer_array;

    --Signal declared to track counting for timing purposes
    signal count_Hz      :integer := 0;
    signal flag          :std_logic := '0';
begin
    counter: process(clk)
    begin
        --When reset is pressed all values and counts will be reset to 0.
        if (reset = '1') then
            seven_segments <= b"0000_0000";
            count_Hz <= 0;
            display <= (others => 0);
            flag <= '0';
        elsif (rising_edge(clk)) then
            --To achieve a 62.5Hz switching speed between C1 and C2 on the seven segment display
            -- the switching is delayed by 1,500,000 clock cycles which is equal to a 83.3Hz clock speed
            if(count_Hz < 1_500_000) then
                count_Hz <= count_Hz + 1;
            else
                --If the display has not already been updated i.e. a new key has been pressed
                -- display value shifts to the left ssd output and the right output is updated
                if(display(0) /= key_data and key_data <= 9) then
                    display(1) <= display(0);
                    display(0) <= key_data;
                end if;
                -- At this point the switching speed is 83.3Hz and the flag below is used to toggle the first
                --  bit of the std_logic_vector.
                if(flag = '0') then
                    case (display(0)) is
                        when 0 => seven_segments <= b"0011_1111";
                        when 1 => seven_segments <= b"0000_0110";
                        when 2 => seven_segments <= b"0101_1011";
                        when 3 => seven_segments <= b"0100_1111";
                        when 4 => seven_segments <= b"0110_0110";
                        when 5 => seven_segments <= b"0110_1101";
                        when 6 => seven_segments <= b"0111_1101";
                        when 7 => seven_segments <= b"0000_0111";
                        when 8 => seven_segments <= b"0111_1111";
                        when 9 => seven_segments <= b"0110_1111";
                    end case;
                    flag <= '1';
                else
                    case (display(1)) is
                        when 0 => seven_segments <= b"1011_1111";
                        when 1 => seven_segments <= b"1000_0110";
                        when 2 => seven_segments <= b"1101_1011";
                        when 3 => seven_segments <= b"1100_1111";
                        when 4 => seven_segments <= b"1110_0110";
                        when 5 => seven_segments <= b"1110_1101";
                        when 6 => seven_segments <= b"1111_1101";
                        when 7 => seven_segments <= b"1000_0111";
                        when 8 => seven_segments <= b"1111_1111";
                        when 9 => seven_segments <= b"1110_1111";
                    end case;
                    flag <= '0';
                end if;
                 count_Hz <= 0;
                
            end if;
                
        end if; 

    end process;


end Behavioral;
