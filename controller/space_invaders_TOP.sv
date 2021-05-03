module space_invaders_TOP
(
    input logic CLOCK_50,
    input logic resetN,
    input logic PS2_CLK,
    input logic PS2_DAT,
    input logic AUD_ADCDAT,

    output logic [VGA_width - 1:0] OVGA,
    output logic [AUDIO_width - 1:0] AUDOUT,
    output logic [HEX_width-1:0] HEX0,
    output logic [HEX_width-1:0] HEX1,
    output logic [HEX_width-1:0] HEX2,
    output logic [HEX_width-1:0] HEX3,
    output logic [HEX_width-1:0] HEX4,
    output logic [HEX_width-1:0] HEX5
);

    parameter unsigned VGA_width = 29;
    parameter unsigned AUDIO_width = 8;
    parameter unsigned HEX_width = 7;

    logic clk;

    clock_divider clock_div_inst (.refclk(CLOCK_50), .rst(~resetN), .outclk_0(clk));
    player player_inst ();
    monsters monsters_inst ();
    hit_detection hit_detection_inst ();
    missiles missiles_inst ();
    obstacles obstacles_inst ();
    background background_inst ();
    video_unit video_unit_inst ();
    sound_unit sound_unit_inst ();

endmodule
