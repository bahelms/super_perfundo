==title==
Ray Tracer Challenge, pt. 1: Create A 2D Image

==tags==
rust, graphics, algorithms, ray-tracer-challenge

==description==
Let's accept the The Ray Tracer Challenge and write a 3D renderer in Rust!
In Part 1, we'll generate and save an image showing the trajectory of a launched projectile.

==image==
trajectory.png

==body==
Hello there! Have you ever wondered what goes on under the hood when generating computer graphics?
Ever yearned to write a 3D renderer from scratch? Me too! You've come to the right place.
This is the first in a series of posts detailing my adventures in doing just that.
A ray tracer, specifically. And my guide on this journey is the incredible book
[The Ray Tracer Challenge](https://pragprog.com/titles/jbtracer/the-ray-tracer-challenge/){:target="x"}.

This book is how all tutorials should be structured. Each chapter builds on the previous,
describing what is necessary to implement in order to create a program that has the power to generate
3D images. The killer feature is that you can code it however you want.
There are no copy pastas or typing exercises involved. You're given explanations
of what must be done and high level tests to prove it works. You are free to use
whatever you can to get the tests to pass and have a running program. So cool.
If you've read any of my recent posts, you'll correctly guess that I chose
Rust to complete this challenge. As an extra bonus, it's a non-trivial piece of work that will get you
deep into your chosen tech, which makes it a great benchmark program to translate
into other languages that you may want to learn in the future.

## Show Me Something
Part one is about laying the foundation for our renderer. Before we
can get to making amazing 3D images, we need to start with making amazing 2D images.
Along the way we'll develop some of the primitive data structures that our ray tracer will need to work.
Let's skip to the end and see our reward:
<div class="flex" style="justify-content:center;">
  <img class="md-image" style="width:60%;" src="<%= img_url.("trajectory.png") %>" alt="Projectile Trajectory" />
</div>
It's beautiful! We launched a projectile from the bottom left corner of the
image with a given velocity. It fights through wind and gravity to screech
into the sky before it's finally overcome and begins its descent, landing
somewhere on the right. How cool is that? It's like the Hello World of 3D rendering.

## What's Your Point?
From that description, we can identify several entities we'll need to model.
Let's start with the most fundamental. Looking at the image, we see it's simply
a collection of points at different positions on a grid. A 2D point is a coordinate
on the X and Y axes: `(1.0, 3.2)`. Our first codes!
```rust
struct Point {
    x: f64, // x-axis
    y: f64, // y-axis
    z: f64, // z-axis for when we go 3D
    w: f64, // special value denoting a Point
}

impl Point {
    pub fn new(x: f64, y: f64, z: f64) -> Self {
        Self { x, y, z, w: 1.0 }
    }
}

let point = Point::new(4.0, 3.2, 0.7); // 3D point
```
We've gone ahead and added a field for the z-axis, technically making this a 3D point. The book
describes a point as a four element tuple where the "w" field is 1 (it doesn't know about types).
Beyond specifying a type, the "w" value will be important when we need to multiply
matrices later on. We're also using floating point numbers here so that we can
be as precise as possible!

## Tick Tock
Now that we have a point, we must figure out how to make it change over time to create
a trajectory. Let's lay the foundation with a loop and the famous gaming `tick` function.
The loop should stop when the point's y-axis value reaches 0, which means it's laying on
the ground, and the point is transformed each tick.
```rust
let mut point = Point::new(0.0, 0.0, 0.0);

while point.y > 0.0 {
    point = tick(point);
}

fn tick(point: Point) -> Point {
    point
}
```
Ship it! Well, this begs the question of how do we change a point? With a vector!

## How Vexing
Vectors are just the line between two points. Given points `(1, 2)` & `(3, 4)`,
the vector would be `(2, 2)`. It describes the direction and distance the first
point needs to move to become the second. Adding a vector to a point will produce
this "moved" point, which is exactly what we need. We can model it the same as a
Point, but set the "w" to 0.0.
```rust
struct Vector {
    x: f64,
    y: f64,
    z: f64,
    w: f64,
}

impl Vector {
    pub fn new(x: f64, y: f64, z: f64) -> Self {
        Self { x, y, z, w: 0.0 }
    }
}
```
This next part is cool and reminds me of Python's object model. How do we add
a point and a vector? Overload the addition operator by implementing the `std::ops::Add` trait.
```rust
impl Add<Vector> for Point {
    type Output = Self;

    fn add(self, other: Vector) -> Self {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
            w: self.w + other.w,
        }
    }
}

let new_point = point + vector;
```
`Add` is generic over the right hand side (`Add<Rhs = Self>`). By implementing `add`
for Point and declaring the right hand side as a Vector, we can add a vector to a
point. However, the opposite won't work: `vector + point`. We'd need to do the same
for Vectors and define `impl Add<Point> for Vector` to have commutativity. Since
the generic type defaults to `Self`, you can leave it out and add Points to Points or
Vectors to Vectors: `impl Add for Vector`.

## What Projects Are You Working On?
A point and a vector compose a projectile, where the point is its position and
the vector is its velocity.
```rust
struct Projectile {
    position: Point,
    velocity: Vector,
}
```

For each tick, the projectile's position can be transformed by applying its velocity.
```rust
fn tick(projectile: Projectile) -> Projectile {
    Projectile {
        position: projectile.position + projectile.velocity,
        velocity: projectile.velocity
    }
}
```
This code works great if you want to see a projectile shoot into space on a linear
trajectory. We must also make the velocity change so we're not just drawing a straight line.
The projectile is launched inside some environment. We could go crazy here modelling
the environment with all sorts of physical aspects, but let's keep it simple and
provide gravity to bring the projectile back down to earth and wind just to annoy the velocity.
Will also keep it immutable, so the environment never changes.
```rust
struct Environment {
    gravity: Vector,
    wind: Vector,
}

fn tick(env: &Environment, projectile: Projectile) -> Projectile {
    Projectile {
        position: projectile.position + projectile.velocity,
        velocity: projectile.velocity + env.gravity + env.wind,
    }
}
```
And now the updated generation of a trajectory:
```rust
let env = Environment {
    gravity: Vector::new(0.0, -0.1, 0.0),
    wind: Vector::new(-0.01, 0.0, 0.0),
};

let mut projectile = Projectile {
    position: Point::new(0.0, 1.0, 0.0),
    velocity: Vector::new(1.0, 1.8, 0.0), // mysterious numbers, AKA machine learning params
};

while projectile.position.y > 0.0 { // not heavy enough to bore into the Earth
    projectile = tick(&env, projectile);
    // do something to record this state
}
```
We start the position just off the ground, so the loop will actually run
(also to account for the height of the launcher, am I right?). Gravity and wind are
both negative so as to gradually drop and slow the projectile.
The velocity and environment values are highly tweakable and perfect for experimentation.
The book goes into vector magnitude, normalization, and multiplication in order to create a nice trajectory curve.
I'm glossing over those details for now, so if you're interested in them,
[get the book!](https://pragprog.com/titles/jbtracer/the-ray-tracer-challenge/){:target="x"}

## Blank Canvas
Intro



```rust
pub struct Canvas {
    width: i32,
    height: i32,
    pixels: Vec<Color>,
}
```
When a new canvas is made, it should be blank, and we'll use black to do that (cause dark mode rocks).
We'll look at `Color` later, but for now black is all zeroes and white is all max (255).
```rust
impl Canvas {
    pub fn new(width: i32, height: i32) -> Self {
        let capacity = width * height; // capacity is known!
        let mut pixels = Vec::with_capacity(capacity as usize); // allocate list
        for _ in 0..capacity {
            pixels.push(Color::new(0.0, 0.0, 0.0)); // fill list with black pixels
        }

        Self {
            width,
            height,
            pixels,
        }
    }
}
```

## File Type and Contents
What type of image file should we use? Unless you've already taken this challenge,
you may have never heard of the type suggested by the book: PPM! The
[Portable Pixmap](https://netpbm.sourceforge.net/){:target="x"}
is one of many ways to encode graphics formats. It consists of a header and pixel data:
```
P3
5 3
255
255 0 0 0 0 0 0 0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 128 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0 0 0 0 0 0 0 255
```
The first three lines are the header:
* `P3` - The PPM spec. P3 means "plain" PPM.
* `5 3` - Image width and height in pixels.
* `255` - Maximum color value - each red/green/blue value can be 0-255.

The rest is the representation of pixels in the image. The height is 3, so there
are 3 lines. Each pixel contains values for 3 colors (red, green, blue) and
the width is 5. Therefore, each line has 3*5 integers that don't exceed the max
value, seperated by spaces. Logically grouping the pixels can help you visualize:
```
(255 0 0) (0 0 0) (0 0 0) (0 0 0) (0 0 0)
```
Now we have the text version of our image! Save it to a file.
```rust
let mut file = File::create("images/trajectory.ppm").unwrap();
file.write_all(canvas.to_ppm().as_bytes()).unwrap();
```
There are various apps you can use to render a `.ppm` file. On macOS, Preview.app
has built in support. In Linux, you can use GIMP. Notice on the last line the use
of `canvas.to_ppm()`. The canvas is a struct representing the image and it can
be converted to a PPM string. I wonder what that canvas looks like?
