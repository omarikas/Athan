//
//  Wave.metal
//  Athan
//
//  Created by Omarrhazem Khattab  on 03/01/2025.
//

#include <metal_stdlib>
using namespace metal;

[[stitchable]] half4 wave (float2 pos,half4 color, float t){
    float angle =atan2(pos.y-125, pos.x+100)+t;
    return half4(sin(angle)/5,
                sin(angle+2)/5,
                 sin(angle+4)/5,
                 color.a/10);
}
