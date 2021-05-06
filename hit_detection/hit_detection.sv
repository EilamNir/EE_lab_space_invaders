
module hit_detection(
    input logic	clk,
    input logic	resetN,
    input logic	startOfFrame,  // short pulse every start of frame 30Hz 
    input logic [0:NUMBER_OF_OBJECTS - 1] draw_requests,
	
    output logic [3:0] collision,
    output logic [3:0] HitPulse 
	);

    parameter unsigned NUMBER_OF_OBJECTS = 5;

    assign collision[0] = draw_requests[2] && draw_requests[1]; // monster1 and missile
	assign collision[1] = draw_requests[3] && draw_requests[1]; // monster2 and missile
	assign collision[2] = draw_requests[2] && draw_requests[4]; // monster1 and boundry
	assign collision[3] = draw_requests[0] && draw_requests[5]; // player and boundry

	
	logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

	always_ff@(posedge clk or negedge resetN)	
	begin
		if(!resetN)		begin 
			flag <= 1'b0;
			HitPulse <= 4'b0; 
		end 
		else begin 
			for (int j = 0 ; j < NUMBER_OF_OBJECTS-2 ; j++) 
				HitPulse[j] <= 1'b0; 
			if(startOfFrame) 
				for (int k = 0 ; k < NUMBER_OF_OBJECTS-2 ; k++) 
					if (collision[k] && (flag == 1'b0)) begin 
						flag <= 1'b1; // to enter only once 
						HitPulse[k] <= 1'b1 ; 
					end
				flag <= 1'b0 ; // reset for next time  

		end					
	end
endmodule


