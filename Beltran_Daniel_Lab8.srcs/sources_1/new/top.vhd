-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 7
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-9-27
-- Last update: 2024-11-3
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity top is
    Port (
        XCLK            : in std_logic;
        XLOCKED         : out std_logic;
        XSWITCHES       : inout std_logic_vector(3 downto 0);
        XLEDS           : inout std_logic_vector(3 downto 0);
        XSEVEN_SEGMENT  : out std_logic_vector(7 downto 0);
        XTESTBUS        : out std_logic_vector(3 downto 0);

        --UART CONTROL
        XRX             : in std_logic;
        XTX             : out std_logic;

        --KEYPAD CONTROL
        XROWS           : in std_logic_vector(1 to 4);
        XCOLUMNS        : buffer std_logic_vector(1 to 4);

        --GAME CONTROLS
        XRESET          : in std_logic;
        XRECORD_VALUE   : in std_logic;
        XBLUE_LED       : out std_logic;
        XRED_LED        : out std_logic;
        XGREEN_LED      : out std_logic
    );
end top;

architecture Behavioral of top is

component gpio is
    Port(
        oe      : in std_logic_vector(3 downto 0);
        inp     : in std_logic_vector(3 downto 0);
        outp    : out std_logic_vector(3 downto 0);
        bidir   : inout std_logic_vector(3 downto 0));
end component;

component system_controller is
    generic (RESET_COUNT : integer := 32
    );
    port(
        clk_in    : in  std_logic;
        reset_in  : in  std_logic;
        clk_out   : out std_logic;
        locked    : out std_logic;
        reset_out : out std_logic
    );
end component;

component seven_segment is
    Port (
        clk             : in std_logic;
        reset           : in std_logic;
        key_data        : in integer range 0 to 15;
        seven_segments  : out std_logic_vector(7 downto 0);
        timer_expired   : out std_logic
    );
end component;

component UART is
    port(
        clk      : in std_logic;
        reset    : in std_logic;
        tx_start : in std_logic;

        data_in       : in  std_logic_vector (7 downto 0);
        data_out      : out std_logic_vector (7 downto 0);
        rx_data_ready : out std_logic;

        rx : in  std_logic;
        tx : out std_logic
    );
end component;


component pmod_keypad is
  generic(
    clk_freq    : integer := 50_000_000;  --system clock frequency in hz
    stable_time : integer := 10);         --time pressed key must remain stable in ms
  port(
    clk     :  in     std_logic;                           --system clock
    reset_n :  in     std_logic;                           --asynchornous active-low reset
    rows    :  in     std_logic_vector(1 to 4);            --row connections to keypad
    columns :  buffer std_logic_vector(1 to 4) := "1111";  --column connections to keypad
    keys    :  out    std_logic_vector(0 to 15));          --resultant key presses
end component;

component keypad_to_UART is
    Port ( 
        clk         : in std_logic;
        reset       : in std_logic;
        key_data    : in integer range 0 to 15;
        tx_start    : out std_logic;
        tx_data     : out std_logic_vector(7 downto 0)
    );
end component;

component decode_keys is
    Port (
        clk         : in std_logic;
        reset       : in std_logic;
        keys        : in std_logic_vector(0 to 15);
        key_data    : out integer range 0 to 15
    );
end component;

component game_controller is
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

    --SIGNALS FOR GPIO
    signal temp     : std_logic_vector(3 downto 0);
    signal oe_drive : std_logic_vector(3 downto 0) := b"1111";
    signal oe_read  : std_logic_vector(3 downto 0) := b"0000";
    signal inp_read : std_logic_vector(3 downto 0) := b"0000";

    --SIGNALS FOR SYSTEM_CONTROLLER
    signal clk      : std_logic;
    signal reset    : std_logic;
    signal tx_start : std_logic;
    signal rx_ready : std_logic;

    --SIGNALS FOR UART
    signal data_in  : std_logic_vector (7 downto 0);
    signal data_out : std_logic_vector (7 downto 0);

    --SIGNALS FOR KEYPAD
    signal keys     : std_logic_vector(0 to 15);
    signal key_data : integer range 0 to 15;
begin
    --READ FROM SWITCHES
    read_switches: gpio
        port map(
            oe => oe_read,
            inp => inp_read,
            outp => temp,
            bidir => XSWITCHES
        );
    --OUTPUT THE VALUE FROM THE SWITCH TO THE LEDS
    drive_leds: gpio
        port map(
            oe => oe_drive,
            inp => temp,
            bidir => XLEDS
        );

    --INSANTIATE SYSTEM_CONTROLLER TO DEAL WITH THE CLOCK AND RESET
    syscon : system_controller
        generic map(
          RESET_COUNT => 32
        )
        port map (
          clk_in    => XCLK,
          reset_in  => XRESET,
          clk_out   => clk,
          locked    => XLOCKED,
          reset_out => reset
        );    
    -- INSTANTIATE SEVEN SEGMENT DISPLAY OUTPUT CONTROLLER
    sev_seg : seven_segment
        port map (
            clk => clk,   
            reset => reset,
            key_data => key_data,
            seven_segments => XSEVEN_SEGMENT,
            timer_expired => XTESTBUS(0)
        );
    -- INSTANTIATE UART INTEFACE CONTROLLER
    uart_interface: UART
        port map(
            clk => clk,
            reset => reset,
            tx_start => tx_start,
            data_in => data_in,
            data_out => data_out,
            rx_data_ready => rx_ready,
            rx => XRX,
            tx => XTX
        );
    --KEYPAD PMOD CONTROLLER
    keypad : pmod_keypad 
        generic map(
          clk_freq    => 125_000_000,
          stable_time => 10
        )
        port map(
          clk       => clk,
          reset_n   => reset,
          rows      => XROWS,
          columns   => XCOLUMNS,
          keys      => keys 
        );
    -- KEYPAD INPUTS TO UART
    kypd_uart: keypad_to_UART
        port map( 
            clk      => clk,
            reset    => reset,
            key_data => key_data,
            tx_start => tx_start,
            tx_data  => data_in
        );
    --DECODES KEYPAD PRESSES
    decode: decode_keys
        port map(
            clk      => clk,
            reset    => reset,
            keys     => keys,
            key_data => key_data
        );
    --CONTROLS HOT AND COLD GAME
    game_con: game_controller
        port map(
            clk           => clk,
            reset         => reset,
            record_value  => XRECORD_VALUE,
            key_data      => key_data,
            hot_guess     => XRED_LED,
            cold_guess    => XBLUE_LED,
            correct_guess => XGREEN_LED
         );
end Behavioral;
