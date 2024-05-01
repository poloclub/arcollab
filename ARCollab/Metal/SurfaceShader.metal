//
//  SurfaceShader.metal
//  shaderTest
//
//  Created by Pratham Mehta on 06/03/24.
//

#include <metal_stdlib>
#include "ShaderUtils.h"

using namespace metal;

[[visible]]
void SurfaceShaderInner(realitykit::surface_parameters params) {
    half3 baseColor = half3(1.0, 0.8, 0.8); // red: 1.0, green: 0.8, blue: 0.8
    applySurfaceShader(params, baseColor);
}

[[visible]]
void SurfaceShaderOuter(realitykit::surface_parameters params) {
    half3 baseColor = half3(0.3, 0.3, 0.3); // red: 0.3, green: 0.3, blue: 0.3
    applySurfaceShader(params, baseColor);
}

[[visible]]
void PlaneShader(realitykit::surface_parameters params) {
    auto surface = params.surface();

    // Set a constant black color with 50% opacity
    half3 baseColor = half3(0.0, 0.0, 0.0); // RGB components for black
    half alpha = 0.6; // 50% opacity

    surface.set_base_color(baseColor);
    surface.set_opacity(alpha);
    surface.set_metallic(1);
    surface.set_roughness(1);
}

