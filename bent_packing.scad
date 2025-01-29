/*
 * bent packing
 * by Dr. Arne Köhn <arne@chark.eu>
 * 2022-12-13, last updated 2024-11-16 (see changelog below)
 *
 * Goal: make an apparent cylinder. 4 assemblies, one solution.
 *
 * This file is provided under CC-by 4.0, meaning:
 *  - you may print the puzzle for yourself
 *  - you may print the puzzle for others
 *  - you may change the puzzle
 *  - you may sell copies of the puzzle
 * AS LONG AS you give credit
 * if you like the puzzle, consider donating a bit to a good cause.
 * 
 * to render all pieces, run this in your shell:
 * for p in box lid h1 h2 h3 v1 v2; do openscad-nightly -D torender=\"$p\" bent_packing.scad -o bent_packing_$p.3mf; done
 * 
 * you will need to print the v1 piece twice.  The vertical pieces are
 * best printed on the side (this is obvious for v1) so the layers
 * glide more smoothly with the other pieces and the box.
 *
 * If you want to, you can play around with the looseness of the
 * thread. print the threadtest with values you want to try and change
 * slop according to what you prefer.
 *
 * Changelog
 *  2024-11-16:
 *  - optimize thread size for stability (more material on the outer parts)
 *  - voxel size correctly scales everything (tested with 7mm voxel size)
 *  - middle is not hollow at the bottom anymore,
 *    which was an artifact of a donut shape in original plans
 *  - reduced default shrink to 0.15 to make the pieces not as loose
 *  - text scales properly (you can even print a 2m puzzle if you want)
 *  - the hexagons are curved with the box now. Necessary? No, but it prevents
 *    incorrect renders when you print a 2m puzzle with 2mm wall width ...
 */

// BOSL is supposed to read $slop but I cannot figure
// out how this works, so I manually use a different
// variable. Maybe I also did something weird and now
// I am too lazy to check whether this variable is needed.
slop=0.22;

include <BOSL2/std.scad>
include <BOSL2/threading.scad>
use <text_on.scad>
 
$fn=360;


inner_radius=10;
voxel_size=10;
bottom_thickness=2;
wall_thickness=2.5;

thread_thickness=4;

inner_wall_thickness=2;

hex_size=(5/10*voxel_size);

shrink=0.15;

bevel=1;

friction=0.04;
lid_thickness=2;
thread_length=6;

// piece to render.
torender="lid"; // [lid, box, v1, v2, h1, h2, h3, all]

puzzle_radius = inner_radius + 2*voxel_size+wall_thickness;

module voxel(x,y,z){
  translate([0,0,y*voxel_size])
   rotate([0,0,60*x])
    rotate_extrude(angle=60.01) // .01 combats rounding errors in the renderer
      translate([inner_radius+voxel_size*z,0,0])
        square(size=voxel_size);
}

module piece(voxels) {
  minkowski() {
    difference(){
      cube([200,200,200], center=true);
      minkowski() { // shrink step
        difference(){
          cube([200,200,200], center=true);
          piece_true(voxels);
        }
        sphere(shrink+bevel, $fn=10);
      }
    }
    union() {
      cylinder(bevel, bevel, 0, $fn=20);
      rotate([180,0,0])
        cylinder(bevel, bevel, 0, $fn=20);
    }
  }
}

module piece_true(voxels) {
  for (v = voxels) {
    voxel(v[0], v[1], v[2]);
  }
}


module hexagon_hole(radius, x, y, relative_thickness=0.3)
{
   hex_outer_radius = inner_radius + 2*voxel_size + wall_thickness;
   hex_inner_rad = hex_outer_radius - 1.1*wall_thickness;
  difference(){
  rotate([0,0,x])
    translate([0,inner_radius + 2*voxel_size+wall_thickness,y])
      rotate([90,0,0]){

        linear_extrude(1.1*wall_thickness, scale=hex_inner_rad/hex_outer_radius)
        circle(r=radius,$fn=6);
    }
    cylinder(h=3*voxel_size, r=inner_radius + 2*voxel_size + (wall_thickness*(1-relative_thickness)));
  }
}

module box() {
  // outer wall
  difference(){
    cylinder(h=3*voxel_size+2*shrink, r=2*voxel_size+inner_radius+wall_thickness);
    cylinder(h=3*voxel_size+2*shrink, r=2*voxel_size+inner_radius+shrink);
    for (x=[0:30:360]) {
      hexagon_hole(hex_size, x+15, 0*hex_size);
      hexagon_hole(hex_size, x, hex_size);
      hexagon_hole(hex_size, x+15, 2*hex_size);
      if (x == 180) {
            hexagon_hole(hex_size, x, 3*hex_size, 1.2);

      }
      hexagon_hole(hex_size, x, 3*hex_size);
      hexagon_hole(hex_size, x+15, 4*hex_size);
      hexagon_hole(hex_size, x, 5*hex_size);
      hexagon_hole(hex_size, x+15, 6*hex_size);
    }
   // holes in outer wall
   color("red")
       piece_true([
         [0,3,1.9], // the wall is a bit higher than 3 voxels, remove that as well
         [0,2,1.9],
         [0,1,1.9],
         [0,0,1.9],
         [1,0,1.9],
         [2,0,1.9],
         [3,0,1.9]]);
  } // end difference & wall
  
  // 3* wall end pieces
  color("blue")
  rotate_extrude(angle=-3)
    translate([inner_radius+2*voxel_size+shrink,0,0])
      square([wall_thickness-shrink, 3*voxel_size]);
      
  color("blue")
  rotate([0,0,240])
  rotate_extrude(angle=3)
    translate([inner_radius+2*voxel_size+shrink,0,0])
      square([wall_thickness-shrink, 1*voxel_size]);
      
  color("blue")
  rotate([0,0,60])
  rotate_extrude(angle=3)
    translate([inner_radius+2*voxel_size+shrink,voxel_size,0])
      square([wall_thickness-shrink, 2*voxel_size]);
  
  // blocker
  translate([0,0,1*voxel_size])
   rotate([0,0,60*1])
    rotate_extrude(angle=60.0)
      translate([inner_radius+voxel_size*1,0,0])
        square(size=[voxel_size+1.2*shrink, 2*voxel_size] );
  
  // inner wall
  difference(){
    cylinder(h=3*voxel_size+2*shrink, r=inner_radius);
    up(lid_thickness)
      threaded_rod(d=2*(inner_radius - thread_thickness), l=(1.2*thread_length), pitch=2, $slop=slop, internal=true);
   }
  
  text_radius=(1.5*voxel_size+inner_radius);
  text_size=(0.8* (voxel_size));
  // top 
  translate([0,0,3*voxel_size+0*shrink])
  difference(){
    cylinder(h=bottom_thickness,r=inner_radius+2*voxel_size+wall_thickness);
    piece_true([[2,-0.5,0]]);
    up(bottom_thickness) {
      text_on_circle(t="bent packing",r=text_radius,rotate=90,extrusion_height=2,size=text_size, font="roboto");
      text_on_circle(t="Arne Koehn",r=text_radius,rotate=270,extrusion_height=2,size=text_size, font="roboto");
    }
  }

}

module lid() {
  cylinder(h=lid_thickness,r=inner_radius+2*voxel_size+wall_thickness);
  translate([0,0,lid_thickness])
    up(lid_thickness)
      threaded_rod(d=2*(inner_radius - thread_thickness), l=thread_length, pitch=2, internal=false, bevel=true);
}

module h1() {
  piece([[0,0,0],[0,0,1],
         [1,0,0],
         [2,0,0],[2,0,1]]);
}

module h2() {
piece([[0,0,0],
       [1,0,0],[1,0,1],
       [2,0,1]]);
}


module h3() {
piece([[0,0,1],
       [1,0,1],
       [2,0,0],[2,0,1]]);
}


module v1() {
piece([[0,2,0],
       [0,1,0],[0,1,1],
       [0,0,1]]);
}

module v2() {
piece([[0,2,0],[0,2,1],
       [0,1,0],[0,1,1],
       [0,0,0]]);
}

if (torender=="box")
  rotate([0,180,0])
    box();
if (torender=="lid")
  lid();
if (torender=="h1")
  h1();
if (torender=="h2")
  h2();
if (torender=="h3")
  h3();
if (torender=="v1")
  v1();
if (torender=="v2")
  v2();

if (torender=="all") {
  left(2* (inner_radius + 2*voxel_size + wall_thickness) + 3 )
    up(3*voxel_size + bottom_thickness)
      rotate([0,180,0])
        box();
  lid();
  right(7*voxel_size)
    h1();
  move([-2*voxel_size, -7*voxel_size])
    h2();
  move([7*voxel_size, -3* voxel_size])
    h3();
  move([7*voxel_size, -4* voxel_size])
    rotate([90,0,0])
      v1();
  move([4*voxel_size, -4* voxel_size])
    rotate([90,0,0])
      v1();
  move([1*voxel_size, -4* voxel_size])
    rotate([90,0,0])
      v2();
}


if (torender=="threadtest") {
  difference(){
    cylinder(h=5, r=inner_radius);
    threaded_rod(d=2*(inner_radius - thread_thickness), l=11, pitch=2, $slop=0.1, internal=true); 
  }
  right(25) difference(){
    cylinder(h=5, r=inner_radius);
    threaded_rod(d=2*(inner_radius - thread_thickness), l=11, pitch=2, $slop=0.2, internal=true); 
  }
  right(50) difference(){
    cylinder(h=5, r=inner_radius);
    threaded_rod(d=2*(inner_radius - thread_thickness), l=11, pitch=2, $slop=0.3, internal=true); 
  }
  right(75) up(3.5)
    threaded_rod(d=2*(inner_radius - thread_thickness), l=7, pitch=2, $slop=0, internal=false, bevel=true);
}
