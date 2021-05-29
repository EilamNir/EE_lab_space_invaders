/* Hit detection module
	checks if two or more objects ask to be drawed in the same pixel at the same time and sent a relevent collision as an output
	there are 7 options of different collision:
	- player with boundaries, with enemy_missiles and with the enemy itself
	- any enemy withe the boundaries, with the player missile
	- missiles of both sides with the boundary of the game (make them disappear)
	
	this module makes the collision in a combintoric way and send a synchronic hit pulse as an output
written by Nir Eilam and Gil Kapel, may 18th, 2021 */


module hit_detection(
    input logic	clk,
    input logic	resetN,
    input logic	startOfFrame,  // short pulse every start of frame 30Hz 
    input logic [0:HIT_DETECTION_NUMBER_OF_OBJECTS - 1] hit_request,
	
    output logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] collision,
    output logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] HitPulse 
	);

	`include "parameters.sv"

    logic enemy_missile;
	logic player_missile;
	logic any_missile;
	logic edge_boundaries;
	logic middle_boundary;
	logic all_boundaries;
	logic player;
	logic monster;
	logic asteroid;
	logic boss;
	logic gift;
	logic constrained_enemies;
	logic unconstrained_enemies;
	logic any_enemy;
    assign enemy_missile = hit_request[5] | hit_request[8];
    assign player_missile = hit_request[3];
    assign any_missile = enemy_missile | player_missile;
    assign edge_boundaries = hit_request[0];
    assign middle_boundary = hit_request[1];
    assign all_boundaries = edge_boundaries | middle_boundary;
    assign player = hit_request[2];
    assign monster = hit_request[4];
    assign asteroid = hit_request[6];
    assign boss = hit_request[7];
    assign gift = hit_request[9];
    assign constrained_enemies = boss | monster;
    assign unconstrained_enemies = asteroid;
    assign any_enemy = constrained_enemies | unconstrained_enemies;

    assign collision[COLLISION_ENEMY_MISSILE] = any_enemy & player_missile;
	assign collision[COLLISION_ENEMY_ANY_BOUNDARY] = constrained_enemies & all_boundaries;
	assign collision[COLLISION_MISSILE_FAR_BOUNDARY] = any_missile & edge_boundaries;
	assign collision[COLLISION_PLAYER_ANY_BOUNDARY] = player & all_boundaries;
    assign collision[COLLISION_PLAYER_MISSILE] = player & enemy_missile;
	assign collision[COLLISION_ENEMY_FAR_BOUNDARY] = unconstrained_enemies & edge_boundaries;
	assign collision[COLLISION_PLAYER_ENEMY] = player & any_enemy;
	assign collision[COLLISION_PLAYER_GIFT] = player & gift;
	assign collision[COLLISION_GIFT_BOUNDARY] = gift & edge_boundaries;


	logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] flags ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

	always_ff@(posedge clk or negedge resetN)	
	begin
		if(!resetN)		begin 
			flags <= 4'b0;
			HitPulse <= 4'b0; 
		end 
		else begin 
			HitPulse <= 4'b0; 
			if(startOfFrame) flags <= 4'b0 ; // reset for next time  
			for (int k = 0 ; k < HIT_DETECTION_COLLISION_WIDTH - 1 ; k++) begin
				if (collision[k] && (flags[k] == 1'b0)) begin 
					flags[k] <= 1'b1; // to enter only once 
					HitPulse[k] <= 1'b1 ; 
				end
			end
		end					
	end
endmodule


