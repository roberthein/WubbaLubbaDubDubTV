#include <metal_stdlib>
using namespace metal;

// --------- Utilities ----------
inline float fractf(float x) { return x - floor(x); }
inline float2 fractf(float2 v) { return v - floor(v); }
inline float3 fractf(float3 v) { return v - floor(v); }

inline float2x2 rmatrix(float a) {
    float c = cos(a);
    float s = sin(a);
    return float2x2(float2(c, -s), float2(s, c));
}

inline float S(float x) {
    return (3.0 * x * x - 2.0 * x * x * x);
}

// --------- Hash / Noise ----------
inline float2 hash22(float2 p)
{
    float3 p3 = fractf(float3(p.x, p.y, p.x) * float3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 19.19);
    return fractf((p3.xx + p3.yz) * p3.zy);
}

inline float hash11(float p)
{
    return length(hash22(float2(p, p)));
}

inline float hash21(float2 co)
{
    return fractf(sin(dot(co, float2(12.9898, 78.233))) * 43758.5453);
}

inline float noise(float2 pos)
{
    float a = hash21(floor(pos));
    float b = hash21(float2(ceil(pos.x),  floor(pos.y)));
    float c = hash21(float2(floor(pos.x), ceil(pos.y)));
    float d = hash21(ceil(pos));
    
    float s1 = S(pos.x - floor(pos.x));
    float s2 = S(pos.y - floor(pos.y));
    
    float f = a +
    (b - a) * s1 +
    (c - a) * s2 +
    (a - b - c + d) * s1 * s2;
    return f;
}

inline float onoise(float2 pos)
{
    const int n = 3;
    const float delta = 3.1415 / 6.0;
    float sum = 0.0;
    float power = 0.5;
    
    float2 p = pos;
    for (int i = 0; i < n; ++i)
    {
        sum += noise(rmatrix(delta * float(i)) * p) * power;
        power *= 0.40;
        p *= 1.9;
    }
    return sum;
}

inline float3 portalTexture(float2 uv, float time, float2 iResolution,
                            float3 c0, float3 c1, float3 c2, float3 c3)
{
    float2 uv2 = uv;
    
    // Polar transform
    uv2 = float2(length(uv), (atan2(uv.y, uv.x) + M_PI_F) / (2.0 * M_PI_F));
    
    uv2.y = fractf(uv2.y + uv2.x * 0.3 - time * 0.01);
    uv2.x = (uv2.x * 1.0) + time * 0.3;
    
    float3 colors[4] = { c0, c1, c2, c3 };
    
    float2 k = float2(10.0, 10.0);
    
    float br1 = onoise(uv2 * k);
    float br2 = onoise(float2(uv2.x, uv2.y - 1.0) * k);
    
    float br = mix(br1, br2, uv2.y);
    br = min(0.99, pow(br * 1.5, 2.5));
    
    int bri = clamp(int(br / 0.25), 0, 3);
    
    return colors[bri];
}

// --------- Stitchable entry ----------
[[ stitchable ]]
half4 RMPortalShader(float2 position,
                     float    time,
                     float    speed,
                     float2   iResolution,
                     float3   c0,
                     float3   c1,
                     float3   c2,
                     float3   c3)
{
    // Normalized pixel coordinates (from 0 to ~, aspect-correct)
    float2 uv = (position * 2.0 - iResolution) / iResolution.y;
    
    float effTime = time * speed;
    
    float3 col = portalTexture(uv, effTime, iResolution, c0, c1, c2, c3);
    
    return half4(half3(col), half(1.0));
}
