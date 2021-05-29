/* player controls module
	get the keycode and output the direction the player should move
	
written by Nir Eilam and Gil Kapel, May 18th, 2021 */


module  player_controls (
    input logic clk,
    input logic resetN,
    input keycode keyCode,
    input logic make,
    input logic brake,

    output logic upIsPress,
    output logic downIsPress,
    output logic RightIsPress,
    output logic LeftIsPress,
    output logic shotKeyIsPressed
);

    `include "parameters.sv"

    keyToggle_decoder #(.KEY_VALUE(UP_KEY)) control_up_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(upIsPress)
        );

    keyToggle_decoder #(.KEY_VALUE(DOWN_KEY)) control_down_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(downIsPress)
        );

    keyToggle_decoder #(.KEY_VALUE(RIGHT_KEY)) control_right_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(RightIsPress)
        );

    keyToggle_decoder #(.KEY_VALUE(LEFT_KEY)) control_left_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(LeftIsPress)
        );


    keyToggle_decoder #(.KEY_VALUE(SHOOT_KEY)) control_strShot_inst (
        .clk(clk),
        .resetN(resetN),
        .keyCode(keyCode),
        .make(make),
        .brakee(brake),
        .keyIsPressed(shotKeyIsPressed)
        );

endmodule
