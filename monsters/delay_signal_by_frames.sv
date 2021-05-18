
module delay_signal_by_frames(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
    input logic input_signal,

    output logic output_signal
);
    parameter unsigned FRAMES_DELAY_WIDTH = 5;
    parameter logic [FRAMES_DELAY_WIDTH - 1:0] DELAY_FRAMES_AMOUNT = 5;

    logic [FRAMES_DELAY_WIDTH - 1:0] delay_counter;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            delay_counter <= DELAY_FRAMES_AMOUNT;
            output_signal <= 1'b0;
        end else begin
            // Check if we need to reduce the delay
            if (startOfFrame && input_signal) begin
                if (delay_counter != 0) begin
                    delay_counter <= FRAMES_DELAY_WIDTH'(delay_counter - 1);
                end else begin
                    output_signal = 1'b1;
                end
            end
        end
    end

endmodule
