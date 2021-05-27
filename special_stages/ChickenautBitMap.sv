// bitmap file 
// (c) Technion IIT, Department of Electrical Engineering 2021 
// generated bythe automatic Python tool 
 
 
 module ChickenautBitMap (

					input	logic	clk, 
					input	logic	resetN, 
					input coordinate offsetX,// offset from top left  position 
					input coordinate offsetY, 
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
 
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	RGB RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
 ) ; 

    `include "parameters.sv" 
 
// generating the bitmap 
 

localparam RGB TRANSPARENT_ENCODING = 8'h00 ;// RGB value in the bitmap representing a transparent pixel  
logic[0:63][0:63][7:0] object_colors = {
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h06,8'h06,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h06,8'h06,8'h06,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4c,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h06,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h04,8'h06,8'h06,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h4a,8'h02,8'h00,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h06,8'h06,8'h04,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h06,8'h06,8'h06,8'h04,8'h48,8'h4a,8'h48,8'h48,8'h40,8'h02,8'h04,8'h02,8'h40,8'h48,8'h48,8'h48,8'h48,8'h48,8'h48,8'h48,8'h48,8'h48,8'h48,8'h4a,8'h48,8'h40,8'h02,8'h02,8'h42,8'h4a,8'h48,8'h48,8'h4a,8'h48,8'h02,8'h06,8'h06,8'h06,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h04,8'h06,8'h06,8'h06,8'h02,8'h94,8'h94,8'h94,8'h4a,8'h02,8'h04,8'h04,8'h00,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h00,8'h02,8'h04,8'h02,8'h40,8'h94,8'h94,8'h94,8'h4a,8'h04,8'h06,8'h06,8'h04,8'h4a,8'h4c,8'h48,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h06,8'h07,8'h06,8'h04,8'h02,8'h02,8'h02,8'h02,8'h02,8'h04,8'h04,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h04,8'h04,8'h02,8'h02,8'h02,8'h02,8'h00,8'h02,8'h06,8'h06,8'h06,8'h02,8'h00,8'h00,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h40,8'h48,8'h00,8'h02,8'h44,8'h06,8'h06,8'h06,8'h02,8'h04,8'h04,8'h02,8'h02,8'h06,8'h04,8'h02,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h02,8'h04,8'h06,8'h04,8'h02,8'h04,8'h02,8'h02,8'h04,8'h06,8'h06,8'h04,8'h02,8'h00,8'h48,8'h48,8'h40,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h8a,8'h94,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h48,8'h48,8'h00,8'h02,8'h06,8'h06,8'h06,8'h04,8'h02,8'h04,8'h04,8'h02,8'h06,8'h06,8'h02,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h02,8'h04,8'h06,8'h04,8'h04,8'h04,8'h02,8'h02,8'h06,8'h07,8'h06,8'h02,8'h02,8'h4a,8'h92,8'h48,8'h40,8'h42,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h48,8'h4a,8'h8a,8'h4a,8'h00,8'h42,8'h06,8'h06,8'h06,8'h02,8'h04,8'h04,8'h02,8'h06,8'h06,8'h02,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h02,8'h04,8'h06,8'h04,8'h04,8'h04,8'h02,8'h06,8'h06,8'h06,8'h04,8'h02,8'h02,8'h4a,8'h4a,8'h48,8'h4a,8'h8c,8'h94,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h4a,8'h8a,8'h92,8'hd2,8'h42,8'h02,8'h44,8'h06,8'h06,8'h04,8'h04,8'h06,8'h02,8'h04,8'h04,8'h04,8'h07,8'h06,8'h06,8'h06,8'h06,8'h06,8'h06,8'h06,8'h06,8'h06,8'h06,8'h07,8'h04,8'h04,8'h06,8'h04,8'h06,8'h04,8'h02,8'h06,8'h06,8'h04,8'h02,8'h02,8'h8a,8'h94,8'h94,8'h8c,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h8c,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h4a,8'h94,8'h94,8'h94,8'h8c,8'h94,8'h4a,8'h94,8'h94,8'h8c,8'h4a,8'h92,8'h92,8'h02,8'h02,8'h06,8'h06,8'h06,8'h04,8'h07,8'h02,8'h04,8'h04,8'h06,8'h07,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h06,8'h04,8'h04,8'h02,8'h06,8'h02,8'h04,8'h06,8'h06,8'h02,8'h04,8'h4a,8'hd2,8'h8a,8'h4a,8'h4a,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h40,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h4a,8'h94,8'h94,8'h4c,8'h4c,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h4a,8'h4a,8'h02,8'h02,8'h06,8'h06,8'h04,8'h07,8'h04,8'h02,8'h02,8'h06,8'h07,8'h07,8'h06,8'h07,8'h06,8'h06,8'h06,8'h07,8'h07,8'h06,8'h07,8'h07,8'h06,8'h02,8'h04,8'h02,8'h04,8'h02,8'h06,8'h06,8'h02,8'h04,8'h02,8'h92,8'h8a,8'h4a,8'h94,8'h94,8'h94,8'h4a,8'h4c,8'h4c,8'h94,8'h94,8'h40,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h94,8'h94,8'h96,8'h96,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h92,8'h92,8'h4a,8'h02,8'h02,8'h04,8'h04,8'h04,8'h07,8'h00,8'h02,8'h07,8'h07,8'h07,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h02,8'h00,8'h06,8'h04,8'h04,8'h06,8'h04,8'h02,8'h02,8'h94,8'h94,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h8c,8'h4c,8'h96,8'h94,8'h94,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h4a,8'h94,8'h96,8'h4c,8'h8a,8'h94,8'h94,8'h4c,8'h94,8'h94,8'h8c,8'h92,8'h92,8'h92,8'h02,8'h02,8'h02,8'h04,8'h02,8'h07,8'h06,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h02,8'h04,8'h04,8'h02,8'h04,8'h92,8'h92,8'h8a,8'h8a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h96,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h4a,8'h96,8'h94,8'h8a,8'h94,8'h8c,8'h8c,8'h8c,8'h94,8'h4a,8'h4a,8'h8c,8'h8a,8'h4a,8'h02,8'h02,8'h00,8'h02,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h02,8'h02,8'h02,8'h04,8'h4a,8'h8a,8'h8a,8'h8a,8'h4a,8'h94,8'h8c,8'h4c,8'h94,8'h94,8'h4a,8'h96,8'h8c,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h02,8'h96,8'h96,8'h4a,8'h94,8'h96,8'h96,8'h8c,8'h8c,8'h8a,8'h94,8'h94,8'h94,8'h8a,8'h4a,8'h04,8'h04,8'h04,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h04,8'h04,8'h04,8'h02,8'h4a,8'h8c,8'h94,8'h94,8'h8c,8'h8a,8'h8c,8'h96,8'h94,8'h94,8'h4a,8'h96,8'h42,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h94,8'h96,8'h4a,8'h8a,8'h96,8'h96,8'h4c,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h92,8'h4a,8'h04,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h02,8'h92,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h8c,8'h96,8'h94,8'h8a,8'h4c,8'h96,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h94,8'h94,8'h4a,8'h00,8'h94,8'h96,8'h4c,8'h4a,8'h94,8'h94,8'h8c,8'h94,8'h94,8'h8a,8'h92,8'h02,8'h04,8'h06,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h04,8'h4a,8'h92,8'h8a,8'h94,8'h8c,8'h94,8'h94,8'h8a,8'h4c,8'h96,8'h8c,8'h42,8'h4a,8'h94,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'h94,8'h8a,8'h00,8'h94,8'h96,8'h4c,8'h8a,8'h94,8'h8c,8'h4c,8'h94,8'h94,8'h4a,8'h92,8'h4a,8'h02,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h04,8'h02,8'h92,8'h4a,8'h8a,8'h94,8'h4c,8'h8c,8'h94,8'h8a,8'h8c,8'h96,8'h4c,8'h02,8'h8c,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h8c,8'h94,8'h94,8'h94,8'h00,8'h4c,8'h94,8'h4a,8'h4a,8'h94,8'h96,8'h96,8'h4c,8'h94,8'h48,8'h00,8'h00,8'h00,8'h04,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h06,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h06,8'h02,8'h00,8'h00,8'h00,8'h4a,8'h94,8'h96,8'h96,8'h94,8'h4a,8'h4c,8'h96,8'h4c,8'h40,8'h94,8'hd4,8'h8c,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h8a,8'h42,8'h4a,8'h8c,8'h00,8'h8a,8'h94,8'h4a,8'h02,8'h8a,8'h96,8'h8c,8'h4c,8'h4a,8'h04,8'h06,8'h06,8'h06,8'h04,8'h04,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h02,8'h06,8'h06,8'h06,8'h06,8'h04,8'h4a,8'h8c,8'h96,8'h8c,8'h02,8'h4a,8'h94,8'h4a,8'h4a,8'h8a,8'h4a,8'h8c,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h4a,8'h4a,8'h00,8'h94,8'hd4,8'h8c,8'h00,8'h02,8'h94,8'h96,8'h4a,8'h02,8'h06,8'h07,8'h07,8'h07,8'h00,8'h02,8'h04,8'h06,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h04,8'h00,8'h04,8'h07,8'h07,8'h07,8'h04,8'h02,8'h96,8'h96,8'h42,8'h00,8'h8a,8'h94,8'h4a,8'h00,8'h4a,8'h02,8'h8a,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h8a,8'h8a,8'h00,8'h4a,8'h94,8'h8c,8'h94,8'h00,8'h00,8'h94,8'h96,8'h4a,8'h04,8'h04,8'h06,8'h07,8'h06,8'h00,8'h48,8'h02,8'h06,8'h06,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h06,8'h04,8'h02,8'h48,8'h04,8'h07,8'h06,8'h04,8'h04,8'h04,8'h94,8'h96,8'h02,8'h00,8'h94,8'hd4,8'h94,8'h00,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h02,8'h8c,8'h00,8'h00,8'h4c,8'h94,8'h42,8'h04,8'h04,8'h04,8'h06,8'h06,8'h00,8'h88,8'h48,8'h04,8'h06,8'h07,8'h07,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h06,8'h02,8'hd0,8'h88,8'h04,8'h07,8'h04,8'h04,8'h04,8'h02,8'h8c,8'h8c,8'h00,8'h00,8'h8a,8'h4a,8'h94,8'h00,8'h00,8'h42,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h8c,8'h94,8'h4a,8'h02,8'h04,8'h04,8'h04,8'h06,8'h00,8'h88,8'hd0,8'h02,8'h04,8'h06,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h07,8'h06,8'h04,8'h88,8'hd0,8'h88,8'h04,8'h06,8'h04,8'h04,8'h04,8'h02,8'h94,8'h94,8'h00,8'h00,8'h4a,8'h02,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h8a,8'h40,8'h00,8'h00,8'h94,8'hd4,8'h8a,8'h02,8'h02,8'h04,8'h04,8'h04,8'h00,8'h88,8'hd0,8'hd0,8'h02,8'h06,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h06,8'h04,8'h48,8'hd0,8'hd0,8'h48,8'h02,8'h04,8'h04,8'h04,8'h02,8'h02,8'h94,8'hd4,8'h4a,8'h00,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h8c,8'h4a,8'h8c,8'h00,8'h02,8'h04,8'h04,8'h04,8'h02,8'h88,8'hd0,8'hd0,8'h8a,8'h04,8'h06,8'h06,8'h07,8'h07,8'h07,8'h07,8'h07,8'h06,8'h04,8'h02,8'hd0,8'hd0,8'hd0,8'h40,8'h02,8'h04,8'h04,8'h02,8'h00,8'h40,8'h4a,8'h4a,8'h8a,8'h00,8'h00,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h42,8'h4a,8'h42,8'h4a,8'h00,8'h00,8'h02,8'h04,8'h04,8'h02,8'h48,8'h88,8'hd0,8'hdc,8'h48,8'h04,8'h06,8'h07,8'h07,8'h07,8'h07,8'h06,8'h06,8'h02,8'hd2,8'hdc,8'hd0,8'h88,8'h00,8'h04,8'h04,8'h02,8'h02,8'h00,8'h40,8'h42,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h02,8'h02,8'h04,8'h04,8'h40,8'h88,8'hd0,8'hd0,8'hd0,8'h02,8'h04,8'h06,8'h07,8'h07,8'h07,8'h06,8'h04,8'h88,8'hd2,8'hd0,8'hd0,8'h88,8'h02,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h4a,8'h8a,8'h40,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h00,8'h88,8'hd0,8'hd0,8'hd2,8'h88,8'h02,8'h06,8'h06,8'h06,8'h06,8'h04,8'h48,8'hd0,8'hd0,8'hd0,8'h88,8'h48,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h02,8'h04,8'h02,8'h48,8'h90,8'hd0,8'hdc,8'hd0,8'h48,8'h04,8'h06,8'h06,8'h04,8'h02,8'hd0,8'hdc,8'hd0,8'hd0,8'h88,8'h00,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h00,8'h88,8'hd0,8'hd4,8'hd4,8'hd0,8'h40,8'h04,8'h04,8'h02,8'h88,8'hd2,8'hd4,8'hd0,8'hd0,8'h48,8'h02,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h02,8'h04,8'h00,8'h88,8'hd0,8'hd0,8'hd2,8'hd0,8'hd0,8'h00,8'h02,8'h88,8'hd0,8'hd2,8'hd0,8'hd0,8'h88,8'h00,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h40,8'h88,8'hd0,8'hd0,8'hd0,8'hd0,8'h02,8'h02,8'hd0,8'hd0,8'hd0,8'hd0,8'hd0,8'h48,8'h02,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h00,8'h88,8'hd0,8'hd0,8'hd0,8'h02,8'h06,8'h04,8'h48,8'hd0,8'hd0,8'hd0,8'h88,8'h00,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h02,8'h00,8'h88,8'hd0,8'h02,8'h02,8'h06,8'h04,8'h02,8'h48,8'hd0,8'h88,8'h40,8'h02,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h02,8'h04,8'h04,8'h00,8'h88,8'h48,8'h02,8'h02,8'h06,8'h04,8'h02,8'h02,8'h88,8'h88,8'h00,8'h04,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h04,8'h00,8'h02,8'h04,8'h02,8'h06,8'h04,8'h02,8'h02,8'h40,8'h40,8'h04,8'h04,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h04,8'h02,8'h02,8'h02,8'h04,8'h07,8'h04,8'h02,8'h04,8'h02,8'h02,8'h04,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h04,8'h02,8'h02,8'h04,8'h04,8'h06,8'h04,8'h04,8'h02,8'h02,8'h04,8'h04,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h02,8'h02,8'h04,8'h04,8'h02,8'h02,8'h04,8'h04,8'h06,8'h04,8'h04,8'h04,8'h02,8'h02,8'h04,8'h04,8'h04,8'h02,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h02,8'h04,8'h04,8'h02,8'h02,8'h04,8'h04,8'h06,8'h04,8'h04,8'h04,8'h02,8'h02,8'h04,8'h04,8'h04,8'h02,8'h00,8'h00,8'h4a,8'h42,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h8a,8'h8c,8'h8c,8'h8a,8'h4a,8'h00,8'h02,8'h04,8'h04,8'h02,8'h02,8'h02,8'h02,8'h06,8'h04,8'h02,8'h02,8'h02,8'h02,8'h04,8'h04,8'h02,8'h02,8'h4a,8'h8c,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8c,8'h94,8'h94,8'h94,8'h94,8'h8a,8'h02,8'h02,8'h04,8'h04,8'h02,8'h02,8'h02,8'h02,8'h06,8'h04,8'h02,8'h02,8'h02,8'h02,8'h04,8'h04,8'h02,8'h42,8'h8c,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h94,8'h4a,8'h02,8'h04,8'h04,8'h02,8'h02,8'h04,8'h04,8'h04,8'h04,8'h04,8'h02,8'h02,8'h02,8'h04,8'h04,8'h02,8'h4a,8'h94,8'h94,8'h94,8'h94,8'h94,8'h8c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'h94,8'h4c,8'h8c,8'h94,8'h94,8'h4a,8'h00,8'h02,8'h04,8'h02,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h02,8'h02,8'h04,8'h02,8'h02,8'h8a,8'h94,8'h94,8'h4c,8'h94,8'h94,8'h94,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'h94,8'h8c,8'h4c,8'h94,8'h94,8'h4a,8'h00,8'h02,8'h04,8'h02,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h02,8'h02,8'h04,8'h00,8'h00,8'h4a,8'h94,8'h8c,8'h4c,8'h8c,8'h94,8'h94,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h94,8'h94,8'h96,8'h94,8'h8c,8'h94,8'h40,8'h40,8'h00,8'h02,8'h02,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h04,8'h02,8'h02,8'h02,8'h40,8'h00,8'h4a,8'h94,8'h8c,8'h96,8'h96,8'h94,8'h8a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h8c,8'h96,8'h94,8'h4a,8'h4a,8'h4a,8'h4a,8'h40,8'h02,8'h02,8'h04,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h04,8'h02,8'h02,8'h4a,8'h40,8'h40,8'h8a,8'h4c,8'h96,8'h96,8'h94,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4c,8'h96,8'h96,8'h4a,8'h4a,8'h4a,8'h4a,8'h4a,8'h00,8'h02,8'h02,8'h00,8'h00,8'h48,8'h00,8'h40,8'h00,8'h04,8'h00,8'h00,8'h4a,8'h4a,8'h8a,8'h4a,8'h4c,8'h96,8'h96,8'h40,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h96,8'h96,8'h4a,8'h8a,8'h4a,8'h4a,8'h4a,8'h4a,8'h02,8'h02,8'h40,8'h00,8'h4a,8'h40,8'h42,8'h40,8'h04,8'h02,8'h4a,8'h4a,8'h4a,8'h8c,8'h8c,8'h4c,8'h96,8'h96,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h8c,8'h8c,8'h4a,8'h8a,8'h4a,8'h8a,8'h4a,8'h4a,8'h04,8'h02,8'h40,8'h40,8'h8a,8'h4a,8'h4a,8'h4a,8'h04,8'h42,8'h4a,8'h8a,8'h4a,8'h94,8'h94,8'h4a,8'h96,8'h8c,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h94,8'h8c,8'h42,8'h8a,8'h4a,8'h8a,8'h4a,8'h8a,8'h04,8'h02,8'h4a,8'h4a,8'h92,8'h4a,8'h4a,8'h8a,8'h04,8'h4a,8'h4a,8'h8a,8'h4a,8'h8c,8'h8c,8'h4a,8'h94,8'h8a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8a,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h4a,8'h4a,8'h8a,8'h44,8'h04,8'h02,8'h02,8'h02,8'h02,8'h02,8'h02,8'h04,8'h4a,8'h4a,8'h4a,8'h4a,8'h40,8'h00,8'h4a,8'h94,8'h94,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8c,8'h8c,8'h94,8'h4a,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h42,8'h00,8'h4a,8'h42,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h00,8'h00,8'h8a,8'h94,8'h94,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h8a,8'h02,8'h4a,8'h4a,8'h00,8'h00,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h40,8'h40,8'h8a,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h4a,8'h00,8'h00,8'h00,8'h8c,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h42,8'h4a,8'h4a,8'h00,8'h00,8'h40,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h00,8'h00,8'h00,8'h4a,8'h42,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h4a,8'h4a,8'h4a,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h40,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00},
	{8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00,8'h00}};

 
 
//////////--------------------------------------------------------------------------------------------------------------= 
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	 
//there is one bit per edge, in the corner two bits are set  
 logic [0:7] [0:7] [3:0] hit_colors =
		   {32'hC4444446,
			32'h8CCC6662,
			32'h8CCC6662,
			32'h8CCC6662,
			32'h89993332,
			32'h89993332,
			32'h89993332,
			32'h91111113};
 // pipeline (ff) to get the pixel color from the array 	 
//////////--------------------------------------------------------------------------------------------------------------= 
always_ff@(posedge clk or negedge resetN) 
begin 
	if(!resetN) begin 
		RGBout <=	8'h00; 
		HitEdgeCode <= 4'h0; 
	end 
	else begin 
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0; 
 
		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket  
			HitEdgeCode <= hit_colors[offsetY >> 3][offsetX >> 3 ]; // get hitting edge from the colors table
			RGBout <= object_colors[offsetY][offsetX]; 
		end  	 
		 
	end 
end 
 
//////////--------------------------------------------------------------------------------------------------------------= 
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
 
endmodule 
