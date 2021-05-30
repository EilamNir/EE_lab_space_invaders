/* asteroid module

    control the speed, location and draw request of an asteroid

written by Nir Eilam and Gil Kapel, May 18th, 2021 */

module asteroid(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
    input collision_t collision,

    input coordinate pixelX,
    input coordinate pixelY,
    input edge_code HitEdgeCode,

    output coordinate offsetX,
    output coordinate offsetY,

    output logic asteroidDR,
    output logic asteroidIsHit,
    output logic asteroid_deactivated

);

    `include "parameters.sv"

    parameter fixed_point X_SPEED;
    parameter fixed_point Y_SPEED;
    parameter coordinate INITIAL_X;
    parameter coordinate INITIAL_Y;

    logic squareDR;
    logic previous_asteroidDR;
    coordinate topLeftX;
    coordinate topLeftY;

    // Deal with asteroid movement
    asteroids_move #(
        .X_SPEED(X_SPEED),
        .Y_SPEED(Y_SPEED),
        .INITIAL_X(INITIAL_X),
        .INITIAL_Y(INITIAL_Y)
    ) asteroids_move_inst(
        .clk(clk),
        .resetN(resetN),
        .player_collision(collision[COLLISION_ENEMY_MISSILE] & previous_asteroidDR),
        .border_collision(collision[COLLISION_ENEMY_FAR_BOUNDARY] & previous_asteroidDR),
        .startOfFrame(startOfFrame),
        .HitEdgeCode(HitEdgeCode),
        .asteroidIsHit(asteroidIsHit),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY)
        );

    // Deal with asteroid draw request, specifically use an asteroid silhouette to determine the
    // draw request of a asteroid in every pixel
    square_object #(
        .OBJECT_WIDTH_X(ASTEROIDS_X_SIZE),
        .OBJECT_HEIGHT_Y(ASTEROIDS_Y_SIZE))
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

    asteroid_silhouette asteroid_silhouette_inst(
        .clk            (clk),
        .resetN         (resetN),
        .offsetX        (offsetX),
        .offsetY        (offsetY),
        .InsideRectangle(squareDR),
        .asteroidIsHit  (asteroidIsHit),
        .drawingRequest (asteroidDR)
        );

    // Delay the vanishing of the asteroid so the explosion will be visible
    delay_signal_by_frames #(
        .DELAY_FRAMES_AMOUNT(ASTEROIDS_EXPLOSION_DELAY))
    delay_signal_by_frames_inst(
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame),
        .input_signal(asteroidIsHit),
        .output_signal(asteroid_deactivated)
        );

    // Remember the previous draw requests, for collision detection
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previous_asteroidDR <= 0;
        end else begin
            previous_asteroidDR <= asteroidDR;
        end
    end
    
endmodule
