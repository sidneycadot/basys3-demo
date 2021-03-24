
library ieee;

use ieee.std_logic_1164.all, ieee.numeric_std.all, ieee.math_real.all;

entity rot13 is
    port (
        CLK                 : in  std_logic;
        PORT_RESET          : in  std_logic;
        --
        PORT_BYTE_IN        : in std_logic_vector(7 downto 0);
        PORT_BYTE_IN_VALID  : in std_logic;
        PORT_BYTE_IN_READY  : out std_logic;
        --
        PORT_BYTE_OUT       : out std_logic_vector(7 downto 0);
        PORT_BYTE_OUT_VALID : out std_logic;
        PORT_BYTE_OUT_READY : in  std_logic
    );
end entity rot13;

architecture arch of rot13 is

type StateType is record
        byte_in_ready  : std_logic;
        byte_out       : std_logic_vector(7 downto 0);
        byte_out_valid : std_logic; 
    end record StateType;

constant reset_state : StateType := (
        byte_in_ready  => '1',
        byte_out       => (others => '-'),
        byte_out_valid => '0' 
    );

type CombinatorialSignals is record
        next_state : StateType;
     end record CombinatorialSignals;
 
function UpdateCombinatorialSignals(current_state: in StateType; RESET: in std_logic; BYTE_IN_VALID : in std_logic; BYTE_IN : in std_logic_vector(7 downto 0); BYTE_OUT_READY : in std_logic) return CombinatorialSignals is

variable combinatorial : CombinatorialSignals;

begin

    if RESET = '1' then

        combinatorial.next_state := reset_state;

    else

        combinatorial.next_state := current_state;

        if current_state.byte_out_valid = '1' and BYTE_OUT_READY = '1' then
            combinatorial.next_state.byte_out_valid := '0';
            combinatorial.next_state.byte_out       := (others => '-');
            combinatorial.next_state.byte_in_ready  := '1';
        end if;

        if BYTE_IN_VALID = '1' and current_state.byte_in_ready = '1' then
            if ((x"41" <= BYTE_IN) and (BYTE_IN <= x"5a")) or ((x"61" <= BYTE_IN) and (BYTE_IN <= x"7a")) then
                -- The incoming byte is an upper-case or lower-case letter; perform the ROT13!
                combinatorial.next_state.byte_out := BYTE_IN(7 downto 5) & std_logic_vector(to_unsigned((to_integer(unsigned(BYTE_IN(4 downto 0))) - 1 + 13) rem 26 + 1, 5));
            else
                combinatorial.next_state.byte_out := BYTE_IN;
            end if;
            combinatorial.next_state.byte_out_valid := '1';
            combinatorial.next_state.byte_in_ready  := '0';
        end if;

    end if;

    return combinatorial;

end function UpdateCombinatorialSignals;

signal current_state : StateType := reset_state;
signal combinatorial : CombinatorialSignals;

begin -- of architecture body.

    -- Update combinatorial signals continuously.
    combinatorial <= UpdateCombinatorialSignals(current_state, PORT_RESET, PORT_BYTE_IN_VALID, PORT_BYTE_IN, PORT_BYTE_OUT_READY);

    -- Perform the state update at each clock cycle.
    current_state <= combinatorial.next_state when rising_edge(CLK);

    -- Replicate outputs from state register holding the current state.
    PORT_BYTE_IN_READY  <= current_state.byte_in_ready;
    PORT_BYTE_OUT       <= current_state.byte_out;
    PORT_BYTE_OUT_VALID <= current_state.byte_out_valid;

end architecture arch;
