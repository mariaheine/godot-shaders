// Its just a godot reimplementation of a gaussian blur shader by mrharicot at 
// shadertoy: https://www.shadertoy.com/view/XdfGDH 

// Same blur bur with verical mask

shader_type canvas_item;

uniform float sigma : hint_range(1,7) = 3.0;
uniform bool showMask = false;
uniform float blur_distance : hint_range(0,0.5) = 0.1;

float gauss_func(float x)
{
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

void fragment() {
	
	vec3 final_color = vec3(0.0);
	
	const int boxSize = 11; // remember it has to be an odd number
	const int kSize = (boxSize - 1) / 2; // kernel size
	float kernel[11]; // that should be [boxSize] but godot is pretty limited with arrays for shaders yet
	
	// mrharicot: create 1-D kernel
	for (int j = 0; j <= kSize; ++j)
	{
		// Gaus function is "symmetric" in 2d aswell, research that its cool
		kernel[kSize+j] = kernel[kSize-j] = gauss_func(float(j));
	}
		
	//mrharicot: get the normalization factor (as the gaussian has been clamped)
	float Z = 0.0;
	for (int j = 0; j < boxSize; ++j)
	{
		Z += kernel[j];
	}
		
	//mrharicot: read out the texels
	for (int i=-kSize; i <= kSize; ++i)
	{
		for (int j=-kSize; j <= kSize; ++j)
		{
			// replace with TEXTURE_PIXEL_SIZE if you want to blur a specific texture
			vec2 sampledOffset = vec2(float(i), float(j)) * SCREEN_PIXEL_SIZE;
			float sampleWeight = kernel[kSize+j]*kernel[kSize+i];
			final_color += sampleWeight*texture(SCREEN_TEXTURE, SCREEN_UV+sampledOffset).rgb;
		}
	}
	
	final_color = final_color/(Z*Z);
	
	// Apply mask
	float mask = smoothstep(blur_distance, 0.5, UV.x) - smoothstep(0.5, 1.0 - blur_distance, UV.x);
	mask = 1.0 - mask;
	
	if (showMask)
	{
		COLOR = vec4(mask);
	}
	else
	{
		COLOR = texture(SCREEN_TEXTURE, SCREEN_UV) * (1.0 - mask) + vec4(final_color, 1.0) * mask;
	}
	
//	COLOR = vec4(1) * mask;
}