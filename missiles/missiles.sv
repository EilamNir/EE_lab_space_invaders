module missiles(
	
	 input logic clk,
	 input logic resetN,
	 input logic PS2_CLK,
	 input logic PS2_DAT,
	 input logic startOfFrame,
	 input logic [10:0] PixelX,	
	 input logic [10:0] PixelY,	
    input logic [10:0] spaceShip_X,
	 input logic [10:0] spaceShip_Y,
	
	 output logic missleDR,
	 output logic [7:0] missleRGB	
);

	logic keyCode[8:0];
	logic make;
	logic brake;
	
	keyboard_interface kbd_inst(
		.clk(clk),
		.resetN(resetN),
		.PS2_CLK(PS2_CLK),
		.PS2_DAT(PS2_DAT),
		.keyCode(keyCode),
		.make(make),
		.brake(brake)
		);
	
	parameter STR_SHOT_KEY = 9'h070; // digit 0
	logic strShotKeyIsPress;
	
	keyToggle_decoder #(.KEY_VALUE(STR_SHOT_KEY)) control_strShot_inst (
		.clk(clk),
		.resetN(resetN),
		.keyCode(keyCode),
		.make(make),
		.brakee(brake),
		.keyIsPressed(strShotKeyIsPress)
		);

	logic signed [10:0]	topLeftX;
	logic signed [10:0]	topLeftY;
	
	missle_move missle_move_inst(
		.clk(clk),         
		.resetN(resetN),      
		.startOfFrame(startOfFrame), 
		.playerShot(shotKeyIsPress),
		.spaceShip_X(spaceShip_X),
		.spaceShip_Y(spaceShip_Y),
		.topLeftX(topLeftX),
		.topLeftY(topLeftY)
		);	

	square_object square_object_inst(
		.clk(clk),         
		.resetN(resetN), 
		.pixelX(pixelX),
		.pixelY(pixelY),
		.topLeftX(topLeftX), 
		.topLeftY(topLeftY),  
		.offsetX(offsetX),
		.offsetY(offsetY),
		.drawingRequest(drawingRequest),
		.RGBout(RGBout)
		);
		
		
	missleBitMap missleBitMap_inst(
		.clk(clk),         
		.resetN(resetN),  
		.offsetX(offsetX),
		.offsetY(offsetY), 
		.InsideRectangle(drawingRequest), 
		.drawingRequest(missleDR),  
		.RGBout(missleRGB)        
	);

endmodule
