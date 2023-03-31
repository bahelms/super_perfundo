==title==
Ray Tracer Challenge, pt. 3: Let There Be Light!

==tags==
rust, graphics, algorithms, ray-tracer-challenge, math

==description==
Let's accept The Ray Tracer Challenge and write a 3D renderer in Rust!
In Part 3, we'll fill in the analog clock to render a full 2D circle by shooting
rays at a 3D sphere. And then paint it red!

==image==
2d_circle.png

==body==
_The full code for this challenge can be found at [this repo](https://github.com/bahelms/ray_tracer){:target="x"}._

* [Part 1: Creating A 2D Image](/articles/ray-tracer-part1)
* [Part 2: Enter The Matrix](/articles/ray-tracer-part2)
* Part 3: Let There Be Light!

Welcome back, Constant Readers! Without further ado, here is the image we'll create
today:

<div class="flex" style="justify-content:center;">
  <img class="md-image" style="width:40%;" src="<%= img_url.("2d_circle.png") %>" alt="Blood red 2D circle" />
</div>

From a few dots around a clock to a fully formed two dimensional circle! We've taken a big leap.
I'll admit, this was the most mind bending part of this challenge yet. I've had to sit back and
really try to grok what I'm about to describe. Hopefully, I can do it in an understandable way.
Let's start by setting a scene in your mind.

# A wall, a sphere, and a flashlight walk into a bar...
Picture a wall. It's flat and square. Now there is a sphere floating some distance
in front of this wall, perfectly centered. Some distance in front of said sphere is a flashlight.
When the flashlight is turned on, it illuminates both the wall and the sphere.
However, where the light hits the sphere, it's prevented from hitting the wall.
We all know this phenomenon as casting a shadow. This scene is our 3D world space.
It's abstract and devoid of hard numbers and measurements, but it's helpful to keep it in your mind.
What we must do is convert it into the 2D picture you see above. That image and
the world you're imagining are one and the same. It's a black wall with the sphere's red shadow on it.
Hey, it's my blog, and I pick the colors! Before we get into the dirty math,
let's model the three entities in our world.

# Your Balls Are Showing
The sphere is the simplest object. It's a struct with a random ID and a matrix
transformation.
```rust
pub struct Sphere {
    id: f64,
    transform: Matrix,
}

impl Sphere {
    fn new() -> Self {
        Self::with_transform(Matrix::identity()) // default to identity
    }

    pub fn with_transform(transform: Matrix) -> Self {
        use rand::Rng;
        Self {
            id: rand::thread_rng().gen(),
            transform,
        }
    }
}
```
For the sake of simplicity, we'll be using a unit sphere, which means the center is
the world's origin `(0, 0, 0)`, and it has a radius of 1. The sphere's transform describes how it will
be moved and changed within the world. Since it defaults to the identity, the transform
is essentially a no-op. Now, let there be light!

# Ray, A Drop of Golden Sun
Turn the flashlight on! What do you see? Well nothing yet, because the thing's broken.
In a perfect world, with a working flashlight, what would normally shoot out of the
glassy end? Rays of light! See what we're doing? We're gonna cast rays out
into the world and trace them to see what they hit. Ray tracer. We finally know who we are now!
So, just wtf is a ray? I'm glad I asked.
```rust
pub struct Ray {
    origin: Tuple,
    direction: Tuple,
}
```
It's a point (the origin) and a vector (the direction). Given a starting point, a line
shoots out forever in the direction described by the vector. We've got one more piece
to define, and our world will be fully modeled.

# Another Brick In The Wall
The wall behind the sphere is a little more abstract. It's basically there to provide
some bounds on our world and act as a terminus for all the rays we're gonna launch out.
Modeling pure constraints in this way doesn't necessitate the use of a struct because
we're just dealing with raw numbers. But you never know what the future will bring, and
it tends to be a better idea to encapsulate the concept in a type of its own.
```rust
struct Wall {
    z: f64,
    size: f64,
}
```
Remember, the sphere is centered on the origin with a one unit radius. The wall must be
behind it at some point. Moving something away from you entails increasing the Z-axis
value. When we create the wall it must have a Z-axis value of at least one, or the
sphere will be stuck inside it like those poor dudes in the [Philadelphia Experiment](https://en.wikipedia.org/wiki/Philadelphia_Experiment){:target="x"}.
The size of the wall defines the limits of our world. We'll shoot rays at every point
on it and all of them don't make it to the wall will describe the sphere that's in the way.
All that's left to do is code the algorithm to do this and turn the light on.

# Kick the Tires and Light the Fires
We first need to set up some data to initialize the world.
```rust
    let flashlight = Tuple::point(0.0, 0.0, -5.0);
    let sphere = Sphere::new();
    let wall = Wall { z: 10.0, size: 8.0 };
```
The flashlight is centered on the sphere, four units in front of its surface.
The sphere is using an identity matrix for the transform, so it will be rendered
as a normal perfect sphere. The wall is nine units behind sphere's surface and it
has a size of eight. This size is completely arbitray and is ripe for tweaking.
All of these numbers are highly tweakable in fact, and it's encouraged that you
play around with them to see understand their effects. For instance, as you move
the light away from the sphere, the shadow behind it on the wall gets bigger.
You can try that for real life, if you don't believe me. I did.

We have the world set up, but it's pretty abstract still. We'll need to figure out
a way to translate it to our concrete canvas in order to write pixels to a file.
```rust
    let canvas_pixels = 300;
    let mut canvas = Canvas::new(canvas_pixels, canvas_pixels);
    let world_pixel_size = wall.size / canvas_pixels as f64;
    let half_wall_size = wall.size / 2.0;
```

