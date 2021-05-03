module space_invaders_TOP
(
    input logic CLOCK_50,
    input logic resetN,
    input logic PS2_CLK,
    input logic PS2_DAT,
    input logic AUD_ADCDAT,

    output logic [VGA_WIDTH - 1:0] OVGA,
    output logic [AUDIO_WIDTH - 1:0] AUDOUT,
    output logic [HEX_WIDTH-1:0] HEX0,
    output logic [HEX_WIDTH-1:0] HEX1,
    output logic [HEX_WIDTH-1:0] HEX2,
    output logic [HEX_WIDTH-1:0] HEX3,
    output logic [HEX_WIDTH-1:0] HEX4,
    output logic [HEX_WIDTH-1:0] HEX5
);

    parameter unsigned VGA_WIDTH = 29;
    parameter unsigned AUDIO_WIDTH = 8;
    parameter unsigned HEX_WIDTH = 7;

    logic clk;

    clock_divider clock_div_inst (.refclk(CLOCK_50), .rst(~resetN), .outclk_0(clk));
    player player_inst ();
    monsters monsters_inst ();
    hit_detection hit_detection_inst ();
    missiles missiles_inst ();
    obstacles obstacles_inst ();
    background background_inst ();

    logic startOfFrame;
    logic pixelX;
    logic pixelY;

    // TODO: Remove all of this, it is here only as a placeholder until there is something to draw
    logic [7:0] obj_RGB [0:1];
    assign obj_RGB = '{8'b00000011, 8'b11100000};
    logic draw_requests [0:1];
    assign draw_requests = '{1'b1, 1'b1};


    video_unit video_unit_inst (
    .clk            (clk),
    .resetN         (resetN),
    .draw_requests  (draw_requests),
    .obj_RGB        (obj_RGB),
    .background_RGB (8'b11100000),
    .PixelX         (pixelX),
    .PixelY         (pixelY),
    .startOfFrame   (startOfFrame),
    .oVGA           (OVGA));
    
    sound_unit sound_unit_inst ();

endmodule
