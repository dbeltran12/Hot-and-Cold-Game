-------------------------------------------------------------------------------
-- Title      : ECE 524L Lab 7
-- Project    : 
-------------------------------------------------------------------------------
-- File       : UART_echo.vhd
-- Author     : Daniel Beltran
-- Company    : CSUN
-- Created    : 2024-10-29
-- Last update: 2024-10-29
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_echo is
    Port ( 
        clk      : in std_logic;
        rx_data  : in std_logic_vector (7 downto 0);
        rx_done  : in std_logic;
        tx_start : out std_logic;
        tx_data  : out std_logic_vector (7 downto 0)
    );
end UART_echo;

architecture Behavioral of UART_ECHO is

begin
    uart_echo: process(clk)
    begin
        if rising_edge(clk) then
            if rx_done = '1' then
                tx_data <= rx_data;
                tx_start <= '1';
            else
                tx_start <= '0';
            end if;
        end if;
    end process;
end Behavioral;
