Texture2D src : register(t0);
cbuffer constant0 : register(b0) {
	float thresh;
};
static const float3x3 to_bt601 = {
	0.299, 0.587, 0.114,
	-0.16873589, -0.3312641, 0.5,
	0.5, -0.41868758, -0.08131241,
};

float4 dist_init(float4 pos : SV_Position) : SV_Target
{
	const int2 p = int2(pos.xy);
	const uint2 p_edge = src[uint2(p)].a > 0 ? p_none : uint2(p);

	float4 dx = 0, dy = 0;
	[unroll] for (int y = -1; y <= 1; y++) {
		[unroll] for (int x = -1; x <= 1; x++) {
			if (x == 0 && y == 0) continue;
			const float4 c = src.Load(int3(p + int2(x, y), 0));
			dx += x * c; dy += y * c;
		}
	}
	dx.xyz = mul(to_bt601, dx.rgb);
	dy.xyz = mul(to_bt601, dy.rgb);
	const float L = dot(dx, dx) + dot(dy, dy);
	const uint2 p_col = src[p].a > 0 && L < 4 * thresh * thresh ? p_none : uint2(p);

	return enc(uint4(p_edge, p_col));
}
