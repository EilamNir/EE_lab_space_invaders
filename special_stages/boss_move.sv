
module  boss_move (

    input logic clk,
    input logic resetN,
    input logic startOfFrame,  // short pulse every start of frame 30Hz
    input logic border_collision,
    input edge_code HitEdgeCode,
    input logic switch_direction_pulse,
    input logic random_axis,

    output coordinate topLeftX, // output the top left corner
    output coordinate topLeftY  // can be negative , if the object is partliy outside

);

    `include "parameters.sv"

    parameter coordinate INITIAL_X;
    parameter coordinate INITIAL_Y;

    parameter fixed_point X_SPEED;
    parameter fixed_point Y_SPEED;

    fixed_point Xspeed, topLeftX_FixedPoint; // local parameters
    fixed_point Yspeed, topLeftY_FixedPoint;

    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            Xspeed  <= X_SPEED;
            Yspeed  <= Y_SPEED;
            topLeftX_FixedPoint <= INITIAL_X * FIXED_POINT_MULTIPLIER;
            topLeftY_FixedPoint <= INITIAL_Y * FIXED_POINT_MULTIPLIER;
        end else begin

            // Choose an axis to reverse when shooting
            if (switch_direction_pulse) begin
                if (random_axis) begin
                    Yspeed <= -Yspeed;
                end else begin
                    Xspeed <= -Xspeed;
                end
            end

            // Check border collisions
            if (border_collision) begin
                if (((HitEdgeCode [TOP_EDGE] == 1) && (Yspeed < 0)) || // boss hit ceiling while moving up
                    ((HitEdgeCode [BOTTOM_EDGE] == 1) && (Yspeed > 0))) begin // boss hit ground while moving down
                    Yspeed <= -Yspeed;
                end
                if (((HitEdgeCode [LEFT_EDGE] == 1) && (Xspeed < 0 )) || //boss got to the left border while moving left
                    ((HitEdgeCode [RIGHT_EDGE] == 1) && (Xspeed > 0))) begin //boss got to the right border while moving right
                    Xspeed <= -Xspeed;
                end
            end

            // Change the location according to the speed
            if (startOfFrame == 1'b1) begin
                topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
                topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed;
            end
        end
    end

    //get a better (64 times) resolution using integer
    assign  topLeftX = coordinate'(topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER);
    assign  topLeftY = coordinate'(topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER);


endmodule



