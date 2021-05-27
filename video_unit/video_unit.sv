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

    objects_mux #(.NUMBER_OF_OBJECTS(VIDEO_UNIT_NUMBER_OF_OBJECTS)) objects_mux_inst (
        .clk           (clk),
        .resetN        (resetN),
        .draw_requests (draw_requests),
        .obj_RGB       (obj_RGB),
        .background_RGB(background_RGB),
        .RGBOut        (RGBOut));

    VGA_Controller VGA_Controller_inst (
        .RGBIn       (RGBOut),
        .pixelX      (pixelX),
        .pixelY      (pixelY),
        .startOfFrame(startOfFrame),
        .oVGA        (oVGA),
        .clk         (clk),
        .resetN      (resetN));

endmodule
