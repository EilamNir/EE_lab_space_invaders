
module check_overlap(
    input logic clk,
    input logic resetN,
    input logic startOfFrame,
    input logic [OBJECT_AMOUNT - 1:0] draw_request,
    input logic [OBJECT_AMOUNT - 1:0] object_deactivated,

    output logic overlap,
    output logic any_DR,
    output logic [OBJECT_AMOUNT_WIDTH - 1:0] first_object_index
);
    parameter unsigned OBJECT_AMOUNT_WIDTH = 4;
    parameter logic unsigned [OBJECT_AMOUNT_WIDTH - 1:0] OBJECT_AMOUNT = 3;

    logic [OBJECT_AMOUNT_WIDTH - 1:0] last_object_index;

    // Find the first object that wants to be drawn in this space
    always_comb begin
        first_object_index = 0;
        any_DR = 1'b0;
        for (logic [OBJECT_AMOUNT_WIDTH - 1:0] j = 0; j < OBJECT_AMOUNT; j++) begin
            // check that the object wants to be drawn
            if (draw_request[j] == 1'b1) begin
                // Ignore deactivated objects
                if (object_deactivated[j] == 1'b0) begin
                    // Save the index of the first object
                    first_object_index = j;
                    any_DR = 1'b1;
                    // Do not continue to the next object
                    break;
                end
            end
        end
    end

    // Find the last object that wants to be drawn in this space
    always_comb begin
        last_object_index = 0;
        for (logic [OBJECT_AMOUNT_WIDTH - 1:0] i = 0; i < OBJECT_AMOUNT; i++) begin
            // check that the object wants to be drawn
            if (draw_request[i] == 1'b1) begin
                // Ignore deactivated objects
                if (object_deactivated[i] == 1'b0) begin
                    // Save the index of the first object
                    last_object_index = i;
                    // Continue to the next object
                end
            end
        end
    end


    // Check if the first and last objects that want to be drawn in this space are the same object
    always_ff@(posedge clk or negedge resetN)
    begin
        if(!resetN) begin
            overlap <= 1'b0;
        end else begin
            overlap <= 1'b0;

            // check if there is an overlap of two objects in the same pixel
            // If only one object wants to be drawn in this place, the index will be the same.
            // If no object wants to be drawn in this place, the index will be the same (zero).
            // If two objects want to be drawn in this place, the index will be different.
            if (first_object_index != last_object_index) begin
                overlap <= 1'b1;
            end
        end
    end

endmodule
