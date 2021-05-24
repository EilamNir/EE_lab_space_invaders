
module score (
    input logic clk,
    input logic resetN,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,
    input logic monster_died_pulse,

    output logic scoreDR,
    output logic [7:0] scoreRGB,
    output logic [2:0] [6:0] ss // Output for 7Seg display
);
    parameter unsigned MAX_SCORE_PER_DIGIT = 9;
    logic [2:0] [3:0] score_digits;
    logic [1:0] carry_pulses;

    logic [2:0] [10:0] digit_offsetX;
    logic [2:0] [10:0] digit_offsetY;
    logic [2:0] digits_square_draw_requests;
    logic [2:0] digits_draw_requests;


    up_counter #(.MAX_SCORE_PER_DIGIT(MAX_SCORE_PER_DIGIT)) digit_0(
        .clk        (clk),
        .resetN     (resetN),
        .count_pulse(monster_died_pulse),
        .digit_score(score_digits[0]),
        .carry_pulse(carry_pulses[0])
        );

    up_counter #(.MAX_SCORE_PER_DIGIT(MAX_SCORE_PER_DIGIT)) digit_1(
        .clk        (clk),
        .resetN     (resetN),
        .count_pulse(carry_pulses[0]),
        .digit_score(score_digits[1]),
        .carry_pulse(carry_pulses[1])
        );

    up_counter #(.MAX_SCORE_PER_DIGIT(MAX_SCORE_PER_DIGIT)) digit_2(
        .clk        (clk),
        .resetN     (resetN),
        .count_pulse(carry_pulses[1]),
        .digit_score(score_digits[2])
        );

    hexss digit_0_hexss(
        .hexin(score_digits[0]),
        .ss   (ss[0])
        );

    hexss digit_1_hexss(
        .hexin(score_digits[1]),
        .ss   (ss[1])
        );

    hexss digit_2_hexss(
        .hexin(score_digits[2]),
        .ss   (ss[2])
        );

    square_object #(.OBJECT_WIDTH_X(6), .OBJECT_HEIGHT_Y(10)) digit_square_0(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (600),
                .topLeftY       (466),
                .offsetX        (digit_offsetX[0]),
                .offsetY        (digit_offsetY[0]),
                .drawingRequest (digits_square_draw_requests[0])
                );

    square_object #(.OBJECT_WIDTH_X(6), .OBJECT_HEIGHT_Y(10)) digit_square_1(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (590),
                .topLeftY       (466),
                .offsetX        (digit_offsetX[1]),
                .offsetY        (digit_offsetY[1]),
                .drawingRequest (digits_square_draw_requests[1])
                );

    square_object #(.OBJECT_WIDTH_X(6), .OBJECT_HEIGHT_Y(10)) digit_square_2(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (580),
                .topLeftY       (466),
                .offsetX        (digit_offsetX[2]),
                .offsetY        (digit_offsetY[2]),
                .drawingRequest (digits_square_draw_requests[2])
                );

    // Decide on which square object to pass into the bitmap
    logic chosen_digit_square_DR;
    logic [10:0] chosen_digit_offsetX;
    logic [10:0] chosen_digit_offsetY;
    logic [3:0] chosen_digit_score;
    always_comb begin
        chosen_digit_square_DR = 1'b0;
        chosen_digit_offsetX = 11'b0;
        chosen_digit_offsetY = 11'b0;
        chosen_digit_score = 4'b0;
        for (int j = 0; j < 3; j++) begin
            // Only save the offset of the first square
            if (digits_square_draw_requests[j] == 1'b1) begin
                chosen_digit_square_DR = 1'b1;
                chosen_digit_offsetX = digit_offsetX[j];
                chosen_digit_offsetY = digit_offsetY[j];
                chosen_digit_score = score_digits[j];
                break;
            end
        end
    end

    NumbersBitMap number_bitmap(
        .clk(clk),
        .resetN(resetN),
        .offsetX(chosen_digit_offsetX),
        .offsetY(chosen_digit_offsetY),
        .InsideRectangle(chosen_digit_square_DR),
        .digit(chosen_digit_score),
        .drawingRequest(scoreDR) 
        );

    assign scoreRGB = 8'b00010000;


endmodule
