/*
    This module prints the background of the game.
    The background consists of a black canvas, over which are:
    - a line to mark the side of the player and the side of the enemy
    - boarders to mark how far to the sides the player and the enemies can move
    - a line to mark the bottom of the player space, under which the statistics will be drawn
      (remaining life, score, or any other statistic that will be implemented)
    Each of those lines is represented in the module as a specific Y or X coordinate, at which
    to draw this line.
*/
module background
(
    input logic clk,
    input logic resetN,
    input logic [PIXEL_WIDTH - 1:0] pixelX,
    input logic [PIXEL_WIDTH - 1:0] pixelY,
    output logic [RGB_WIDTH - 1:0] background_RGB,
	output logic [1:0] boardersDrawReq
);

    parameter unsigned RGB_WIDTH = 8;
    parameter unsigned PIXEL_WIDTH = 11;
    parameter logic [RGB_WIDTH - 1:0] PLAYER_ZONE_END_COLOR = 8'b00010000;
    parameter logic [RGB_WIDTH - 1:0] MOVEMENT_ZONE_END_COLOR = 8'b10000000;
    parameter logic [RGB_WIDTH - 1:0] STATISTICS_ZONE_COLOR = 8'b00000010;
    parameter logic [RGB_WIDTH - 1:0] BACKGROUND_COLOR = 8'b00000000;

    const int xFrameSize = 639;
    const int yFrameSize = 479;
    const int movement_zone_offset = 20;
    const int statistics_zone_offset = 20;
    const int player_zone_y = 310;

    always_ff@(posedge clk or negedge resetN) begin
        if(!resetN) begin
            background_RGB <= BACKGROUND_COLOR;
        end else begin
            // Default to printing the background color
            background_RGB <= BACKGROUND_COLOR;

            // Check if we need to print the movement zone end
            if ((pixelX == movement_zone_offset) || (pixelX == (xFrameSize - movement_zone_offset))) begin
                background_RGB <= MOVEMENT_ZONE_END_COLOR;
            end

            // Check if we need to print the player zone end
            if (pixelY == player_zone_y) begin
                background_RGB <= PLAYER_ZONE_END_COLOR;
            end

            // Check if we need to print the statistics zone end
            if (pixelY == (yFrameSize - statistics_zone_offset)) begin
                background_RGB <= STATISTICS_ZONE_COLOR;
            end
        end
    end

endmodule
