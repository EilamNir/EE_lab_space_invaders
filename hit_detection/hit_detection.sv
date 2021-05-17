
module hit_detection(
    input logic	clk,
    input logic	resetN,
    input logic	startOfFrame,  // short pulse every start of frame 30Hz 
    input logic [0:NUMBER_OF_OBJECTS - 1] hit_request,
	
    output logic [COLLISION_WIDTH - 1:0] collision,
    output logic [COLLISION_WIDTH - 1:0] HitPulse 
	);

    parameter unsigned NUMBER_OF_OBJECTS = 5;
    parameter unsigned COLLISION_WIDTH = 5;

    assign collision[0] = hit_request[2] && hit_request[1]; // monster and player_missile
	assign collision[1] = hit_request[2] && (hit_request[4] || hit_request[5]); // monster and boundry
	assign collision[2] = (hit_request[1] | hit_request[3]) && hit_request[4]; // any missile and boundry
	assign collision[3] = hit_request[0] && (hit_request[4] || hit_request[5]); // player and boundry
    assign collision[4] = hit_request[0] && hit_request[3]; // player and monster_missile


	logic [COLLISION_WIDTH - 1:0] flags ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

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


