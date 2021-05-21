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

    parameter unsigned HIT_DETECTION_NUMBER_OF_OBJECTS = 6;
    parameter unsigned VIDEO_UNIT_NUMBER_OF_OBJECTS = 4;

    logic clk;
    logic startOfFrame;
    logic [PIXEL_WIDTH - 1:0] pixelX;
    logic [PIXEL_WIDTH - 1:0] pixelY;
    logic [RGB_WIDTH - 1:0] background_RGB;


    logic [RGB_WIDTH - 1:0] playerRGB;
    logic [RGB_WIDTH - 1:0] player_missleRGB;
    logic [RGB_WIDTH - 1:0] monster_missleRGB;
    logic [RGB_WIDTH - 1:0] monsterRGB;
    logic [0:VIDEO_UNIT_NUMBER_OF_OBJECTS - 1] [RGB_WIDTH - 1:0] obj_RGB;
    assign obj_RGB = {playerRGB, player_missleRGB, monsterRGB, monster_missleRGB};
    logic player_missleDR;
    logic monster_missleDR;
    logic playerDR;
    logic monsterDR;
        
    logic [0:1] bordersDR;
    assign bordersDR = {bordersDR[0], bordersDR[1]};
    logic [0:VIDEO_UNIT_NUMBER_OF_OBJECTS - 1] draw_requests;
    assign draw_requests = {playerDR, player_missleDR, monsterDR, monster_missleDR};//bordersDR[0] = all around borders, bordersDR[1] = player end zone
    logic [0:HIT_DETECTION_NUMBER_OF_OBJECTS - 1] hit_request;
    assign hit_request = {draw_requests, bordersDR};
    
    logic [KEYCODE_WIDTH - 1:0] keyCode;
    logic make;
    logic brake;

    logic [4:0] HitPulse;
    logic [4:0] collision;
    logic all_monsters_dead;

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
        .resetN         (resetN & (~all_monsters_dead)),
        .keyCode        (keyCode),
        .make           (make),
        .brake          (brake),
        .startOfFrame   (startOfFrame),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .collision      (collision),
        .playerDR       (playerDR),
        .playerRGB      (playerRGB),
        .missleDR       (player_missleDR),
        .missleRGB      (player_missleRGB));

    monsters monsters_inst (
        .clk            (clk),
        .resetN         (resetN & (~all_monsters_dead)),
        .startOfFrame   (startOfFrame),
        .collision      (collision),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .monsterDR      (monsterDR),
        .monsterRGB     (monsterRGB),
        .missleDR       (monster_missleDR),
        .missleRGB      (monster_missleRGB),
        .all_monsters_dead(all_monsters_dead));
        
        
    hit_detection #(.NUMBER_OF_OBJECTS(HIT_DETECTION_NUMBER_OF_OBJECTS)) hit_detection_inst (
        .clk            (clk),
        .resetN         (resetN),
        .startOfFrame   (startOfFrame),
        .hit_request    (hit_request),
        .collision      (collision),
        .HitPulse       (HitPulse));

    obstacles obstacles_inst ();

    background background_inst (
        .clk            (clk),
        .resetN         (resetN),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .bordersDR      (bordersDR),
        .background_RGB (background_RGB));

    video_unit #(.NUMBER_OF_OBJECTS(VIDEO_UNIT_NUMBER_OF_OBJECTS)) video_unit_inst (
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
