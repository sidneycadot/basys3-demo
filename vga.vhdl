
library ieee;
use ieee.std_logic_1164.all,
    ieee.numeric_std.all;

entity vga is
    port (
        CLK            : in std_logic;
        PORT_RESET     : in std_logic;
        --
        PORT_VGA_R     : out std_logic_vector(3 downto 0);
        PORT_VGA_G     : out std_logic_vector(3 downto 0);
        PORT_VGA_B     : out std_logic_vector(3 downto 0);
        PORT_VGA_VSYNC : out std_logic;
        PORT_VGA_HSYNC : out std_logic
    );
end entity vga;


architecture arch of vga is

type StateType is record
        --
        x         : natural;
        y         : natural;
        --
        vga_r     : std_logic_vector(3 downto 0);
        vga_g     : std_logic_vector(3 downto 0);
        vga_b     : std_logic_vector(3 downto 0);
        vga_vsync : std_logic;
        vga_hsync : std_logic;
    end record StateType;

constant reset_state : StateType := (
        --
        x         => 0,
        y         => 0,
        --
        vga_r     => "0000",
        vga_g     => "0000",
        vga_b     => "0000",
        vga_vsync => '0',
        vga_hsync => '0'
    );

type CombinatorialSignals is
    record
        next_state : StateType;
    end record CombinatorialSignals;

function UpdateCombinatorialSignals(
            current_state : in StateType;
            RESET         : in std_logic
         ) return CombinatorialSignals is

    type SyncPolarity is (NegativePolarity, PositivePolarity);

    -- Parameters for 1920x1080 at 60 Hz are as follows:

    constant H_SYNC_WIDTH  : natural :=   44;
    constant H_BACK_PORCH  : natural :=  148;
    constant H_PIXELS      : natural := 1920;
    constant H_FRONT_PORCH : natural :=   88;    
    constant H_SYNC_POLARITY : SyncPolarity := PositivePolarity;
    constant V_SYNC_WIDTH  : natural :=    5;
    constant V_BACK_PORCH  : natural :=   36;
    constant V_PIXELS      : natural := 1080;
    constant V_FRONT_PORCH : natural :=    4;    
    constant V_SYNC_POLARITY : SyncPolarity := PositivePolarity;

    -- H_SYNC_WIDTH is followed by H_BACK_PORCH is followed by H_PIXELS is followed by H_FRONT_PORCH.
    -- V_SYNC_WIDTH is followed by V_BACK_PORCH is followed by V_PIXELS is followed by V_FRONT_PORCH.
    constant H_TOTAL       : natural := H_SYNC_WIDTH + H_BACK_PORCH + H_PIXELS + H_FRONT_PORCH;
    constant V_TOTAL       : natural := V_SYNC_WIDTH + V_BACK_PORCH + V_PIXELS + V_FRONT_PORCH;

    variable combinatorial : CombinatorialSignals;

    variable xx : natural;
    variable yy : natural;

begin

    if RESET = '1' then
        combinatorial.next_state := reset_state;
    else

        combinatorial.next_state := current_state;

        combinatorial.next_state.vga_hsync := '1' when (combinatorial.next_state.x < H_SYNC_WIDTH) xor (H_SYNC_POLARITY = NegativePolarity) else '0';
        combinatorial.next_state.vga_vsync := '1' when (combinatorial.next_state.y < V_SYNC_WIDTH) xor (V_SYNC_POLARITY = NegativePolarity) else '0';

        combinatorial.next_state.vga_r := x"0";
        combinatorial.next_state.vga_g := x"0";
        combinatorial.next_state.vga_b := x"0";


        if V_SYNC_WIDTH + V_BACK_PORCH <= combinatorial.next_state.y and combinatorial.next_state.y < V_SYNC_WIDTH + V_BACK_PORCH + V_PIXELS then

            -- Vertically, we're in the active video area.

            if H_SYNC_WIDTH + H_BACK_PORCH <= combinatorial.next_state.x and combinatorial.next_state.x < H_SYNC_WIDTH + H_BACK_PORCH + H_PIXELS then

                -- We're in the active video area, both vertically and horizontally.

                xx := combinatorial.next_state.x - (H_SYNC_WIDTH + H_BACK_PORCH);
                yy := combinatorial.next_state.y - (V_SYNC_WIDTH + V_BACK_PORCH);

                -- Determine the pixel color.

                if xx >= H_PIXELS / 2 then
                    combinatorial.next_state.vga_r := x"f";
                end if;
    
                if yy >= V_PIXELS / 2 then
                    combinatorial.next_state.vga_b := x"f";
                end if;
    
                if (xx = 0 or xx = H_PIXELS - 1 or yy = 0 or yy = V_PIXELS - 1) then
                    combinatorial.next_state.vga_r := x"f";
                    combinatorial.next_state.vga_g := x"f";
                    combinatorial.next_state.vga_b := x"f";
                end if;
    
                if (xx - H_PIXELS / 2) * (xx - H_PIXELS / 2) + (yy - V_PIXELS / 2) * (yy - V_PIXELS / 2) <= (V_PIXELS / 2) * (V_PIXELS / 2) then
                    combinatorial.next_state.vga_r := not combinatorial.next_state.vga_r;
                    combinatorial.next_state.vga_g := not combinatorial.next_state.vga_g;
                    combinatorial.next_state.vga_b := not combinatorial.next_state.vga_b;
                end if;

            end if;

        end if;

        -- We increase combinatorial.next_state.x and combinatorial.next_state.y at the end.
        -- This helps to shorten combinatorial paths, increasing the amount of work we can do per clock cycle.
    
        if combinatorial.next_state.x /= H_TOTAL - 1 then
            combinatorial.next_state.x := combinatorial.next_state.x + 1;
        else
            combinatorial.next_state.x := 0;
            if combinatorial.next_state.y /= V_TOTAL - 1 then
                combinatorial.next_state.y := combinatorial.next_state.y + 1;
            else
                combinatorial.next_state.y := 0;
            end if;
        end if;
    
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

    PORT_VGA_R     <= current_state.vga_r;
    PORT_VGA_G     <= current_state.vga_g;
    PORT_VGA_B     <= current_state.vga_b;
    PORT_VGA_VSYNC <= current_state.vga_vsync;
    PORT_VGA_HSYNC <= current_state.vga_hsync;

end architecture arch;
