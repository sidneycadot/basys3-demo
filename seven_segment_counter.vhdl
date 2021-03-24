
library ieee;
use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

entity seven_segment_counter is
    port (
        CLK             : in std_logic;
        PORT_RESET      : in std_logic;
        --
        PORT_D3         : out std_logic_vector(3 downto 0);
        PORT_D2         : out std_logic_vector(3 downto 0);
        PORT_D1         : out std_logic_vector(3 downto 0);
        PORT_D0         : out std_logic_vector(3 downto 0);
        PORT_D3_EN      : out std_logic;
        PORT_D2_EN      : out std_logic;
        PORT_D1_EN      : out std_logic;
        PORT_D0_EN      : out std_logic;
        PORT_D3_LDOT    : out std_logic;
        PORT_D2_LDOT    : out std_logic;
        PORT_D1_LDOT    : out std_logic;
        PORT_D0_LDOT    : out std_logic
    );
end entity seven_segment_counter;


architecture arch of seven_segment_counter is

type CounterType is range 0 to 14849999;

type StateType is record
        counter : CounterType;
        d3      : std_logic_vector(3 downto 0);
        d2      : std_logic_vector(3 downto 0);
        d1      : std_logic_vector(3 downto 0);
        d0      : std_logic_vector(3 downto 0);
        d3_en   : std_logic;
        d2_en   : std_logic;
        d1_en   : std_logic;
        d0_en   : std_logic;
        d3_ldot : std_logic;
        d2_ldot : std_logic;
        d1_ldot : std_logic;
        d0_ldot : std_logic;
    end record StateType;

constant reset_state : StateType := (
        counter => 0,
        d3      => "0000",
        d2      => "0000",
        d1      => "0000",
        d0      => "0000",
        d3_en   => '0',
        d2_en   => '0',
        d1_en   => '0',
        d0_en   => '0',
        d3_ldot => '0',
        d2_ldot => '0',
        d1_ldot => '1',
        d0_ldot => '0'
    );

type CombinatorialSignals is
    record
        next_state : StateType;
    end record CombinatorialSignals;

function UpdateCombinatorialSignals(
            current_state : in StateType;
            RESET         : in std_logic
         ) return CombinatorialSignals is

variable combinatorial : CombinatorialSignals;

begin


    if RESET = '1' then
        combinatorial.next_state := reset_state;
    else
        combinatorial.next_state := current_state;

        if combinatorial.next_state.counter /= CounterType'high then
            combinatorial.next_state.counter := combinatorial.next_state.counter + 1;        
        else
            combinatorial.next_state.counter := 0;

            if combinatorial.next_state.d0 /= x"9" then
                combinatorial.next_state.d0 := std_logic_vector(unsigned(combinatorial.next_state.d0) + 1);
            else
                combinatorial.next_state.d0 := x"0";                
                if combinatorial.next_state.d1 /= x"9" then
                    combinatorial.next_state.d1 := std_logic_vector(unsigned(combinatorial.next_state.d1) + 1);
                else
                    combinatorial.next_state.d1 := x"0";
                    if combinatorial.next_state.d2 /= x"9" then
                        combinatorial.next_state.d2 := std_logic_vector(unsigned(combinatorial.next_state.d2) + 1);
                    else
                        combinatorial.next_state.d2 := x"0";
                        if combinatorial.next_state.d3 /= x"9" then
                            combinatorial.next_state.d3 := std_logic_vector(unsigned(combinatorial.next_state.d2) + 1);
                        else
                            combinatorial.next_state.d3 := x"0";
                        end if;
                    end if;
                end if;
            end if;
        end if;

        combinatorial.next_state.d0_en := '1';
        combinatorial.next_state.d1_en := '1';
        --if combinatorial.next_state.d3 /= "0000" or combinatorial.next_state.d2 /= "0000" or combinatorial.next_state.d1 /= "0000" then combinatorial.next_state.d1_en := '1'; else combinatorial.next_state.d1_en := '0'; end if;
        if combinatorial.next_state.d3 /= "0000" or combinatorial.next_state.d2 /= "0000"                                          then combinatorial.next_state.d2_en := '1'; else combinatorial.next_state.d2_en := '0'; end if;
        if combinatorial.next_state.d3 /= "0000"                                                                                   then combinatorial.next_state.d3_en := '1'; else combinatorial.next_state.d3_en := '0'; end if;

    end if;

    return combinatorial;

end function UpdateCombinatorialSignals;

signal combinatorial : CombinatorialSignals;
signal current_state : StateType := reset_state;
signal next_state : StateType;

begin

    combinatorial <= UpdateCombinatorialSignals(
            current_state,
            PORT_RESET
        );

    current_state <= combinatorial.next_state when rising_edge(CLK);
    
    PORT_D3      <= current_state.d3;
    PORT_D2      <= current_state.d2;
    PORT_D1      <= current_state.d1;
    PORT_D0      <= current_state.d0;
    PORT_D3_EN   <= current_state.d3_en;
    PORT_D2_EN   <= current_state.d2_en;
    PORT_D1_EN   <= current_state.d1_en;
    PORT_D0_EN   <= current_state.d0_en;
    PORT_D3_LDOT <= current_state.d3_ldot;
    PORT_D2_LDOT <= current_state.d2_ldot;
    PORT_D1_LDOT <= current_state.d1_ldot;
    PORT_D0_LDOT <= current_state.d0_ldot;

end architecture arch;
