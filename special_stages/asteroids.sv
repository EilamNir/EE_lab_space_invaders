
module asteroids(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
	input logic [4:0] collision,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,

    output logic asteroidsDR,
    output logic [7:0] asteroidsRGB
);

    parameter unsigned KEYCODE_WIDTH = 9;
	parameter int INITIAL_X = 50;
	parameter int INITIAL_Y = 20;
	parameter int X_SPEED = 0;
    parameter int Y_SPEED = 20;
    parameter unsigned ASTEROIDS_AMOUNT = 20;

    logic [ASTEROIDS_AMOUNT - 1:0] [10:0] offsetX;
    logic [ASTEROIDS_AMOUNT - 1:0] [10:0] offsetY;
    logic [ASTEROIDS_AMOUNT - 1:0] squareDR;
    logic [ASTEROIDS_AMOUNT - 1:0] [7:0] squareRGB;
    logic [3:0] HitEdgeCode;
    logic signed [ASTEROIDS_AMOUNT - 1:0] [10:0] topLeftX;
    logic signed [ASTEROIDS_AMOUNT - 1:0] [10:0] topLeftY;
    logic [ASTEROIDS_AMOUNT - 1:0] asteroidsIsHit;
    logic [ASTEROIDS_AMOUNT - 1:0] asteroids_deactivated;

    genvar i;
    generate
        for (i = 0; i < ASTEROIDS_AMOUNT; i++) begin : generate_asteroids
            asteroids_move #(.X_SPEED(X_SPEED + (i * 4)), .Y_SPEED(Y_SPEED + (i * 4)), .INITIAL_X(INITIAL_X + (i * 8)), .INITIAL_Y(INITIAL_Y)) asteroids_move_inst(
                .clk(clk),
                .resetN(resetN),
                .missile_collision(collision[0] & squareDR[i]),
                .border_collision(collision[5] & squareDR[i]),
                .startOfFrame(startOfFrame),
                .HitEdgeCode(HitEdgeCode),
                .asteroidsIsHit(asteroidsIsHit[i]),
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
                .startOfFrame(startOfFrame),
                .input_signal(asteroidsIsHit[i]),
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
                    chosen_asteroids_is_hit = asteroidsIsHit[j];
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
        .InsideRectangle(chosen_square_DR),
        .asteroidsIsHit(chosen_asteroids_is_hit),
        .drawingRequest(asteroidsDR),
        .RGBout(asteroidsRGB),
        .HitEdgeCode(HitEdgeCode)
    );


endmodule
