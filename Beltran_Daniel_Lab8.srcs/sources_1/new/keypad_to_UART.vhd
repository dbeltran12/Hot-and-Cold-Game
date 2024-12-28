-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 7
-- Project    : 
-------------------------------------------------------------------------------
-- File       : keypad_to_UART.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-11-2
-- Last update: 2024-11-2
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity keypad_to_UART is
    Port ( 
        clk         : in std_logic;
        reset       : in std_logic;
        key_data    : in integer range 0 to 15;
        tx_start    : out std_logic;
        tx_data     : out std_logic_vector(7 downto 0)
    );
end keypad_to_UART;

architecture Behavioral of keypad_to_UART is
begin
    determine_keys:process (clk)
    variable output_data     : integer range 0 to 15;
    begin
        if(reset = '1') then
            output_data := 0;
        elsif(rising_edge(clk)) then
            if(output_data /= key_data) then
                --If the display has not already been updated i.e. a new key has been pressed
                -- then key_data is updated and UART trasmitter is started
                    output_data := key_data;
                    tx_start <= '1';
                else
                --transmitter is turned off
                    tx_start <= '0';
            end if;
            -- tx_data is given ascii value of the character input
            case (output_data) is
                when 0  => tx_data <= x"30";
                when 1  => tx_data <= x"31";
                when 2  => tx_data <= x"32";
                when 3  => tx_data <= x"33";
                when 4  => tx_data <= x"34";
                when 5  => tx_data <= x"35";
                when 6  => tx_data <= x"36";
                when 7  => tx_data <= x"37";
                when 8  => tx_data <= x"38";
                when 9  => tx_data <= x"39";
                when 10 => tx_data <= x"41";
                when 11 => tx_data <= x"42";
                when 12 => tx_data <= x"43";
                when 13 => tx_data <= x"44";
                when 14 => tx_data <= x"45";
                when 15 => tx_data <= x"46";
            end case;
        end if;
    end process;
end Behavioral;
