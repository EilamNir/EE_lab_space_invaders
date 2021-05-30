/* monsters module

    combines and chooses the speed, location and draw request of all the monsters.

	the monsters will be initialzed to a certian number of groups, 
	each group has a starting pattern which will change randomly duo to coliisions
	
	two important outpouts are that one monster died and all of the monster died
	all monsters died will be used to determine that a stage is over (win stage)

written by Nir Eilam and Gil Kapel, May 18th, 2021 */


module monsters(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input collision_t collision,
	input game_stage stage_num,
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

    coordinate [MONSTERS_MAX_MONSTER_AMOUNT - 1:0] offsetX;
    coordinate [MONSTERS_MAX_MONSTER_AMOUNT - 1:0] offsetY;
    logic [MONSTERS_MAX_MONSTER_AMOUNT - 1:0] silhouetteDR;
    logic [MONSTERS_MAX_MONSTER_AMOUNT - 1:0] monsterIsHit;
    logic [MONSTERS_MAX_MONSTER_AMOUNT - 1:0] monster_deactivated;
	logic [MONSTERS_MAX_MONSTER_AMOUNT - 1:0] monster_exploded;
    logic monster_overlap;
    logic [MONSTERS_MAX_MONSTER_AMOUNT - 1:0] previous_monsterIsHit;
    logic [MONSTERS_MAX_MONSTER_AMOUNT-1:0] missiles_draw_requests;
	logic [MONSTERS_MONSTER_AMOUNT_WIDTH - 1:0] monster_amount;
    logic random_bit;

    // Decide how many monsters in every stage
    logic [0:4] [MONSTERS_MONSTER_AMOUNT_WIDTH - 1:0] monsters_per_stage = {
        MONSTERS_MONSTER_AMOUNT_WIDTH'('d0), //leave at zero
        MONSTERS_MONSTER_AMOUNT_WIDTH'('d8),
        MONSTERS_MONSTER_AMOUNT_WIDTH'('d16),
        MONSTERS_MONSTER_AMOUNT_WIDTH'('d0),
        MONSTERS_MONSTER_AMOUNT_WIDTH'('d12)};

    assign monster_amount = monsters_per_stage[stage_num];

    // Generate all monsters
    genvar i;
    generate
        for (i = 0; i < MONSTERS_MAX_MONSTER_AMOUNT; i++) begin : generate_monsters
            monster #(
                .X_SPEED(fixed_point'(MONSTERS_X_SPEED + (i * 2))),
                .Y_SPEED(fixed_point'(MONSTERS_Y_SPEED + ((i>>2) * 8) + i * 2)),
                .INITIAL_X(coordinate'(MONSTERS_INITIAL_X + ((2'(i) & 2'b11) * MONSTERS_X_SPACING))),
                .INITIAL_Y(coordinate'(MONSTERS_INITIAL_Y + ((i>>2) * MONSTERS_Y_SPACING)))
            ) monster_inst (
                .clk(clk),
                .resetN(resetN),
                .startOfFrame(startOfFrame & enable & (i < monster_amount)),
                .collision(collision),
                .pixelX(pixelX),
                .pixelY(pixelY),
                .shooting_cooldown(8'(40 + ((2'(i) & 2'b11) * 2) + (2 * i))),
                .monster_overlap(monster_overlap),
                .random_bit(random_bit),
                .monsterDR(silhouetteDR[i]),
                .missleDR(missiles_draw_requests[i]),
                .offsetX(offsetX[i]),
                .offsetY(offsetY[i]),
                .monsterIsHit(monsterIsHit[i]),
                .monster_exploded(monster_exploded[i])
            );

			assign monster_deactivated[i] = monster_exploded[i] | (i >= monster_amount);
        end
    endgenerate
    
    // Decide if to show a missile on this pixel or not
    assign missleRGB = MONSTERS_MISSILE_COLOR;
    assign missleDR = (missiles_draw_requests != 0);

    // Deal with multiple monsters in the same pixel
    logic chosen_monster_DR;
    coordinate chosen_offsetX;
    coordinate chosen_offsetY;
    logic chosen_monster_is_hit;
    logic [MONSTERS_MONSTER_AMOUNT_WIDTH - 1:0] chosen_monster_index;

    // Check if there is an overlap of monsters in this space
    check_overlap #(
        .OBJECT_AMOUNT_WIDTH(MONSTERS_MONSTER_AMOUNT_WIDTH),
        .OBJECT_AMOUNT(MONSTERS_MAX_MONSTER_AMOUNT)
    ) check_overlap_inst(
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
