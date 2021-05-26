
module game_timer (
    input logic clk,
    input logic resetN,
    input logic enable,

    output logic [DIGIT_WIDTH - 1:0] seconds,
    output logic [DIGIT_WIDTH - 1:0] minutes
);
    parameter unsigned DIGIT_WIDTH = 6;
    parameter logic [DIGIT_WIDTH - 1:0] SECONDS_PER_MIN = 60;
	logic one_sec;
	
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            seconds <= 0;
            minutes <= 0;
        end else begin
            if (enable && one_sec) begin
				if()
                if (seconds + 1'b1 < SECONDS_PER_MIN) begin
                    // Add score to the current digit
                    seconds <= seconds + 1'b1;
                end else begin
                    // Reset the current digit and output a carry pulse
                    seconds <= 1'b0;
                    minutes <= minutes + 1'b1;
                end
            end
        end
    end
	
	one_sec_counter one_sec_counter_inst(
		.clk(clk),
		.resetN(resetN),
		.one_sec(one_sec));
		
endmodule
