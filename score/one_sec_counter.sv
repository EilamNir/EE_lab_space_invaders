// (c) Technion IIT, Department of Electrical Engineering 2020 

// Implements a slow clock as an one-second counter with
// a one-second output pulse and a 0.5 Hz duty50 output
 
 module one_sec_counter(
	input  logic clk, 
	input  logic resetN, 
	input logic enable,
	
	output logic one_sec,
	output logic duty50
   );
	
	int oneSecCount ;
	
//       ----------------------------------------------	
	localparam oneSecVal = 26'd25_000_000; 
//       ----------------------------------------------	
		
   always_ff @( posedge clk or negedge resetN )
   begin
		if ( !resetN ) begin
			one_sec <= 1'b0;
			duty50 <= 1'b0;
			oneSecCount <= 26'd0;
		end 
		// executed once every clock 	
		else if (enable) begin
			if (oneSecCount >= oneSecVal) begin
				one_sec <= 1'b1;
				duty50 <= ~duty50;
				oneSecCount <= 0;
			end
			else begin
				oneSecCount <= oneSecCount + 1;
				one_sec <= 1'b0;
			end
		end 
	end 
endmodule