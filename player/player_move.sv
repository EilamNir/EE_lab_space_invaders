
module  player_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic move_left,
    input logic move_right,
    input logic move_up,
    input logic move_down,
	input logic [3:0] collision,
	input logic [3:0] HitEdgeCode,
	
    output logic signed [PIXEL_WIDTH - 1:0] topLeftX, // output the top left corner
    output logic signed [PIXEL_WIDTH - 1:0] topLeftY  // can be negative , if the object is partliy outside

);

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
    // we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
    // we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions

    int Xspeed, topLeftX_FixedPoint; // local parameters
    int Yspeed, topLeftY_FixedPoint;
	logic [1:0] border_flags;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Xspeed  <= 0;
            Yspeed  <= 0;
            topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
            topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;

        end else begin
			if(startOfFrame) border_flags <= 2'b11;
            // Control the speed in the Y direction
            if ((move_up ^ move_down) == 1'b0)
                Yspeed <= 0;
            else if (move_down)
                Yspeed <= Y_SPEED;
            else
                Yspeed <= -Y_SPEED;

            // Control the speed in the X direction
            if ((move_left ^ move_right) == 1'b0)
                Xspeed <= 0;
            else if (move_right)
                Xspeed <= X_SPEED;
            else
                Xspeed <= -X_SPEED;

            // Change the location according to the speed
            if (startOfFrame == 1'b1 && border_flags[0] && border_flags[1]) begin
                topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
                topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
            end
			
//-------------collisions---------------///
		if(collision[3]) begin
			if (HitEdgeCode[2] == 1) begin  // player hit the border
				if (Yspeed < 0) // while moving up
					border_flags[0] <= 1'b0;
					Yspeed <= 0;
			end
			if (HitEdgeCode[0] == 1) begin // player hit the border 
				if (Yspeed > 0 )   //  while moving down
					border_flags[0] <= 1'b0 ; 
			end
			if (HitEdgeCode[3] == 1) begin  //player hit the border
				if (Xspeed < 0 ) // while moving left
					border_flags[1] <= 1'b0 ; // positive move right 
					Xspeed <= 0;
			end
			if (HitEdgeCode[1] == 1) begin   
				if (Xspeed > 0 ) //  while moving right
					border_flags[1] <= 1'b0  ;  // negative move left
					Xspeed <= 0;					
			end
		end
		
        end
    end

    //get a better (64 times) resolution using integer
    assign  topLeftX = PIXEL_WIDTH'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = PIXEL_WIDTH'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule
