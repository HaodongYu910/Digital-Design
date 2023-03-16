----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/03/07 17:48:29
-- Design Name: 
-- Module Name: top_module - Behavioral
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
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity top_module is
    port(   
        CLK100MHZ:  in std_logic;
        CPU_RESETN: in std_logic; 
        SWITCHES:   in std_logic_vector(3 downto 0);	 -- use switch to input key number		
        LEDS :      out std_logic_vector(15 downto 0);		-- use led to show which switch is on
        BTNU:       in std_logic;    -- button_u to unlock the system
        BTNL:       in std_logic;   -- button_l to confirm the first input
        BTNR:       in std_logic;   -- button_r to confirm the second input
        DIGITS:     out std_logic_vector(7 downto 0);	--??????
        SEGMENTS:   out std_logic_vector(7 downto 0) 
		);		
end top_module;

architecture digital_lock_archi of top_module is
    -- signal  unlock    : std_logic; -- receive from BTNU
    -- signal  confirm : std_logic; -- receive from BTNC

    signal  wrong_flag    : std_logic; -- display input key is wrong!
    signal  right_flag_1  : std_logic;  -- display input key all right
    signal  right_flag_2  : std_logic;  -- display input key all right

    signal  display0:       std_logic_vector(15 downto 0);  --first key
    signal  display1:       std_logic_vector(15 downto 0);  --second key
    signal  random_data:    std_logic_vector(3 downto 0);

    component center_control is
        port(   
            clk_cc:         in std_logic;	
            reset_cc:       in std_logic;
            switch_in_cc:   in std_logic_vector(3 downto 0);	-- use switch to control input key 
            unlock:         in std_logic; -- press to unlock the system
            confirm_1:      in std_logic; -- press to confirm the first input
            confirm_2:      in std_logic; -- press to confirm the second input
            require_random: out std_logic_vector(1 downto 0);   -- require random entity to generate data
            display0_out:   out std_logic_vector(15 downto 0);	--the number should apperence on segment0 transfer it to segment_handler		
            display1_out:   out std_logic_vector(15 downto 0);	--the number should apperence on segment1 transfer it to segment_handler	
            key_wrong :     out std_logic;	-- input key is wrong		
            key_right_1 :     out std_logic; -- input key is right
            key_right_2 :     out std_logic -- input key is right					
            );		
    end component;

    component segment_handler is
        port(   
            clk:            in std_logic;
            reset_sh:       in std_logic;
            display0_in:    in std_logic_vector(15 downto 0);--the number should apperence on segment0 receive from center_control
            display1_in:    in std_logic_vector(15 downto 0);--the number should apperence on segment1 receive from center_control		
            scan:           out std_logic_vector(7 downto 0);	-- choose which segment to be show, stores in binary code
            segs:           out std_logic_vector(7 downto 0)
            );		
    end component;


    begin
        center_control_map : center_control port map (
            clk_cc 	        =>      CLK100MHZ,		
            reset_cc        =>      CPU_RESETN,	
            switch_in_cc   	=>      SWITCHES, 
            unlock          =>      BTNU,
            confirm_1       =>      BTNL,
            confirm_2       =>      BTNR,  
            display0_out    =>      display0, 
            display1_out    =>      display1,  
            key_wrong       =>      wrong_flag , 
            key_right_1       =>      right_flag_1,
            key_right_2 => right_flag_2

	        );	
	
        LEDS(15)             <= wrong_flag;
        LEDS(14 downto 8 )   <= right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1;
        LEDS(7 downto 0) <= right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1 & right_flag_1;

        segment_handeler_map : segment_handler port map (
            clk 	        =>      CLK100MHZ,
            reset_sh   	    =>      CPU_RESETN,		
            display0_in     =>      display0, 
            display1_in     =>      display1,
            scan     	    =>      DIGITS,
            segs     	    =>      SEGMENTS    		
            );	
end digital_lock_archi;