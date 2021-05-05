
module missiles(
    input logic clk,
    input logic resetN,
    input logic PS2_CLK,
    input logic PS2_DAT,
    input logic startOfFrame,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [10:0] spaceShip_X,
    input logic [10:0] spaceShip_Y,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    logic [8:0] keyCode;
    logic make;
    logic brake;

    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic squareDR;
    logic [7:0] squareRGB;
    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;

    parameter STR_SHOT_KEY = 9'h070; // digit 0
    logic strShotKeyIsPress;

    keyboard_interface kbd_inst(
        .clk(clk),
        .resetN(resetN),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .keyCode(keyCode),
        .make(make),
        .brake(brake)
        );

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
        .spaceShip_X(spaceShip_X),
        .spaceShip_Y(spaceShip_Y),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );

    square_object #(.OBJECT_WIDTH_X(64), .OBJECT_HEIGHT_Y(64)) square_object_inst(
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

    missileBitMap missileBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR),
        .drawingRequest(missleDR),
        .RGBout(missleRGB)
    );

endmodule
