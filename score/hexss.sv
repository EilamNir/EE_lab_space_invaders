// (c) Technion IIT, Department of Electrical Engineering 2018 

// Implements the hexadecimal to 7Segment conversion unit
// by using a two-dimensional array

module hexss 
    (
    input logic [3:0] hexin, // Data input: hex numbers 0 to f
    output logic [6:0] ss   // Output for 7Seg display
    );

    // Declaration of two-dimensional array that holds the 7seg codes
    logic [0:15] [6:0] SevenSeg = 
    {
        7'b1000000, // 0
        7'b1111001, // 1
        7'b0100100, // 2
        7'b0110000, // 3
        7'b0011001, // 4
        7'b0010010, // 5
        7'b0000010, // 6
        7'b1111000, // 7
        7'b0000000, // 8
        7'b0010000, // 9
        7'b0001000, // 10
        7'b0000011, // 11
        7'b1000110, // 12
        7'b0100001, // 13
        7'b0000110, // 14
        7'b0001110  // 15
    };

    assign ss = SevenSeg[hexin];

endmodule


