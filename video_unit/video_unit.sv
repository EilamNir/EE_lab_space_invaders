module video_unit
(
    input logic clk,
    input logic resetN,
    input logic [0:NUMBER_OF_OBJECTS - 1] draw_requests,
    input logic [0:NUMBER_OF_OBJECTS - 1] [RGB_WIDTH - 1:0] obj_RGB,
    input logic [RGB_WIDTH - 1:0] background_RGB,
    output logic [PIXEL_WIDTH - 1:0] PixelX,
    output logic [PIXEL_WIDTH - 1:0] PixelY,
    output logic startOfFrame,
    output logic [VGA_WIDTH - 1:0] oVGA
);
    parameter unsigned NUMBER_OF_OBJECTS = 2;
    parameter unsigned RGB_WIDTH = 8;
    parameter unsigned PIXEL_WIDTH = 11;
    parameter unsigned VGA_WIDTH = 29;


    logic [RGB_WIDTH - 1:0] RGBOut;

    // TODO: Pass the amount of objects as parameter
    objects_mux objects_mux_inst (
        .clk           (clk),
        .resetN        (resetN),
        .draw_requests (draw_requests),
        .obj_RGB       (obj_RGB),
        .background_RGB(background_RGB),
        .RGBOut        (RGBOut));

    VGA_Controller VGA_Controller_inst (
        .RGBIn       (RGBOut),
        .PixelX      (PixelX),
        .PixelY      (PixelY),
        .startOfFrame(startOfFrame),
        .oVGA        (oVGA),
        .clk         (clk),
        .resetN      (resetN));

endmodule
