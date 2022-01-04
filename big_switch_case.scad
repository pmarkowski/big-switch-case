// Uncomment for smoother curves when rendering
$fs = 0.1;
$fa = 1.0;

// Variables/Parameters

PCB_LENGTH=79;
PCB_WIDTH=65;
PCB_THICKNESS=1.57;
PCB_PADDING=2;

// Assuming these threaded inserts:
// https://www.amazon.ca/iplusmile-Embedment-Threaded-Printing-Projects/dp/B087N4LVD1/ref=sr_1_9?keywords=threaded+insert+heat+set&qid=1639598068&sr=8-9
// Measurements came from a more detailed review
THREADED_INSERT_WIDTH=4.6;
THREADED_INSERT_DEPTH=5.5;
THREADED_INSERT_OPENING=4;
THREADED_INSERT_PADDING=2.2;

// Given above, assume M3 screws
SCREW_THICKNESS=3;

SWITCH_PLATE_OPENING=56;
SWITCH_PLATE_THICKNESS=6;

USB_C_HEIGHT=3.5;
USB_C_WIDTH=9;
USB_C_PADDING=3;

// Looks like this is about 3/32"
PRO_MICRO_HEADER_THICKNESS=2.4;
DISTANCE_FROM_BOTTOM_OF_PLATE_TO_USB_C=20 - SWITCH_PLATE_THICKNESS + PCB_THICKNESS + PRO_MICRO_HEADER_THICKNESS;

// Needs to be *at least* 20 - SWITCH_PLATE_THICKNESS + PCB_THICKNESS + 12
CASE_HEIGHT=20 - SWITCH_PLATE_THICKNESS + PCB_THICKNESS + 12;
CASE_BOTTOM_THICKNESS=3;

module screw_post(depth = THREADED_INSERT_DEPTH, center = true) {
    cylinder(h = depth, r = (THREADED_INSERT_WIDTH / 2) + THREADED_INSERT_PADDING, center = center);
};

module screw_hole(depth, center = true) {
    cylinder(h = depth, d = SCREW_THICKNESS, center = center);
};


// Dimensions of the plate, not including the outer radius of the screw posts
INNER_PLATE_WIDTH = 2 * (THREADED_INSERT_WIDTH / 2 + THREADED_INSERT_PADDING + PCB_PADDING) + PCB_WIDTH;
INNER_PLATE_LENGTH = 2 * (THREADED_INSERT_WIDTH / 2 + THREADED_INSERT_PADDING + PCB_PADDING) + PCB_LENGTH;

TOP_LEFT_HOLE_POSITION = [-INNER_PLATE_WIDTH / 2, INNER_PLATE_LENGTH / 2];
TOP_RIGHT_HOLE_POSITION = [INNER_PLATE_WIDTH / 2, INNER_PLATE_LENGTH / 2];
BOTTOM_LEFT_HOLE_POSITION = [-INNER_PLATE_WIDTH / 2, -INNER_PLATE_LENGTH / 2];
BOTTOM_RIGHT_HOLE_POSITION = [+INNER_PLATE_WIDTH / 2, -INNER_PLATE_LENGTH / 2];

HOLE_POSITIONS = [
    TOP_LEFT_HOLE_POSITION,
    TOP_RIGHT_HOLE_POSITION,
    BOTTOM_LEFT_HOLE_POSITION,
    BOTTOM_RIGHT_HOLE_POSITION
];

module place_at_hole_positions() {
    for (hole_position = HOLE_POSITIONS) {
        translate(hole_position) {
            children();
        };
    };
};

module outer_case_shape(height) {
    hull() {
        place_at_hole_positions()
            screw_post(height, true);
        cube([INNER_PLATE_WIDTH, INNER_PLATE_LENGTH, height], true);
    };
};

module switch_plate() {
    difference() {
        outer_case_shape(SWITCH_PLATE_THICKNESS);
        place_at_hole_positions()
                screw_hole(SWITCH_PLATE_THICKNESS + 0.1);
        cube(SWITCH_PLATE_OPENING, true);
    };
};


module case_bottom() {
    inner_cutout_width = INNER_PLATE_WIDTH - THREADED_INSERT_PADDING - THREADED_INSERT_WIDTH / 2;
    inner_cutout_length = INNER_PLATE_LENGTH - THREADED_INSERT_PADDING - THREADED_INSERT_WIDTH / 2;
    difference() {
        // Outer shell of the case
        outer_case_shape(CASE_HEIGHT);
        // Cut out for the inside of the case
        cube([inner_cutout_width, inner_cutout_length, CASE_HEIGHT + 0.1], true);
        // Pilot holes for threaded inserts
        translate([0, 0, CASE_HEIGHT / 2 - THREADED_INSERT_DEPTH + 0.1])
            place_at_hole_positions() {
                cylinder(h = THREADED_INSERT_DEPTH + 0.1, d = THREADED_INSERT_OPENING, center = false);
            };
        // Cut out for the USB C port
        // Pro Micro seems slightly offset on the PCB, so perform a negative translation along the X axis
        translate([-2, INNER_PLATE_LENGTH / 2, CASE_HEIGHT / 2 - DISTANCE_FROM_BOTTOM_OF_PLATE_TO_USB_C + (USB_C_HEIGHT + USB_C_PADDING) / 2])
            usb_c_cutout(20);
    };
    translate([0, 0, -(CASE_HEIGHT + CASE_BOTTOM_THICKNESS) / 2])
        outer_case_shape(CASE_BOTTOM_THICKNESS);
}

module usb_c_cutout(depth) {
    rotate([90, 0, 0])
        hull() {
            translate([-(USB_C_WIDTH / 2 + USB_C_PADDING), 0])
                cylinder(h = depth, d = USB_C_HEIGHT + USB_C_PADDING, center = true);
            translate([USB_C_WIDTH / 2 + USB_C_PADDING, 0])
                cylinder(h = depth, d = USB_C_HEIGHT + USB_C_PADDING, center = true);
        };
}

//case_bottom();

// translate([-150, 0])
    switch_plate();
