
module  player (
    input logic clk,
    input logic resetN,
    input logic [KEYCODE_WIDTH - 1:0] keyCode,
    input logic make,
    input logic brake,
    input logic startOfFrame,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,
	input logic [3:0] collision,

    output logic playerDR,
    output logic [7:0] playerRGB,

    output logic missleDR,
    output logic [7:0] missleRGB
);
    parameter UP    = 9'h075; // digit 8
    parameter DOWN  = 9'h073; // digit 5
    parameter RIGHT = 9'h074; // digit 6
    parameter LEFT  = 9'h06B; // digit 4
    parameter unsigned KEYCODE_WIDTH = 9;

    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;
    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic squareDR;
    logic [7:0] squareRGB;
    logic [3:0] HitEdgeCode;

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

    player_move player_move_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame),
        .move_left(LeftIsPress),
        .move_right(RightIsPress),
        .move_up(upIsPress),
        .move_down(downIsPress),
		.collision(collision),
		.HitEdgeCode(HitEdgeCode),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );

    square_object #(.OBJECT_WIDTH_X(32), .OBJECT_HEIGHT_Y(32)) square_object_inst(
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .drawingRequest(squareDR),
        .RGBout(squareRGB)
        );


    spaceShipBitMap spaceShipBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR),
        .drawingRequest(playerDR),
        .RGBout(playerRGB),
        .HitEdgeCode(HitEdgeCode)
        );


    missiles missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
        .keyCode        (keyCode),
        .make           (make),
        .brake          (brake),
        .startOfFrame   (startOfFrame),
        .collision      (collision),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .missleDR       (missleDR),
        .missleRGB      (missleRGB)
        );



endmodule
