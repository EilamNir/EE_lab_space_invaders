// bitmap file 
// (c) Technion IIT, Department of Electrical Engineering 2021 
// generated bythe automatic Python tool 
 
 
 module asteroidBitMap (

					input	logic	clk, 
					input	logic	resetN, 
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY, 
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
 
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
 ) ; 
 
 
// generating the bitmap 
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel  
logic[0:31][0:31][7:0] object_colors = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h8a,8'hd4,8'hde,8'hd6,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'hde,8'hd4,8'hde,8'hde,8'hd4,8'hd4,8'hde,8'hd4,8'h94,8'h94,8'h94,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h94,8'h11e,8'hde,8'hd4,8'hde,8'hde,8'hd4,8'hd4,8'hde,8'hd6,8'hd4,8'hde,8'hde,8'hd4,8'hd4,8'hd4,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h94,8'hde,8'hde,8'hde,8'h94,8'hde,8'hde,8'hde,8'hde,8'hd4,8'hd4,8'hd6,8'hd4,8'hde,8'hde,8'hd6,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'hde,8'hde,8'hd4,8'h94,8'h94,8'hde,8'hde,8'hde,8'hde,8'hde,8'hd4,8'hd4,8'hd4,8'hde,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h94,8'hde,8'hde,8'hde,8'hd6,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'h94,8'h94,8'h94,8'hd6,8'h94,8'hd4,8'hde,8'hde,8'h94,8'h8c,8'h94,8'h94,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h94,8'hde,8'hde,8'hde,8'hd4,8'hde,8'hd4,8'hd4,8'hde,8'hd4,8'hd4,8'hd4,8'hde,8'h94,8'h94,8'h94,8'h94,8'h94,8'hde,8'hd6,8'hd4,8'hd4,8'h94,8'h8a,8'hd4,8'h40,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h94,8'hd4,8'hd4,8'hd4,8'hd4,8'h94,8'hd4,8'h94,8'hd4,8'hd4,8'hd4,8'hd4,8'hde,8'hd4,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hde,8'h94,8'h94,8'h94,8'h94,8'h4a,8'hd4,8'h4a,8'h00,8'h00,8'h00},
	{8'h00,8'h94,8'hd6,8'hd4,8'hd4,8'hd4,8'hd4,8'h94,8'hd4,8'hd4,8'hde,8'hde,8'hde,8'hd4,8'hde,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hde,8'hd4,8'hd4,8'hd4,8'h94,8'h94,8'h8a,8'h94,8'h4a,8'h00,8'h00,8'h00},
	{8'h4a,8'hde,8'h94,8'hd4,8'hde,8'hde,8'hd6,8'h94,8'hd4,8'hde,8'hde,8'hd6,8'hde,8'hd4,8'hd4,8'h94,8'hd4,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00},
	{8'h8a,8'hd4,8'hd4,8'hd4,8'hde,8'hde,8'hde,8'h94,8'h94,8'hd4,8'hd4,8'h94,8'hde,8'hd4,8'h94,8'h94,8'hd4,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h00,8'h00,8'h00},
	{8'h94,8'hd4,8'hde,8'hd4,8'hde,8'hde,8'hde,8'hde,8'h94,8'hd6,8'hde,8'hde,8'hd4,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'hd4,8'h94,8'h00,8'h00},
	{8'hd4,8'hd4,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hde,8'hd6,8'hde,8'hde,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h00},
	{8'hd4,8'hd4,8'hde,8'hd4,8'hd4,8'hd4,8'hde,8'hde,8'hd4,8'h94,8'hd6,8'hd4,8'h94,8'h94,8'hd4,8'h94,8'h94,8'hd4,8'hd4,8'hd4,8'h94,8'hde,8'hde,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h4a},
	{8'hd4,8'h94,8'hd4,8'hde,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hde,8'hde,8'hde,8'hde,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94},
	{8'hde,8'h94,8'h94,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h94,8'h94,8'hde,8'hde,8'hde,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94},
	{8'hd4,8'hd4,8'h94,8'hd4,8'h94,8'hd4,8'hde,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h8c,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h8a,8'h94,8'h94,8'hd4,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94},
	{8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hde,8'hd4,8'h94,8'h94,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94},
	{8'h94,8'hd4,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h8a,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hde,8'h94,8'h8a,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94},
	{8'h4a,8'hd4,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'hd4,8'hde,8'h94,8'h94,8'h94,8'h94,8'h92,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h8a,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94},
	{8'h4a,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h92,8'h94,8'h94,8'h94},
	{8'h00,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h4a},
	{8'h00,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h92,8'h8a,8'h94,8'h94,8'h94,8'h40},
	{8'h00,8'h8a,8'h94,8'h94,8'h8a,8'h94,8'h94,8'h92,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'hd4,8'hdc,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h4a,8'h8a,8'h94,8'h94,8'h94,8'h00},
	{8'h00,8'h00,8'h94,8'h94,8'h92,8'h94,8'h94,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hd4,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h8a,8'h8a,8'h8a,8'h94,8'h4a,8'h00},
	{8'h00,8'h00,8'h00,8'h8a,8'h92,8'h8a,8'h94,8'h94,8'h8a,8'h8a,8'h94,8'h92,8'h94,8'h94,8'hd4,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h92,8'h94,8'h8a,8'h94,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h92,8'h94,8'h94,8'hd4,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h8a,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h92,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'hd4,8'h94,8'hd4,8'hd4,8'h92,8'h92,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h92,8'h94,8'h94,8'h94,8'h94,8'hd4,8'hd4,8'h94,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h94,8'hd4,8'h94,8'hd4,8'hde,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

 
 
//////////--------------------------------------------------------------------------------------------------------------= 
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	 
//there is one bit per edge, in the corner two bits are set  
 logic [0:3] [0:3] [3:0] hit_colors = 
		   {16'hC446,     
			16'h8C62,    
			16'h8932, 
			16'h9113}; 
 // pipeline (ff) to get the pixel color from the array 	 
//////////--------------------------------------------------------------------------------------------------------------= 
always_ff@(posedge clk or negedge resetN) 
begin 
	if(!resetN) begin 
		RGBout <=	8'h00; 
		HitEdgeCode <= 4'h0; 
	end 
	else begin 
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0; 
 
		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket  
			HitEdgeCode <= hit_colors[offsetY >> 3][offsetX >> 3 ]; // get hitting edge from the colors table
			RGBout <= object_colors[offsetY][offsetX]; 
		end  	 
		 
	end 
end 
 
//////////--------------------------------------------------------------------------------------------------------------= 
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
 
endmodule 
