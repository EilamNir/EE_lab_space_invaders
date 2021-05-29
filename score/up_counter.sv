/* up counter module

	simple counter that rise up until a max value for digit that can be change
	using a carry bit	

written by Nir Eilam and Gil Kapel, May 20th, 2021 */

module up_counter (
    input logic clk,
    input logic resetN,
    input logic [2:0] count_pulse,

    output logic [UP_COUNTER_DIGIT_WIDTH - 1:0] digit_score,
    output logic carry_pulse
);

    `include "parameters.sv"

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            digit_score <= 0;
            carry_pulse <= 0;
        end else begin
            // Default assignment of 0 to carry pulse
            carry_pulse <= 0;

            if (count_pulse) begin
                if (digit_score + count_pulse <= MAX_VALUE_PER_DIGIT) begin
                    // Add score to the current digit
                    digit_score <= digit_score + count_pulse;
                end else begin
                    // Reset the current digit and output a carry pulse
                    digit_score <= digit_score + count_pulse - MAX_VALUE_PER_DIGIT - 1'b1;
                    carry_pulse <= carry_pulse + 1'b1;
                end
            end
        end
    end



endmodule
