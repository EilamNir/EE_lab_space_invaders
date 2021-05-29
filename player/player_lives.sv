/* player lives module

	display icons for the player lives on the statistics zone of the screen
	
written by Nir Eilam and Gil Kapel, May 18th, 2021 */


module player_lives(
    input logic clk,
    input logic resetN,
    input coordinate pixelX,
    input coordinate pixelY,
    input logic [PLAYER_LIVES_AMOUNT_WIDTH - 1:0] remaining_lives,

    output logic livesDR,
    output RGB livesRGB
);

    `include "parameters.sv"

    logic [PLAYER_LIVES_AMOUNT - 1:0] lives_square_draw_requests;
    logic [PLAYER_LIVES_AMOUNT - 1:0] lives_draw_requests;
    coordinate [PLAYER_LIVES_AMOUNT - 1:0] lives_offsetX;
    coordinate [PLAYER_LIVES_AMOUNT - 1:0] lives_offsetY;

    genvar i;
    generate
        for (i = 0; i < PLAYER_LIVES_AMOUNT; i++) begin : generate_lives
            // Generate an icon for each possible life
            square_object #(
                .OBJECT_WIDTH_X(LIVES_X_SIZE),
                .OBJECT_HEIGHT_Y(LIVES_Y_SIZE)
            ) square_object_lives_inst(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (LIVES_TOPLEFT_X + (i * 16)),
                .topLeftY       (LIVES_TOPLEFT_Y),
                .offsetX        (lives_offsetX[i]),
                .offsetY        (lives_offsetY[i]),
                .drawingRequest (lives_square_draw_requests[i])
                );

            // Only draw the remaining lives
            assign lives_draw_requests[i] = lives_square_draw_requests[i] & (i < remaining_lives);
        end
    endgenerate

    // Decide on which square object to pass into the bitmap
    logic chosen_lives_square_DR;
    coordinate chosen_lives_offsetX;
    coordinate chosen_lives_offsetY;
    always_comb begin
        chosen_lives_square_DR = 1'b0;
        chosen_lives_offsetX = 11'b0;
        chosen_lives_offsetY = 11'b0;
        for (logic unsigned [PLAYER_LIVES_AMOUNT_WIDTH - 1:0] j = 0; j < PLAYER_LIVES_AMOUNT; j++) begin
            // Only save the offset of the first square
            if (lives_draw_requests[j] == 1'b1) begin
                chosen_lives_square_DR = 1'b1;
                chosen_lives_offsetX = lives_offsetX[j];
                chosen_lives_offsetY = lives_offsetY[j];
                break;
            end
        end
    end

    livesBitMap livesBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_lives_offsetX),
        .offsetY(chosen_lives_offsetY),
        .InsideRectangle(chosen_lives_square_DR),
        .drawingRequest(livesDR),
        .RGBout(livesRGB)
    );
endmodule
