Texture2D src : register(t0);
SamplerState smp : register(s0);
cbuffer constant0 : register(b0) {
	float4 back_color;
	float3x2 mat;
	float3 t;
};
float4 back_proj(float4 pos : SV_Position) : SV_Target
{
	const float3 p = mul(mat, pos.xy) + t;
	const float4 c = p.z > 0 ? src.SampleLevel(smp, p.xy / p.z, 0) : 0;
	return c + (1 - c.a) * back_color;
}
