/* Missile movement module
	determine the coordinates to draw the next shot duo to speed, current position or collisions with other objects
written by Nir Eilam and Gil Kapel, May 30th, 2021 */

module  missile_movement
(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic shooting_pulse,
    input logic collision,
    input edge_code HitEdgeCode,

    input coordinate spaceShip_X,
    input coordinate spaceShip_Y,
    input logic double_y_speed,

    output coordinate  topLeftX, // output the top left corner
    output coordinate  topLeftY,  // can be negative , if the object is partly outside
    output logic missile_active
);

    `include "parameters.sv"

    parameter fixed_point X_SPEED;
    parameter fixed_point Y_SPEED;

    parameter coordinate X_OFFSET;
    parameter coordinate Y_OFFSET;

    logic shot_fired;
    fixed_point topLeftX_FixedPoint;
    fixed_point topLeftY_FixedPoint;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            topLeftX_FixedPoint <= 0;
            topLeftY_FixedPoint <= 0;
            shot_fired <= 1'b0;
            missile_active <= 1'b0;
        end else begin

            if (collision || (topLeftY_FixedPoint < 0)) begin
                topLeftX_FixedPoint <= 0;
                topLeftY_FixedPoint <= 0;
                // Remove the missile from the screen
                missile_active <= 1'b0;
            end

            if (startOfFrame == 1'b1 ) begin
                // Reset the shot fired for the next frame
                shot_fired <= 1'b0;
                if (shot_fired == 1'b1) begin
                    // If a shot was fired, move the missile to the player location
                    topLeftX_FixedPoint <= (spaceShip_X + X_OFFSET) * FIXED_POINT_MULTIPLIER;
                    topLeftY_FixedPoint <= (spaceShip_Y + Y_OFFSET) * FIXED_POINT_MULTIPLIER;
                    // Add the missile to the screen
                    missile_active <= 1'b1;
                end else if (missile_active == 1'b1) begin
                    // If no shot was fired in this frame and the missile is active, move the missile according to its speed
                    topLeftX_FixedPoint  <= topLeftX_FixedPoint + X_SPEED;
                    topLeftY_FixedPoint  <= topLeftY_FixedPoint + (Y_SPEED << double_y_speed);
                end
            end

            // If a shot is fired, raise a flag for the next frame
            // Note: It might be possible that the shooting_pulse is active at the startOfFrame pulse,
            // so we must keep this after the if of startOfFrame, so if both of them are sent at the same time,
            // the shot_fired will still be set for the next frame.
            if (shooting_pulse == 1'b1) begin
                shot_fired <= 1'b1;
            end
        end
    end
    //get a better (64 times) resolution using integer
    assign  topLeftX = coordinate'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = coordinate'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);

    // Send a short pulse when activating the missile

endmodule
