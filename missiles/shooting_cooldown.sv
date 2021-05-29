/* shooting_cooldown module
	delay the shot
written by Nir Eilam and Gil Kapel, May 30th, 2021 */

module shooting_cooldown(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
    input logic fire_command,
    input logic [SHOOTING_COOLDOWN_WIDTH - 1:0] shooting_cooldown,

    output logic shooting_pusle
);

    `include "parameters.sv"

    logic [SHOOTING_COOLDOWN_WIDTH - 1:0] count_down;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            count_down <= SHOOTING_COOLDOWN_WIDTH'('b0);
            shooting_pusle <= 1'b0;
        end else begin
			
			// Default to not shooting
            shooting_pusle <= 1'b0;

            // Check if we are ready to shoot
            if (fire_command && (count_down == 0)) begin
                // Fire a pulse
                shooting_pusle <= 1'b1;
                // Start the cooldown after shooting
                count_down <= shooting_cooldown;
            end else if (startOfFrame && (count_down != 0)) begin
                // If we are not shooting and the cooldown is active, reduce it
                count_down <= SHOOTING_COOLDOWN_WIDTH'(count_down - 1);
            end
        end
    end

endmodule
