module space_invaders_TOP
(
    input logic clk, 
    input logic resetN, 

    output logic lampTest
);

    assign lampTest = resetN;

endmodule
