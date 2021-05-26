
module monsters(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input logic [6:0] collision,
	input logic [2:0] stage_num,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,

    output logic monsterDR,
    output logic [7:0] monsterRGB,

    output logic missleDR,
    output logic [7:0] missleRGB,

    output logic monster_died_pulse,
    output logic all_monsters_dead
);

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 100;
	parameter int INITIAL_Y = 50;
	parameter int X_SPEED = -24;
    parameter int Y_SPEED = -15;
	parameter unsigned MONSTER_AMOUNT_WIDTH = 5;
    parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] MONSTER_AMOUNT = 16;
	parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] FIRST_STAGE_AMOUNT = 8;
	parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] SECOND_STAGE_AMOUNT = 16;
	parameter logic unsigned [MONSTER_AMOUNT_WIDTH - 1:0] BOSS_STAGE_AMOUNT = 12;

    parameter unsigned NUMBER_OF_MONSTER_EXPLOSION_FRAMES = 3;
    parameter unsigned X_SPACING = 128; // Change according to amount of monsters: 96 for 5 in a row (20 total), 128 for 4 in a row (16 total)



    logic [MONSTER_AMOUNT - 1:0] [10:0] offsetX;
    logic [MONSTER_AMOUNT - 1:0] [10:0] offsetY;
    logic [MONSTER_AMOUNT - 1:0] squareDR;
    logic [MONSTER_AMOUNT - 1:0] silhouetteDR;
    logic [MONSTER_AMOUNT - 1:0] previousDR;
    logic [MONSTER_AMOUNT - 1:0] [7:0] squareRGB;
    logic [MONSTER_AMOUNT - 1:0] [3:0] HitEdgeCode;
    logic signed [MONSTER_AMOUNT - 1:0] [10:0] topLeftX;
    logic signed [MONSTER_AMOUNT - 1:0] [10:0] topLeftY;
    logic [MONSTER_AMOUNT - 1:0] monsterIsHit;
    logic [MONSTER_AMOUNT - 1:0] monster_deactivated;
	logic [MONSTER_AMOUNT - 1:0] monster_exploded;
    logic monster_overlap;
    logic [MONSTER_AMOUNT - 1:0] previous_monsterIsHit;
    logic [MONSTER_AMOUNT - 1:0] shooting_pusle;
	logic [MONSTER_AMOUNT - 1:0] monster_amount;
    logic [MONSTER_AMOUNT-1:0] missiles_draw_requests;


    genvar i;
    generate
        for (i = 0; i < MONSTER_AMOUNT; i++) begin : generate_monsters
            monsters_move #(.X_SPEED(X_SPEED + ((i>>2) * 8) + i * 2), .Y_SPEED(Y_SPEED + (i * 2)), .INITIAL_X(INITIAL_X + ((i>>2) * X_SPACING)), .INITIAL_Y(INITIAL_Y + ((2'(i) & 2'b11) * 64))) monsters_move_inst(
                .clk(clk),
                .resetN(resetN),
                .missile_collision(collision[0] & previousDR[i]),
                .border_collision((monster_overlap | collision[1]) & previousDR[i]),
                .startOfFrame(startOfFrame & enable & (i < monster_amount)),
                .HitEdgeCode(HitEdgeCode[i]),
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

            shooting_cooldown #(.SHOOTING_COOLDOWN(60 + ((i>>2) * 2) + i)) shooting_cooldown_inst(
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
    logic [10:0] chosen_offsetX;
    logic [10:0] chosen_offsetY;
    logic chosen_monster_is_hit;
    logic [MONSTER_AMOUNT_WIDTH - 1:0] chosen_monster_index;

    // Check if there is an overlap of monsters in this space
    check_overlap #(.OBJECT_AMOUNT_WIDTH(MONSTER_AMOUNT_WIDTH), .OBJECT_AMOUNT(MONSTER_AMOUNT)) check_overlap_inst(
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
    always_comb begin
		monster_amount <= MONSTER_AMOUNT;
		if(stage_num == 1) begin
			monster_amount <= FIRST_STAGE_AMOUNT;
		end
		if(stage_num == 2) begin
			monster_amount <= SECOND_STAGE_AMOUNT;
		end
		if(stage_num == 4) begin
			monster_amount <= BOSS_STAGE_AMOUNT;
		end
	end


    assign missleRGB = 8'hD0;
    assign missleDR = (missiles_draw_requests != 0);

    // Only raise all_monsters_dead if monster_deactivated is all 1s
    assign all_monsters_dead = &monster_deactivated;

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
