//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;

float4x4 InverseTransposeWorld;

// added: top level variable for Lambertian shading
float4 DiffuseColor;
float4 AmbientColor;
float AmbientIntensity;

// added: top level variables for Blinn-Phong shading
float4 SpecularColor;
float SpecularIntensity;
float SpecularPower;


//---------------------------------- Input / Output structures ----------------------------------

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	// added: added Normal3D; is to be converted to a color for exercise 1.1
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
	// added: added ColorNormal, the normal of the pixel
	float4 ColorNormal : TEXCOORD1;
	// added: added the coordinate in the 3D world with texture coordinate semantic
	float4 XYZ3D : TEXCOORD0;
	// added: added the color when using Lambertian shading
	float4 ColorLambert : COLOR1;
};

//------------------------------------------ Functions ------------------------------------------

// Implement the Coloring using normals assignment here
float4 NormalColor(float4 input)
{
	// added: color the pixel using the provided value.
	return float4(input);
}

// Implement the Procedural texturing assignment here
float4 ProceduralColor(VertexShaderOutput input)
{
	// added: define the output variable
	float4 color;

	// added: check if the pixel is on a white or black square in the XY plane in 3D
	// added: 100 is added to X and Y, since fmod only works with positive values.
	if(fmod(floor(input.XYZ3D.x + 1000) + floor(input.XYZ3D.y + 1000), 2) < 1)
	{
		// added: white square
		color = input.ColorNormal;
	}
	else
	{
		// added: black square
		color = -1*input.ColorNormal;
	}

	// added: return the color
	return color;
}

// added: Lambertian shading is implemented here
float4 LambertianColor(float4 normal)
{
	// added: define the output variable
	float4 color;

	// added: define the direction of the light
	float3 lightDirection = normalize(float3(-1, -1, -1));

	// added: extract the rotation+scale matrix from the World matrix
	float3x3 rotateAndScale = (float3x3) InverseTransposeWorld;
	
	// added: rotate and scale the normal according to world transformations
	float3 rotatedNormal = mul(normal.xyz, rotateAndScale);

	// added: inverse and normalize the normal
	float3 inversedNormal = normalize(mul(-1, rotatedNormal));

	// added: calculate the dot product between the light direction and the inversed normal
	// R; to determine the light intensity
	float dotProduct = dot(inversedNormal, lightDirection);

	// added: calculate the amount of ambient light
	// added: set AmbientIntensity to zero for no ambient light
	float3 AmbientLight;
	AmbientLight.xyz = AmbientColor.xyz * AmbientIntensity;

	// added: calculate the final coloadded: DiffuseColor * DiffuseIntensity + AmbientLight
	color.xyz = DiffuseColor * max(0.0f, dotProduct) + AmbientLight;
	// added: set alpha to zero
	color.w = 0.0f;
	
	// added: return the color
	return color;
}

// added: 
float4 BlinnPhongColor(float4 normal, float4 pixelPosition)
{
	// added: define the output variable
	float4 color;

	// added: define the direction of the light
	float3 l = normalize(float3(-1, -1, -1));

	// added: extract the rotation+scale matrix from the World matrix
	float3x3 rotateAndScale = (float3x3) InverseTransposeWorld;

	// added: rotate and scale the normal according to world transformations
	float3 rotatedNormal = mul(normal.xyz, rotateAndScale);

	// added: inverse and normalize the normal
	float3 inversedNormal = normalize(mul(-1, rotatedNormal));

	// added:  Define all undefined variables of the formula:

	float3 cameraPosition = {0.0f, 50.0f, 100.0f};
	float3 v = normalize(pixelPosition.xyz-cameraPosition.xyz);

	// added: calculate h; the bisector of the angle between the direction of the light and the viewingdirection
	float3 h = normalize(v+l);

	// added:  Calculate the Blinn-Phong shade:
	color.xyz = SpecularColor * SpecularIntensity * pow(max(0.0f, dot(inversedNormal, h)), SpecularPower);

	// added: set alpha to zero
	color.w = 0.0f;

	// added: return the color
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

	// added: added Normal2D to ColorNormal "conversion"
	output.ColorNormal.xyz = input.Normal3D.xyz;
	output.XYZ3D = worldPosition;

	// added: Lambertian shading is implemented here
	float4 colorLambert = {0, 0, 0, 0};
	// added: comment the next line and the indicated line in the pixel shader
	// added: to not render Lambertian shading and thus improve efficiency
	colorLambert = LambertianColor(input.Normal3D);
	output.ColorLambert = colorLambert;
	
	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	// added: define the output variable
	float4 color;
	// added: uncomment one and only one of the following functions
	// added: uncomment the next line to render Normal Coloring
	//color = NormalColor(input.ColorNormal);
	// added: uncomment the next line to render  Procedural Coloring
	//color = ProceduralColor(input);
	// added: uncomment the next 2 lines to render Lambertian+Blinn-Phong Shading
	color = NormalColor(input.ColorLambert);
	color += BlinnPhongColor(input.ColorNormal, input.XYZ3D);


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