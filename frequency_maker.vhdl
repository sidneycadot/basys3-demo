
library ieee;

use ieee.std_logic_1164.all, ieee.numeric_std.all, ieee.math_real.all;

entity frequency_maker is
    generic (
        num_counter_bits : in positive;
        clk_frequency    : in real;
        target_frequency : in real;
        duty_cycle       : in real  -- unit: percent (0 .. 100)
    );
    port (
        CLK         : in  std_logic;
        PORT_RESET  : in  std_logic; -- Synchronous reset request, synchronous to CLK.
        PORT_OUTPUT : out std_logic  -- Registered output, synchronous to CLK.
    );
end entity frequency_maker;


architecture arch of frequency_maker is

subtype UnsignedCounterType is unsigned(num_counter_bits - 1 downto 0);

function real_to_unsigned(x: in real) return UnsignedCounterType is
-- This function rounds a real number to the nearest integer, then converts it into an UnsignedCounterType.
-- We use this instead of something like to_unsigned(natural(round(x)), num_counter_bits) because the range of a real number exceeds the range of a natural.
-- NOTE: in Vivado 2020, the assert statements are not triggered even if the assertion condition is false.
variable xi, xi_lsb: real;
variable result: UnsignedCounterType;
begin
    assert (x >= 0.0) report "real value must be nonnegative" severity failure;
    -- Start by rounding to the nearest integer value.
    xi := round(x);
    for i in result'reverse_range loop
         xi_lsb := xi mod 2.0;
         result(i) := '1' when xi_lsb /= 0.0 else '0';
         xi := 0.5 * (xi - xi_lsb);
    end loop;
    assert (xi = 0.0) report "real value cannot be represented (out of range)" severity failure;
    return result;
end function real_to_unsigned;

type StateType is record
        counter : UnsignedCounterType;
        output  : std_logic;
    end record StateType;

constant reset_state : StateType := (
        counter => to_unsigned(0, num_counter_bits),
        output  => '0'
    );

type CombinatorialSignals is record
        next_state : StateType;
     end record CombinatorialSignals;
 
function UpdateCombinatorialSignals(current_state: in StateType; RESET: in std_logic) return CombinatorialSignals is

constant delta               : UnsignedCounterType := real_to_unsigned(2.0 ** num_counter_bits * target_frequency / clk_frequency);
constant duty_cycle_boundary : UnsignedCounterType := real_to_unsigned(2.0 ** num_counter_bits * duty_cycle / 100.0);

variable combinatorial : CombinatorialSignals;

begin

    if RESET = '1' then

        combinatorial.next_state := reset_state;

    else
    
        combinatorial.next_state := current_state;

        -- Handle regular state update.
        combinatorial.next_state.counter := combinatorial.next_state.counter + delta;

        -- Set output register in accordance with main state.
        combinatorial.next_state.output := '1' when (combinatorial.next_state.counter < duty_cycle_boundary) else '0';

    end if;

    return combinatorial;

end function UpdateCombinatorialSignals;

signal current_state : StateType := reset_state;
signal combinatorial : CombinatorialSignals;

begin -- of architecture body.

    -- Update combinatorial signals continuously.
    combinatorial <= UpdateCombinatorialSignals(current_state, PORT_RESET);

    -- Perform the state update at each clock cycle.
    current_state <= combinatorial.next_state when rising_edge(CLK);

    -- Replicate outputs from state register holding the current state.
    PORT_OUTPUT <= current_state.output;

end architecture arch;
