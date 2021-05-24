
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
    output logic boss_dead,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 300;
	parameter int INITIAL_Y = 200;
	parameter int X_SPEED = 64;
    parameter int Y_SPEED = -16;
    parameter int BOSS_MISSILE_AMOUNT = 5;
	parameter unsigned LIVES_AMOUNT_WIDTH = 5;
    parameter logic [LIVES_AMOUNT_WIDTH - 1:0] LIVES_AMOUNT = 3;
    parameter unsigned RGB_WIDTH = 8;

    logic [10:0] offsetX;
    logic [10:0] offsetY;
    logic squareDR;
	logic previous_DR;
    logic [7:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;
    logic Boss_deactivated;
    logic shooting_pusle;
    logic boss_faded;
    logic boss_damaged;
	logic [RGB_WIDTH - 1:0] bitmapRGB;

    logic [BOSS_MISSILE_AMOUNT-1:0] missiles_draw_requests;
    boss_move #(.X_SPEED(X_SPEED), .Y_SPEED(Y_SPEED), .INITIAL_X(INITIAL_X), .INITIAL_Y(INITIAL_Y)) boss_move_inst(
         .clk(clk),
         .resetN(resetN),
         .border_collision(collision[1] & squareDR),
         .startOfFrame(startOfFrame & (enable)),
         .HitEdgeCode(HitEdgeCode),
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

    delay_signal_by_frames #(.DELAY_FRAMES_AMOUNT(10)) delay_signal_by_frames_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame & (enable)),
        .input_signal(boss_dead),
        .output_signal(Boss_deactivated)
        );

    shooting_cooldown #(.SHOOTING_COOLDOWN(90)) shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame & (enable)),
        .fire_command  (~(boss_dead)),
        .shooting_pusle(shooting_pusle)
        );

    genvar i;
    generate
        for (i = 0; i < BOSS_MISSILE_AMOUNT; i++) begin : generate_missiles
            missiles #(.SHOT_AMOUNT(4), .X_SPEED((i - 2) * 16), .Y_SPEED(128), .X_OFFSET(60), .Y_OFFSET(28), .MISSILE_COLOR(8'hD0)) missiles_inst (
                .clk            (clk),
                .resetN         (resetN),
                .shooting_pusle (shooting_pusle),
                .startOfFrame   (startOfFrame & (enable)),
                .collision      ((collision[4] | collision[2])),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .spaceShip_X    (topLeftX),
                .spaceShip_Y    (topLeftY),
                .missleDR       (missiles_draw_requests[i])
                );
        end
    endgenerate
  
      player_lives #(.LIVES_AMOUNT(LIVES_AMOUNT), .LIVES_AMOUNT_WIDTH(LIVES_AMOUNT_WIDTH), .PLAYER_DAMAGED_FRAME_AMOUNT(10)) player_lives_inst(
        .clk              (clk),
        .resetN           (resetN),
        .startOfFrame     (startOfFrame & (enable)),
        .missile_collision(collision[0] & previous_DR),
        .player_faded     (boss_faded),
        .player_dead      (boss_dead)
        );
	
    ChickenautBitMap ChickenautBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR & !Boss_deactivated),
        .drawingRequest(BossDR),
        .RGBout(bitmapRGB),
        .HitEdgeCode(HitEdgeCode)
    );
	
	// Remember the previous draw requests, for collision detection
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previous_DR <= 0;
        end else begin
            previous_DR <= BossDR;
        end
    end
	
	assign BossRGB = RGB_WIDTH'((boss_faded == 1'b1) ? RGB_WIDTH'('b0) : bitmapRGB) ;
    assign missleRGB = 8'hD0;
    assign missleDR = (missiles_draw_requests != 0);

endmodule
