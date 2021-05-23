// Sound_unit --- may 17th, 2021, Gil Kapel
//-- This module gets sound requests from collisions
//-- and transform them into sinus frequency to an output speaker - using the build in audio_codec_controller module



module sound_unit
(
    input logic clk,
    input logic resetN,
    input logic [0:1] sound_requests,
    input logic startOfFrame,
    input logic AUD_ADCDAT,

    output logic [7:0] AUDOUT
);

    logic [3:0] sound_signal;
    logic [9:0] preScaleValue;
    logic slowEnPulse;
    logic slowEnPulse_d; // a delayed enalbe to avoid read and write DPRAM at the same time
    logic [7:0] freq;
    logic [15:0] soundData;
    logic enable_sound;

    sound_mux sound_mux_inst (
        .clk(clk),
        .resetN(resetN),
        .sound_requests(sound_requests),
        .startOfFrame(startOfFrame),
        .sound_signal(sound_signal),
        .enable_sound(enable_sound)
    );

    ToneDecoder tone_dec_inst(
        .tone(sound_signal),
        .preScaleValue(preScaleValue)
    );

    prescaler prescaler_inst(
        .clk(clk),
        .resetN(resetN),
        .preScaleValue(preScaleValue),
        .slowEnPulse(slowEnPulse),
        .slowEnPulse_d(slowEnPulse_d)
    );

    addr_counter addr_counter_inst(
        .clk(clk),
        .resetN(resetN),
        .en(enable_sound),
        .en1(slowEnPulse),
        .addr(freq)    // sin table index will choose the right frequency
    );

    sintable sintable_inst(
        .clk(clk),
        .resetN(resetN),
        .addr(freq),
        .Q(soundData)
    );

    audio_codec_controller audio_controller_inst(
        .CLOCK_50(clk),
        .resetN(resetN),
        .MICROPHON_ON(0),
        .dacdata_left(soundData),
        .dacdata_right(soundData),
        .AUD_ADCDAT(AUD_ADCDAT),
        .MICROPHON_LED(AUDOUT[0]),
        .AUD_ADCLRCK(AUDOUT[1]),
        .AUD_BCLK(AUDOUT[2]),
        .AUD_DACDAT(AUDOUT[3]),
        .AUD_DACLRCK(AUDOUT[4]),
        .AUD_XCK(AUDOUT[5]),
        .AUD_I2C_SCLK(AUDOUT[6]),
        .AUD_I2C_SDAT(AUDOUT[7])
    );

endmodule
