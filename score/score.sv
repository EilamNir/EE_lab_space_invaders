
module score (
    input logic clk,
    input logic resetN,
    input logic [10:0]pixelX,
    input logic [10:0]pixelY,
    input logic monster_died_pulse,
	input logic boss_died_pulse,
	input logic asteroid_exploded_pulse,
	input logic [2:0] stage_num,
    output logic scoreDR,
    output logic [7:0] scoreRGB,
    output logic [DIGIT_AMOUNT - 1:0] [6:0] ss // Output for 7Seg display
);
    parameter unsigned MAX_SCORE_PER_DIGIT = 9;
    parameter unsigned DIGIT_AMOUNT = 3;
	logic [2:0] add_amount;
	assign add_amount = ({monster_died_pulse, boss_died_pulse, asteroid_exploded_pulse} != 0) ? stage_num : 1'b0;
    logic [DIGIT_AMOUNT - 1:0] [3:0] score_digits;
    logic [DIGIT_AMOUNT - 1:0] [3:0] carry_pulses;

    logic [DIGIT_AMOUNT - 1:0] [10:0] digit_offsetX;
    logic [DIGIT_AMOUNT - 1:0] [10:0] digit_offsetY;
    logic [DIGIT_AMOUNT - 1:0] digits_square_draw_requests;
    logic [DIGIT_AMOUNT - 1:0] digits_draw_requests;

    // the up_counter of the first digit has a different count_pulse
    up_counter #(.MAX_SCORE_PER_DIGIT(MAX_SCORE_PER_DIGIT)) digit_counter_0(
        .clk        (clk),
        .resetN     (resetN),
        .count_pulse(add_amount),
        .digit_score(score_digits[0]),
        .carry_pulse(carry_pulses[0])
        );

    genvar i;
    generate
        // generate up counters for every digit but the first
        for (i = 1; i < DIGIT_AMOUNT; i++) begin : generate_up_counters
            up_counter #(.MAX_SCORE_PER_DIGIT(MAX_SCORE_PER_DIGIT)) digit_counter(
                .clk        (clk),
                .resetN     (resetN),
                .count_pulse(carry_pulses[i - 1]),
                .digit_score(score_digits[i]),
                .carry_pulse(carry_pulses[i])
                );
        end
        // generate a hexss for every digit
        for (i = 0; i < DIGIT_AMOUNT; i++) begin : generate_hexss
            hexss digit_hexss(
                .hexin(score_digits[i]),
                .ss   (ss[i])
                );
        end
        // generate a square for every digit
        for (i = 0; i < DIGIT_AMOUNT; i++) begin : generate_squares
            square_object #(.OBJECT_WIDTH_X(6), .OBJECT_HEIGHT_Y(10)) digit_square(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (600 - (i * 10)),
                .topLeftY       (466),
                .offsetX        (digit_offsetX[i]),
                .offsetY        (digit_offsetY[i]),
                .drawingRequest (digits_square_draw_requests[i])
                );
        end
    endgenerate

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
        for (int j = 0; j < DIGIT_AMOUNT; j++) begin
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
