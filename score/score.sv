
module score (
    input logic clk,
    input logic resetN,
    input coordinate pixelX,
    input coordinate pixelY,
    input logic monster_died_pulse,
	input logic boss_died_pulse,
	input logic asteroid_exploded_pulse,
	input game_stage stage_num,
    input logic game_over,

    output logic scoreDR,
    output RGB scoreRGB,
    output hex_dig [SCORE_DIGIT_AMOUNT - 1:0] ss // Output for 7Seg display
);

    `include "parameters.sv"

	logic [2:0] add_amount;
	assign add_amount = ({monster_died_pulse, boss_died_pulse, asteroid_exploded_pulse} != 0) ? stage_num : 1'b0;
    logic [SCORE_DIGIT_AMOUNT - 1:0] [3:0] score_digits;
    logic [SCORE_DIGIT_AMOUNT - 1:0] [3:0] carry_pulses;

    coordinate [SCORE_DIGIT_AMOUNT - 1:0] digit_offsetX;
    coordinate [SCORE_DIGIT_AMOUNT - 1:0] digit_offsetY;
    coordinate [SCORE_DIGIT_AMOUNT - 1:0] digit_offsetX_small;
    coordinate [SCORE_DIGIT_AMOUNT - 1:0] digit_offsetY_small;
    coordinate [SCORE_DIGIT_AMOUNT - 1:0] digit_offsetX_large;
    coordinate [SCORE_DIGIT_AMOUNT - 1:0] digit_offsetY_large;
    logic [SCORE_DIGIT_AMOUNT - 1:0] digits_square_draw_requests;
    logic [SCORE_DIGIT_AMOUNT - 1:0] digits_square_draw_requests_small;
    logic [SCORE_DIGIT_AMOUNT - 1:0] digits_square_draw_requests_large;
    logic [SCORE_DIGIT_AMOUNT - 1:0] digits_draw_requests;

    // the up_counter of the first digit has a different count_pulse
    up_counter #(
        .MAX_SCORE_PER_DIGIT(SCORE_MAX_VALUE_PER_DIGIT)
    ) digit_counter_0(
        .clk        (clk),
        .resetN     (resetN),
        .count_pulse(add_amount),
        .digit_score(score_digits[0]),
        .carry_pulse(carry_pulses[0])
        );

    genvar i;
    generate
        // generate up counters for every digit but the first
        for (i = 1; i < SCORE_DIGIT_AMOUNT; i++) begin : generate_up_counters
            up_counter #(
                .MAX_SCORE_PER_DIGIT(SCORE_MAX_VALUE_PER_DIGIT)
            ) digit_counter(
                .clk        (clk),
                .resetN     (resetN),
                .count_pulse(carry_pulses[i - 1]),
                .digit_score(score_digits[i]),
                .carry_pulse(carry_pulses[i])
                );
        end
        // generate a hexss for every digit
        for (i = 0; i < SCORE_DIGIT_AMOUNT; i++) begin : generate_hexss
            hexss digit_hexss(
                .hexin(score_digits[i]),
                .ss   (ss[i])
                );
        end
        // generate a square for every digit
        for (i = 0; i < SCORE_DIGIT_AMOUNT; i++) begin : generate_squares
            square_object #(
                .OBJECT_WIDTH_X(NUMBERS_X_SIZE),
                .OBJECT_HEIGHT_Y(NUMBERS_Y_SIZE)
            ) digit_square_small(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (SCORE_SMALL_TOPLEFT_X - (i * 10)),
                .topLeftY       (SCORE_SMALL_TOPLEFT_Y),
                .offsetX        (digit_offsetX_small[i]),
                .offsetY        (digit_offsetY_small[i]),
                .drawingRequest (digits_square_draw_requests_small[i])
                );

            square_object #(
                .OBJECT_WIDTH_X(NUMBERS_X_SIZE << SCORE_SIZE_MULTIPLIER),
                .OBJECT_HEIGHT_Y(NUMBERS_Y_SIZE << SCORE_SIZE_MULTIPLIER)
            ) digit_square_large(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (SCORE_LARGE_TOPLEFT_X - ((i + 1) * (10 << SCORE_SIZE_MULTIPLIER))),
                .topLeftY       (SCORE_LARGE_TOPLEFT_Y),
                .offsetX        (digit_offsetX_large[i]),
                .offsetY        (digit_offsetY_large[i]),
                .drawingRequest (digits_square_draw_requests_large[i])
                );
        end
    endgenerate

    assign digits_square_draw_requests = (!game_over) ? digits_square_draw_requests_small : digits_square_draw_requests_large;
    assign digit_offsetX = (!game_over) ? digit_offsetX_small : (digit_offsetX_large >> SCORE_SIZE_MULTIPLIER);
    assign digit_offsetY = (!game_over) ? digit_offsetY_small : (digit_offsetY_large >> SCORE_SIZE_MULTIPLIER);

    // Decide on which square object to pass into the bitmap
    logic chosen_digit_square_DR;
    coordinate chosen_digit_offsetX;
    coordinate chosen_digit_offsetY;
    logic [3:0] chosen_digit_score;
    always_comb begin
        chosen_digit_square_DR = 1'b0;
        chosen_digit_offsetX = 11'b0;
        chosen_digit_offsetY = 11'b0;
        chosen_digit_score = 4'b0;
        for (logic unsigned [SCORE_DIGIT_AMOUNT_WIDTH-1:0] j = 0; j < SCORE_DIGIT_AMOUNT; j++) begin
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
