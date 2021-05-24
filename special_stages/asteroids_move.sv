
module  asteroids_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic player_collision,
    input logic border_collision,
    input logic [3:0] HitEdgeCode,

    output logic asteroidIsHit,
    output logic signed [PIXEL_WIDTH - 1:0] topLeftX, // output the top left corner
    output logic signed [PIXEL_WIDTH - 1:0] topLeftY  // can be negative , if the object is partliy outside

);
    parameter int INITIAL_X = 50;
    parameter int INITIAL_Y = 50;

    // TODO: Decide on a speed. If we use a multiplication of 64, the speed will be a multiplication
    // of a full pixel, so if we decide to change the speed to such a multiplication, we should also
    // change this module to not use enhanced precision and just work with pixels directly.
    parameter int X_SPEED = 8;
    parameter int Y_SPEED = 0;
    parameter unsigned PIXEL_WIDTH = 11;

    const int   FIXED_POINT_MULTIPLIER  =   64;
    // FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
    // we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
    // we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

    int Xspeed, topLeftX_FixedPoint; // local parameters
    int Yspeed, topLeftY_FixedPoint;
    int gravity_counter;
    const int FRAMES_WITHOUT_GRAVITY = 5;

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
                if (((HitEdgeCode [2] == 1) && (Yspeed < 0)) || // asteroid hit ceiling while moving up
                    ((HitEdgeCode [0] == 1) && (Yspeed > 0))) begin // asteroid hit ground while moving down
                    topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
                end
                if (((HitEdgeCode [3] == 1) && (Xspeed < 0 )) || //asteroid got to the left border while moving left
                    ((HitEdgeCode [1] == 1) && (Xspeed > 0))) begin //asteroid got to the right border while moving right
                    topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
					topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
                end
            end

            // Change the location according to the speed
            if (startOfFrame == 1'b1) begin
                topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
                topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
                // Add gravity to asteroid every frame
                if (Yspeed < Y_SPEED * 3) begin
                    if (gravity_counter < FRAMES_WITHOUT_GRAVITY) begin
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
    assign  topLeftX = PIXEL_WIDTH'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = PIXEL_WIDTH'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule



