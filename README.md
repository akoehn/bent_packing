# Bent packing

*A circular puzzle by Dr. Arne Köhn*

Ever got angry at a puzzle and bent the pieces? And then asked
yourself whether you can make a new puzzle out these pieces? no? Well,
me neither. I designed this puzzle in my head while bringing my kid to
bed and then did some minor adjustments on paper.

The goal of this puzzle is to put all pieces into the cylindrical box
such that there are no unfilled holes in the box (in other words: make
an "apparent cylinder").  Are rotations required? Depends!

## license

This puzzle is distributed under a Creative Commons attribution
license (CC-by 4.0). You may print, change, distribute, and sell the
puzzle as long as you give credit to me.

As I am not selling this puzzle, consider making a donation to a good
cause if you like the puzzle.

## printing

If you just want to print the puzzle, you can 
[download the model files from printables](https://www.printables.com/model/417667-bent-packing).

There are three vertical pieces (`v1` needs to be printed twice) and
three horizontal pieces.

The vertical pieces are best printed on the side (this is obvious for
`v1`) so the layers glide more smoothly with the other pieces and the
box.

This puzzle is quite forgiving with tolerances and nozzle sizes, as
there are no sharp corners needed.  I print it with a 0.8 nozzle.

While not needed for a solve, the piece slide is much more
satisfactory when printed with high infill to add weight. I use 50%.

## rendering and making changes

This design requires the use of [The Belfry OpenScad Library, v2](https://github.com/BelfrySCAD/BOSL2?tab=readme-ov-file#installation).

To render the pieces without an interactive openscad session, run:
```bash
openscad-nightly --backend=manifold -D torender=\"all\" bent_packing.scad -o bent_packing_all.3mf
```

you can also render the pieces individually:

```bash
for p in box lid h1 h2 h3 v1 v2; do
  openscad-nightly --backend=manifold -D torender=\"$p\" bent_packing.scad -o bent_packing_$p.3mf
done
```

There are some variables at the top of the scad file that change the
dimensions of the puzzle. 

You can print the threadtest object if you want to test which `slop`
value works best for you. It prints three different threads and you
can change the slop values for them.

`--backend=manifold` is not necessary but cuts rendering time drastically.

## random things

The code is structured in a way that it should be fairly easy to
design new puzzles with the same geometry.  If you do so, forward it
to me if you want, i am interested in new designs.

I used `minkowski` for beveling. Derek Bosch made me aware of this
technique and adapted his approach by using bicones for the
operation. I think that worked out quite well.

There is a solver (only the assembly part) for this puzzle over at
https://github.com/akoehn/circular_assembler
Do check it out, the code is straight-forward to read and fun.
