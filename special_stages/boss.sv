
module boss(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input logic [6:0] collision,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,

    output logic BossDR,
    output logic [7:0] BossRGB,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 300;
	parameter int INITIAL_Y = 200;
	parameter int X_SPEED = 8;
    parameter int Y_SPEED = -2;

    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic squareDR;
    logic [7:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;
    logic BossIsHit;
    logic Boss_deactivated;
    logic shooting_pusle;

    logic missiles_draw_requests;
    boss_move #(.X_SPEED(X_SPEED), .Y_SPEED(Y_SPEED), .INITIAL_X(INITIAL_X), .INITIAL_Y(INITIAL_Y)) boss_move_inst(
         .clk(clk),
         .resetN(resetN),
         .missile_collision(collision[0] & squareDR),
         .border_collision(collision[1] & squareDR),
         .startOfFrame(startOfFrame & (enable)),
         .HitEdgeCode(HitEdgeCode),
         .BossIsHit(BossIsHit),
         .topLeftX(topLeftX),
         .topLeftY(topLeftY)
     );

    square_object #(.OBJECT_WIDTH_X(128), .OBJECT_HEIGHT_Y(128)) square_object_inst(
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

    delay_signal_by_frames #(.DELAY_FRAMES_AMOUNT(10)) delay_signal_by_frames_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame & (enable)),
        .input_signal(BossIsHit),
        .output_signal(Boss_deactivated)
        );

    shooting_cooldown #(.SHOOTING_COOLDOWN(90)) shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame & (enable)),
        .fire_command  (~(BossIsHit)),
        .shooting_pusle(shooting_pusle)
        );

    missiles #(.SHOT_AMOUNT(40), .X_SPEED(0), .Y_SPEED(128), .X_OFFSET(60), .Y_OFFSET(28), .MISSILE_COLOR(8'hD0)) missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
        .shooting_pusle (shooting_pusle),
        .startOfFrame   (startOfFrame & (enable)),
        .collision      ((collision[4] | collision[2])),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .missleDR       (missiles_draw_requests)
        );
    
		
    ChickenautBitMap ChickenautBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR),
        .drawingRequest(BossDR),
        .RGBout(BossRGB),
        .HitEdgeCode(HitEdgeCode)
    );

    assign missleRGB = 8'hD0;
    assign missleDR = (missiles_draw_requests != 0);

endmodule
