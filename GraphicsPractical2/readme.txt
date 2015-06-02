Rick Sen 3472361
Nikè Lambooy 4090349

We regularly met and implemented together. This way we could explain things to eachother and work the fastest.

Notes on use:
To use normal coloring, uncomment line 193 in Simple.fx
To use procedural coloring, uncomment line 195 in Simple.fx
To use Lambertian shading, uncomment line 197 in Simple.fx
To use Lambertian and Blinn-Phong shading, uncomment lines 197 and 198 in Simple.fx

The teapot model and the cobblestone ground each have their own shader.

Further notes:
2.1: We used a directional light. We implemented Lambertian shading in the vertex shader, because this is computationally cheaper
2.3: we implemented Blinn-Phong shading in the pixel shader, because calculating the Blinn-Phong effect in the vertex shader and interpolating it to the pixel shader gives inaccurate results.


We did no bonus assignments