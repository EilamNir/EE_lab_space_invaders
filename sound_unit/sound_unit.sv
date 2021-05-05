module sound_unit
(
	input logic AUD_ADCDAT,
    output logic [AUDIO_WIDTH - 1:0] AUDOUT
);

    parameter unsigned AUDIO_WIDTH = 8;

    // TODO: Change this to actually play sounds.
    // This is here right now only to make the compilation not throw an error
    // that AUDOUT is not set anywhere and that AUD_ADCDAT is not used.
    assign AUDOUT = AUDIO_WIDTH'(AUD_ADCDAT);
endmodule
