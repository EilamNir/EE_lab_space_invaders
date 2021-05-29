/* monster module

	control the speed, location and draw request of a monster
	control the missiles the monster by the missile unit

    the monster does not output an RGB to make all the monsters use
    only one big bitmap, and each monster only uses a silhouette for
    draw request purposes

written by Nir Eilam and Gil Kapel, May 18th, 2021 */


module monster(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
	input logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] collision,
    input coordinate pixelX,
    input coordinate pixelY,
    input logic [SHOOTING_COOLDOWN_WIDTH - 1:0] shooting_cooldown,
    input logic monster_overlap,
    input logic random_bit,

    output logic monsterDR,
    output logic missleDR,

    output coordinate offsetX,
    output coordinate offsetY,

    output logic monsterIsHit,
    output logic monster_exploded
);

    `include "parameters.sv"

    parameter fixed_point X_SPEED;
    parameter fixed_point Y_SPEED;
    parameter coordinate INITIAL_X;
    parameter coordinate INITIAL_Y;

    logic previousDR;
    logic squareDR;
    edge_code HitEdgeCode;
    coordinate topLeftX;
    coordinate topLeftY;
    logic shooting_pusle;


    // Deal with monster movement
    monsters_move #(
        .X_SPEED(X_SPEED),
        .Y_SPEED(Y_SPEED),
        .INITIAL_X(INITIAL_X),
        .INITIAL_Y(INITIAL_Y)
    ) monsters_move_inst(
        .clk(clk),
        .resetN(resetN),
        .missile_collision(collision[COLLISION_ENEMY_MISSILE] & previousDR),
        .border_collision((monster_overlap | collision[COLLISION_ENEMY_ANY_BOUNDARY]) & previousDR),
        .startOfFrame(startOfFrame),
        .HitEdgeCode(HitEdgeCode),
        .random_bit(random_bit),
        .monsterIsHit(monsterIsHit),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );

    // Deal with monster draw request, specifically use a monster silhouette to determine the
    // draw request of a monster in every pixel
    square_object #(
        .OBJECT_WIDTH_X(MONSTERS_X_SIZE),
        .OBJECT_HEIGHT_Y(MONSTERS_Y_SIZE))
    square_object_inst(
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .drawingRequest(squareDR)
        );
    chicken_silhouette chicken_silhouette_inst(
        .clk            (clk),
        .resetN         (resetN),
        .offsetX        (offsetX),
        .offsetY        (offsetY),
        .InsideRectangle(squareDR),
        .monsterIsHit   (monsterIsHit),
        .HitEdgeCode    (HitEdgeCode),
        .drawingRequest (monsterDR)
        );

    // Delay the vanishing of the monster so the explosion will be visible
    delay_signal_by_frames #(
        .DELAY_FRAMES_AMOUNT(MONSTERS_EXPLOSION_DELAY))
    delay_signal_by_frames_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame),
        .input_signal(monsterIsHit),
        .output_signal(monster_exploded)
        );

    // Have a cooldown between shooting, so the monster will not shoot continuously
    shooting_cooldown shooting_cooldown_inst(
        .clk           (clk),
        .resetN        (resetN),
        .startOfFrame  (startOfFrame),
        .fire_command  (~(monsterIsHit)),
        .shooting_cooldown(shooting_cooldown),
        .shooting_pusle(shooting_pusle)
        );

    // Shoot a missile from the monster
    missiles #(
        .SHOT_AMOUNT(MONSTERS_SHOT_AMOUNT),
        .X_SPEED(MONSTERS_MISSILE_X_SPEED),
        .Y_SPEED(MONSTERS_MISSILE_Y_SPEED),
        .X_OFFSET(MONSTERS_MISSILE_X_OFFSET),
        .Y_OFFSET(MONSTERS_MISSILE_Y_OFFSET),
        .MISSILE_COLOR(MONSTERS_MISSILE_COLOR))
    missiles_inst (
        .clk            (clk),
        .resetN         (resetN),
        .shooting_pusle (shooting_pusle),
        .startOfFrame   (startOfFrame),
        .collision      ((collision[COLLISION_PLAYER_MISSILE] | collision[COLLISION_MISSILE_FAR_BOUNDARY])),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .spaceShip_X    (topLeftX),
        .spaceShip_Y    (topLeftY),
        .double_y_speed (1'b0),
        .missleDR       (missleDR)
        );

    // Remember the previous draw requests, for collision detection
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previousDR <= 0;
        end else begin
            previousDR <= monsterDR;
        end
    end

endmodule
