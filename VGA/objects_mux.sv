module  objects_mux (   
    input logic clk,
    input logic resetN,
    input logic [0:NUMBER_OF_OBJECTS - 1] draw_requests,
    input logic [0:NUMBER_OF_OBJECTS - 1] [RGB_WIDTH - 1:0] obj_RGB,
    input logic [RGB_WIDTH - 1:0] background_RGB,
    output logic [RGB_WIDTH - 1:0] RGBOut
);

    parameter unsigned NUMBER_OF_OBJECTS = 2;
    parameter unsigned RGB_WIDTH = 8;

always_ff@(posedge clk or negedge resetN)
begin
    if(!resetN) begin
        RGBOut  <= 8'b0;
    end

    else begin
        // Go over the draw requests and draw the first object that wants to be drawn
        // TODO: Change this into a for loop
        if (draw_requests[0] == 1'b1 )   
            RGBOut <= obj_RGB[0];

        else if (draw_requests[1] == 1'b1 )   
            RGBOut <= obj_RGB[1];
        
        // If we didn't draw any object, draw the background
        else 
            RGBOut <= background_RGB ;
        end ; 
    end

endmodule


