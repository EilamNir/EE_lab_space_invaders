module keyboard_interface 	
 ( 
	input logic clk,
	input logic resetN, 
	input logic PS2_CLK,	
	input logic PS2_DAT,
	
	output logic keyCode[8:0],
	output logic make,
	output logic brake
  ) ;
	logic kbd_clk;
	lpf lpf_inst (
		.clk(clk),
		.resetN(resetN),
		.in(PS2_CLK),
		.out_filt(kbd_clk)
		);
	
	logic d_bitrec[7:0];
	logic enb_byterec;
	
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


