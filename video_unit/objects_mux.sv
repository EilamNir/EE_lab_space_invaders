/* object mux module
	
	mux for the video unit 
	gets draw requests and object rgb and determines which to show first
	if more then one request will be in the same pixel,
	the mux will "choose" the first one - that makes the draw request order important!
	
written by Nir Eilam May 3th, 2021 */

module  objects_mux (
    input logic clk,
    input logic resetN,
    input logic [0:NUMBER_OF_OBJECTS - 1] draw_requests,
    input RGB [0:NUMBER_OF_OBJECTS - 1] obj_RGB,
    input RGB background_RGB,
    output RGB RGBOut
);

    `include "parameters.sv"

    parameter [VIDEO_UNIT_NUMBER_OF_OBJECTS_WIDTH - 1:0] NUMBER_OF_OBJECTS;

    logic [VIDEO_UNIT_NUMBER_OF_OBJECTS_WIDTH - 1:0] first_draw_request_index;
    logic any_draw_request;

    // Go over the draw requests and draw the first object that wants to be drawn
    always_comb begin
        first_draw_request_index = 0;
        any_draw_request = 1'b0;
        for (logic [VIDEO_UNIT_NUMBER_OF_OBJECTS_WIDTH - 1:0] i = 0; i < NUMBER_OF_OBJECTS; i++) begin
            if (draw_requests[i] == 1'b1) begin
                first_draw_request_index = i;
                any_draw_request = 1'b1;
                break;
            end
        end
    end

    // Save the RGB value for this index of the object to draw
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            // Reset RGB to zeros on reset
            RGBOut  <= RGB'('b0);
        end

        else begin
            if (any_draw_request == 1'b1) begin
                // Draw the object with the highest priority
                RGBOut = obj_RGB[first_draw_request_index];
            end else begin
                // If no object wants to be drawn, draw the background
                RGBOut <= background_RGB ;
            end
        end
    end

endmodule
