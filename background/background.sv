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

    always_ff@(posedge clk or negedge resetN) begin
        if(!resetN) begin
            background_RGB <= BACKGROUND_BACKGROUND_COLOR;
        end else begin
            // Default to printing the background color
            background_RGB <= BACKGROUND_BACKGROUND_COLOR;
            bordersDR <= 2'b0;
            // Check if we need to print the movement zone end
            if ((pixelX == BACKGROUND_MOVEMENT_ZONE_OFFSET) ||
                (pixelX == (FRAMESIZE_X - BACKGROUND_MOVEMENT_ZONE_OFFSET)) ||
                (pixelY == (FRAMESIZE_Y - BACKGROUND_STATISTICS_ZONE_OFFSET))||
                (pixelY == (BACKGROUND_UPPERBORDER))) begin
                background_RGB <= BACKGROUND_MOVEMENT_ZONE_END_COLOR;
                bordersDR[0] <= 1'b1;
            end
            // Check if we need to print the player zone end
            if (pixelY == BACKGROUND_PLAYER_ZONE_Y ) begin
                background_RGB <= BACKGROUND_STATISTICS_ZONE_COLOR;
                bordersDR[1] <= 1'b1;
            end
        end
    end

    logic square_DR;
    coordinate offsetX;
    coordinate offsetY;
    square_object #(
        .OBJECT_WIDTH_X(BACKGROUND_LETTER_X_SIZE << BACKGROUND_LETTER_SIZE_MULTIPLIER),
        .OBJECT_HEIGHT_Y(BACKGROUND_LETTER_Y_SIZE << BACKGROUND_LETTER_SIZE_MULTIPLIER))
    square_object_end_game_inst(
        .clk            (clk),
        .resetN         (resetN),
        .pixelX         (pixelX),
        .pixelY         (pixelY),
        .topLeftX       (BACKGROUND_LETTER_TOPLEFT_X),
        .topLeftY       (BACKGROUND_LETTER_TOPLEFT_Y),
        .offsetX        (offsetX),
        .offsetY        (offsetY),
        .drawingRequest (square_DR)
    );

    end_gameBitMap end_gameBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX >> BACKGROUND_LETTER_SIZE_MULTIPLIER),
        .offsetY(offsetY >> BACKGROUND_LETTER_SIZE_MULTIPLIER),
        .InsideRectangle(game_over & square_DR),
        .game_won(game_won),
        .drawingRequest(end_gameDR)
    );

    assign end_game_RGB = game_won ? BACKGROUND_GAME_WON_COLOR : BACKGROUND_GAME_OVER_COLOR;

endmodule
