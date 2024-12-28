-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 8
-- Project    : 
-------------------------------------------------------------------------------
-- File       : testbench.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-11-15
-- Last update: 2024-11-17
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.testing_pkg.all;

entity testbench is
--  Port ( );
end testbench;

architecture Behavioral of testbench is
    component game_controller is
        generic (
        clk_freq        : integer := 125_000_000 --USED FOR LED FLASH
        );
        Port (
            clk             : in std_logic;
            reset           : in std_logic;
            record_value    : in std_logic;
            key_data        : in integer range 0 to 15;
            hot_guess       : out std_logic;
            cold_guess      : out std_logic;
            correct_guess   : out std_logic
         );
    end component;
    
    signal clk          : std_logic;
    signal reset        : std_logic;
    signal key_data     : integer range 0 to 15;
    signal record_value : std_logic;
    signal blue_led     : std_logic;
    signal red_led      : std_logic;
    signal green_led    : std_logic;
begin

    DUT: game_controller
        generic map (
            clk_freq => 10
        )
        port map(
            clk           => clk,
            reset         => reset,
            record_value  => record_value,
            key_data      => key_data,
            hot_guess     => red_led,
            cold_guess    => blue_led,
            correct_guess => green_led
        );
    create_clock(clk, 125.0e6);
    game_test: process
    begin
        start_tests(11);
        reset_pulse(reset);
        wait until falling_edge(reset);
        wait until rising_edge(clk);
        wait for 40 ns;
        
        record_value <= '1'; --Record value 5
        wait for 9 ns;
        record_value <= '0';
        --Initial key input is zero and should be hot
        compare_bit("Testing Hot", true, '1', red_led); 
        compare_bit("Testing Cold", true, '0', blue_led);
        
        --11 is farther from 5 than 0 so output is cold
        wait for 15 ns;
        key_data <= 11;
        wait for 9 ns;
        compare_bit("Testing Hot", true, '0', red_led);
        compare_bit("Testing Cold", true, '1', blue_led);
        
        --1 is closer to 5 than 11 so output is hot
        wait for 7 ns;
        key_data <= 1;
        wait for 9 ns;
        compare_bit("Testing Hot", true, '1', red_led);
        compare_bit("Testing Cold", true, '0', blue_led);
        
        --14 is farther from 5 than 11 so the output is cold
        wait for 7 ns;
        key_data <= 14;
        wait for 9 ns;
        compare_bit("Testing Hot", true, '0', red_led);
        compare_bit("Testing Cold", true, '1', blue_led);
        
        --7 is closer to 5 than 14 so the output is hot
        wait for 7 ns;
        key_data <= 7;
        wait for 9 ns;
        compare_bit("Testing Hot", true, '1', red_led);
        compare_bit("Testing Cold", true, '0', blue_led);
        
        --5 is the correct number so the green should falsh
        --to see the flashing check waveform
        wait for 7 ns;
        key_data <= 5;
        wait for 55 ns;
        compare_bit("Testing Hot", true, '1', green_led);
        
        
        wait for 1 us;
        end_tests(0);

    end process;
end Behavioral;
