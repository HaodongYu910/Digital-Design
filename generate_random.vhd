----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/03/11 21:37:57
-- Design Name: 
-- Module Name: generate_random - archi_gr
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
use ieee.std_logic_arith.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity generate_random is
    Port (
        clk:            in std_logic;    
        reset_gr:       in std_logic;
        require_random: in std_logic_vector(1 downto 0);   -- require random entity to generate data
        random_data:    out std_logic_vector(3 downto 0);    -- the random order number 1 of which password should be enter
        right_key:      out std_logic_vector(3 downto 0)    -- correct password coresponding to random_1
 );
end generate_random;

architecture archi_gr of generate_random is
    signal clk_count:           integer;
    signal random_data_out:     std_logic_vector(3 downto 0);
begin

    process
    begin
        if (reset_gr='0') then
            null;
        elsif (clk'event and clk='1') then
            if require_random=b"11" then
                random_data_out <= CONV_STD_LOGIC_VECTOR (clk_count, 4); -- use clk number mod 4 to generate a number
                random_data <= random_data_out;
                case random_data_out is
                    when "0000" =>
                        right_key <= "1000";
                    when "0001" =>
                        right_key <= "0011";
                    when "0010" =>
                        right_key <= "0111";
                    when "0011" =>
                        right_key <= "0000";
                    when others =>
                        null;
                end case;
            else
                null;     
            end if ;       
        else
            null;
            
        end if ;
    end process;

    process (clk,reset_gr) -- store current number of clk rise as 1
    begin
        if (reset_gr='0') then
            clk_count <= 0;     
        elsif (clk'event and clk='1') then
            clk_count <= clk_count + 1; 
        end if;
    end process;


end archi_gr;



