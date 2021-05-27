
module  player_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic move_left,
    input logic move_right,
    input logic move_up,
    input logic move_down,
    input logic border_collision,
    input logic [3:0] HitEdgeCode,

    output logic signed [PIXEL_WIDTH - 1:0] topLeftX, // output the top left corner
    output logic signed [PIXEL_WIDTH - 1:0] topLeftY  // can be negative , if the object is partly outside
);

    `include "parameters.sv"

    parameter int INITIAL_X = 300;
    parameter int INITIAL_Y = 400;
    parameter int MIN_HEIGHT= 280;
    parameter int MAX_HEIGHT= 450;
    // TODO: Decide on a speed. If we use a multiplication of 64, the speed will be a multiplication
    // of a full pixel, so if we decide to change the speed to such a multiplication, we should also
    // change this module to not use enhanced precision and just work with pixels directly.
    parameter int X_SPEED = 128;
    parameter int Y_SPEED = 128;
    parameter unsigned PIXEL_WIDTH = 11;

    const int   FIXED_POINT_MULTIPLIER  =   64;
    // FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
    // we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calculations,
    // we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

    int Xspeed, topLeftX_FixedPoint; // local parameters
    int Yspeed, topLeftY_FixedPoint;
    // Flags to remember collision with a wall. The flags are {left border, ceiling, right border, ground}.
    logic [3:0] border_collision_flags;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Xspeed  <= 0;
            Yspeed  <= 0;
            topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
            topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
            border_collision_flags <= 4'b0;
        end else begin			
            // Control the speed in the Y direction
            if (move_down && (!move_up) && (!border_collision_flags[0])) begin
                Yspeed <= Y_SPEED;
            end else if (move_up && (!move_down) && (!border_collision_flags[2])) begin
                Yspeed <= -Y_SPEED;
            end else begin
                Yspeed <= 0;
            end

            // Control the speed in the X direction
            if (move_right && (!move_left) && (!border_collision_flags[1])) begin
                Xspeed <= X_SPEED;
            end else if (move_left && (!move_right) && (!border_collision_flags[3])) begin
                Xspeed <= -X_SPEED;
            end else begin
                Xspeed <= 0;
            end

            // Remember collisions with the borders
            if (border_collision) begin
                border_collision_flags <= border_collision_flags | HitEdgeCode;
            end

            // Change the location according to the speed
            if (startOfFrame == 1'b1) begin
                topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
                topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
                // Reset collision flags for next frame
                border_collision_flags <= 4'b0;
            end
        end
    end
    //get a better (64 times) resolution using integer
    assign  topLeftX = PIXEL_WIDTH'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = PIXEL_WIDTH'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule
