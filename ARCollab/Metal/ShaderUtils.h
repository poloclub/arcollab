//
//  ShaderUtils.h
//  CollabTest
//
//  Created by Pratham Mehta on 25/03/24.
//

#ifndef SurfaceShader_h
#define SurfaceShader_h


#include <metal_stdlib>
#include <RealityKit/RealityKit.h>

using namespace metal;

void applySurfaceShader(realitykit::surface_parameters params, half3 color) {
    auto surface = params.surface();

    // Set the roughness
    surface.set_roughness(1.0);
    surface.set_metallic(0);
    surface.set_emissive_color(0);

    auto uniforms = params.uniforms();
    
    float4 customs = uniforms.custom_parameter();
        
    float3 planeNormal = float3(customs.x, customs.y, customs.z);
    float planeDistance = customs.w;

    float3 worldPosition = params.geometry().model_position();
    float distance = dot(worldPosition.xyz, planeNormal) - planeDistance;
    
    surface.set_base_color(color);
    
    if (distance > 0) {
        discard_fragment();
    }
}



#endif /* ShaderUtils_h */
