
module missiles(
    input logic clk,
    input logic resetN,
    input logic [KEYCODE_WIDTH - 1:0] keyCode,
    input logic make,
    input logic brake,
    input logic startOfFrame,
	input logic [3:0] collision,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [10:0] spaceShip_X,
    input logic [10:0] spaceShip_Y,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter STR_SHOT_KEY = 9'h15A; // enter key
    parameter unsigned KEYCODE_WIDTH = 9;
    parameter unsigned RGB_WIDTH = 8;
    parameter [RGB_WIDTH - 1:0] MISSILE_COLOR = 8'h1F;
    parameter unsigned SHOT_AMOUNT = 7;
    parameter unsigned SHOOTING_COOLDOWN_WIDTH = 4;
    parameter logic [SHOOTING_COOLDOWN_WIDTH - 1:0] SHOOTING_COOLDOWN = 15;

    logic [SHOOTING_COOLDOWN_WIDTH - 1:0] shooting_cooldown;

    logic [10:0] offsetX;
    logic [10:0] offsetY;

    logic shotKeyIsPressed;

    keyToggle_decoder #(.KEY_VALUE(STR_SHOT_KEY)) control_strShot_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(shotKeyIsPressed)
        );

    logic signed [SHOT_AMOUNT-1:0] [10:0] topLeftX;
    logic signed [SHOT_AMOUNT-1:0] [10:0] topLeftY;
    logic [SHOT_AMOUNT-1:0] draw_requests;
    logic [SHOT_AMOUNT-1:0] missile_active;
    logic [SHOT_AMOUNT-1:0] activation_pulse;
    logic [SHOT_AMOUNT-1:0] key_presses;

    // Choose which missile to send the key press to
    always_comb begin
        key_presses = SHOT_AMOUNT'('b0);
        for (int j = 0; j < SHOT_AMOUNT; j++) begin
            if ((missile_active[j] == 1'b0) && // Only send the key press to the first available shot
                (shooting_cooldown == 0) && (activation_pulse == 0)) begin // Only send the key press if the cooldown is not active
                key_presses[j] = shotKeyIsPressed;
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
                .shotKeyIsPress(key_presses[i]),
                .collision((collision[0] | collision[2]) & draw_requests[i]), // Only collide the missile that asked to be drawn in the collision pixel
                .spaceShip_X(spaceShip_X),
                .spaceShip_Y(spaceShip_Y),
                .topLeftX(topLeftX[i]),
                .topLeftY(topLeftY[i]),
                .missile_active(missile_active[i]),
                .activation_pulse(activation_pulse[i])
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

    // Missile fire cooldown
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            shooting_cooldown <= SHOOTING_COOLDOWN_WIDTH'('b0);
        end else begin
            if (activation_pulse != 0) begin
                // Start the cooldown after shooting
                shooting_cooldown <= SHOOTING_COOLDOWN;
            end else if (startOfFrame && (shooting_cooldown != 0)) begin
                // If we are not shooting and the cooldown is active, reduce it
                shooting_cooldown <= SHOOTING_COOLDOWN_WIDTH'(shooting_cooldown - 1);
            end
        end
    end

endmodule
