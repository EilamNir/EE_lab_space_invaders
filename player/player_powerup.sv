
module player_powerup (
    input logic clk,
    input logic resetN,
    input logic powerup,
    input logic giftIsHit,

    output logic [SHOOTING_COOLDOWN_WIDTH - 1:0] shooting_cooldown,
    output logic double_missile_speed
);

    `include "parameters.sv"

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            shooting_cooldown <= PLAYER_SHOT_COOLDOWN;
            double_missile_speed <= 1'b0;
        end else begin

            if(giftIsHit) begin
                if (powerup == 1'b1) begin
                    shooting_cooldown <= PLAYER_ALTERNATIVE_SHOT_COOLDOWN;
                end else begin
                    double_missile_speed <= 1'b1;
                end
            end
        end
    end

endmodule


