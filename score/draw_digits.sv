/* draw digits module
	
	a module to print to the screen digits and a counter to rise the digits up each amount added
	this module can support each max digit count we need, for this game we use only decimal counting (also for the timer)
	this module will use the hexess module to translate a number to hex code
	
written by Nir Eilam and Gil Kapel, May 20th, 2021 */

 
module draw_digits (
    input logic clk,
    input logic resetN,
    input coordinate pixelX,
    input coordinate pixelY,
	input logic [2:0] add_amount,
	input logic game_over,
	
    output logic digitDR,
    output RGB digitRGB,
    output hex_dig [DIGIT_AMOUNT - 1:0] ss // Output for 7Seg display
);

    `include "parameters.sv"
	
	parameter unsigned DIGIT_COLOR;
    parameter unsigned DIGIT_AMOUNT_WIDTH;
    parameter logic unsigned [DIGIT_AMOUNT_WIDTH-1:0] DIGIT_AMOUNT;
	parameter coordinate SMALL_TOPLEFT_X;
	parameter coordinate SMALL_TOPLEFT_Y;
	parameter coordinate LARGE_TOPLEFT_X;
	parameter coordinate LARGE_TOPLEFT_Y;

	logic [DIGIT_AMOUNT - 1:0] [3:0] digits;
    logic [DIGIT_AMOUNT - 1:0] carry_pulses;
    coordinate [DIGIT_AMOUNT - 1:0] digit_offsetX;
    coordinate [DIGIT_AMOUNT - 1:0] digit_offsetY;
    coordinate [DIGIT_AMOUNT - 1:0] digit_offsetX_small;
    coordinate [DIGIT_AMOUNT - 1:0] digit_offsetY_small;
    coordinate [DIGIT_AMOUNT - 1:0] digit_offsetX_large;
    coordinate [DIGIT_AMOUNT - 1:0] digit_offsetY_large;
    logic [DIGIT_AMOUNT - 1:0] digits_square_draw_requests;
    logic [DIGIT_AMOUNT - 1:0] digits_square_draw_requests_small;
    logic [DIGIT_AMOUNT - 1:0] digits_square_draw_requests_large;
    logic [DIGIT_AMOUNT - 1:0] digits_draw_requests;

    // the up_counter of the first digit has a different count_pulse
    up_counter digit_counter_0(
        .clk        (clk),
        .resetN     (resetN),
        .count_pulse(add_amount),
        .digit_score(digits[0]),
        .carry_pulse(carry_pulses[0])
        );

    genvar i;
    generate
        // generate up counters for every digit but the first
        for (i = 1; i < DIGIT_AMOUNT; i++) begin : generate_up_counters
            up_counter digit_counter(
                .clk        (clk),
                .resetN     (resetN),
                .count_pulse(carry_pulses[i - 1]),
                .digit_score(digits[i]),
                .carry_pulse(carry_pulses[i])
                );
        end
        // generate a hexss for every digit
        for (i = 0; i < DIGIT_AMOUNT; i++) begin : generate_hexss
            hexss digit_hexss(
                .hexin(digits[i]),
                .ss   (ss[i])
                );
        end
        // generate a square for every digit
        for (i = 0; i < DIGIT_AMOUNT; i++) begin : generate_squares
            square_object #(
                .OBJECT_WIDTH_X(NUMBERS_X_SIZE),
                .OBJECT_HEIGHT_Y(NUMBERS_Y_SIZE)
            ) digit_square_small(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (SMALL_TOPLEFT_X - (i * 10)),
                .topLeftY       (SMALL_TOPLEFT_Y),
                .offsetX        (digit_offsetX_small[i]),
                .offsetY        (digit_offsetY_small[i]),
                .drawingRequest (digits_square_draw_requests_small[i])
                );

            square_object #(
                .OBJECT_WIDTH_X(NUMBERS_X_SIZE << SIZE_MULTIPLIER),
                .OBJECT_HEIGHT_Y(NUMBERS_Y_SIZE << SIZE_MULTIPLIER)
            ) digit_square_large(
                .clk            (clk),
                .resetN         (resetN),
                .pixelX         (pixelX),
                .pixelY         (pixelY),
                .topLeftX       (LARGE_TOPLEFT_X - ((i + 1) * (10 << SIZE_MULTIPLIER))),
                .topLeftY       (LARGE_TOPLEFT_Y),
                .offsetX        (digit_offsetX_large[i]),
                .offsetY        (digit_offsetY_large[i]),
                .drawingRequest (digits_square_draw_requests_large[i])
                );
        end
    endgenerate

    assign digits_square_draw_requests = (!game_over) ? digits_square_draw_requests_small : digits_square_draw_requests_large;
    assign digit_offsetX = (!game_over) ? digit_offsetX_small : (digit_offsetX_large >> SIZE_MULTIPLIER);
    assign digit_offsetY = (!game_over) ? digit_offsetY_small : (digit_offsetY_large >> SIZE_MULTIPLIER);

    // Decide on which square object to pass into the bitmap
    logic chosen_digit_square_DR;
    coordinate chosen_digit_offsetX;
    coordinate chosen_digit_offsetY;
    logic [3:0] chosen_digit;
    always_comb begin
        chosen_digit_square_DR = 1'b0;
        chosen_digit_offsetX = 11'b0;
        chosen_digit_offsetY = 11'b0;
        chosen_digit = 4'b0;
        for (logic unsigned [DIGIT_AMOUNT_WIDTH-1:0] j = 0; j < DIGIT_AMOUNT; j++) begin
            // Only save the offset of the first square
            if (digits_square_draw_requests[j] == 1'b1) begin
                chosen_digit_square_DR = 1'b1;
                chosen_digit_offsetX = digit_offsetX[j];
                chosen_digit_offsetY = digit_offsetY[j];
                chosen_digit = digits[j];
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
        .digit(chosen_digit),
        .drawingRequest(digitDR) 
        );

    assign digitRGB = DIGIT_COLOR;


endmodule