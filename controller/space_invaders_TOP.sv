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
	logic [RGB_WIDTH - 1:0] monsterRGB2;
    logic [0:3] [RGB_WIDTH - 1:0] obj_RGB;
    assign obj_RGB = {playerRGB, missleRGB, monsterRGB, monsterRGB2};
    logic missleDR;
    logic playerDR;
	logic monsterDR;
	logic monsterDR2;
		
	logic [0:1] bordersDR;
    logic [0:5] draw_requests;
    assign draw_requests = {playerDR, missleDR, monsterDR, monsterDR2, bordersDR[0], bordersDR[1]};

    logic [KEYCODE_WIDTH - 1:0] keyCode;
    logic make;
    logic brake;

    logic [3:0] HitPulse;
    logic [3:0] collision;

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
		.HitPulse       (HitPulse),
        .topLeftX       (topLeftX),
        .topLeftY       (topLeftY),
        .playerDR       (playerDR),
        .playerRGB      (playerRGB));

    monsters #(.INITIAL_X(150)) monsters_inst (
	    .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
		.collision       (collision),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .monsterDR      (monsterDR),
        .monsterRGB     (monsterRGB));
		
	monsters #(.INITIAL_X(200)) monsters_inst2 (
	    .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
		.collision       (collision),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .monsterDR      (monsterDR2),
        .monsterRGB     (monsterRGB2));
		
		
    hit_detection #(.NUMBER_OF_OBJECTS(6)) hit_detection_inst (
	    .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
        .draw_requests  (draw_requests),
		.collision      (collision),
		.HitPulse 		(HitPulse));

    missiles missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
        .keyCode        (keyCode),
        .make           (make),
        .brake          (brake),
        .startOfFrame   (startOfFrame),
		.collision       (collision),
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
        .pixelX         (pixelX),
        .pixelY         (pixelY),
		.bordersDR(bordersDR),
        .background_RGB (background_RGB));

    video_unit #(.NUMBER_OF_OBJECTS(6)) video_unit_inst (
        .clk            (clk),
        .resetN         (resetN),
        .draw_requests  (draw_requests[0:3]),
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
