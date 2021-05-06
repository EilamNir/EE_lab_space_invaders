
module missiles(
    input logic clk,
    input logic resetN,
    input logic [KEYCODE_WIDTH - 1:0] keyCode,
    input logic make,
    input logic brake,
    input logic startOfFrame,
	input logic [3:0] collision,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [10:0] spaceShip_X,
    input logic [10:0] spaceShip_Y,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter STR_SHOT_KEY = 9'h070; // digit 0
    parameter unsigned KEYCODE_WIDTH = 9;
    parameter unsigned RGB_WIDTH = 8;
    parameter [RGB_WIDTH - 1:0] MISSILE_COLOR = 8'h1F;

    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;

    logic strShotKeyIsPress;

    keyToggle_decoder #(.KEY_VALUE(STR_SHOT_KEY)) control_strShot_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(strShotKeyIsPress)
        );


    missile_movement missle_move_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame),
        .shotKeyIsPress(strShotKeyIsPress),
		.collision(collision),
        .spaceShip_X(spaceShip_X),
        .spaceShip_Y(spaceShip_Y),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );

    square_object #(.OBJECT_WIDTH_X(2), .OBJECT_HEIGHT_Y(5), .OBJECT_COLOR(MISSILE_COLOR)) square_object_inst(
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .drawingRequest(missleDR),
        .RGBout(missleRGB)
        );

endmodule
