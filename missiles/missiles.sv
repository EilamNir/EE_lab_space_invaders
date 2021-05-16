
module missiles(
    input logic clk,
    input logic resetN,
    input logic shooting_pusle,
    input logic startOfFrame,
	input logic [3:0] collision,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [10:0] spaceShip_X,
    input logic [10:0] spaceShip_Y,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter unsigned RGB_WIDTH = 8;
    parameter [RGB_WIDTH - 1:0] MISSILE_COLOR = 8'h1F;
    parameter unsigned SHOT_AMOUNT = 7;

    logic signed [SHOT_AMOUNT-1:0] [10:0] topLeftX;
    logic signed [SHOT_AMOUNT-1:0] [10:0] topLeftY;
    logic [SHOT_AMOUNT-1:0] draw_requests;
    logic [SHOT_AMOUNT-1:0] missile_active;
    logic [SHOT_AMOUNT-1:0] fire_commands;

    // Choose which missile to send the key press to
    always_comb begin
        fire_commands = SHOT_AMOUNT'('b0);
        for (int j = 0; j < SHOT_AMOUNT; j++) begin
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
            missile_movement missile_movement_inst (
                .clk(clk),
                .resetN(resetN),
                .startOfFrame(startOfFrame),
                .shooting_pulse(fire_commands[i]),
                .collision((collision[0] | collision[2]) & draw_requests[i]), // Only collide the missile that asked to be drawn in the collision pixel
                .spaceShip_X(spaceShip_X),
                .spaceShip_Y(spaceShip_Y),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i]),
                .missile_active(missile_active[i]),
                );

            square_object #(.OBJECT_WIDTH_X(2), .OBJECT_HEIGHT_Y(5)) square_object_isnt (
                .clk(clk),
                .resetN(resetN),
                .pixelX(pixelX),
                .pixelY(pixelY),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i]),
                .drawingRequest(draw_requests[i])
                );
        end
    endgenerate

    // Only draw the pixel if there is at least one missile that wants to be drawn
    assign missleRGB = MISSILE_COLOR;
    assign missleDR = |(draw_requests & missile_active);

endmodule
