/* asteroid move module

	control the speed, location and draw request of the asteroid
	the asteroid ignore the middle boundry between the player and the monsters
	if the asteroid was hit by the boundry it will bounced back to the top of the screen,
	if it hits by a missile a singal flag will be raised
	
written by Nir Eilam and Gil Kapel, May 25th, 2021 */

module  asteroids_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic player_collision,
    input logic border_collision,
    input edge_code HitEdgeCode,

    output logic asteroidIsHit,
    output coordinate topLeftX, // output the top left corner
    output coordinate topLeftY  // can be negative , if the object is partliy outside

);

    `include "parameters.sv"

    parameter coordinate INITIAL_X;
    parameter coordinate INITIAL_Y;
    parameter fixed_point X_SPEED;
    parameter fixed_point Y_SPEED;

    fixed_point Xspeed, topLeftX_FixedPoint; // local parameters
    fixed_point Yspeed, topLeftY_FixedPoint;

    logic unsigned [ASTEROIDS_MOVE_GRAVITY_COUNTER_WIDTH - 1:0] gravity_counter;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Xspeed  <= X_SPEED;
            Yspeed  <= Y_SPEED;
            topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
            topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
            asteroidIsHit <= 0;
            gravity_counter <= 0;
        end else begin

            if(asteroidIsHit || player_collision) begin
                // If the asteroid was hit by a missile, stop it
                asteroidIsHit <= 1'b1;
                Xspeed  <= 0;
                Yspeed  <= 0;
            end

            // Check border collisions
            if (border_collision) begin
                if (((HitEdgeCode [TOP_EDGE] == 1) && (Yspeed < 0)) || // asteroid hit ceiling while moving up
                    ((HitEdgeCode [BOTTOM_EDGE] == 1) && (Yspeed > 0))) begin // asteroid hit ground while moving down
                    topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
                end
                if (((HitEdgeCode [LEFT_EDGE] == 1) && (Xspeed < 0 )) || //asteroid got to the left border while moving left
                    ((HitEdgeCode [RIGHT_EDGE] == 1) && (Xspeed > 0))) begin //asteroid got to the right border while moving right
                    topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
					topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
                end
            end

            // Change the location according to the speed
            if (startOfFrame == 1'b1) begin
                topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
                topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
                // Add gravity to asteroid every frame
                if (Yspeed < Y_SPEED * ASTEROIDS_MOVE_MAXIMUM_SPEED_MULTIPLIER) begin
                    if (gravity_counter < ASTEROIDS_MOVE_FRAMES_WITHOUT_GRAVITY) begin
                        gravity_counter <= gravity_counter + 1'b1;
                    end else begin
                        gravity_counter <= 0;
                        Yspeed <= Yspeed + 1'b1;
                    end
                end
            end
        end
    end

    //get a better (64 times) resolution using integer
    assign  topLeftX = coordinate'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = coordinate'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule



