half4 enc(uint4 p) { p += 1 << 13; p &= 0xffff; p = (p << 15) | (p >> 1); return f16tof32(p); }
uint4 dec(half4 u) { uint4 p = f32tof16(u); p = (p >> 15) | (p << 1); p &= 0xffff; p -= 1 << 13; return p; }
bool valid(uint2 p) { return all((p + (1 << 13)) < (3 << 13)); }
static const uint2 p_none = (1 << 15) - 1;
