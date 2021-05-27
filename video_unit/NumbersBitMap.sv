//
// coding convention dudy December 2018
// (c) Technion IIT, Department of Electrical Engineering 2021
// generating a number bitmap



module NumbersBitMap (
    input logic clk,
    input logic resetN,
    input coordinate offsetX, // offset from top left position
    input coordinate offsetY,
    input logic InsideRectangle, //input that the pixel is within a bracket
    input logic [3:0] digit, // digit to display

    output logic drawingRequest //output that the pixel should be dispalyed
);

    `include "parameters.sv"

    // generating a numbers bitmap
    bit [0:9] [0:9] [0:5] number_bitmap = {
        {6'b 111111,
         6'b 111111,
         6'b 110011,
         6'b 110011,
         6'b 110011,
         6'b 110011,
         6'b 110011,
         6'b 110011,
         6'b 111111,
         6'b 111111},

        {6'b 001100,
         6'b 001100,
         6'b 111100,
         6'b 111100,
         6'b 001100,
         6'b 001100,
         6'b 001100,
         6'b 001100,
         6'b 001100,
         6'b 001100},

        {6'b 111111,
         6'b 111111,
         6'b 110011,
         6'b 110011,
         6'b 000011,
         6'b 001111,
         6'b 111100,
         6'b 110000,
         6'b 111111,
         6'b 111111},

        {6'b 111111,
         6'b 111111,
         6'b 000011,
         6'b 000011,
         6'b 111111,
         6'b 111111,
         6'b 000011,
         6'b 000011,
         6'b 111111,
         6'b 111111},

        {6'b 110011,
         6'b 110011,
         6'b 110011,
         6'b 110011,
         6'b 111111,
         6'b 111111,
         6'b 000011,
         6'b 000011,
         6'b 000011,
         6'b 000011},

        {6'b 111111,
         6'b 111111,
         6'b 110000,
         6'b 110000,
         6'b 111111,
         6'b 111111,
         6'b 000011,
         6'b 000011,
         6'b 111111,
         6'b 111111},


        {6'b 111111,
         6'b 111111,
         6'b 110000,
         6'b 110000,
         6'b 111111,
         6'b 111111,
         6'b 110011,
         6'b 110011,
         6'b 111111,
         6'b 111111},

        {6'b 111111,
         6'b 111111,
         6'b 000011,
         6'b 000011,
         6'b 000110,
         6'b 000110,
         6'b 001100,
         6'b 001100,
         6'b 011000,
         6'b 011000},

        {6'b 111111,
         6'b 111111,
         6'b 110011,
         6'b 110011,
         6'b 111111,
         6'b 111111,
         6'b 110011,
         6'b 110011,
         6'b 111111,
         6'b 111111},

        {6'b 111111,
         6'b 111111,
         6'b 110011,
         6'b 110011,
         6'b 111111,
         6'b 111111,
         6'b 000011,
         6'b 000011,
         6'b 111111,
         6'b 111111}
    } ;

    // pipeline (ff) to get the pixel color from the array
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            drawingRequest <=   1'b0;
        end
        else begin
            drawingRequest <=   1'b0;

            if (InsideRectangle == 1'b1 )
                drawingRequest <= (number_bitmap[digit][offsetY][offsetX]); //get value from bitmap
        end
    end

endmodule