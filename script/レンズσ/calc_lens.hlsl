RWTexture2D<half4> pos_map : register(u0);
RWTexture2D<half4> lit_map : register(u1);
Texture2D<half4> src : register(t0);
cbuffer constant0 : register(b0) {
	float2 size_f; float ht_adj_factor;
	float lift, edge_amplify, edge_round, luma_amplify, col_amplify, col_round,
		refr_idx;
	float2 dir_light; float refl_power;
};
static const uint2 size = uint2(size_f);
static const float refr_cff_0 = 1 - (refr_idx - 1) * (refr_idx - 1) / ((refr_idx + 1) * (refr_idx + 1));

float calc_luma(float4 col)
{
	static const float3 luma_coeff = { 0.299, 0.587, 0.114 };
	return dot(luma_coeff, col.rgb) / col.a;
}
float calc_d_luma(float4 c0, float luma, float4 c1)
{
	return c0.a > 0 ? c1.a > 0 ?
		0.5 * (calc_luma(c1) - calc_luma(c0)) :
		luma - calc_luma(c0) : c1.a > 0 ?
		calc_luma(c1) - luma : 0;
}
float2 grad_cylinder(float2 pos, float rnd, out float height)
{
	const float L = length(pos),
		r = rnd > 0 ? 1 - L / max(L, rnd) : 0, s = sqrt(1 - r * r), t = r / s;
	height = s;
	return L > 0 && rnd > 0 ? -(t / (L * rnd)) * pos : 0;
}
float2 grad_height(float2 pos_edge, float2 pos_col, float luma, float2 d_luma, out float height)
{
	height = edge_amplify + luma_amplify * luma;
	float2 slope = luma_amplify * d_luma;

	float ht; float2 sl;
	sl = grad_cylinder(pos_edge, edge_round, ht);
	slope = ht * slope + sl * height;
	height *= ht;

	sl = grad_cylinder(pos_col, col_round, ht);
	slope += col_amplify * sl;
	height += col_amplify * ht;

	return slope;
}
[numthreads(8, 8, 1)]
void calc_lens(uint2 id : SV_DispatchThreadID)
{
	if (any(id >= size)) return;
	const float4 p = pos_map[id];
	if (all(p.xy == 0)) {
		pos_map[id] = 0; lit_map[id] = 0;
		return;
	}
	const float luma = calc_luma(src[id]);
	const float2 d_luma = float2(
		calc_d_luma(src.Load(int3(id.x - 1, id.y, 0)), luma, src.Load(int3(id.x + 1, id.y, 0))),
		calc_d_luma(src.Load(int3(id.x, id.y - 1, 0)), luma, src.Load(int3(id.x, id.y + 1, 0))));
	float ht;
	const float2 slope = grad_height(p.xy, p.zw, luma, d_luma, ht);
	ht += lift;

	const float t2 = dot(slope, slope), t = sqrt(t2), c = 1 / sqrt(1 + t2);
	const float2 ht_dir = (ht_adj_factor * ht) * (t > 0 ? slope / t : 0);

	// refraction.
	float t_r = t2 / (1 + t2); // sin^2(a_i)
	t_r /= refr_idx * refr_idx; // sin^2(a_t)
	t_r = sqrt(t_r / (1 - t_r)); // tan(a_t)
	t_r = (t - t_r) / (1 + t * t_r); // tan(a_i - a_t)

	// reflection.
	const bool has_reflect = t2 > 1;
	const float t_l = has_reflect ? max(2 * t / (1 - t2), -2) : 0; // tan(2 a_i)

	// refraction coefficient by Schlick's approximation.
	float refr_cff = 1 - c;
	refr_cff *= refr_cff; refr_cff *= refr_cff; refr_cff *= 1 - c;
	refr_cff = refr_cff_0 * (1 - refr_cff);

	// highlights. Beckmann distribution.
	float2 lit = -dot(slope, dir_light) * float2(1, -1);
	lit = 0.5 * c * (sqrt(3) + lit);
	lit = lit > 0 ? 1 / (lit * lit) : 0;
	lit = lit * lit * exp(-refl_power * abs(lit - 1));

	pos_map[id] = 512.0 * float4(t_r * ht_dir, refr_cff, 1);
	lit_map[id] = 512.0 * float4(t_l * ht_dir, lit.x - lit.y, has_reflect ? 1 : 0);
}
