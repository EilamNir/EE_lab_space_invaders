

module  player (
    input logic clk,
    input logic resetN,
    input logic PS2_CLK,
    input logic PS2_DAT,
    input logic startOfFrame,
    input logic [10:0]PixelX,
    input logic [10:0]PixelY,

    output logic signed [10:0] topLeftX,
    output logic signed [10:0] topLeftY,
    output logic playerDR,
    output logic [7:0] playerRGB
);

    logic keyCode[8:0];
    logic make;
    logic brake;

    keyboard_interface kbd_inst(
        .clk(clk),
        .resetN(resetN),
        .PS2_CLK(PS2_CLK),
        .PS2_DAT(PS2_DAT),
        .keyCode(keyCode),
        .make(make),
        .brake(brake)
        );

    parameter UP    = 9'h075; // digit 8
    parameter DOWN  = 9'h073; // digit 5
    parameter RIGHT = 9'h074; // digit 6
    parameter LEFT  = 9'h06B; // digit 4

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
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );


    square_object square_object_inst(
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .drawingRequest(drawingRequest),
        .RGBout(RGBout)
        );


    spaceShipBitMap spaceShipBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(drawingRequest),
        .drawingRequest(playerDR),
        .RGBout(playerRGB)
    );



endmodule