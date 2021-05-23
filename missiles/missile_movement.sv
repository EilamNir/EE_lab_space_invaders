
module  missile_movement
(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic shooting_pulse,
    input logic collision,
    input logic [3:0] HitEdgeCode,

    input logic [PIXEL_WIDTH - 1:0] spaceShip_X,
    input logic [PIXEL_WIDTH - 1:0] spaceShip_Y,

    output logic signed [PIXEL_WIDTH - 1:0]  topLeftX, // output the top left corner
    output logic signed [PIXEL_WIDTH - 1:0]  topLeftY,  // can be negative , if the object is partly outside
    output logic missile_active
);
    parameter int X_SPEED = 0;
    parameter int Y_SPEED = -256;
    parameter unsigned PIXEL_WIDTH = 11;

    parameter logic signed [PIXEL_WIDTH - 1:0] X_OFFSET = 15;
    parameter logic signed [PIXEL_WIDTH - 1:0] Y_OFFSET = 0;

    const int   FIXED_POINT_MULTIPLIER  =   64;
    // FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
    // we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calculations,
    // we divide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

    logic shot_fired;
    int topLeftX_FixedPoint;
    int topLeftY_FixedPoint;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            topLeftX_FixedPoint <= 0;
            topLeftY_FixedPoint <= 0;
            shot_fired <= 1'b0;
            missile_active <= 1'b0;
        end else begin

            if (collision) begin
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
                    topLeftY_FixedPoint  <= topLeftY_FixedPoint + Y_SPEED;
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
    assign  topLeftX = PIXEL_WIDTH'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = PIXEL_WIDTH'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);

    // Send a short pulse when activating the missile

endmodule
