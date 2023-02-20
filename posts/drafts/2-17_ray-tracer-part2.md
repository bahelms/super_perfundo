==title==
Ray Tracer Challenge, pt. 2: Enter The Matrix

==tags==
rust, graphics, algorithms, ray-tracer-challenge, math

==description==
Let's accept The Ray Tracer Challenge and write a 3D renderer in Rust!
In Part 2, we'll generate an image showing the hours on an analog clock as points
on the canvas. We'll take a starting point and transform it with matrices!

==image==
analog-clock.png

==body==
_The full code for this challenge can be found at [this repo](https://github.com/bahelms/ray_tracer){:target="x"}._

* [Part 1: Creating A 2D Image](/articles/ray-tracer-part1)
* Part 2: Enter The Matrix

Welcome back! Last time we set up the foundational data structures for our ray tracer
by creating points, vectors, colors, and the canvas on which to draw them. This time,
we're going to continue with a very important foundational concept: the matrix.
We'll be able to transform shapes in our image by multiplying them with specific
matrices. This will entail modeling some linear algebra magic with algorithms, but
don't worry if that sounds scary; matrix manipulations are pretty straightforward.

## It's That Time Again
Like in part one, let's start at the end and see our target image:

<div class="flex" style="justify-content:center;">
  <img class="md-image" style="width:60%;" src="<%= img_url.("analog-clock.png") %>" alt="Analog Clock" />
</div>

Wow. Mind blowing, right? It may not be a ray traced Mona Lisa, but it showcases
some of the bread and butter calculations that we'll need to make much more
impressive scenes later on. This takes an initial point and transforms it to create
new points showing where every hour sits on an analog clock. Here's the code
used to generate this image:

```rust
use std::f64::consts::PI;

fn main() {
    let mut canvas = Canvas::new(250, 250);
    let start_point = Tuple::point(0.0, -100.0, 0.0);
    let identity = Matrix::identity();

    for hour in 1..=12 {
        let new_point = identity
            .rotate_z(hour as f64 * PI / 6.0)
            .translate(125.0, 125.0, 0.0)
            * start_point;
        canvas.write_pixel(&new_point, Color::white());
    }

    save_image(canvas);
}
```

*Side note: I refactored the `Point` and `Vector` structs into one `Tuple` struct
with named constructors: `::point` and `::vector`. This cleaned up a lot of duplicated
code and simplified the whole design since we only need to think about the one type.*

At a high level, we take the starting point, rotate it across the Z axis, then move it
along the X and Y axes (translation). This is done for every hour: `1..=12` inclusive range.
Each new point is then written to the canvas before being converted to PPM format
and saved to disk (review in [part one](/articles/ray-tracer-part1)).
The main change to note here is the use of the new `Matrix` type, which we've so
eloquently implemented with a 
[fluent interface](https://en.wikipedia.org/wiki/Fluent_interface){:target="x"}.

So WTF is a matrix?
## Red pill or blue pill?
