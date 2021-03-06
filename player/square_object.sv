//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// System-Verilog Alex Grinshpun May 2018
// New coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2021


module	square_object	(	
    input logic clk,
    input logic resetN,
    input coordinate pixelX,// current VGA pixel
    input coordinate pixelY,
    input coordinate topLeftX, //position on the screen
    input coordinate topLeftY,   // can be negative , if the object is partliy outside

    output coordinate offsetX,// offset inside bracket from top left position
    output coordinate offsetY,
    output logic drawingRequest // indicates pixel inside the bracket
);

    `include "parameters.sv"

    parameter coordinate OBJECT_WIDTH_X;
    parameter coordinate OBJECT_HEIGHT_Y;

    coordinate rightX ; //coordinates of the sides
    coordinate bottomY ;
    logic insideBracket ;

//////////--------------------------------------------------------------------------------------------------------------=
// Calculate object right  & bottom  boundaries
	assign rightX	= (topLeftX + OBJECT_WIDTH_X);
	assign bottomY	= (topLeftY + OBJECT_HEIGHT_Y);
	assign	insideBracket  = 	 ( (pixelX  >= topLeftX) &&  (pixelX < rightX) // math is made with SIGNED variables
								&& (pixelY  >= topLeftY) &&  (pixelY < bottomY) )  ; // as the top left position can be negative
			
	
	
	//////////--------------------------------------------------------------------------------------------------------------=
	always_ff@(posedge clk or negedge resetN)
	begin
		if(!resetN) begin
			drawingRequest	<=	1'b0;
		end	else begin
		
			// DEFUALT outputs
				drawingRequest <= 1'b0 ;// transparent color
				offsetX	<= 0; //no offset
				offsetY	<= 0; //no offset
	
			if (insideBracket) // test if it is inside the rectangle
			begin
				drawingRequest <= 1'b1 ;
				offsetX	<= (pixelX - topLeftX); //calculate relative offsets from top left corner allways a positive number
				offsetY	<= (pixelY - topLeftY);
			end
			
		end
	end
endmodule 