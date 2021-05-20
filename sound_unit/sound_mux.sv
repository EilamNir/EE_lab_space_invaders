// sound_mux --- may 17th, 2021, Gil Kapel
//-- This module gets sound requests from varity of a-synchronous signal from - keyboard, 
//-- hit detector and maybe other staff and pass the audio unit the right signal


module  sound_mux (
    input logic clk,
    input logic resetN,
    input logic [0:1] sound_requests,
    output logic [3:0] sound_signal
);

    parameter unsigned NUMBER_OF_OBJECTS = 4;
	parameter MONSTER_HIT_SOUND = 4'b0001;
	parameter SPACESHIP_HIT_SOUND = 4'b1101;



    // Save the RGB value for this index of the object to draw
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            // Reset RGB to zeros on reset
            sound_signal  <= 4'b0;
        end else begin
			if (sound_requests[0] == 1'b1) sound_signal <= MONSTER_HIT_SOUND;
			else if (sound_requests[1] == 1'b1) sound_signal <= SPACESHIP_HIT_SOUND;
			else sound_signal <= 4'b0;
        end
    end

endmodule
