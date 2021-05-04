
module	player_move	(	
 
    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz 
    input logic move_left,  
    input logic move_right,
	input logic move_up,  
    input logic move_down,
    
    output logic signed [10:0] topLeftX, // output the top left corner 
    output logic signed [10:0] topLeftY  // can be negative , if the object is partliy outside 
					
);

	parameter int INITIAL_X = 240;
	parameter int INITIAL_Y = 580;
	parameter int X_SPEED = 10;
	parameter int Y_SPEED = 10;

	const int	FIXED_POINT_MULTIPLIER	=	64;
	// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
	// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
	// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
	const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
	const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
	const int	bracketOffset =	30;
	const int   OBJECT_WIDTH_X = 64;
	
	int Xspeed, topLeftX_FixedPoint; // local parameters 
	int Yspeed, topLeftY_FixedPoint;
	
	
	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN) begin 
			Xspeed	<= 0;
			Yspeed	<= 0;
			topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
			topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
	
		end 
		
		if (move_up)          Yspeed <= -Y_SPEED;
		else if (~move_up)    Yspeed <= 0;	
							
		if (move_down)        Yspeed <= Y_SPEED;
		else if (~move_down)  Yspeed <= 0;	
							
		if (move_left)        Xspeed <= -X_SPEED;
		else if (~move_left)  Xspeed <= 0;	
						
		if (move_right)       Xspeed <= -X_SPEED;
		else if (~move_right) Xspeed <= 0;	
	
		
		if (startOfFrame == 1'b1) begin
			topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
			topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
		end
	end 
	
	//get a better (64 times) resolution using integer   
	assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ; 
	assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule