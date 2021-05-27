
module  monsters_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic missile_collision,
    input logic border_collision,
    input logic [3:0] HitEdgeCode,
    input logic random_bit,

    output logic monsterIsHit,
    output coordinate topLeftX, // output the top left corner
    output coordinate topLeftY  // can be negative , if the object is partliy outside

);

    `include "parameters.sv"

    parameter coordinate INITIAL_X = coordinate'(300);
    parameter coordinate INITIAL_Y = coordinate'(200);

    // TODO: Decide on a speed. If we use a multiplication of 64, the speed will be a multiplication
    // of a full pixel, so if we decide to change the speed to such a multiplication, we should also
    // change this module to not use enhanced precision and just work with pixels directly.
    parameter fixed_point X_SPEED = fixed_point'(8);
    parameter fixed_point Y_SPEED = fixed_point'(0);

    const fixed_point FIXED_POINT_MULTIPLIER = 64;
    // FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
    // we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
    // we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

    fixed_point Xspeed, topLeftX_FixedPoint; // local parameters
    fixed_point Yspeed, topLeftY_FixedPoint;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Xspeed  <= X_SPEED;
            Yspeed  <= Y_SPEED;
            topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
            topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
            monsterIsHit <= 0;
        end else begin

            if(monsterIsHit || missile_collision) begin
                // If the monster was hit by a missile, stop it
                monsterIsHit <= 1'b1;
                Xspeed  <= 0;
                Yspeed  <= 0;
            end

            // Check border collisions
            if (border_collision) begin
                if (((HitEdgeCode [2] == 1) && (Yspeed < 0)) || // monster hit ceiling while moving up
                    ((HitEdgeCode [0] == 1) && (Yspeed > 0))) begin // monster hit ground while moving down
                    Yspeed <= -Yspeed;
                    // Randomize the direction of the x speed
                    if (random_bit) begin
                        Xspeed <= -Xspeed;
                    end
                end
                if (((HitEdgeCode [3] == 1) && (Xspeed < 0 )) || //monster got to the left border while moving left
                    ((HitEdgeCode [1] == 1) && (Xspeed > 0))) begin //monster got to the right border while moving right
                    Xspeed <= -Xspeed;
                    // Randomize the direction of the x speed
                    if (random_bit) begin
                        Yspeed <= -Yspeed;
                    end
                end
            end

            // Change the location according to the speed
            if (startOfFrame == 1'b1) begin
                topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
                topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
            end
        end
    end

    //get a better (64 times) resolution using integer
    assign  topLeftX = coordinate'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = coordinate'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule



