
module up_counter (
    input logic clk,
    input logic resetN,
    input logic count_pulse,

    output logic [DIGIT_WIDTH - 1:0] digit_score,
    output logic carry_pulse
);
    parameter unsigned DIGIT_WIDTH = 4;
    parameter unsigned MAX_SCORE_PER_DIGIT = 9;



    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            digit_score <= 0;
            carry_pulse <= 0;
        end else begin
            // Default assignment of 0 to carry pulse
            carry_pulse <= 0;

            if (count_pulse) begin
                if (digit_score < MAX_SCORE_PER_DIGIT) begin
                    // Add one to the current digit
                    digit_score <= digit_score + 1'b1;
                end else begin
                    // Reset the current digit and output a carry pulse
                    digit_score <= 0;
                    carry_pulse <= 1;
                end
            end
        end
    end



endmodule
