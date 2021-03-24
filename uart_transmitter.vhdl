library ieee;

use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

entity uart_transmitter is
    port (
        PORT_CLK        : in  std_logic;
        PORT_RESET      : in  std_logic;
        --
        PORT_DIVIDER    : in  std_logic_vector(31 downto 0);
        --
        PORT_DATA       : in  std_logic_vector(7 downto 0);
        PORT_DATA_VALID : in  std_logic;
        PORT_DATA_READY : out std_logic;
        --
        PORT_UART_TX    : out std_logic
    );
end entity uart_transmitter;

architecture arch of uart_transmitter is

type FsmState is (STARTBIT, B0, B1, B2, B3, B4, B5, B6, B7, STOPBIT);

type StateType is record
        st         : FsmState;
        counter    : unsigned(31 downto 0);
        data       : std_logic_vector(7 downto 0);
        data_ready : std_logic;
        uart_tx    : std_logic;
    end record StateType;

constant reset_state: StateType := (
        st         => STOPBIT,
        counter    => to_unsigned(0, 32),
        data       => "--------",
        data_ready => '1',
        uart_tx    => '1'
    );

type CombinatorialSignals is record
        next_state : StateType;
    end record CombinatorialSignals;

function UpdateCombinatorialSignals(current_state : in StateType; RESET : in std_logic; DATA_VALID : in std_logic; DATA : in std_logic_vector(7 downto 0); DIVIDER : in std_logic_vector(31 downto 0)) return CombinatorialSignals is

constant period_minus_one : unsigned(31 downto 0) := to_unsigned(to_integer(unsigned(PORT_DIVIDER)) - 1, 32);

variable combinatorial : CombinatorialSignals;

begin

    if RESET = '1' then
        combinatorial.next_state := reset_state;
    else

        combinatorial.next_state := current_state;

        if (combinatorial.next_state.data_ready and DATA_VALID) = '1' then
            combinatorial.next_state.data       := DATA;
            combinatorial.next_state.data_ready := '0';
        end if;

        if combinatorial.next_state.counter = 0 then
            case combinatorial.next_state.st is
                when STARTBIT => combinatorial.next_state.st := B0     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(0);
                when B0       => combinatorial.next_state.st := B1     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(1);
                when B1       => combinatorial.next_state.st := B2     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(2);
                when B2       => combinatorial.next_state.st := B3     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(3);
                when B3       => combinatorial.next_state.st := B4     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(4);
                when B4       => combinatorial.next_state.st := B5     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(5);
                when B5       => combinatorial.next_state.st := B6     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(6);
                when B6       => combinatorial.next_state.st := B7     ; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := combinatorial.next_state.data(7);
                                                                    combinatorial.next_state.data := "--------"; combinatorial.next_state.data_ready := '1'; -- signal our willingness to accept new data.
                when B7       => combinatorial.next_state.st := STOPBIT; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := '1';
                when STOPBIT  => if combinatorial.next_state.data_ready = '0' then
                                     combinatorial.next_state.st := STARTBIT; combinatorial.next_state.counter := period_minus_one; combinatorial.next_state.uart_tx := '0';
                                 end if;
            end case;
        else
            combinatorial.next_state.counter := combinatorial.next_state.counter - 1;
        end if;

    end if;

    return combinatorial;

end function UpdateCombinatorialSignals;

signal current_state : StateType := reset_state;
signal combinatorial : CombinatorialSignals;

begin

    combinatorial <= UpdateCombinatorialSignals(current_state, PORT_RESET, PORT_DATA_VALID, PORT_DATA, PORT_DIVIDER);

    current_state <= combinatorial.next_state when rising_edge(PORT_CLK);

    PORT_UART_TX    <= current_state.uart_tx;
    PORT_DATA_READY <= current_state.data_ready;

end architecture arch;
