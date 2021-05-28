
module  gift_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic collision,
    input logic random_location,

    output logic giftIsHit,
    output coordinate topLeftX, // output the top left corner
    output coordinate topLeftY  // can be negative , if the object is partliy outside

);

    `include "parameters.sv"

    parameter coordinate INITIAL_X;
    parameter coordinate ALTERNATIVE_X;
    parameter coordinate INITIAL_Y;
    parameter fixed_point Y_SPEED;

    fixed_point Yspeed, topLeftY_FixedPoint;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Yspeed  <= Y_SPEED;
            topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
            giftIsHit <= 0;
        end else begin

            if(giftIsHit || collision) begin
                // If the gift was hit by a missile, stop it
                giftIsHit <= 1'b1;
                Yspeed  <= 0;
            end

            // Change the location according to the speed
            if (startOfFrame == 1'b1) begin
                topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
            end
        end
    end

    //get a better (64 times) resolution using integer
    assign  topLeftX = random_location ? INITIAL_X : ALTERNATIVE_X;
    assign  topLeftY = coordinate'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule


