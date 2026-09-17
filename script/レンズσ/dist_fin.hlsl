Texture2D prev : register(t0);
cbuffer constant0 : register(b0) {
	float2 size_f;
};
static const uint2 size = uint2(size_f);

float4 dist_fin(float4 pos : SV_Position) : SV_Target
{
	const uint2 p0 = int2(pos.xy);

	uint4 p_min = uint4(p_none, p_none);
	int2 len_sq_min = dot(p_none, p_none);
	[unroll] for (int j = -1; j <= 1; j++) {
		[unroll] for (int i = -1; i <= 1; i++) {
			uint4 p = uint4(p0 + int2(i, j), 0, 0); p.zw = p.xy;
			if (all(p.xy < size)) p = dec(prev[p.xy]);

			const int4 dp = p - int4(p0, p0);
			const int2 len_sq = int2(dot(dp.xy, dp.xy), dot(dp.zw, dp.zw));
			if (valid(p.xy) && len_sq.x < len_sq_min.x) {
				p_min.xy = p.xy;
				len_sq_min.x = len_sq.x;
			}
			if (valid(p.zw) && len_sq.y < len_sq_min.y) {
				p_min.zw = p.zw;
				len_sq_min.y = len_sq.y;
			}
		}
	}

	return float4(int4(p_min) - int4(p0, p0));
}
