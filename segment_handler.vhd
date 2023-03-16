----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/03/08 15:06:48
-- Design Name: 
-- Module Name: segment_handler - archi_sh
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity segment_handler is
    port(   
        clk:            in std_logic;
        reset_sh:       in std_logic;
        display0_in:    in std_logic_vector(15 downto 0);--the number should apperence on segment0 receive from center_control
        display1_in:    in std_logic_vector(15 downto 0);--the number should apperence on segment1 receive from center_control		
        scan:           out std_logic_vector(7 downto 0);	-- choose which segment to be show, stores in binary code
        segs:           out std_logic_vector(7 downto 0)	
        );	
end segment_handler;

architecture archi_sh of segment_handler is
    signal segment_number:      integer range 0 to 7:=0; -- choose which segment to be show
    signal temp_store:          std_logic_vector(3 downto 0); -- the number of current segment should be show

    signal clk_sh:              std_logic;
    signal clk_sh_count:        integer   range 0 to 25_000;
    begin

    process (clk,reset_sh)
    begin
        if (reset_sh='0') then
            clk_sh_count <= 0;	
            clk_sh <= '0';
        elsif (clk'event and clk='1') then
            if( clk_sh_count = 24_999   ) then
                clk_sh_count <= 0;	
                clk_sh <= not clk_sh;
            else
                clk_sh_count <= clk_sh_count + 1;
            end if;
        end if;
    end process;

    process (clk_sh,reset_sh)
    begin
        if (reset_sh='0') then
            segment_number<=0;	
        elsif (clk_sh'event and clk_sh='1') then
            if (segment_number=7) then 
                segment_number<=0;
            else
                segment_number<=segment_number+1;
            end if;
        end if;
    end process;


    process(segment_number,display0_in,display1_in)
    begin
        case segment_number is
            when 0 => temp_store <=display0_in(15 downto 12) ;scan<="01111111";
            when 1 => temp_store <=display0_in(11 downto 8)  ;scan<="10111111";
            when 2 => temp_store <=display0_in(7  downto 4)  ;scan<="11011111";
            when 3 => temp_store <=display0_in(3  downto 0)  ;scan<="11101111";	
            when 4 => temp_store <=display1_in(15 downto 12) ;scan<="11110111";
            when 5 => temp_store <=display1_in(11 downto 8)  ;scan<="11111011";
            when 6 => temp_store <=display1_in(7  downto 4)  ;scan<="11111101";
            when 7 => temp_store <=display1_in(3  downto 0)  ;scan<="11111110";
            when others=>null;
        end case;
    end process;

    process(temp_store)
    begin
        case temp_store is
            WHEN"0000" => segs <="11000000"; --display 0
            WHEN"0001" => segs <="11111001"; --display 1
            WHEN"0010" => segs <="10100100"; --display 2
            WHEN"0011" => segs <="10110000"; --display 3
            WHEN"0100" => segs <="10011001"; --display 4
            WHEN"0101" => segs <="10010010"; --display 5
            WHEN"0110" => segs <="10000010"; --display 6
            WHEN"0111" => segs <="11111000"; --display 7
            WHEN"1000" => segs <="10000000"; --display 8
            WHEN"1001" => segs <="10010000"; --display 9
            WHEN"1010" => segs <="10111111"; --when a --> display "-"
            WHEN"1011" => segs <="11001110"; --when b --> display "["
            WHEN"1100" => segs <="11110001"; --when c --> display "]"
            WHEN"1101" => segs <="11110111"; --when d --> display "_"	  
            WHEN"1111" => segs <="11111111"; --when f --> display nothing
            
            WHEN others=> segs <="11111111";
        end case;                     
    end process;
end archi_sh;
