
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


endmodule
