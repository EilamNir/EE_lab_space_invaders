// sound_mux --- may 17th, 2021, Gil Kapel
//-- This module gets sound requests from varity of a-synchronous signal from - keyboard, 
//-- hit detector and maybe other staff and pass the audio unit the right signal


module  sound_mux (
    input logic clk,
    input logic resetN,
    input logic [3:0] sound_requests,
    output logic [3:0] sound_signal
);

    parameter unsigned NUMBER_OF_OBJECTS = 4;

    int first_sound_request_index;
    logic any_sound_request;

    // Go over the sound requests and generate the first signal that wants to be heard
    always_comb begin
        first_sound_request_index = 0;
        any_sound_request = 1'b0;
        for (int i = 0; i < NUMBER_OF_OBJECTS; i++) begin
            if (sound_requests[i] == 1'b1) begin
                first_sound_request_index = i;
                any_sound_request = 1'b1;
                break;
            end
        end
    end

    // Save the RGB value for this index of the object to draw
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            // Reset RGB to zeros on reset
            sound_signal  <= 4'b0;
        end else begin
			if (any_sound_request == 1'b1) begin
                // the request with the highest priority
                sound_signal = sound_signal[first_sound_request_index];
            end
        end
    end

endmodule
