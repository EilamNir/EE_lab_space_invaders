// Design types
// =================

typedef logic signed [10:0] coordinate;
typedef logic signed [16:0] fixed_point; //TODO: Consider changing this to 16 bit, and changing FIXED_POINT_MULTIPLIER to 32 from 64
typedef logic [7:0] RGB;
typedef logic [28:0] VGA;
typedef logic [7:0] audio;
typedef logic [8:0] keycode;
typedef logic [6:0] hex_dig;
typedef logic [2:0] game_stage;
typedef logic [3:0] edge_code;
typedef logic [8:0] collision_t; // must be of size HIT_DETECTION_COLLISION_WIDTH
typedef logic [9:0] hit_request_t; // must be of size HIT_DETECTION_NUMBER_OF_OBJECTS
typedef logic [11:0] video_logic_t; // must be of size VIDEO_UNIT_NUMBER_OF_OBJECTS
typedef RGB [11:0] video_RGB_t; // must be of size VIDEO_UNIT_NUMBER_OF_OBJECTS
typedef hex_dig [2:0] score_hex_t; // must be of size SCORE_DIGIT_AMOUNT
typedef hex_dig [2:0] timer_hex_t; // must be of size TIMER_DIGIT_AMOUNT
