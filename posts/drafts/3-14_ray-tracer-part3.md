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

# A Whole New World
We first need to set up some data to initialize the world.
```rust
let flashlight = Tuple::point(0.0, 0.0, -5.0);
let sphere = Sphere::new();
let wall = Wall { z: 10.0, size: 8.0 };
```
The flashlight is centered on the sphere, four units in front of its surface.
The sphere is using an identity matrix for its transform, so it will be rendered
as is, without actually being transformed. The wall is nine units behind sphere's surface and it
has a size of eight. This size is completely arbitray and is ripe for tweaking.
All of these numbers are highly tweakable, in fact, and it's encouraged that you
play around with them to understand their effects. For instance, as you move
the light away from the sphere, the shadow behind it on the wall gets bigger.
You can try that for real life, if you don't believe me. I did. It's true.

Now we have the world set up, but it's still pretty abstract. We need to figure out
a way to translate it to our concrete canvas so we can write the pixels to a file.
We'll start with a square canvas.
```rust
let canvas_pixels = 300;
let mut canvas = Canvas::new(canvas_pixels, canvas_pixels);
```
The final two data points we need before starting the algorithm are the size of a pixel in world space and
the bounds of the wall's four sides. Using a square canvas makes calculating both
of these values easier.
```rust
let world_pixel_size = wall.size / canvas_pixels as f64;
let half_wall_size = wall.size / 2.0;
```
The world pixel size is a relationship between the wall and the canvas.
To calculate it, we divide the wall size by the number of canvas pixels on a side.
Next, since everything is centered on the origin, using half of the wall size would satisfy all
directions on the X and Y axes. For example, with a wall size of 8, 4 is max X,
-4 is min X with the same for Y.

# Kick the Tires and Light the Fires
Now, let's crunch some numbers! The following is the full algorithm for tracing
the sphere. See if you can grok it before I explain it.
```rust
for x in 0..canvas.width {
    for y in 0..canvas.height {
        let world_y = half_wall_size - world_pixel_size * y as f64;
        let world_x = half_wall_size - world_pixel_size * x as f64;
        let world_position = Tuple::point(world_x, world_y, wall.z);
        let ray = Ray::new(flashlight, (world_position - flashlight).normalize());

        if let Some(intersections) = ray.intersect(&sphere) {
            if hit(&intersections).is_some() {
                let point = Tuple::point(x as f64, y as f64, 0.0);
                canvas.write_pixel(&point, Color::red());
            }
        }
    }
}
```
We iterate over the positions of every pixel, which is O(n) by the way because it's just one
pass through the array (nested loops don't always equate to quadratic time).
For each pixel position, the first order of business is to convert it
into a position in world space. We already know Z since that's where the wall is.
That leaves X and Y. I admit calculating these values initially seemed like magic
because the book doesn't explain it very well. Hopefully, I can do better.

```rust
let world_y = half_wall_size - world_pixel_size * y as f64;
let world_x = half_wall_size - world_pixel_size * x as f64;
let world_position = Tuple::point(world_x, world_y, wall.z);
```
We'll start with finding the world X and Y values. It's easier to understand by describing their boundaries first.
Remember, the wall size is 8 and centered on the origin, so it goes from -4 to 4 on both axes.
At the beginning of the loop, canvas Y is 0 and at the end
it's 299. That gives us the following calculations: `4 - (8/300) * 0 = 4` and `4 - (8/300) * 299 = -3.97333`.
This means the iterations start at 4 and go down each axis, picking 300 values until reaching -4.
After finding X and Y, they're combined with the wall's Z to make a concrete point in world space. Whew.
Now, we know where to point the flashlight, so let's turn it on!
```rust
let ray = Ray::new(flashlight, (world_position - flashlight).normalize());
```
Ahh my eyes! The flashlight is the origin of this ray and the direction is the spot
we just calculated minus the ray's origin. But those are both points, you say.
Correct! When you subtract a point from a point, you get a vector that describes their
difference in space. Remember, from [Part 1](/articles/ray-tracer-part1){:target="x"},
a point is a tuple with "w" = 1, and a vector is "w" = 0. `1 - 1 = 0`, therefore, a vector.
We also normalize the vector, which makes its length equal to 1 unit, which simpliflies
the calculations. It's just a direction that can be extrapolated on with further
calculations on the ray, which we will discuss next!

# Intersections and Hits: I Hope You Have Insurance
Now that we have a ray and a spot to cast it to, we need to see if it actually
runs into anything. The first step is to determine any intersections between the ray's
origin and the wall: `ray.intersect(&sphere)`. Regarding math, here be dragons.
```rust
pub fn intersect<'a>(&'a self, sphere: &'a Sphere) -> Option<Vec<Intersection>>
```
The ray accepts a sphere and returns a list of intersections, or `None` if it only
finds empty space. Let's look at the implementation of `intersect` in sections.
```rust
// Hardcoded unit sphere
let sphere_center = Tuple::point(0.0, 0.0, 0.0);
// Transform the ray instead of the sphere - let the sphere stay at unit
let transform_inverse = match sphere.transform.inverse() {
    Some(transform_inverse) => transform_inverse,
    None => return None,
};
let new_ray = self.transform(transform_inverse);
```
This is an interesting take on using the transformations. Since the origin of the axes
is actually the top left corner of the canvas, that's where the center of the sphere starts.
In order to render the sphere centered in the canvas, it must be transformed to have
the corresponding coordinates. That's why it has the `transform` attribute containing
a matrix. However, instead of applying the matrix to the sphere to transform it, you
can take the matrix's inverse and apply it to the ray to get the same result. The
sphere never moves, but the way ray *thinks* it has. That's pretty neat.
We start with a hardcoded unit sphere, take the inverse of its transform
(not all matrices can be inverted - #math), and create a new ray by multiplying
the current one with said transform:
```rust
fn transform(&self, transformation: Matrix) -> Self {
    Self {
        origin: &transformation * self.origin,
        direction: &transformation * self.direction,
    }
}
```
According to the book, using this method to keep the sphere a unit is the simple path.
Well, I'm glad we're not going down the hard path. Especially when you see the rest of
`intersect`. Without further ado:
```rust
let center_to_origin = new_ray.origin - sphere_center;
let a = new_ray.direction.dot(&new_ray.direction);
let b = 2.0 * new_ray.direction.dot(&center_to_origin);
let c = center_to_origin.dot(&center_to_origin) - 1.0;
let discriminant = b * b - 4.0 * a * c;

if discriminant < 0.0 {
    return None;
}

let sqrt = discriminant.sqrt();
Some(vec![
    Intersection::new((-b - sqrt) / (2.0 * a), sphere),
    Intersection::new((-b + sqrt) / (2.0 * a), sphere),
])
```
This is mostly just codifying the math behind checking ray/sphere intersections.
I'm waving my hand here because I can't explain something I don't understand myself.
If you're feeling frisky, [here's an article that goes into it](https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-sphere-intersection.html){:target="x"}.
The tl;dr: the ray intersects if there is a discriminant value. We've made a new
type to hold onto the intersection values, the object that was hit and the time
it took for the ray to hit it.
```rust
pub struct Intersection<'a> {
    pub time: f64,
    pub object: &'a Sphere,
}
```
Time is relative here; you can think of it as the number of units the ray traveled
before intersecting with the sphere. We return two intersections because the ray
will hit the front side of the sphere and then the back side on the way out. It
could also only glance of the surface at one point as a tangent, in which case
the time values for both intersections are the same.

Now, the final piece of work is to
determine which of the found intersections is the one that is actually visible from
the perspective of the flashlight. Most intersections won't be seen, such as the back
part of the sphere or in more complicated scenes, objects behind objects.
```rust
pub fn hit<'a>(intersections: &'a Vec<Intersection>) -> Option<&'a Intersection<'a>> {
    let mut hit = None;
    for intersection in intersections {
        if intersection.time < 0.0 {
            continue;
        }

        match hit {
            None => hit = Some(intersection),
            Some(last_hit) => {
                if intersection.time < last_hit.time {
                    hit = Some(intersection)
                }
            }
        }
    }
    hit
}
```
We only care about non-negative intersections, since they are in front of the flashlight.
Then we pick the intersection with the smallest time, since that means it is closest
to the flashlight. Much simpler than `intersect`. We return an `Option` in the case
that none of the intersections match these constraints. If we have a hit, we write
that shit down!
```rust
if let Some(intersections) = ray.intersect(&sphere) {
    if hit(&intersections).is_some() {
        let point = Tuple::point(x as f64, y as f64, 0.0);
        canvas.write_pixel(&point, Color::red());
    }
}
```
And there we have it. Convert the canvas to a PPM string and save it to a file.

# Final Summation
