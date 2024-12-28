-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 4
-- Project    : 
-------------------------------------------------------------------------------
-- File       : gpio.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-9-27
-- Last update: 2024-9-29
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gpio is
    Port (
        oe      : in std_logic_vector(3 downto 0);
        inp     : in std_logic_vector(3 downto 0);
        outp    : out std_logic_vector(3 downto 0);
        bidir   : inout std_logic_vector(3 downto 0)
    );
end gpio;

architecture Behavioral of gpio is

component gpio_bit is
        Port(
            oe      : in std_logic;
            inp     : in std_logic;
            outp    : out std_logic;
            bidir   : inout std_logic);
end component;
    signal oe_temp     :std_logic;
    signal inp_temp     :std_logic;
    signal outp_temp    :std_logic;
    signal bidir_temp   :std_logic;
begin
    --instantiaing 4 gpio_bits, one for each switch and LED
    gpio_0: gpio_bit
        port map(
            oe => oe(0),
            inp => inp(0),
            outp => outp(0),
            bidir => bidir(0)
        );
    gpio_1: gpio_bit
        port map(
            oe => oe(1),
            inp => inp(1),
            outp => outp(1),
            bidir => bidir(1)
        );
    gpio_2: gpio_bit
        port map(
            oe => oe(2),
            inp => inp(2),
            outp => outp(2),
            bidir => bidir(2)
        );
    gpio_3: gpio_bit
        port map(
            oe => oe(3),
            inp => inp(3),
            outp => outp(3),
            bidir => bidir(3)
        );

end Behavioral;
