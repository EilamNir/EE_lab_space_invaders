
module  missile_movement
(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic shotKeyIsPress,
    input logic collision,

    // inputs to make this work for multiple missiles
    input logic signed [FIXED_POINT_WIDTH - 1:0] current_location_x,
    input logic signed [FIXED_POINT_WIDTH - 1:0] current_location_y,
    input logic signed [FIXED_POINT_WIDTH - 1:0] current_speed_x,
    input logic signed [FIXED_POINT_WIDTH - 1:0] current_speed_y,
    input logic current_missile_active,
    input logic current_shot_fired,

    input logic [PIXEL_WIDTH - 1:0] spaceShip_X,
    input logic [PIXEL_WIDTH - 1:0] spaceShip_Y,

    output logic signed [PIXEL_WIDTH - 1:0]  topLeftX, // output the top left corner
    output logic signed [PIXEL_WIDTH - 1:0]  topLeftY,  // can be negative , if the object is partliy outside

    // outputs to make this work for multiple missiles
    output logic signed [FIXED_POINT_WIDTH - 1:0] new_location_x,
    output logic signed [FIXED_POINT_WIDTH - 1:0] new_location_y,
    output logic signed [FIXED_POINT_WIDTH - 1:0] new_speed_x,
    output logic signed [FIXED_POINT_WIDTH - 1:0] new_speed_y,
    output logic new_missile_active,
    output logic new_shot_fired
);
    parameter unsigned PIXEL_WIDTH = 11;
    parameter unsigned FIXED_POINT_WIDTH = 16;

    parameter signed [PIXEL_WIDTH - 1:0] X_OFFSET = 16;

    const logic [15:0]   FIXED_POINT_MULTIPLIER  =   32;
    // FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
    // we do all calculations with topLeftX_FixedPoint to get a resolution of 1/32 pixel in calcuatuions,
    // we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

    always_ff@(posedge clk or negedge resetN) begin
        if(!resetN) begin
            new_location_x <= 0;
            new_location_y <= 0;
            new_speed_x <= 0;
            new_speed_y <= 0;
        end else begin
            // Default to write disabled and read enabled
            new_location_x <= current_location_x;
            new_location_y <= current_location_y;
            new_speed_x <= current_speed_x;
            new_speed_y <= current_speed_y;
            new_missile_active <= current_missile_active;
            new_shot_fired <= current_shot_fired;

            // If a shot is fired, raise a flag for the next frame
            if (shotKeyIsPress == 1'b1) begin
                new_shot_fired <= 1'b1;
            end
            if (collision == 1'b1) begin
                // Move missile to zero point
                new_location_x <= 0;
                new_location_y <= 0;
                // Remove the missile from the screen
                new_missile_active <= 0;
            end

            // Stuff to deal with only at the start of a frame
            if (startOfFrame == 1'b1 ) begin
                // Reset the shot fired for the next frame
                new_shot_fired <= 1'b0;
                if (current_shot_fired == 1'b1) begin
                    // If a shot was fired, move the missile to the player location
                    new_location_x <= spaceShip_X * FIXED_POINT_MULTIPLIER;
                    new_location_y <= spaceShip_Y * FIXED_POINT_MULTIPLIER;
                    // Add the missile to the screen
                    new_missile_active <= 1;
                end else if (current_missile_active == 1'b1) begin
                    // If no shot was fired in this frame and the missile is active, move the missile according to its speed
                    new_location_x  <= current_location_x + current_speed_x;
                    new_location_y  <= current_location_y + current_speed_y;
                end
            end
        end
    end

    //get a better (32 times) resolution using integer
    assign  topLeftX = PIXEL_WIDTH'(current_location_x / FIXED_POINT_MULTIPLIER) + X_OFFSET;
    assign  topLeftY = PIXEL_WIDTH'(current_location_y / FIXED_POINT_MULTIPLIER);

endmodule
