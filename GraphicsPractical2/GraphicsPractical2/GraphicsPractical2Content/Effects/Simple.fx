//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;

// R:
float4 DiffuseColor;
float4 AmbientColor;
float AmbientIntensity;

//---------------------------------- Input / Output structures ----------------------------------

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	// R: added Normal3D; is to be converted to a color for exercise 1.1
	float4 Normal3D : NORMAL0;
};

// The output of the vertex shader. After being passed through the interpolator/rasterizer it is also 
// the input of the pixel shader. 
// Note 1: The values that you pass into this struct in the vertex shader are not the same as what 
// you get as input for the pixel shader. A vertex shader has a single vertex as input, the pixel 
// shader has 3 vertices as input, and lets you determine the color of each pixel in the triangle 
// defined by these three vertices. Therefor, all the values in the struct that you get as input for 
// the pixel shaders have been linearly interpolated between there three vertices!
// Note 2: You cannot use the data with the POSITION0 semantic in the pixel shader.
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	// R: added ColorN 
	float4 ColorN : COLOR0;
	// R: added the coordinate in the XY plane in the 3D world with texture coordinate semantic
	float4 XY3D : TEXCOORD0;
};

//------------------------------------------ Functions ------------------------------------------

// Implement the Coloring using normals assignment here
float4 NormalColor(VertexShaderOutput input)
{
	// R: color the pixel using the normal (non-clamped) converted to a color: ColorN
	return float4(input.ColorN);
}

// Implement the Procedural texturing assignment here
float4 ProceduralColor(VertexShaderOutput input)
{
	// R: normalize the normal
	float4 normal = normalize(input.ColorN);
	// R: define the vector used for inversion
	float4 invertor = {1, 1, 1, 0};
	// R: define the output variable
	float4 color;

	// R: check is the pixel is on a white or black square in the XY plane in 3D
	// R: 100 is added to X and Y, since fmod only works with positive values.
	if(fmod(floor(input.XY3D.x + 1000) + floor(input.XY3D.y + 1000), 2) < 1)
	{
		// R: white square
		color = normal;
	}
	else
	{
		// R: black square
		color = normalize(invertor - normal);
	}
	return color;
}

// R:
float4 LambertianColor(VertexShaderOutput input)
{
	float4 color;

	float3 lightDirection = normalize(float3(-1, -1, -1));
	float3 normal = input.ColorN;
	float3x3 rotateAndScale = (float3x3) World;

	float3 rotatedNormal = normalize(mul(normal, rotateAndScale));
	float3 inversedNormal = mul(-1, rotatedNormal);
	float dotProduct = dot(inversedNormal, lightDirection);

	float3 AmbientLight;
	AmbientLight.xyz = AmbientColor.xyz * AmbientIntensity;



	color.xyz = DiffuseColor * max(0.0f, dotProduct) + AmbientLight; 

	color.w = 0.0f;

	return color;
}

//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
    float4 viewPosition  = mul(worldPosition, View);
	output.Position2D    = mul(viewPosition, Projection);

	// R: added Normal2D to ColorN "conversion"
	output.ColorN = input.Normal3D;
	output.XY3D = worldPosition;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	// R: added parameter Normal2D to function call
	//float4 color = NormalColor(input);
	// R: added call to ProceduralColor()
	//float4 color = ProceduralColor(input);
	// R:
	float4 color = LambertianColor(input);

	return color;
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader  = compile ps_2_0 SimplePixelShader();
	}
}