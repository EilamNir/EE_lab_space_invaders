/* asteroids module

	combines and controls the speed, location and draw request of all the asteroids

	the asteroids will be initialzed to a certian number of groups, 
	each group has a starting pattern which will change randomly duo to coliisions
	the asteroids has a gravity effect that makes them go faster throw time until a max speed limit
	
	two important outpouts are that one asteroid exploded and all of the asteroids exploded
	all asteroids exploded will be use for determine that a stage is over (win stage)
	
written by Nir Eilam and Gil Kapel, May 18th, 2021 */

module asteroids(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] collision,
    input coordinate pixelX,
    input coordinate pixelY,

    output logic asteroidsDR,
	output logic asteroid_exploded_pulse,
	output logic all_asteroids_destroied,
    output RGB asteroidsRGB
);

    `include "parameters.sv"

    coordinate [ASTEROIDS_AMOUNT - 1:0] offsetX;
    coordinate [ASTEROIDS_AMOUNT - 1:0] offsetY;
    logic [ASTEROIDS_AMOUNT - 1:0] silhouetteDR;
    edge_code HitEdgeCode;
    logic [ASTEROIDS_AMOUNT - 1:0] asteroidIsHit;
    logic [ASTEROIDS_AMOUNT - 1:0] asteroids_deactivated;
    logic [ASTEROIDS_AMOUNT - 1:0] previous_asteroidIsHit;

    genvar i;
    generate
        for (i = 0; i < ASTEROIDS_AMOUNT; i++) begin : generate_asteroids
            asteroid #(
                .X_SPEED(fixed_point'(ASTEROIDS_X_SPEED - ((i>>2) * 8) + i * 2)),
                .Y_SPEED(fixed_point'(ASTEROIDS_Y_SPEED + (2'(i) & 2'b11) * 16)),
                .INITIAL_X(coordinate'(ASTEROIDS_INITIAL_X + (((i>>2) * ASTEROIDS_X_SPACING) - ((2'(i) & 2'b11) * 4)))),
                .INITIAL_Y(coordinate'(ASTEROIDS_INITIAL_Y + (2'(i) & 2'b11) * ASTEROIDS_Y_SPACING))
            ) asteroid_inst(
                .clk(clk),
                .resetN(resetN),
                .collision(collision),
                .startOfFrame(startOfFrame & (enable)),
                .pixelX(pixelX),
                .pixelY(pixelY),
                .HitEdgeCode(HitEdgeCode),
                .asteroidIsHit(asteroidIsHit[i]),
                .offsetX(offsetX[i]),
                .offsetY(offsetY[i]),
                .asteroidDR(silhouetteDR[i]),
                .asteroid_deactivated(asteroids_deactivated[i])
                );
        end
    endgenerate

    // Decide on which square object to pass into the bitmap
    logic chosen_asteroid_DR;
    coordinate chosen_offsetX;
    coordinate chosen_offsetY;
    logic chosen_asteroids_is_hit;
    always_comb begin
        chosen_asteroid_DR = 1'b0;
        chosen_offsetX = 11'b0;
        chosen_offsetY = 11'b0;
        chosen_asteroids_is_hit = 1'b0;
        for (logic unsigned [ASTEROIDS_AMOUNT_WIDTH-1:0] j = 0; j < ASTEROIDS_AMOUNT; j++) begin
            // Only save the offset of the first asteroid
            if (silhouetteDR[j] == 1'b1) begin
                // Ignore deactivated asteroids
                if (asteroids_deactivated[j] == 1'b0) begin
                    chosen_asteroid_DR = 1'b1;
                    chosen_offsetX = offsetX[j];
                    chosen_offsetY = offsetY[j];
                    chosen_asteroids_is_hit = asteroidIsHit[j];
                    break;
                end
            end
        end
    end

    asteroidBitMap asteroidBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_offsetX),
        .offsetY(chosen_offsetY),
        .asteroidIsHit(chosen_asteroids_is_hit),
        .InsideRectangle(chosen_asteroid_DR),
        .drawingRequest(asteroidsDR),
        .RGBout(asteroidsRGB),
        .HitEdgeCode(HitEdgeCode)
    );

    assign all_asteroids_destroied = &asteroids_deactivated;

    // Send a pulse when an asteroid explodes
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            previous_asteroidIsHit <= 0;
        end else begin
            previous_asteroidIsHit <= asteroidIsHit;
        end
    end
    assign asteroid_exploded_pulse = (asteroidIsHit != previous_asteroidIsHit);
	

endmodule
