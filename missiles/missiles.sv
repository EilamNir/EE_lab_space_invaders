
module missiles(
    input logic clk,
    input logic resetN,
    input logic [KEYCODE_WIDTH - 1:0] keyCode,
    input logic make,
    input logic brake,
    input logic startOfFrame,
    input logic startOfPixel,
    input logic collision,
    input logic [10:0] pixelX,
    input logic [10:0] pixelY,
    input logic [10:0] spaceShip_X,
    input logic [10:0] spaceShip_Y,

    output logic missleDR,
    output logic [7:0] missleRGB
);

    parameter STR_SHOT_KEY = 9'h070; // digit 0
    parameter unsigned KEYCODE_WIDTH = 9;
    parameter unsigned RGB_WIDTH = 8;
    parameter [RGB_WIDTH - 1:0] MISSILE_COLOR = 8'h1F;
    parameter unsigned SHOT_AMOUNT = 10;

    logic [10:0] offsetX;
    logic [10:0] offsetY;

    logic strShotKeyIsPress;

    keyToggle_decoder #(.KEY_VALUE(STR_SHOT_KEY)) control_strShot_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(strShotKeyIsPress)
        );

    logic [5:0] current_missile;

    logic [15:0] location_x_ram_data_in;
    logic [6:0] location_x_ram_rdaddress;
    logic location_x_ram_rden;
    logic [6:0] location_x_ram_wraddress;
    logic location_x_ram_wren;
    logic [15:0] location_x_ram_data_out;
    dpram location_x_ram(
        .clock(clk),
        .data(location_x_ram_data_in),
        .rdaddress(location_x_ram_rdaddress),
        .rden(location_x_ram_rden),
        .wraddress(location_x_ram_wraddress),
        .wren(location_x_ram_wren),
        .q(location_x_ram_data_out));
    logic [15:0] location_y_ram_data_in;
    logic [6:0] location_y_ram_rdaddress;
    logic location_y_ram_rden;
    logic [6:0] location_y_ram_wraddress;
    logic location_y_ram_wren;
    logic [15:0] location_y_ram_data_out;
    dpram location_y_ram(
        .clock(clk),
        .data(location_y_ram_data_in),
        .rdaddress(location_y_ram_rdaddress),
        .rden(location_y_ram_rden),
        .wraddress(location_y_ram_wraddress),
        .wren(location_y_ram_wren),
        .q(location_y_ram_data_out));
    logic [15:0] missile_active_ram_data_in;
    logic [6:0] missile_active_ram_rdaddress;
    logic missile_active_ram_rden;
    logic [6:0] missile_active_ram_wraddress;
    logic missile_active_ram_wren;
    logic [15:0] missile_active_ram_data_out;
    dpram missile_active_ram(
        .clock(clk),
        .data(missile_active_ram_data_in),
        .rdaddress(missile_active_ram_rdaddress),
        .rden(missile_active_ram_rden),
        .wraddress(missile_active_ram_wraddress),
        .wren(missile_active_ram_wren),
        .q(missile_active_ram_data_out));
    logic [15:0] shot_fired_ram_data_in;
    logic [6:0] shot_fired_ram_rdaddress;
    logic shot_fired_ram_rden;
    logic [6:0] shot_fired_ram_wraddress;
    logic shot_fired_ram_wren;
    logic [15:0] shot_fired_ram_data_out;
    dpram shot_fired_ram(
        .clock(clk),
        .data(shot_fired_ram_data_in),
        .rdaddress(shot_fired_ram_rdaddress),
        .rden(shot_fired_ram_rden),
        .wraddress(shot_fired_ram_wraddress),
        .wren(shot_fired_ram_wren),
        .q(shot_fired_ram_data_out));


    missile_movement missile_movement_inst (
        .clk(clk),
        .resetN(resetN),
        .startOfFrame(startOfFrame),
        .shotKeyIsPress(strShotKeyIsPress), // TODO: Fix this so only one missile will be shot at a time
        .collision(collision), // TODO: Fix this so only the missile that collided will get 1 here
        .current_location_x(location_x_ram_data_out),
        .current_location_y(location_y_ram_data_out),
        .current_speed_x(0),
        .current_speed_y(-256),
        // .current_missile_active(missile_active_ram_data_out), // TODO: Uncomment this
        .current_missile_active(1'b1), // TODO: Remove this
        .current_shot_fired(shot_fired_ram_data_out),
        .spaceShip_X(spaceShip_X),
        .spaceShip_Y(spaceShip_Y),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .new_location_x(location_x_ram_data_in),
        .new_location_y(location_y_ram_data_in),
        // .new_speed_x(new_speed_x), // TODO: Decide if we need this or not, and either remove or fix this 
        // .new_speed_y(new_speed_y), // TODO: Decide if we need this or not, and either remove or fix this 
        // .new_missile_active(missile_active_ram_data_in), // TODO: uncomment this
        .new_shot_fired(shot_fired_ram_data_in));
    assign missile_active_ram_data_in = 1'b1; // TODO: Remove this

    logic current_missile_draw_request;
    logic signed [10:0] topLeftX;
    logic signed [10:0] topLeftY;

    square_object #(.OBJECT_WIDTH_X(2), .OBJECT_HEIGHT_Y(5)) square_object_isnt (
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .drawingRequest(current_missile_draw_request)
        );

    logic [10:0] last_pixelX;

    always_ff@(posedge clk or negedge resetN) begin
        if(!resetN) begin
            current_missile <= 0;
            last_pixelX <= 0;
        end else begin
            // Defaults
            last_pixelX <= pixelX;
            location_x_ram_rden <= 0;
            location_y_ram_rden <= 0;
            missile_active_ram_rden <= 0;
            shot_fired_ram_rden <= 0;
            location_x_ram_wren <= 0;
            location_y_ram_wren <= 0;
            missile_active_ram_wren <= 0;
            shot_fired_ram_wren <= 0;

            // Reset to the first missile at the start of a pixel
            if (last_pixelX != pixelX) begin
                missleDR <= 0;
                current_missile <= 0;
                // Get the data of the first missile ready
                location_x_ram_rden <= 1;
                location_x_ram_rdaddress <= 0;
                location_y_ram_rden <= 1;
                location_y_ram_rdaddress <= 0;
                missile_active_ram_rden <= 1;
                missile_active_ram_rdaddress <= 0;
                shot_fired_ram_rden <= 1;
                shot_fired_ram_rdaddress <= 0;
            end
            // Advance to the next missile if we didn't go over them all
            if (current_missile < SHOT_AMOUNT) begin
                // Go to the next missile
                current_missile <= current_missile + 1;
            end
            // Get the data for the next missile ready
            if (current_missile < (SHOT_AMOUNT - 1)) begin
                location_x_ram_rden <= 1;
                location_x_ram_rdaddress <= current_missile + 1;
                location_y_ram_rden <= 1;
                location_y_ram_rdaddress <= current_missile + 1;
                missile_active_ram_rden <= 1;
                missile_active_ram_rdaddress <= current_missile + 1;
                shot_fired_ram_rden <= 1;
                shot_fired_ram_rdaddress <= current_missile + 1;
            end

            if (current_missile < SHOT_AMOUNT) begin
                // The missile_move and square_object will have run their calculation by now,
                // so all we need to do is update the RAM about it and update the draw request
                // Update RAM about last missile move output
                location_x_ram_wren <= 1;
                location_x_ram_wraddress <= current_missile;
                location_y_ram_wren <= 1;
                location_y_ram_wraddress <= current_missile;
                missile_active_ram_wren <= 1;
                missile_active_ram_wraddress <= current_missile;
                shot_fired_ram_wren <= 1;
                shot_fired_ram_wraddress <= current_missile;

                // Update the draw request if needed
                if (current_missile_draw_request == 1'b1) begin
                    missleDR <= 1'b1;
                end
            end
        end
    end

    assign missleRGB = MISSILE_COLOR;

    // // Only send the key press to the first available shot
    // always_comb begin
    //     key_presses = SHOT_AMOUNT'('b0);
    //     for (int j = 0; j < SHOT_AMOUNT; j++) begin
    //         if (missile_active[j] == 1'b0) begin
    //             key_presses[j] = strShotKeyIsPress;
    //             break;
    //         end
    //     end
    // end

    // genvar i;
    // generate
    //     for (i = 0; i < SHOT_AMOUNT; i++) begin : generate_missiles
    //         // TODO: Change these parameters, these are only here as a test that multiple missiles can have different parameters
    //         missile_movement #(.X_OFFSET(16 + (i * 4)), .X_SPEED(i * 4), .Y_SPEED(-256 + (i * 16))) missile_movement_inst (
    //             .clk(clk),
    //             .resetN(resetN),
    //             .startOfFrame(startOfFrame),
    //             .shotKeyIsPress(key_presses[i]),
    //             .collision(collision & draw_requests[i]), // Only collide the missile that asked to be drawn in the collision pixel
    //             .spaceShip_X(spaceShip_X),
    //             .spaceShip_Y(spaceShip_Y),
    //             .topLeftX(topLeftX[i]),
    //             .topLeftY(topLeftY[i]),
    //             .missile_active(missile_active[i])
    //             );

    //         square_object #(.OBJECT_WIDTH_X(2), .OBJECT_HEIGHT_Y(5)) square_object_isnt (
    //             .clk(clk),
    //             .resetN(resetN),
    //             .pixelX(pixelX),
    //             .pixelY(pixelY),
    //             .topLeftX(topLeftX[i]),
    //             .topLeftY(topLeftY[i]),
    //             .drawingRequest(draw_requests[i])
    //             );
    //     end
    // endgenerate

    // // Only draw the pixel if there is at least one missile that wants to be drawn
    // assign missleRGB = MISSILE_COLOR;
    // assign missleDR = |(draw_requests & missile_active);

endmodule
