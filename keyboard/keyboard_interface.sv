module keyboard_interface
(
    input logic clk,
    input logic resetN,
    input logic PS2_CLK,
    input logic PS2_DAT,

    output logic [8:0] keyCode,
    output logic make,
    output logic brake
);

    `include "parameters.sv"

    logic kbd_clk;
    logic[7:0] d_bitrec;
    logic enb_byterec;

    lpf lpf_inst (
        .clk(clk),
        .resetN(resetN),
        .in(PS2_CLK),
        .out_filt(kbd_clk)
        );

    bitrec bitrec_inst (
        .clk(clk),
        .resetN(resetN),
        .kbd_dat(PS2_DAT),
        .kbd_clk(kbd_clk),
        .dout(d_bitrec),
        .dout_new(enb_byterec)
        );

    byterec byterec_inst (
        .clk(clk),
        .resetN(resetN),
        .din_new(enb_byterec),
        .din(d_bitrec),
        .keyCode(keyCode),
        .make(make),
        .brakk(brake)
        );

endmodule


