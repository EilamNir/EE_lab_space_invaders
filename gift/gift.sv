
module gift(
    input logic clk,
    input logic resetN,
    input logic enable,
    input logic startOfFrame,
	input logic [HIT_DETECTION_COLLISION_WIDTH - 1:0] collision,
    input coordinate pixelX,
    input coordinate pixelY,

    output logic giftDR,
    output RGB giftRGB,
    output logic powerup
);

    `include "parameters.sv"

    coordinate offsetX;
    coordinate offsetY;
    logic squareDR;
    coordinate topLeftX;
    coordinate topLeftY;
    logic bitmapDR;
    logic giftIsHit;
    logic random_bit;
    RGB gift_color;
    logic [GIFT_RANDOM_AMOUNT - 1:0] random_parameters;
    logic unsigned [GIFT_RANDOM_AMOUNT_WIDTH - 1:0] current_random_bit;

    gift_move #(
        .INITIAL_X(GIFT_INITIAL_X),
        .ALTERNATIVE_X(GIFT_ALTERNATIVE_X),
        .INITIAL_Y(GIFT_INITIAL_Y),
        .Y_SPEED(GIFT_Y_SPEED)
    ) gift_move_inst(
         .clk(clk),
         .resetN(resetN),
         .collision((collision[COLLISION_GIFT_BOUNDARY] | collision[COLLISION_PLAYER_GIFT]) & giftDR),
         .random_location(random_parameters[0]),
         .startOfFrame(startOfFrame & (enable)),
         .giftIsHit(giftIsHit),
         .topLeftX(topLeftX),
         .topLeftY(topLeftY)
     );

    square_object #(
        .OBJECT_WIDTH_X(GIFT_X_SIZE),
        .OBJECT_HEIGHT_Y(GIFT_Y_SIZE)
    ) square_object_inst(
        .clk(clk),
        .resetN(resetN),
        .pixelX(pixelX),
        .pixelY(pixelY),
        .topLeftX(topLeftX),
        .topLeftY(topLeftY),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .drawingRequest(squareDR)
    );

    giftBitMap giftBitMap_inst(
        .clk(clk),
        .resetN(resetN),
        .offsetX(offsetX),
        .offsetY(offsetY),
        .InsideRectangle(squareDR),
        .gift_color(gift_color),
        .drawingRequest(bitmapDR),
        .RGBout(giftRGB)
    );

    assign giftDR = bitmapDR & (~giftIsHit) & enable;

    // Get random bits for present parameters
    GARO_random_bit GARO_random_bit_inst(
        .clk       (clk),
        .resetN    (resetN),
        .enable    (current_random_bit != GIFT_RANDOM_AMOUNT),
        .random_bit(random_bit)
        );

    // Decide on gift parameters, one on each of the first frames
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            random_parameters <= 0;
            current_random_bit <= 0;
        end else begin
            if (startOfFrame && (current_random_bit != GIFT_RANDOM_AMOUNT)) begin
                random_parameters[current_random_bit] <= random_bit;
                current_random_bit <= current_random_bit + 1'b1;
            end
        end
    end

    // Choose gift type
    assign powerup = random_parameters[1];
    // Choose gift color
    assign gift_color = random_parameters[1] ? GIFT_COLOR_RED : GIFT_COLOR_BLUE;

endmodule
