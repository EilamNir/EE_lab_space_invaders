
module hit_detection(
    input logic	clk,
    input logic	resetN,
    input logic	startOfFrame,  // short pulse every start of frame 30Hz 
    input logic [0:NUMBER_OF_OBJECTS - 1] draw_requests,
	
    output logic [3:0] collision,
    output logic [3:0] HitPulse 
	);

    parameter unsigned NUMBER_OF_OBJECTS = 5;

    assign collision[0] = draw_requests[2] && draw_requests[1]; // monster and missile
	assign collision[1] = draw_requests[2] && draw_requests[3]; // monster and boundry
	assign collision[2] = draw_requests[2] && draw_requests[3]; // missile and boundry
	assign collision[3] = draw_requests[0] && (draw_requests[3] || draw_requests[4]); // player and boundry

	
	logic [3:0] flags ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

	always_ff@(posedge clk or negedge resetN)	
	begin
		if(!resetN)		begin 
			flags <= 4'b0;
			HitPulse <= 4'b0; 
		end 
		else begin 
			HitPulse <= 4'b0; 
			if(startOfFrame) flags <= 4'b0 ; // reset for next time  
			for (int k = 0 ; k < NUMBER_OF_OBJECTS - 1 ; k++) begin
				if (collision[k] && (flags[k] == 1'b0)) begin 
					flags[k] <= 1'b1; // to enter only once 
					HitPulse[k] <= 1'b1 ; 
				end
			end
		end					
	end
endmodule


