
module monsters(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
	input logic [3:0] collision,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,

    output logic monsterDR,
    output logic [7:0] monsterRGB
);

    parameter unsigned KEYCODE_WIDTH = 9;

    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic squareDR;
    logic [7:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;
	logic monsterIsHit;
	
    monsters_move monsters_move_inst(
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



endmodule
