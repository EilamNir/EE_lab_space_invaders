
module  player (
    input logic clk,
    input logic resetN,
	input logic enable,
    input logic [KEYCODE_WIDTH - 1:0] keyCode,
    input logic make,
    input logic brake,
    input logic startOfFrame,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,
    input logic [6:0] collision,

    output logic playerDR,
    output logic [RGB_WIDTH - 1:0] playerRGB,

    output logic missleDR,
    output logic [RGB_WIDTH - 1:0] missleRGB,
    output logic player_dead
);
    parameter UP    = 9'h06C; // digit 7
    parameter DOWN  = 9'h075; // digit 8
    parameter RIGHT = 9'h14A; // key '/'
    parameter LEFT  = 9'h073; // digit 5
    parameter STR_SHOT_KEY = 9'h15A; // enter key
    parameter unsigned KEYCODE_WIDTH = 9;

    parameter unsigned RGB_WIDTH = 8;


    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;
    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic squareDR;
    logic [RGB_WIDTH - 1:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic shooting_pusle;
    logic [RGB_WIDTH - 1:0] bitmapRGB;
    logic player_faded;

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
		.enable(enable),
        .startOfFrame(startOfFrame),
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
		.enable		    (enable),
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

    player_lives player_lives_inst(
        .clk              (clk),
        .resetN           (resetN),
		.enable			  (enable),
        .startOfFrame     (startOfFrame),
        .missile_collision(collision[4] || collision[6]),
        .player_faded     (player_faded),
        .player_dead      (player_dead)
        );

    assign playerRGB = RGB_WIDTH'((player_faded == 1'b1) ? RGB_WIDTH'('b0) : bitmapRGB) ;

    shooting_cooldown shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
		.enable		   (enable),
        .startOfFrame  (startOfFrame),
        .fire_command  (shotKeyIsPressed & (~player_faded)),
        .shooting_pusle(shooting_pusle)
        );

    missiles missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
		.enable 		(enable),
        .shooting_pusle (shooting_pusle),
        .startOfFrame   (startOfFrame),
        .collision      ((collision[0] | collision[2])),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .missleDR       (missleDR),
        .missleRGB      (missleRGB)
        );



endmodule
