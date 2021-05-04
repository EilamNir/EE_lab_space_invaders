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
    parameter unsigned RGB_WIDTH = 8;
    parameter unsigned PIXEL_WIDTH = 11;

    logic clk;
    logic startOfFrame;
    logic [PIXEL_WIDTH - 1:0] pixelX;
    logic [PIXEL_WIDTH - 1:0] pixelY;
    logic [RGB_WIDTH - 1:0] background_RGB;

    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;

    clock_divider clock_div_inst (.refclk(CLOCK_50), .rst(~resetN), .outclk_0(clk));

    player player_inst (
    .clk            (clk),
    .resetN         (resetN),
    .PS2_CLK        (PS2_CLK),
    .PS2_DAT        (PS2_DAT),
    .startOfFrame   (startOfFrame),
    .PixelX         (pixelX),
    .PixelY         (pixelY),
    .topLeftX       (topLeftX),
    .topLeftY       (topLeftY),
    .playerDR       (playerDR),
    .playerRGB      (playerRGB));

    monsters monsters_inst ();
    hit_detection hit_detection_inst ();
    missiles missiles_inst ();
    obstacles obstacles_inst ();

    background background_inst (
        .clk            (clk),
        .resetN         (resetN),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .background_RGB (background_RGB));


    // TODO: Remove all of this, it is here only as a placeholder until there is something to draw
    logic [0:1] [7:0] obj_RGB;
    assign obj_RGB = {playerRGB, 8'b00000011};
    logic [0:1] draw_requests;
    assign draw_requests = {playerDR, 1'b0};


    video_unit video_unit_inst (
    .clk            (clk),
    .resetN         (resetN),
    .draw_requests  (draw_requests),
    .obj_RGB        (obj_RGB),
    .background_RGB (background_RGB),
    .PixelX         (pixelX),
    .PixelY         (pixelY),
    .startOfFrame   (startOfFrame),
    .oVGA           (OVGA));
    
    sound_unit sound_unit_inst ();

endmodule
