
module  monsters_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
	input logic [3:0] collision,
	input logic [3:0] HitEdgeCode,

	output logic monsterIsHit,
    output logic signed [PIXEL_WIDTH - 1:0] topLeftX, // output the top left corner
    output logic signed [PIXEL_WIDTH - 1:0] topLeftY  // can be negative , if the object is partliy outside

);
	parameter int INITIAL_X = 300;
	parameter int INITIAL_Y = 200;

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


    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Xspeed  <= 0;
            Yspeed  <= 0;
            topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
            topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
			monsterIsHit <= 0;

        end else begin
			if(~monsterIsHit) begin
				Xspeed  <= X_SPEED;
				Yspeed  <= Y_SPEED;
			end else begin
				Xspeed  <= 0;
				Yspeed  <= 0;
			end if (collision[0]) //monster was hit by a missile
				monsterIsHit <= 1'b1;
		if ((collision[1] && HitEdgeCode [2] == 1 )) begin  // monster hit border  
			if (Yspeed < 0) // while moving up
				Yspeed <= -Yspeed ; 
			
			if ((collision[1] && HitEdgeCode [0] == 1 )) begin // || (collision && HitEdgeCode [1] == 1 ))   
				if (Yspeed > 0 )//  while moving down
					Yspeed <= -Yspeed ; 
			end
	    end
	
		if (collision[1] && HitEdgeCode [3] == 1) begin  //monster got to the boarder
			if (Xspeed < 0 ) // while moving left
				Xspeed <= -Xspeed ; // positive move right 
		
			if (collision[1] && HitEdgeCode [1] == 1 ) begin   
				if (Xspeed > 0 ) //  while moving right
					Xspeed <= -Xspeed  ;  // negative move left    
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
    assign  topLeftX = PIXEL_WIDTH'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = PIXEL_WIDTH'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule



