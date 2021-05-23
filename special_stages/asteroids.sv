
module asteroids(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input logic [6:0] collision,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,

    output logic asteroidsDR,
	output logic all_asteroids_destroied,
    output logic [7:0] asteroidsRGB
);

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 50;
	parameter int INITIAL_Y = 20;
	parameter int X_SPEED = 10;
    parameter int Y_SPEED = 60;
    parameter unsigned ASTEROIDS_AMOUNT = 20;
    parameter unsigned X_SPACING = 128; // Change according to amount of monsters: 96 for 5 in a row (20 total), 128 for 4 in a row (16 total)

    logic [ASTEROIDS_AMOUNT - 1:0] [10:0] offsetX;
    logic [ASTEROIDS_AMOUNT - 1:0] [10:0] offsetY;
    logic [ASTEROIDS_AMOUNT - 1:0] squareDR;
    logic [ASTEROIDS_AMOUNT - 1:0] [7:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic signed [ASTEROIDS_AMOUNT - 1:0] [10:0] topLeftX;
    logic signed [ASTEROIDS_AMOUNT - 1:0] [10:0] topLeftY;
    logic [ASTEROIDS_AMOUNT - 1:0] asteroidIsHit;
    logic [ASTEROIDS_AMOUNT - 1:0] asteroids_deactivated;

    genvar i;
    generate
        for (i = 0; i < ASTEROIDS_AMOUNT; i++) begin : generate_asteroids
            asteroids_move #(.X_SPEED(X_SPEED + ((i>>2) * 8) + i * 2), .Y_SPEED(Y_SPEED + ((i>>2) * 8)), .INITIAL_X(INITIAL_X + ((i>>2) * X_SPACING)), .INITIAL_Y(INITIAL_Y + ((2'(i) & 2'b11) * 64))) asteroids_move_inst(
				.clk(clk),
                .resetN(resetN),
                .missile_collision(collision[0] & squareDR[i]),
                .border_collision(collision[5] & squareDR[i]),
                .startOfFrame(startOfFrame & (enable)),
                .HitEdgeCode(HitEdgeCode),
                .asteroidIsHit(asteroidIsHit[i]),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i])
                );

            square_object #(.OBJECT_WIDTH_X(32), .OBJECT_HEIGHT_Y(32)) square_object_inst(
                .clk(clk),
                .resetN(resetN),
                .pixelX(pixelX),
                .pixelY(pixelY),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i]),
                .offsetX(offsetX[i]),
                .offsetY(offsetY[i]),
                .drawingRequest(squareDR[i]),
                .RGBout(squareRGB[i])
                );

            delay_signal_by_frames #(.DELAY_FRAMES_AMOUNT(10)) delay_signal_by_frames_inst(
                .clk(clk),
                .resetN(resetN),
                .startOfFrame(startOfFrame & (enable)),
                .input_signal(asteroidIsHit[i]),
                .output_signal(asteroids_deactivated[i])
                );

                end
    endgenerate

    // Decide on which square object to pass into the bitmap
    logic chosen_square_DR;
    logic [10:0] chosen_offsetX;
    logic [10:0] chosen_offsetY;
    logic chosen_asteroids_is_hit;
    always_comb begin
        chosen_square_DR = 1'b0;
        chosen_offsetX = 11'b0;
        chosen_offsetY = 11'b0;
        chosen_asteroids_is_hit = 1'b0;
        for (int j = 0; j < ASTEROIDS_AMOUNT; j++) begin
            // Only save the offset of the first square
            if (squareDR[j] == 1'b1) begin
                // Ignore deactivated asteroids
                if (asteroids_deactivated[j] == 1'b0) begin
                    chosen_square_DR = 1'b1;
                    chosen_offsetX = offsetX[j];
                    chosen_offsetY = offsetY[j];
                    chosen_asteroids_is_hit = asteroidIsHit[j];
                    break;
                end
            end
        end
    end

    asteroidBitMap asteroidBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_offsetX),
        .offsetY(chosen_offsetY),
        .asteroidIsHit(chosen_asteroids_is_hit),
        .InsideRectangle(chosen_square_DR),
        .drawingRequest(asteroidsDR),
        .RGBout(asteroidsRGB),
        .HitEdgeCode(HitEdgeCode)
    );

    assign all_asteroids_destroied = &asteroids_deactivated;


endmodule
