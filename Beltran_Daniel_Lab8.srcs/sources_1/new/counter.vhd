-------------------------------------------------------------------------------
-- Title      : ECE 524L Homework 2
-- Project    : 
-------------------------------------------------------------------------------
-- File       : counter.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-9-13
-- Last update: 2024-9-13
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counter is
    generic(
        WIDTH: integer := 8;
        MAX_COUNT: integer := 255
        );
    Port (
        clk: in std_logic;
        reset: in std_logic;
        count: out std_logic_vector((WIDTH-1) downto 0)
        );
end counter;

architecture Behavioral of counter is
    signal temp: unsigned((WIDTH-1) downto 0);
begin
    process(clk)
    begin
        if (reset = '1') then
            temp <= (others => '0');
        elsif (rising_edge(clk)) then
            if (temp = MAX_COUNT) then
                temp <= (others => '0');
            else 
                temp <= temp + 1;
            end if;
        end if;
    end process;
    count <= std_logic_vector(temp);
end Behavioral;
