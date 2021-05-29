/* player lives module

	count each time there is a coliision between the player and an enemy missile or asteroid 
	and sent a pulse when the amount reaches a certian amount
	sent a delay pulse to image a real hit
	
written by Nir Eilam and Gil Kapel, May 18th, 2021 */


module player_lives(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
    input logic missile_collision,

    output logic [LIVES_AMOUNT_WIDTH - 1:0] remaining_lives,
    output logic player_faded,
    output logic player_damaged,
    output logic player_dead
);

    `include "parameters.sv"

    parameter unsigned LIVES_AMOUNT_WIDTH;
    parameter logic [LIVES_AMOUNT_WIDTH - 1:0] LIVES_AMOUNT;

    parameter unsigned DAMAGED_FRAME_AMOUNT_WIDTH;
    parameter logic [DAMAGED_FRAME_AMOUNT_WIDTH - 1:0] DAMAGED_FRAME_AMOUNT;
    logic [DAMAGED_FRAME_AMOUNT_WIDTH - 1:0] damaged_timeout;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            remaining_lives <= LIVES_AMOUNT;
            player_faded <= 1'b0;
            player_damaged <= 1'b0;
            player_dead <= 1'b0;
            damaged_timeout <= 0;
        end else begin
            // Reset the player damaged flag when the timeout is over
            if (damaged_timeout == 0) begin
                player_faded <= 1'b0;
                player_damaged <= 1'b0;
            end else if (startOfFrame) begin
                // Reduce the damaged timeout by one every frame
                damaged_timeout <= DAMAGED_FRAME_AMOUNT_WIDTH'(damaged_timeout - 1);
                // Flip between the player being faded and not faded every few frames
                if (damaged_timeout[3:0] == 4'b1000) begin
                    player_faded <= ~player_faded;
                end
            end

            // Check if the player should be dead
            if (remaining_lives == 0) begin
                // Mark the player as dead
                player_dead <= 1'b1;
                // Dead player is always faded
                player_faded <= 1'b1;
                player_damaged <= 1'b1;
            end else if (missile_collision && (damaged_timeout == 0)) begin // Check if the player hit a missile while not damaged
                // Mark the player as damaged
                player_faded <= 1'b1;
                player_damaged <= 1'b1;
                // Start the damaged timeout
                damaged_timeout <= DAMAGED_FRAME_AMOUNT;
                // Remove one life from the player
                remaining_lives <= LIVES_AMOUNT_WIDTH'(remaining_lives - 1);
            end


        end
    end

endmodule
