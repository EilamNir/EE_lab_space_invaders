
module hit_detection(
    input logic	clk,
    input logic	resetN,
    input logic	startOfFrame,  // short pulse every start of frame 30Hz 
    input logic [0:NUMBER_OF_OBJECTS - 1] hit_request,
	
    output logic [COLLISION_WIDTH - 1:0] collision,
    output logic [COLLISION_WIDTH - 1:0] HitPulse 
	);

    parameter unsigned NUMBER_OF_OBJECTS = 7;
    parameter unsigned COLLISION_WIDTH = 7;


    logic eneny_missile;
	logic player_missile;
	logic any_missile;
	logic edge_boundaries;
	logic middle_boundary;
	logic all_boundaries;
	logic player;
	logic monster;
	logic asteroid;
	logic boss;
	logic constrained_enemies;
	logic unconstrained_enemies;
	logic any_enemy;
    assign eneny_missile = hit_request[3] | hit_request[6];
    assign player_missile = hit_request[1];
    assign any_missile = eneny_missile | player_missile;
    assign edge_boundaries = hit_request[7];
    assign middle_boundary = hit_request[8];
    assign all_boundaries = edge_boundaries | middle_boundary;
    assign player = hit_request[0];
    assign monster = hit_request[2];
    assign asteroid = hit_request[4];
    assign boss = hit_request[5];
    assign constrained_enemies = boss | monster;
    assign unconstrained_enemies = asteroid;
    assign any_enemy = constrained_enemies | unconstrained_enemies;

    assign collision[0] = any_enemy & player_missile;
	assign collision[1] = constrained_enemies & all_boundaries;
	assign collision[2] = any_missile & edge_boundaries;
	assign collision[3] = player & all_boundaries;
    assign collision[4] = player & eneny_missile;
	assign collision[5] = unconstrained_enemies & edge_boundaries;
	assign collision[6] = player & any_enemy;


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
			for (int k = 0 ; k < COLLISION_WIDTH - 1 ; k++) begin
				if (collision[k] && (flags[k] == 1'b0)) begin 
					flags[k] <= 1'b1; // to enter only once 
					HitPulse[k] <= 1'b1 ; 
				end
			end
		end					
	end
endmodule


