/* Missiles module
	get the inital place (the player / the enemy) and generate shots
	its possible to change the speed, direction and amount of the missiles
	this comintoric unit can generate varity amount of missiles to the screen moving in the same frame,
	using draw and movment object for each missile, and drawing them using only one logic with the size of the rgb parameter
	if the missile hits an object (player, enemy) or get out of the boundry, in "shot down" with the a missile active flag
written by Nir Eilam and Gil Kapel, May 30th, 2021 */

module missiles(
    input logic clk,
    input logic resetN,
    input logic shooting_pusle,
    input logic startOfFrame,
	input logic collision,
    input coordinate pixelX,
    input coordinate pixelY,
    input coordinate spaceShip_X,
    input coordinate spaceShip_Y,

    output logic missleDR,
    output RGB missleRGB
);

    `include "parameters.sv"

    parameter RGB MISSILE_COLOR;
    parameter logic [MISSILE_SHOT_AMOUNT_WIDTH-1:0] SHOT_AMOUNT;

    parameter fixed_point X_SPEED;
    parameter fixed_point Y_SPEED;
    parameter coordinate X_OFFSET;
    parameter coordinate Y_OFFSET;


    coordinate [SHOT_AMOUNT-1:0] topLeftX;
    coordinate [SHOT_AMOUNT-1:0] topLeftY;
    logic [SHOT_AMOUNT-1:0] draw_requests;
    logic [SHOT_AMOUNT-1:0] missile_active;
    logic [SHOT_AMOUNT-1:0] fire_commands;

    // Choose which missile to send the key press to
    always_comb begin
        fire_commands = SHOT_AMOUNT'('b0);
        for (logic [MISSILE_SHOT_AMOUNT_WIDTH-1:0] j = 0; j < SHOT_AMOUNT; j++) begin
            // Only send the key press to the first available shot
            if (missile_active[j] == 1'b0) begin
                fire_commands[j] = shooting_pusle;
                break;
            end
        end
    end

    genvar i;
    generate
        for (i = 0; i < SHOT_AMOUNT; i++) begin : generate_missiles
            missile_movement #(.X_SPEED(X_SPEED), .Y_SPEED(Y_SPEED), .X_OFFSET(X_OFFSET), .Y_OFFSET(Y_OFFSET)) missile_movement_inst (
                .clk			(clk),
                .resetN			(resetN),
                .startOfFrame	(startOfFrame),
                .shooting_pulse	(fire_commands[i]),
                .collision		(collision & draw_requests[i]), // Only collide the missile that asked to be drawn in the collision pixel
                .spaceShip_X	(spaceShip_X),
                .spaceShip_Y	(spaceShip_Y),
                .topLeftX		(topLeftX[i]),
                .topLeftY		(topLeftY[i]),
                .missile_active	(missile_active[i])
                );

            square_object #(.OBJECT_WIDTH_X(2), .OBJECT_HEIGHT_Y(5)) square_object_isnt (
                .clk			(clk),
                .resetN			(resetN),
                .pixelX			(pixelX),
                .pixelY			(pixelY),
                .topLeftX		(topLeftX[i]),
                .topLeftY		(topLeftY[i]),
                .drawingRequest	(draw_requests[i])
                );
        end
    endgenerate

    // Only draw the pixel if there is at least one missile that wants to be drawn
    assign missleRGB = MISSILE_COLOR;
    assign missleDR = |(draw_requests & missile_active);

endmodule
