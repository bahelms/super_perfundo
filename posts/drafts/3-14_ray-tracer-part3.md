==title==
Ray Tracer Challenge, pt. 3: Rays of Sunshine

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
* Part 3: Rays of Sunshine

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
transformation (more on this later).
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


# Ray, A Drop of Golden Sun