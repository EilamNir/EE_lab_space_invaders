
module player_lives(
    input logic clk,
    input logic resetN,
	input logic enable,
    input logic startOfFrame,
    input logic missile_collision,

    output logic player_faded,
    output logic player_dead
);
    parameter unsigned LIVES_AMOUNT_WIDTH = 3;
    parameter logic [LIVES_AMOUNT_WIDTH - 1:0] LIVES_AMOUNT = 4;
    logic [LIVES_AMOUNT_WIDTH - 1:0] current_lives;

    parameter unsigned PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH = 6;
    parameter logic [PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH - 1:0] PLAYER_DAMAGED_FRAME_AMOUNT = 30;
    logic [PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH - 1:0] damaged_timeout;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            current_lives <= LIVES_AMOUNT;
            player_faded <= 1'b0;
            player_dead <= 1'b0;
            damaged_timeout <= 0;
        end else if(enable) begin
            // Reset the player damaged flag when the timeout is over
            if (damaged_timeout == 0) begin
                player_faded <= 1'b0;
            end else if (startOfFrame) begin
                // Reduce the damaged timeout by one every frame
                damaged_timeout <= PLAYER_DAMAGED_FRAME_AMOUNT_WIDTH'(damaged_timeout - 1);
                // Flip between the player being faded and not faded every few frames
                if (damaged_timeout[3:0] == 4'b1000) begin
                    player_faded <= ~player_faded;
                end
            end

            // Check if the player should be dead
            if (current_lives == 0) begin
                // Mark the player as dead
                player_dead <= 1'b1;
                // Dead player is always faded
                player_faded <= 1'b1;
            end else if (missile_collision && (damaged_timeout == 0)) begin // Check if the player hit a missile while not damaged
                // Mark the player as damaged
                player_faded <= 1'b1;
                // Start the damaged timeout
                damaged_timeout <= PLAYER_DAMAGED_FRAME_AMOUNT;
                // Remove one life from the player
                current_lives <= LIVES_AMOUNT_WIDTH'(current_lives - 1);
            end


        end
    end

endmodule
