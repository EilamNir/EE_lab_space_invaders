/* video_unit 
	This module gets draw requests from all objects in the game
	and transform them into vga outputs using the right rgb color

written by Nir Eilam May 3th, 2021 */


module video_unit
(
    input logic clk,
    input logic resetN,
    input logic [0:VIDEO_UNIT_NUMBER_OF_OBJECTS - 1] draw_requests,
    input RGB [0:VIDEO_UNIT_NUMBER_OF_OBJECTS - 1] obj_RGB,
    input RGB background_RGB,
    output coordinate pixelX,
    output coordinate pixelY,
    output logic startOfFrame,
    output VGA oVGA
);

    `include "parameters.sv"

    RGB RGBOut;
	//select which DR and which RGB to paint in a single pixel
    objects_mux #(.NUMBER_OF_OBJECTS(VIDEO_UNIT_NUMBER_OF_OBJECTS)) objects_mux_inst (
        .clk           (clk),
        .resetN        (resetN),
        .draw_requests (draw_requests),
        .obj_RGB       (obj_RGB),
        .background_RGB(background_RGB),
        .RGBOut        (RGBOut));
	// make the RGB and DR an output for the vga
    VGA_Controller VGA_Controller_inst (
        .RGBIn       (RGBOut),
        .pixelX      (pixelX),
        .pixelY      (pixelY),
        .startOfFrame(startOfFrame),
        .oVGA        (oVGA),
        .clk         (clk),
        .resetN      (resetN));

endmodule
