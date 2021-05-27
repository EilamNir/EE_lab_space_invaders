module  objects_mux (
    input logic clk,
    input logic resetN,
    input logic [0:NUMBER_OF_OBJECTS - 1] draw_requests,
    input RGB [0:NUMBER_OF_OBJECTS - 1] obj_RGB,
    input RGB background_RGB,
    output RGB RGBOut
);

    `include "parameters.sv"

    parameter unsigned NUMBER_OF_OBJECTS_WIDTH = 4;
    // Note: This parameter is used in a for loop, that is unrolled at compilation.
    // If this parameter ever gets too large, it may take a lot space, and we might
    // want to move to some other way to check for the first object to draw.
    parameter [NUMBER_OF_OBJECTS_WIDTH - 1:0] NUMBER_OF_OBJECTS = NUMBER_OF_OBJECTS_WIDTH'(5);

    logic [NUMBER_OF_OBJECTS_WIDTH - 1:0] first_draw_request_index;
    logic any_draw_request;

    // Go over the draw requests and draw the first object that wants to be drawn
    always_comb begin
        first_draw_request_index = 0;
        any_draw_request = 1'b0;
        for (logic [NUMBER_OF_OBJECTS_WIDTH - 1:0] i = 0; i < NUMBER_OF_OBJECTS; i++) begin
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
