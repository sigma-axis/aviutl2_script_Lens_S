Texture2D src : register(t0);
Texture2D back : register(t1);
cbuffer constant0 : register(b0) {
	float4 base_color; float base_alpha;
	float3 tint_color; float tint_luma, tint_chroma;
	float mul_luma, mul_chroma, add_luma;
	float noise_intensity, noise_seed, inv_noise_size;
	float2 noise_offset;
};
static const float2 V01 = { 0, 1 };
static const float3x3 to_bt601 = {
	0.299, 0.587, 0.114,
	-0.16873589, -0.3312641, 0.5,
	0.5, -0.41868758, -0.08131241,
}, from_bt601 = {
	1, 0, 1.402,
	1, -0.3441363, -0.7141363,
	1, 1.772, 0,
},
mat_luma = mul(mul(from_bt601, float3x3(V01.yxx, V01.xxx, V01.xxx)), to_bt601),
mat_chroma = mul(mul(from_bt601, float3x3(V01.xxx, V01.xyx, V01.xxy)), to_bt601);

static const float3x3
	mat_back = mul_luma * mat_luma + mul_chroma * mat_chroma,
	mat_tint = tint_luma * mat_luma + tint_chroma * mat_chroma;
float4 combine(float4 pos : SV_Position) : SV_Target
{
	float4 c = src[pos.xy], b = back[pos.xy];
	const float noise = noise_intensity * (ibuki(float4(
		inv_noise_size * (pos.xy - noise_offset) + ((1 << 16) - 0.5),
		noise_seed, 7)) - 0.5);

	b.rgb = mul(mat_back, b.rgb) + add_luma * b.a;
	b.rgb += mul(mat_tint, tint_color * b.a - b.rgb) + noise * b.a;
	b *= saturate(base_alpha > 0 ? c.a / base_alpha : sign(c.a));
	[branch] if (base_color.a == 1)
		c -= (base_alpha < 1  && c.a > base_alpha ?
			(1 - c.a) * base_alpha / (1 - base_alpha) :
			c.a) * base_color;
	else c *= saturate(base_alpha < 1  && c.a > 0 ?
			(c.a - base_alpha) / ((1 - base_alpha) * c.a) : 0);
	c += (1 - c.a) * b;
	return c + (1 - c.a) * b;
}
