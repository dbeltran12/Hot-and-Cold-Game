-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 8
-- Project    : 
-------------------------------------------------------------------------------
-- File       : game_controller.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-11-13
-- Last update: 2024-11-16
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity game_controller is
    generic (
        clk_freq        : integer := 125_000_000 --USED FOR LED FLASH
    );
    Port (
        clk             : in std_logic;     
        reset           : in std_logic;     
        record_value    : in std_logic; --Determines value recorded
        key_data        : in integer range 0 to 15; --Value from Keypad
        hot_guess       : out std_logic; --Hot LED output indicator
        cold_guess      : out std_logic; --Cold LED output indicator
        correct_guess   : out std_logic  --Correct LED output indicator
    );
end game_controller;

architecture Behavioral of game_controller is
    component counter is
        generic(
            WIDTH: integer := 8;
            MAX_COUNT: integer := 255
        );
        Port (
            clk: in std_logic;
            reset: in std_logic;
            count: out std_logic_vector((WIDTH-1) downto 0)
        );
    end component;
    type state_type is (IDLE_STATE, HOT_STATE, COLD_STATE, CORRECT_STATE);
    signal state            : state_type;
    signal target_count     : std_logic_vector(3 downto 0);
    signal target_number    : integer range 0 to 15;

begin
    --target_counter determins the random target number from range 0x0 to 0xF
    --when record_value(button) is high the count is set as the target number
    target_counter:counter
        generic map(
            WIDTH     => 4,
            MAX_COUNT => 15
            )
        port map(
            clk     => clk,
            reset   => reset,
            count   => target_count
            );
    state_machine: process(clk) is
        variable current_diff   : integer range 0 to 15;
        variable previous_diff  : integer range 0 to 15;
        variable timing_count   : integer;
        variable blink_count    : integer;
    begin
        if(rising_edge(clk)) then
            if(reset = '1') then
                state <= IDLE_STATE;
                target_number <= 0;
                hot_guess <= '0';
                cold_guess <= '0';
                correct_guess <= '0';
                timing_count := 0;
                blink_count := 0;
                previous_diff := 15; --Initially the highest value to ensure the first guess is always hot
                current_diff := 0;
            else
                case(state) is
                    when IDLE_STATE =>
                        --Leaves IDLE_STATE when recorded_value(button) is high
                        if(record_value = '1') then
                            state <= HOT_STATE; --Always begin in HOT_STATE
                            target_number <= to_integer(unsigned(target_count)); --target number is set based on the counter
                        else
                            state <= IDLE_STATE;
                            target_number <= 0;
                            hot_guess <= '0';
                            cold_guess <= '0';
                            correct_guess <= '0';
                            timing_count := 0;
                            blink_count := 0;
                            previous_diff := 15; --Initially the highest value to ensure the first guess is always hot
                            current_diff := 0;
                        end if;
                    --In the HOT_STATE hot_guess LED is on and cold_guess LED is off.
                    --If the key data is the same as the target number than the guess is correct.
                    --Determine the differnce between the key data and the target number.
                    --if the current difference is less than the previous difference than the guess is hot if not the guess was cold.
                    when HOT_STATE =>
                        hot_guess <= '1';
                        cold_guess <= '0';
                        if(target_number = key_data) then
                            state <= CORRECT_STATE;
                        else
                            current_diff := abs(key_data - target_number);
                            if(current_diff <= previous_diff) then
                                state <= HOT_STATE;
                            else
                                state <= COLD_STATE;
                            end if;
                        end if;
                        previous_diff := current_diff;
                    --In the COLD_STATE hot_guess LED is off and cold_guess LED is on.
                    --If the key data is the same as the target number than the guess is correct.
                    --Determine the differnce between the key data and the target number.
                    --if the current difference is less than the previous difference than the guess is hot if not the guess was cold.
                    when COLD_STATE =>
                        hot_guess <= '0';
                        cold_guess <= '1';
                        if(target_number = key_data) then
                            state <= CORRECT_STATE;
                        else
                            current_diff := abs(key_data - target_number);
                            if(current_diff < previous_diff) then
                                state <= HOT_STATE;
                            else
                                state <= COLD_STATE;
                            end if;
                        end if;
                        previous_diff := current_diff;
                    --In the CORRECT_STATE both the hot and cold LEDs are off and the correct guess LED blinks 10 times
                    when CORRECT_STATE =>
                        hot_guess <= '0';
                        cold_guess <= '0';
                        --Switches on and off 20 times
                        if(blink_count < 20) then 
                            timing_count := timing_count + 1;
                            if(timing_count = clk_freq/2) then --Blinks once per second
                                timing_count := 0;
                                blink_count := blink_count + 1;
                                correct_guess <= not correct_guess;                                
                            end if;
                        else
                            state <= IDLE_STATE;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;