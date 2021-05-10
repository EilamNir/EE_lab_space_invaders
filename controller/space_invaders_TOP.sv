module space_invaders_TOP
(
    input logic CLOCK_50,
    input logic resetN,
    input logic PS2_CLK,
    input logic PS2_DAT,
    input logic AUD_ADCDAT,

    output logic [VGA_WIDTH - 1:0] OVGA,
    output logic [AUDIO_WIDTH - 1:0] AUDOUT
);

    parameter unsigned VGA_WIDTH = 29;
    parameter unsigned AUDIO_WIDTH = 8;
    parameter unsigned HEX_WIDTH = 7;
    parameter unsigned RGB_WIDTH = 8;
    parameter unsigned PIXEL_WIDTH = 11;
    parameter unsigned KEYCODE_WIDTH = 9;

    logic clk;
    logic startOfFrame;
    logic [PIXEL_WIDTH - 1:0] pixelX;
    logic [PIXEL_WIDTH - 1:0] pixelY;
    logic [RGB_WIDTH - 1:0] background_RGB;

    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;

    logic [RGB_WIDTH - 1:0] playerRGB;
    logic [RGB_WIDTH - 1:0] missleRGB;
    logic [RGB_WIDTH - 1:0] monsterRGB;
    logic [0:2] [RGB_WIDTH - 1:0] obj_RGB;
    assign obj_RGB = {playerRGB, missleRGB, monsterRGB};
    logic missleDR;
    logic playerDR;
    logic monsterDR;

    logic [1:0] boardersDrawReq;
    logic [0:2] draw_requests;
    assign draw_requests = {playerDR, missleDR, monsterDR};

    logic [KEYCODE_WIDTH - 1:0] keyCode;
    logic make;
    logic brake;

    logic [3:0] HitPulse;
    logic collision;

    clock_divider clock_div_inst (
        .refclk(CLOCK_50),
        .rst(~resetN),
        .outclk_0(clk));

    keyboard_interface kbd_inst(
        .clk(clk),
        .resetN(resetN),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .keyCode(keyCode),
        .make(make),
        .brake(brake)
        );

    player player_inst (
        .clk            (clk),
        .resetN         (resetN),
        .keyCode        (keyCode),
        .make           (make),
        .brake          (brake),
        .startOfFrame   (startOfFrame),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .topLeftX       (topLeftX),
        .topLeftY       (topLeftY),
        .playerDR       (playerDR),
        .playerRGB      (playerRGB));

    monsters monsters_inst (
        .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
        .collision      (collision),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .monsterDR      (monsterDR),
        .monsterRGB     (monsterRGB));

    hit_detection hit_detection_inst (
        .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
        .draw_requests  (draw_requests),
        .collision      (collision),
        .HitPulse       (HitPulse));

    missiles missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
        .keyCode        (keyCode),
        .make           (make),
        .brake          (brake),
        .startOfFrame   (startOfFrame),
        .collision      (HitPulse[0]),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .missleDR       (missleDR),
        .missleRGB      (missleRGB));

    obstacles obstacles_inst ();

    background background_inst (
        .clk            (clk),
        .resetN         (resetN),
        .boardersDrawReq(boardersDrawReq),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .background_RGB (background_RGB));

    video_unit video_unit_inst (
        .clk            (clk),
        .resetN         (resetN),
        .draw_requests  (draw_requests),
        .obj_RGB        (obj_RGB),
        .background_RGB (background_RGB),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .startOfFrame   (startOfFrame),
        .oVGA           (OVGA));

    sound_unit sound_unit_inst (
        .AUD_ADCDAT(AUD_ADCDAT),
        .AUDOUT(AUDOUT));

endmodule
