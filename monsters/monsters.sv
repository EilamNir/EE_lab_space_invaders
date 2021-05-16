
module monsters(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
	input logic [4:0] collision,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,

    output logic monsterDR,
    output logic [7:0] monsterRGB,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 300;
	parameter int INITIAL_Y = 200;
	parameter int X_SPEED = 8;
	
    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic squareDR;
    logic [7:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;
	logic monsterIsHit;
    logic shooting_pusle;
	
    monsters_move #(.X_SPEED(X_SPEED),.INITIAL_X(INITIAL_X)) monsters_move_inst(
        .clk(clk),
        .resetN(resetN),
		.collision(collision),
        .startOfFrame(startOfFrame),
		.HitEdgeCode(HitEdgeCode),
		.monsterIsHit(monsterIsHit),
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


    chickenBitMap chickenBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR),
		.monsterIsHit(monsterIsHit),
        .drawingRequest(monsterDR),
        .RGBout(monsterRGB),
        .HitEdgeCode(HitEdgeCode)
    );

    shooting_cooldown #(.SHOOTING_COOLDOWN(30)) shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame),
        .fire_command  (~monsterIsHit),
        .shooting_pusle(shooting_pusle)
        );

    missiles #(.SHOT_AMOUNT(5), .X_SPEED(0), .Y_SPEED(128), .X_OFFSET(15), .Y_OFFSET(32), .MISSILE_COLOR(8'hD0)) missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
        .shooting_pusle (shooting_pusle),
        .startOfFrame   (startOfFrame),
        .collision      ((collision[4] | collision[2])),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .missleDR       (missleDR),
        .missleRGB      (missleRGB)
        );



endmodule
