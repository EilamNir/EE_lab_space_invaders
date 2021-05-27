
module monsters(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input logic [6:0] collision,
	input logic [2:0] stage_num,
    input coordinate pixelX,
    input coordinate pixelY,

    output logic monsterDR,
    output RGB monsterRGB,

    output logic missleDR,
    output RGB missleRGB,

    output logic monster_died_pulse,
    output logic all_monsters_dead
);

    `include "parameters.sv"

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 100;
	parameter int INITIAL_Y = 50;
	parameter int X_SPEED = -24;
    parameter int Y_SPEED = -15;
	parameter unsigned MONSTER_AMOUNT_WIDTH = 5;
    parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] MAX_MONSTER_AMOUNT = 16;
	parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] FIRST_STAGE_AMOUNT = 4;
	parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] SECOND_STAGE_AMOUNT = 0;
	parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] BOSS_STAGE_AMOUNT = 1;

    parameter unsigned NUMBER_OF_MONSTER_EXPLOSION_FRAMES = 3;
    parameter unsigned X_SPACING = 128;


    coordinate [MAX_MONSTER_AMOUNT - 1:0] offsetX;
    coordinate [MAX_MONSTER_AMOUNT - 1:0] offsetY;
    logic [MAX_MONSTER_AMOUNT - 1:0] squareDR;
    logic [MAX_MONSTER_AMOUNT - 1:0] silhouetteDR;
    logic [MAX_MONSTER_AMOUNT - 1:0] previousDR;
    RGB [MAX_MONSTER_AMOUNT - 1:0] squareRGB;
    logic [MAX_MONSTER_AMOUNT - 1:0] [3:0] HitEdgeCode;
    coordinate [MAX_MONSTER_AMOUNT - 1:0] topLeftX;
    coordinate [MAX_MONSTER_AMOUNT - 1:0] topLeftY;
    logic [MAX_MONSTER_AMOUNT - 1:0] monsterIsHit;
    logic [MAX_MONSTER_AMOUNT - 1:0] monster_deactivated;
	logic [MAX_MONSTER_AMOUNT - 1:0] monster_exploded;
    logic monster_overlap;
    logic [MAX_MONSTER_AMOUNT - 1:0] previous_monsterIsHit;
    logic [MAX_MONSTER_AMOUNT - 1:0] shooting_pusle;
    logic [MAX_MONSTER_AMOUNT-1:0] missiles_draw_requests;
	logic [MONSTER_AMOUNT_WIDTH - 1:0] monster_amount;
    logic random_bit;

    // Decide how many monsters in every stage
    logic [0:4] [MONSTER_AMOUNT_WIDTH - 1:0] monsters_per_stage = {
        MONSTER_AMOUNT_WIDTH'('d0),
        MONSTER_AMOUNT_WIDTH'('d8),
        MONSTER_AMOUNT_WIDTH'('d16),
        MONSTER_AMOUNT_WIDTH'('d0),
        MONSTER_AMOUNT_WIDTH'('d12)};

    assign monster_amount = monsters_per_stage[stage_num];


    genvar i;
    generate
        for (i = 0; i < MAX_MONSTER_AMOUNT; i++) begin : generate_monsters
            monsters_move #(.X_SPEED(X_SPEED + (i * 2)), .Y_SPEED(Y_SPEED + ((i>>2) * 8) + i * 2), .INITIAL_X(INITIAL_X + ((2'(i) & 2'b11) * X_SPACING)), .INITIAL_Y(INITIAL_Y + ((i>>2) * 64))) monsters_move_inst(
                .clk(clk),
                .resetN(resetN),
                .missile_collision(collision[0] & previousDR[i]),
                .border_collision((monster_overlap | collision[1]) & previousDR[i]),
                .startOfFrame(startOfFrame & enable & (i < monster_amount)),
                .HitEdgeCode(HitEdgeCode[i]),
                .random_bit(random_bit),
                .monsterIsHit(monsterIsHit[i]),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i])
                );

            square_object #(.OBJECT_WIDTH_X(32), .OBJECT_HEIGHT_Y(32)) square_object_inst(
                .clk(clk),
                .resetN(resetN),
                .pixelX(pixelX),
                .pixelY(pixelY),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i]),
                .offsetX(offsetX[i]),
                .offsetY(offsetY[i]),
                .drawingRequest(squareDR[i]),
                .RGBout(squareRGB[i])
                );

            chicken_silhouette chicken_silhouette_inst(
                .clk            (clk),
                .resetN         (resetN),
                .offsetX        (offsetX[i]),
                .offsetY        (offsetY[i]),
                .InsideRectangle(squareDR[i]),
                .monsterIsHit   (monsterIsHit[i]),
                .HitEdgeCode    (HitEdgeCode[i]),
                .drawingRequest (silhouetteDR[i])
                );

            delay_signal_by_frames #(.DELAY_FRAMES_AMOUNT(10)) delay_signal_by_frames_inst(
                .clk(clk),
                .resetN(resetN),
                .startOfFrame(startOfFrame & enable & (i < monster_amount)),
                .input_signal(monsterIsHit[i]),
                .output_signal(monster_exploded[i])
                );
			assign monster_deactivated[i] = monster_exploded[i] | (i >= monster_amount);

            shooting_cooldown #(.SHOOTING_COOLDOWN(8'(40 + ((2'(i) & 2'b11) * 2) + (2 * i)))) shooting_cooldown_inst(
                .clk           (clk),
                .resetN        (resetN),
                .startOfFrame  (startOfFrame & enable & (i < monster_amount)),
                .fire_command  (~(monsterIsHit[i])),
                .shooting_pusle(shooting_pusle[i])
                );

            missiles #(.SHOT_AMOUNT(4), .X_SPEED(0), .Y_SPEED(128), .X_OFFSET(15), .Y_OFFSET(28), .MISSILE_COLOR(8'hD0)) missiles_inst (
                .clk            (clk),
                .resetN         (resetN),
                .shooting_pusle (shooting_pusle[i]),
                .startOfFrame   (startOfFrame & enable & (i < monster_amount)),
                .collision      ((collision[4] | collision[2])),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .spaceShip_X    (topLeftX[i]),
                .spaceShip_Y    (topLeftY[i]),
                .missleDR       (missiles_draw_requests[i])
                );
                end
    endgenerate

    // Remember the previous draw requests, for collision detection
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previousDR <= 0;
        end else begin
            previousDR <= silhouetteDR;
        end
    end

    // Deal with multiple monsters in the same pixel
    logic chosen_monster_DR;
    coordinate chosen_offsetX;
    coordinate chosen_offsetY;
    logic chosen_monster_is_hit;
    logic [MONSTER_AMOUNT_WIDTH - 1:0] chosen_monster_index;

    // Check if there is an overlap of monsters in this space
    check_overlap #(.OBJECT_AMOUNT_WIDTH(MONSTER_AMOUNT_WIDTH), .OBJECT_AMOUNT(MAX_MONSTER_AMOUNT)) check_overlap_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame),
        .draw_request(silhouetteDR),
        .object_deactivated(monster_deactivated),
        .overlap(monster_overlap),
        .any_DR(chosen_monster_DR),
        .first_object_index(chosen_monster_index)
        );

    // Decide on which square object to pass into the bitmap
    assign chosen_offsetX = offsetX[chosen_monster_index];
    assign chosen_offsetY = offsetY[chosen_monster_index];
    assign chosen_monster_is_hit = monsterIsHit[chosen_monster_index];

    chickenBitMap chickenBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_offsetX),
        .offsetY(chosen_offsetY),
        .InsideRectangle(chosen_monster_DR),
        .monsterIsHit(chosen_monster_is_hit),
        .drawingRequest(monsterDR),
        .RGBout(monsterRGB)
    );

    // Choose a random bit for all the monsters each clock, to randomize movement when colliding with a border.
    GARO_random_bit GARO_random_bit_inst(
        .clk       (clk),
        .resetN    (resetN),
        .enable    (enable),
        .random_bit(random_bit)
        );


    assign missleRGB = 8'hD0;
    assign missleDR = (missiles_draw_requests != 0);

    // Only raise all_monsters_dead if monster_deactivated is all 1s
    assign all_monsters_dead = (&monster_deactivated) & (monster_amount != 0);

    // Send a pulse when a monster dies
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previous_monsterIsHit <= 0;
        end else begin
            previous_monsterIsHit <= monsterIsHit;
        end
    end
    assign monster_died_pulse = (monsterIsHit != previous_monsterIsHit);

endmodule
