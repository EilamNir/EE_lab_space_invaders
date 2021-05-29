/* player move module
	control the speed, location and draw request of the player
	this module will handle the case of multiple keys pressed by cancel or sum the signals
written by Nir Eilam and Gil Kapel, May 18th, 2021 */

module  player_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic move_left,
    input logic move_right,
    input logic move_up,
    input logic move_down,
    input logic border_collision,
    input edge_code HitEdgeCode,

    output coordinate topLeftX, // output the top left corner
    output coordinate topLeftY  // can be negative , if the object is partly outside
);

    `include "parameters.sv"

    fixed_point Xspeed, topLeftX_FixedPoint; // local parameters
    fixed_point Yspeed, topLeftY_FixedPoint;
    // Flags to remember collision with a wall. The flags are {left border, ceiling, right border, ground}.
    edge_code border_collision_flags;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Xspeed  <= 0;
            Yspeed  <= 0;
            topLeftX_FixedPoint <= PLAYER_INITIAL_X * FIXED_POINT_MULTIPLIER;
            topLeftY_FixedPoint <= PLAYER_INITIAL_Y * FIXED_POINT_MULTIPLIER;
            border_collision_flags <= 4'b0;
        end else begin			
            // Control the speed in the Y direction
            if (move_down && (!move_up) && (!border_collision_flags[BOTTOM_EDGE])) begin
                Yspeed <= PLAYER_Y_SPEED;
            end else if (move_up && (!move_down) && (!border_collision_flags[TOP_EDGE])) begin
                Yspeed <= -PLAYER_Y_SPEED;
            end else begin
                Yspeed <= 0;
            end

            // Control the speed in the X direction
            if (move_right && (!move_left) && (!border_collision_flags[RIGHT_EDGE])) begin
                Xspeed <= PLAYER_X_SPEED;
            end else if (move_left && (!move_right) && (!border_collision_flags[LEFT_EDGE])) begin
                Xspeed <= -PLAYER_X_SPEED;
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
    assign  topLeftX = coordinate'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = coordinate'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule
