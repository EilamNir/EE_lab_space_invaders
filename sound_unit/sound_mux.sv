// sound_mux --- may 17th, 2021, Gil Kapel
//-- This module gets sound requests from varity of a-synchronous signal from - keyboard, 
//-- hit detector and maybe other staff and pass the audio unit the right signal


module  sound_mux (
    input logic clk,
    input logic resetN,
    input logic [0:1] sound_requests,
    input logic startOfFrame,
    output logic [3:0] sound_signal,
    output logic enable_sound
);

    parameter unsigned NUMBER_OF_OBJECTS = 4;
    parameter MONSTER_HIT_SOUND = 4'd7;
    parameter SPACESHIP_HIT_SOUND = 4'd1;

    parameter unsigned SOUND_TIMER_WIDTH = 6;
    parameter MONSTER_HIT_SOUND_TIME = SOUND_TIMER_WIDTH'('d6);
    parameter SPACESHIP_HIT_SOUND_TIME = SOUND_TIMER_WIDTH'('d25);


    logic [SOUND_TIMER_WIDTH - 1:0] sound_timer;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            // Reset and disable sound
            sound_signal  <= 4'b0;
            enable_sound <= 1'b0;
            sound_timer <= 0;
        end else begin
            if (sound_requests[1] == 1'b1) begin
                sound_signal <= SPACESHIP_HIT_SOUND;
                sound_timer <= SPACESHIP_HIT_SOUND_TIME;
                enable_sound <= 1'b1;
            end else if (sound_requests[0] == 1'b1) begin
                sound_signal <= MONSTER_HIT_SOUND;
                sound_timer <= MONSTER_HIT_SOUND_TIME;
                enable_sound <= 1'b1;
            end else if (sound_timer != 0) begin
                // We only check for startOfFrame if sound_timer is not zero, so we will not reach
                // the else and disable the sound signal every time startOfFrame is zero
                if (startOfFrame) begin
                    // Reduce the sound timer by one every frame
                    sound_timer <= SOUND_TIMER_WIDTH'(sound_timer - 1);
                end
            end else begin
                sound_signal <= 4'b0;
                enable_sound <= 1'b0;
            end
        end
    end

endmodule
