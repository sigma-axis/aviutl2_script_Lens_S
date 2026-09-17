// IbukiHash by Andante (https://twitter.com/andanteyk)
// This work is marked with CC0 1.0. To view a copy of this license, visit https://creativecommons.org/publicdomain/zero/1.0/

float ibuki(float4 v)
{
    const uint4 mult =
        uint4(0xae3cc725, 0x9fe72885, 0xae36bfb5, 0x82c1fcad);

    uint4 u = uint4(v);
    u = u * mult;
    u ^= u.wxyz ^ u >> 13;

    uint r = dot(u, mult);

    r ^= r >> 11;
    r = (r * r) ^ r;

    return r * 2.3283064365386962890625e-10;
}
