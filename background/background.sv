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
    input coordinate pixelX,
    input coordinate pixelY,
    input logic game_won,
    input logic game_over,

    output RGB background_RGB,
    output logic [0:1] bordersDR,
    output RGB end_game_RGB,
    output logic end_gameDR
);

    `include "parameters.sv"

    parameter RGB MOVEMENT_ZONE_END_COLOR = 8'b10000000;
    parameter RGB STATISTICS_ZONE_COLOR = 8'b00000010;
    parameter RGB BACKGROUND_COLOR = 8'b00000000;
    parameter RGB GAME_WON_COLOR = 8'hFF;
    parameter RGB GAME_OVER_COLOR = 8'b10000000;
    parameter unsigned LETTER_SIZE_MULTIPLIER = 3;

    const coordinate xFrameSize = 639;
    const coordinate yFrameSize = 479;
    const coordinate movement_zone_offset = 20;
    const coordinate statistics_zone_offset = 20;
    const coordinate upperBorder = 20;
    const coordinate player_zone_y = 310;

    always_ff@(posedge clk or negedge resetN) begin
        if(!resetN) begin
            background_RGB <= BACKGROUND_COLOR;
        end else begin
            // Default to printing the background color
            background_RGB <= BACKGROUND_COLOR;
            bordersDR <= 2'b0;
            // Check if we need to print the movement zone end
            if ((pixelX == movement_zone_offset) ||
                (pixelX == (xFrameSize - movement_zone_offset)) ||
                (pixelY == (yFrameSize - statistics_zone_offset))||
                (pixelY == (upperBorder))) begin
                background_RGB <= MOVEMENT_ZONE_END_COLOR;
                bordersDR[0] <= 1'b1;
            end
            // Check if we need to print the player zone end
            if (pixelY == player_zone_y ) begin
                background_RGB <= STATISTICS_ZONE_COLOR;
                bordersDR[1] <= 1'b1;
            end
        end
    end

    logic square_DR;
    coordinate offsetX;
    coordinate offsetY;
    square_object #(.OBJECT_WIDTH_X(64 << LETTER_SIZE_MULTIPLIER), .OBJECT_HEIGHT_Y(16 << LETTER_SIZE_MULTIPLIER)) square_object_end_game_inst(
        .clk            (clk),
        .resetN         (resetN),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .topLeftX       (63),
        .topLeftY       (159),
        .offsetX        (offsetX),
        .offsetY        (offsetY),
        .drawingRequest (square_DR)
    );

    end_gameBitMap end_gameBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX >> LETTER_SIZE_MULTIPLIER),
        .offsetY(offsetY >> LETTER_SIZE_MULTIPLIER),
        .InsideRectangle(game_over & square_DR),
        .game_won(game_won),
        .drawingRequest(end_gameDR)
    );

    assign end_game_RGB = game_won ? GAME_WON_COLOR : GAME_OVER_COLOR;

endmodule
