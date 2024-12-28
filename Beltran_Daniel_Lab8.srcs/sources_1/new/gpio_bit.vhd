-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 4
-- Project    : 
-------------------------------------------------------------------------------
-- File       : gpio_bit.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-9-27
-- Last update: 2024-9-29
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;


entity gpio_bit is
    Port(
        oe      : in std_logic;
        inp     : in std_logic;
        outp    : out std_logic;
        bidir   : inout std_logic
        );
end gpio_bit;

architecture Behavioral of gpio_bit is

begin
    --========================================================================
    --  FOLOWING CODE IS TAKEN FROM PROFESSOR TRACTON'S LECTURE SLIDES
    --========================================================================

    --when OE is asserted drive the bidir signal as an output with the bit 
    --supplied
    bidir <= inp when oe = '1' else 'Z';

    -- when OE is cleared pass the incoming signal into the rest of the system
    outp <= bidir when oe = '0' else 'Z';

end Behavioral;
