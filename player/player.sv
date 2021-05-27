
module  player (
    input logic clk,
    input logic resetN,
	input logic enable,
    input logic [KEYCODE_WIDTH - 1:0] keyCode,
    input logic make,
    input logic brake,
    input logic startOfFrame,
    input coordinate pixelX,
    input coordinate pixelY,
    input logic [6:0] collision,

    output logic playerDR,
    output RGB playerRGB,

    output logic missleDR,
    output RGB missleRGB,

    output logic livesDR,
    output RGB livesRGB,

    output logic player_dead
);

    `include "parameters.sv"

    parameter UP    = 9'h06C; // digit 7
    parameter DOWN  = 9'h075; // digit 8
    parameter RIGHT = 9'h14A; // key '/'
    parameter LEFT  = 9'h073; // digit 5
    parameter STR_SHOT_KEY = 9'h15A; // enter key
    parameter unsigned KEYCODE_WIDTH = 9;

    parameter unsigned LIVES_AMOUNT_WIDTH = 3;
    parameter logic [LIVES_AMOUNT_WIDTH - 1:0] LIVES_AMOUNT = 4;


    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;
    coordinate offsetX;
    coordinate offsetY;
    logic squareDR;
    RGB squareRGB;
    logic [3:0] HitEdgeCode;
    logic shooting_pusle;
    RGB bitmapRGB;
    logic [LIVES_AMOUNT_WIDTH - 1:0] remaining_lives;
    logic player_faded;
    logic player_damaged;

    logic upIsPress;
    keyToggle_decoder #(.KEY_VALUE(UP)) control_up_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(upIsPress)
        );

    logic downIsPress;
    keyToggle_decoder #(.KEY_VALUE(DOWN)) control_down_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(downIsPress)
        );

    logic RightIsPress;
    keyToggle_decoder #(.KEY_VALUE(RIGHT)) control_right_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(RightIsPress)
        );

    logic LeftIsPress;
    keyToggle_decoder #(.KEY_VALUE(LEFT)) control_left_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(LeftIsPress)
        );

    logic shotKeyIsPressed;

    keyToggle_decoder #(.KEY_VALUE(STR_SHOT_KEY)) control_strShot_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(shotKeyIsPressed)
        );

    player_move player_move_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame & (enable)),
        .move_left(LeftIsPress),
        .move_right(RightIsPress),
        .move_up(upIsPress),
        .move_down(downIsPress),
        .border_collision(collision[3]),
        .HitEdgeCode(HitEdgeCode),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );

    square_object #(.OBJECT_WIDTH_X(32), .OBJECT_HEIGHT_Y(32)) square_object_inst(
        .clk			(clk),
        .resetN			(resetN),
        .pixelX			(pixelX),
        .pixelY			(pixelY),
        .topLeftX		(topLeftX),
        .topLeftY		(topLeftY),
        .offsetX		(offsetX),
        .offsetY		(offsetY),
        .drawingRequest	(squareDR),
        .RGBout			(squareRGB)
        );


    spaceShipBitMap spaceShipBitMap_inst(
        .clk			(clk),
        .resetN			(resetN),
        .offsetX		(offsetX),
        .offsetY		(offsetY),
        .InsideRectangle(squareDR),
        .drawingRequest	(playerDR),
        .RGBout			(bitmapRGB),
        .HitEdgeCode	(HitEdgeCode)
        );

    player_lives #(.LIVES_AMOUNT(LIVES_AMOUNT), .LIVES_AMOUNT_WIDTH(LIVES_AMOUNT_WIDTH)) player_lives_inst(
        .clk              (clk),
        .resetN           (resetN),
        .startOfFrame     (startOfFrame & (enable)),
        .missile_collision(collision[4] || collision[6]),
        .remaining_lives  (remaining_lives),
        .player_faded     (player_faded),
        .player_damaged   (player_damaged),
        .player_dead      (player_dead)
        );

    assign playerRGB = RGB'((player_faded == 1'b1) ? RGB'('b0) : bitmapRGB) ;

    logic [LIVES_AMOUNT - 1:0] lives_square_draw_requests;
    logic [LIVES_AMOUNT - 1:0] lives_draw_requests;
    logic [LIVES_AMOUNT - 1:0] [10:0] lives_offsetX;
    logic [LIVES_AMOUNT - 1:0] [10:0] lives_offsetY;

    genvar i;
    generate
        for (i = 0; i < LIVES_AMOUNT; i++) begin : generate_lives
            square_object #(.OBJECT_WIDTH_X(8), .OBJECT_HEIGHT_Y(8)) square_object_lives_inst(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (32 + (i * 16)),
                .topLeftY       (467),
                .offsetX        (lives_offsetX[i]),
                .offsetY        (lives_offsetY[i]),
                .drawingRequest (lives_square_draw_requests[i])
                );

            assign lives_draw_requests[i] = lives_square_draw_requests[i] & (i < remaining_lives);
        end
    endgenerate

    // Decide on which square object to pass into the bitmap
    logic chosen_lives_square_DR;
    coordinate chosen_lives_offsetX;
    coordinate chosen_lives_offsetY;
    always_comb begin
        chosen_lives_square_DR = 1'b0;
        chosen_lives_offsetX = 11'b0;
        chosen_lives_offsetY = 11'b0;
        for (int j = 0; j < LIVES_AMOUNT; j++) begin
            // Only save the offset of the first square
            if (lives_draw_requests[j] == 1'b1) begin
                chosen_lives_square_DR = 1'b1;
                chosen_lives_offsetX = lives_offsetX[j];
                chosen_lives_offsetY = lives_offsetY[j];
                break;
            end
        end
    end

    livesBitMap livesBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_lives_offsetX),
        .offsetY(chosen_lives_offsetY),
        .InsideRectangle(chosen_lives_square_DR),
        .drawingRequest(livesDR),
        .RGBout(livesRGB)
    );

    // assign livesDR = (lives_draw_requests != 0);
    // assign livesRGB = 8'b00010000;

    shooting_cooldown shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame & (enable)),
        .fire_command  (shotKeyIsPressed & (~player_damaged)),
        .shooting_pusle(shooting_pusle)
        );

    missiles missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
        .shooting_pusle (shooting_pusle),
        .startOfFrame   (startOfFrame & (enable)),
        .collision      ((collision[0] | collision[2])),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .missleDR       (missleDR),
        .missleRGB      (missleRGB)
        );



endmodule
