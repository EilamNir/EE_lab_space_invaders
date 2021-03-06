/* a small model of the space ship that represent one live and will be shown in the buttom left of the screen

drawing by Nir Eilam May 2021 */



module livesBitMap (

    input logic clk,
    input logic resetN,
    input coordinate offsetX,
    input coordinate offsetY,
    input logic InsideRectangle,

    output logic drawingRequest,
    output RGB RGBout
);

    `include "parameters.sv"

    // generating the bitmap
    localparam RGB TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel
    RGB [0:LIVES_Y_SIZE-1][0:LIVES_X_SIZE-1] object_colors = {
        {8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h00},
        {8'h00,8'h00,8'h4a,8'h01,8'h01,8'h4a,8'h00,8'h00},
        {8'h00,8'h00,8'h4a,8'h01,8'h01,8'h4a,8'h00,8'h00},
        {8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h00},
        {8'h4a,8'h00,8'h4a,8'h4a,8'h4a,8'h4a,8'h00,8'h4a},
        {8'h4a,8'h4a,8'h4a,8'h4a,8'h4a,8'h4a,8'h4a,8'h4a},
        {8'h4a,8'h4a,8'h4a,8'h4a,8'h4a,8'h4a,8'h4a,8'h4a},
        {8'h00,8'hc0,8'hc0,8'h00,8'h00,8'hc0,8'hc0,8'h00}};

    //////////--------------------------------------------------------------------------------------------------------------=
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            RGBout <= 8'h00;
        end
        else begin
            RGBout <= TRANSPARENT_ENCODING ; // default

            if (InsideRectangle == 1'b1 )
            begin // inside an external bracket
                RGBout <= object_colors[offsetY][offsetX];
            end

        end
    end

    //////////--------------------------------------------------------------------------------------------------------------=
    // decide if to draw the pixel or not
    assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmap

endmodule
