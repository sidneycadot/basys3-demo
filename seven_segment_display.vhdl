
library ieee;
use ieee.std_logic_1164.all;

entity seven_segment_display is
    port (
        CLK             : in std_logic;
        PORT_RESET      : in std_logic;
        --
        PORT_D3         : in std_logic_vector(3 downto 0);
        PORT_D2         : in std_logic_vector(3 downto 0);
        PORT_D1         : in std_logic_vector(3 downto 0);
        PORT_D0         : in std_logic_vector(3 downto 0);
        PORT_D3_EN      : in std_logic;
        PORT_D2_EN      : in std_logic;
        PORT_D1_EN      : in std_logic;
        PORT_D0_EN      : in std_logic;
        PORT_D3_LDOT    : in std_logic;
        PORT_D2_LDOT    : in std_logic;
        PORT_D1_LDOT    : in std_logic;
        PORT_D0_LDOT    : in std_logic;
        --
        PORT_SEG_C      : out std_logic_vector(7 downto 0);
        PORT_SEG_AN     : out std_logic_vector(3 downto 0)
    );
end entity seven_segment_display;


architecture arch of seven_segment_display is

type AnodeStatus is (Digit0, Digit1, Digit2, Digit3);

type CounterType is range 0 to 65535;

type StateType is record
        anode_status : AnodeStatus;
        counter      : CounterType;
        seg_an       : std_logic_vector(3 downto 0);
        seg_c        : std_logic_vector(7 downto 0);
    end record StateType;

constant reset_state : StateType := (
        anode_status => Digit0,
        counter      => 0,
        seg_an       => "1111",    -- all off
        seg_c        => "00000000" -- all off
    );

type CombinatorialSignals is record
        next_state : StateType;
    end record CombinatorialSignals;

function UpdateCombinatorialSignals(
            current_state : in StateType;
            RESET         : in std_logic;
            D3            : in std_logic_vector(3 downto 0);
            D2            : in std_logic_vector(3 downto 0);
            D1            : in std_logic_vector(3 downto 0);
            D0            : in std_logic_vector(3 downto 0);
            D3_EN         : in std_logic;
            D2_EN         : in std_logic;
            D1_EN         : in std_logic;
            D0_EN         : in std_logic;
            D3_LDOT       : in std_logic;
            D2_LDOT       : in std_logic;
            D1_LDOT       : in std_logic;
            D0_LDOT       : in std_logic
         ) return CombinatorialSignals is

function nibble_to_sseg(nibble : in std_logic_vector(3 downto 0); enable : in std_logic) return std_logic_vector is
begin

    if enable = '0' then
        return "0000000"; 
    end if;

    case nibble is
        when x"0"   => return "0111111"; 
        when x"1"   => return "0000110"; 
        when x"2"   => return "1011011"; 
        when x"3"   => return "1001111"; 
        when x"4"   => return "1100110"; 
        when x"5"   => return "1101101"; 
        when x"6"   => return "1111101"; 
        when x"7"   => return "0000111"; 
        when x"8"   => return "1111111"; 
        when x"9"   => return "1101111"; 
        when x"a"   => return "1110111"; 
        when x"b"   => return "1111100"; 
        when x"c"   => return "0111001"; 
        when x"d"   => return "1011110"; 
        when x"e"   => return "1111001"; 
        when x"f"   => return "1110001";
        when others => return "1000000";
    end case;

end function nibble_to_sseg;

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
            if combinatorial.next_state.anode_status /= AnodeStatus'high then
                combinatorial.next_state.anode_status := AnodeStatus'succ(combinatorial.next_state.anode_status);
            else
                combinatorial.next_state.anode_status := AnodeStatus'low;
            end if;
        end if;

        case combinatorial.next_state.anode_status is
            when Digit0 =>
                combinatorial.next_state.seg_an := not "0001";
                combinatorial.next_state.seg_c  := not (D0_LDOT & nibble_to_sseg(D0, D0_EN));
            when Digit1 =>
                combinatorial.next_state.seg_an := not "0010";
                combinatorial.next_state.seg_c  := not (D1_LDOT & nibble_to_sseg(D1, D1_EN));
            when Digit2 =>
                combinatorial.next_state.seg_an := not "0100";
                combinatorial.next_state.seg_c  := not (D2_LDOT & nibble_to_sseg(D2, D2_EN));
            when Digit3 =>
                combinatorial.next_state.seg_an := not "1000";
                combinatorial.next_state.seg_c  := not (D3_LDOT & nibble_to_sseg(D3, D3_EN));
        end case;

    end if;

    return combinatorial;

end function UpdateCombinatorialSignals;

signal combinatorial : CombinatorialSignals;
signal current_state : StateType := reset_state;

begin

    combinatorial <= UpdateCombinatorialSignals(
            current_state,
            PORT_RESET,
            PORT_D3,
            PORT_D2,
            PORT_D1,
            PORT_D0,
            PORT_D3_EN,
            PORT_D2_EN,
            PORT_D1_EN,
            PORT_D0_EN,
            PORT_D3_LDOT,
            PORT_D2_LDOT,
            PORT_D1_LDOT,
            PORT_D0_LDOT
        );

    current_state <= combinatorial.next_state when rising_edge(CLK);
    
    PORT_SEG_AN <= current_state.seg_an;
    PORT_SEG_C  <= current_state.seg_c;

end architecture arch;
