RWTexture2D<half4> pos_map : register(u0);
Texture2D<half4> src : register(t0);
cbuffer constant0 : register(b0) {
	float2 size_f; float ht_adj_factor;
	float lift, edge_amplify, edge_round, luma_amplify, col_amplify, col_round;
};
static const uint2 size = uint2(size_f);

float calc_luma(float4 col)
{
	static const float3 luma_coeff = { 0.299, 0.587, 0.114 };
	return dot(luma_coeff, col.rgb) / col.a;
}
float cylinder(float2 pos, float rnd)
{
	const float L = length(pos),
		r = rnd > 0 ? 1 - L / max(L, rnd) : 0;
	return sqrt(1 - r * r);
}
float grad_height(float2 pos_edge, float2 pos_col, float luma)
{
	float height = edge_amplify + luma_amplify * luma;
	height *= cylinder(pos_edge, edge_round);
	height += col_amplify * cylinder(pos_col, col_round);

	return height;
}
[numthreads(8, 8, 1)]
void visualize(uint2 id : SV_DispatchThreadID)
{
	if (any(id >= size)) return;
	const float4 p = pos_map[id];
	if (all(p.xy == 0)) {
		pos_map[id] = 0;
		return;
	}
	const float ht = grad_height(p.xy, p.zw, calc_luma(src[id])) + lift;

	pos_map[id] = float4((ht_adj_factor * ht).rrr, 1);
}
