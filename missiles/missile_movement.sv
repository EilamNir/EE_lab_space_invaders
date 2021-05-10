
module  missile_movement
(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic shotKeyIsPress,
	input logic [3:0] collision,
	input logic [3:0] HitEdgeCode,
	
    input logic [PIXEL_WIDTH - 1:0] spaceShip_X,
    input logic [PIXEL_WIDTH - 1:0] spaceShip_Y,

    output logic signed [PIXEL_WIDTH - 1:0]  topLeftX, // output the top left corner
    output logic signed [PIXEL_WIDTH - 1:0]  topLeftY  // can be negative , if the object is partliy outside
);
    parameter int X_SPEED = 0;
    parameter int Y_SPEED = -256;
    parameter unsigned PIXEL_WIDTH = 11;
	
	const int X_OFFSET = 16;

    const int   FIXED_POINT_MULTIPLIER  =   64;
    // FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that
    // we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
    // we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

	logic hit_cieling;
    logic shot_fired;
    int topLeftX_FixedPoint;
    int topLeftY_FixedPoint;
	
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            topLeftX_FixedPoint <= 0;
            topLeftY_FixedPoint <= 0;
            shot_fired <= 1'b0;
			hit_cieling <= 1'b0;
        end else begin
            // If a shot is fired, raise a flag for the next frame
			if (shotKeyIsPress == 1'b1) begin
                shot_fired <= 1'b1;
            end
			if (collision[0] == 1'b1) begin
				topLeftX_FixedPoint <= 0;
				topLeftY_FixedPoint <= 0;
				shot_fired <= 1'b0;
			end
			if (collision[2] == 1'b1) begin
				topLeftX_FixedPoint <= 0;
				topLeftY_FixedPoint <= 0;
				hit_cieling <= 1'b1;
			end
            if (startOfFrame == 1'b1 ) begin
                // Reset the shot fired for the next frame
                hit_cieling <= 1'b1;
				shot_fired <= 1'b0;
                if (shot_fired == 1'b1 && hit_cieling == 1'b1) begin
                    // If a shot was fired, move the missile duo to the player location
                    topLeftX_FixedPoint <= spaceShip_X * FIXED_POINT_MULTIPLIER;
                    topLeftY_FixedPoint <= spaceShip_Y * FIXED_POINT_MULTIPLIER;
                end else begin
                    // If no shot was fired, move the missile according to its speed
                    topLeftX_FixedPoint  <= topLeftX_FixedPoint + X_SPEED;
                    topLeftY_FixedPoint  <= topLeftY_FixedPoint + Y_SPEED;
                end
            end
        end
    end
    //get a better (64 times) resolution using integer
    assign  topLeftX = PIXEL_WIDTH'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER) + X_OFFSET;
    assign  topLeftY = PIXEL_WIDTH'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule
