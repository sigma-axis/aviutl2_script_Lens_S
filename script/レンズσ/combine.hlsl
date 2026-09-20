Texture2D src : register(t0);
Texture2D back : register(t1);
Texture2D refr_map : register(t2);
Texture2D refl_map : register(t3);
SamplerState smp : register(s0);
cbuffer constant0 : register(b0) {
	float2 size_f; float back_margin, ht_adj_factor;
	float3 chrm_abrr;
	float refl_power; float2 refl_light;
	float mul_luma, add_luma, mul_chroma;
	float face_luma, face_chroma;
	float noise_intensity, noise_seed, inv_noise_size;
	float2 noise_offset;
};
static const uint2 size_back = uint2(size_f + 2 * back_margin);
static const float pi = 2 * acos(0);
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
	mat_fore = face_luma * mat_luma + face_chroma * mat_chroma;

float4 combine(float4 pos : SV_Position) : SV_Target
{
	float4 c = src[pos.xy], p = refr_map[pos.xy] / 512.0, l = refl_map[pos.xy] / 512.0;
	p.xyz = p.w > 0 ? p.xyz / p.w : 0;
	l.xy = l.w > 0 ? l.xy / l.w : 0;
	l.z = p.w > 0 ? l.z / p.w : 0;
	const float2 refr_pos = ht_adj_factor * p.xy, refl_pos = ht_adj_factor * l.xy;
	float2 lit = max(sign(l.z) * pow(abs(refl_power / pi * l.z), 1 / 2.2) * float2(1, -1), 0);
	const float refr_cff = 1 - p.z,
		refl_cff = saturate(4 * (l.w - 0.5) + 0.5) * p.z;
	const float noise = noise_intensity * (ibuki(float4(
		inv_noise_size * (pos.xy - noise_offset) + ((1 << 16) - 0.5),
		noise_seed, 3)) - 0.5);

	const float2
		back_r = back.SampleLevel(smp, (pos.xy + chrm_abrr.r * refr_pos + back_margin) / size_back, 0).ra,
		back_g = back.SampleLevel(smp, (pos.xy + chrm_abrr.g * refr_pos + back_margin) / size_back, 0).ga,
		back_b = back.SampleLevel(smp, (pos.xy + chrm_abrr.b * refr_pos + back_margin) / size_back, 0).ba;
	float3 b_rgb = { back_r.x, back_g.x, back_b.x },
		b_a = { back_r.y, back_g.y, back_b.y };
	const float4 refl = refl_cff * back.SampleLevel(smp, (pos.xy + refl_pos + back_margin) / size_back, 0);
	lit.x = saturate(refl_light.x * lit.x);
	lit.y = refl_light.y * saturate(lit.y);

	b_rgb = mul(mat_back, b_rgb);
	b_rgb *= (1 - lit.y) * refr_cff;
	b_rgb += add_luma * b_a;

	c.rgb = mul(mat_fore, c.rgb);
	c.rgb += c.a * (b_rgb + refl.rgb);
	c.rgb += c.a * (lit.x + noise);

	c.a *= saturate((face_luma + 2 * face_chroma + dot(b_a, 1)) / 3);

	return c;
}
