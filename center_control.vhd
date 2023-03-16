----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/03/07 21:54:22
-- Design Name: 
-- Module Name: center_control - Behavioral
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

library ieee;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;

entity center_control is
    port(   
            clk_cc:         in std_logic;	
            reset_cc:       in std_logic;
            switch_in_cc:   in std_logic_vector(3 downto 0);	-- use switch to control input key 
            unlock:         in std_logic;                       -- press to unlock the system
            confirm_1:      in std_logic;                       -- press to confirm the first input
            confirm_2:      in std_logic;                       -- press to confirm the second input
            require_random: out std_logic_vector(1 downto 0);   -- require random entity to generate data
            display0_out:   out std_logic_vector(15 downto 0);	--the number should apperence on segment0 transfer it to segment_handler		
            display1_out:   out std_logic_vector(15 downto 0);	--the number should apperence on segment1 transfer it to segment_handler
            
            key_wrong :     out std_logic;	-- input key is wrong		
            key_right_1 :     out std_logic; -- input key is right	
            key_right_2 :     out std_logic -- input key is right		
            );		
end center_control;

architecture archi_cc of center_control is

    -- function generate_random_number(x : integer) return std_logic_vector is -- function to generate random number and its corresponding right key
    --     variable result: std_logic_vector(7 downto 0);
    --     variable reminder: integer;
    --     variable right_number: integer;
    -- begin
    --     reminder := x mod 4;
    --     if (reminder=0) then
    --         right_number := 8;
    --     elsif (reminder=1) then
    --         right_number := 3;
    --     elsif (reminder=2) then
    --         right_number := 7;
    --     elsif (reminder=3) then
    --         right_number := 0;
    --     else
    --         null; 
    --     end if ;
    --     result := CONV_STD_LOGIC_VECTOR(reminder, 4) & CONV_STD_LOGIC_VECTOR(right_number, 4);
    --     return result;
    -- end generate_random_number;

    signal password_1:                  std_logic_vector(3 downto 0);
    signal password_2:                  std_logic_vector(3 downto 0);
    signal random_number:               std_logic_vector(3 downto 0);
    signal random_1:                    std_logic_vector(3 downto 0);
    signal random_2:                    std_logic_vector(3 downto 0);
    signal right_1:                     std_logic_vector(3 downto 0);
    signal right_2:                     std_logic_vector(3 downto 0);
    signal result_1:                    std_logic_vector(7 downto 0);
    signal result_2:                    std_logic_vector(7 downto 0);
    -- signal unlock_state:                std_logic_vector(1 downto 0); -- check for unlock button
    -- signal confirm_1_state:             std_logic_vector(1 downto 0); -- check for unlock button

    signal State_current:               std_logic_vector(2 downto 0); -- current system state
    signal State_next:                  std_logic_vector(2 downto 0); -- current system state

    signal confirm_count:               integer range 0 to 3 :=0;
    signal clk_count_password_flash:    integer range 0 to 50_000_000 :=0;
    signal clk_count:                   integer;                     -- count the number of clk rise
    signal wrong_count:                 integer;    -- current wrong password count
    signal waiting_time:                integer;    -- current seconds system needs to be waiting
    signal current_count_down:          integer;    -- current count down number
    signal dp1_0:                       integer;
    signal dp1_1:                       integer;

    signal password_flash_1:            boolean;
    signal password_flash_2:            boolean;
    signal key_wrong_flag:              boolean:=false;
    signal need_to_back_idel:           boolean:=false;

    constant State_IDLE:                std_logic_vector(2 downto 0) := "000";   -- system IDLE state	          
    constant State_reading_key_1:       std_logic_vector(2 downto 0) := "001";   -- system state waiting for first password
    constant State_reading_key_2:       std_logic_vector(2 downto 0) := "010";   -- system state waiting for second password
    constant State_judge_password:      std_logic_vector(2 downto 0) := "011";   -- system state judge password right or not
    constant State_waiting_next_try:    std_logic_vector(2 downto 0) := "100";
    constant State_delay:               std_logic_vector(2 downto 0) := "101";   -- system state when key entered wrong
    constant State_wrong:               std_logic_vector(2 downto 0) := "110";   -- system state where current password is wrong 
    constant State_right:               std_logic_vector(2 downto 0) := "111";   -- system state where current password is right 


    begin
       
    -- state output process    
    process (clk_cc,switch_in_cc,clk_count_password_flash,State_current,current_count_down)
    begin
        if (reset_cc='0') then
            display0_out <= x"0000"; 
            display1_out <= x"0000";
            key_right_1 <= '0';
            key_right_2 <= '0';
            key_wrong <= '0';
            key_wrong_flag <= false;
            wrong_count <= 0;
        elsif (clk_cc'event and clk_cc='1') then
            if (State_current=State_IDLE) then
                    display0_out <= x"0000"; 
                    display1_out <= x"0000";
                    key_right_1 <= '0';
                    key_right_2 <= '0';
                    key_wrong <= '0';
                    key_wrong_flag <= false;
                    need_to_back_idel <= false;
            elsif (State_current=State_reading_key_1) then -- system state waiting for first password
                key_right_1 <= '0';
                key_right_2 <= '0';
                key_wrong <= '0';
                if (password_flash_1 = true) then
                    display0_out <= x"b" & random_1(3 downto 0) & x"a" & switch_in_cc(3 downto 0);
                    display1_out <= x"d" & x"adc";
                else
                    display0_out <= x"b" & random_1(3 downto 0) & x"af";
                    display1_out <= x"d" & x"adc";
                end if;
            
            elsif (State_current=State_reading_key_2) then  -- system state waiting for second password
                key_right_1 <= '0';
                key_right_2 <= '0';
                key_wrong <= '0';
                if (password_flash_2 = true) then
                    display0_out <= x"b" & random_1(3 downto 0) & x"a" & password_1(3 downto 0);
                    display1_out <= random_2(3 downto 0) & x"a"  & switch_in_cc(3 downto 0) & x"c";
                else
                    display0_out <= x"b" & random_1(3 downto 0) & x"a" & password_1(3 downto 0);
                    display1_out <= random_2(3 downto 0) & x"afc";
                end if;

            elsif (State_current=State_judge_password) then  -- system state judge password is right or not         
                display0_out <= x"b" & random_1(3 downto 0) & x"a" & password_1(3 downto 0);
                display1_out <= random_2(3 downto 0) & x"a"  & password_2(3 downto 0) & x"c";
                if (password_1="1000" or password_1="0011" or password_1="0100" or password_1="0000" or password_2="1000" or password_2="0011" or password_2="0100" or password_2="0000") then
                    key_right_1 <= '1';
                    key_right_2 <= '1';
                    key_wrong_flag <= false;
                    wrong_count <= 0;
                elsif not (password_1="1000" or password_1="0011" or password_1="0100" or password_1="0000" or password_2="1000" or password_2="0011" or password_2="0100" or password_2="0000") then
                    wrong_count <= wrong_count + 1;
                    key_wrong <= '1'; 
                else
                    null; 
                end if ;

                if not (wrong_count=0) then
                    waiting_time <= wrong_count * 5;
                    current_count_down <= waiting_time;
                    key_wrong_flag <= true;
                elsif (wrong_count=0) then
                    waiting_time <=0;
                else 
                    null;
                end if ;
            elsif (State_current=State_waiting_next_try) then
                if (current_count_down/10=0) then
                    display0_out <= x"fff" & CONV_STD_LOGIC_VECTOR(wrong_count,4);
                    display1_out <= x"000" & CONV_STD_LOGIC_VECTOR(current_count_down,4);
                elsif not (current_count_down/10=0) then
                    dp1_1 <= current_count_down/10;
                    dp1_0 <= current_count_down mod 10;
                
                    display0_out <= x"fff" & CONV_STD_LOGIC_VECTOR(wrong_count,4);
                    display1_out <= x"00" & CONV_STD_LOGIC_VECTOR(dp1_1,4) & CONV_STD_LOGIC_VECTOR(dp1_0,4);
                end if ;

                if (clk_count mod 100000000 = 0) then
                    current_count_down <= current_count_down - 1;
                    if (current_count_down=0) then
                        key_wrong_flag <= false;
                        need_to_back_idel <= true;
                    end if ;
                else
                    null;
                end if ;
            else
                null;	
            end if;
        end if;
    end process;  

    -- state control process
    process (clk_cc,reset_cc,need_to_back_idel) 
    begin
        if (reset_cc='0') then  -- press reset button to make system back to very beginning and delete delay
            State_current <= State_IDLE; -- initial system state
            password_1 <= b"0000"; -- initial stored password
            password_2 <= b"0000";
            confirm_count <= 0;
            clk_count <= 0;
        elsif (clk_cc'event and clk_cc='1') then
            clk_count <= clk_count + 1; -- clk count continuously
            -- make current password place flash
            if clk_count_password_flash=49_999_999 then
                clk_count_password_flash <= 0;
                password_flash_1 <= false; -- make password entered dissapear
                password_flash_2 <= false;
            elsif clk_count_password_flash=24_999_999 then
                password_flash_1 <= true; -- make password entered shows
                password_flash_2 <= true;
                clk_count_password_flash <= clk_count_password_flash + 1;
            else
                clk_count_password_flash <= clk_count_password_flash + 1;
            end if;

            if (unlock='1' and confirm_1='0' and confirm_2='0') then
            -- if (unlock_state="11") then -- press unlock button to unlock system and generate random number
                confirm_count <= 0;
                random_1 <= b"00" & random_number(1 downto 0);
                if (random_1(1 downto 0) = b"00") then
                    right_1 <= b"1000"; 
                elsif (random_1(1 downto 0) = b"01") then
                    right_1 <= b"0011";
                elsif (random_1(1 downto 0) = b"10") then
                    right_1 <= b"0100";
                elsif (random_1(1 downto 0) = b"11") then
                    right_1 <= b"0000";
                else
                    null;
                end if;
                State_current <= State_reading_key_1;
            elsif (unlock='0' and confirm_1='1' and confirm_2='0' and confirm_count=0) then -- press confirm button to confirm first password
            -- if (confirm_1_state="11" and confirm_count=0) then -- press confirm button to confirm first password
                password_1 <= switch_in_cc(3 downto 0);
                random_2 <= b"00" & random_number(1 downto 0);
                if (random_2(1 downto 0) = b"00") then
                    right_2 <= b"1000"; 
                elsif (random_2(1 downto 0) = b"01") then
                    right_2 <= b"0011";
                elsif (random_2(1 downto 0) = b"10") then
                    right_2 <= b"0100";
                elsif (random_2(1 downto 0) = b"11") then
                    right_2 <= b"0000";
                else
                    null;
                end if;  
                State_current <= State_reading_key_2;
                confirm_count <= 1;
            elsif (unlock='0' and confirm_1='0' and confirm_2='1' and confirm_count=1) then -- press confirm button to confirm first password
                -- store second password 
                password_2 <= switch_in_cc(3 downto 0);    
                State_current <= State_judge_password;
                confirm_count <= 2; 
            elsif (key_wrong_flag) then
                State_current <= State_waiting_next_try;
            elsif (need_to_back_idel) then
                State_current <= State_IDLE;
            else
                null;  
            end if ;

        else
            null;    
        end if ;  
    end process;

    -- generate random number
    process (clk_cc,reset_cc)
    begin
        if (reset_cc='0') then
            random_number <= b"0000";
        elsif (clk_cc'event and clk_cc='1') then
            random_number <= CONV_STD_LOGIC_VECTOR(clk_count, 4);
        else
            null;
		end if;
	end process;

end archi_cc;
