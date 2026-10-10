#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uSize;
uniform float uTime;
uniform float uScale;
uniform float uRotation;
uniform float uWarp;
uniform float uA;
uniform float uB;
uniform float uOpacity;
out vec4 fragColor;
const float TAU = 6.28318530718;
void main() {
 vec2 p=(FlutterFragCoord().xy-uSize*.5)/min(uSize.x,uSize.y)*2.;
 float c=cos(uRotation),s=sin(uRotation);
 p=mat2(c,-s,s,c)*p/uScale;
 float t=uTime*TAU/16.;
 p+=uWarp*.22*vec2(sin(p.y*4.+sin(t)),cos(p.x*3.+cos(t)));
 float terrain=sin(p.x*2.+sin(t))*.45+cos(p.y*2.8+cos(t))*.35+sin(p.x*p.y*(2.+uA*4.))*.2;
 float bands=(terrain+1.)*(4.+uB*18.);
 float line=1.-smoothstep(.025,.09,abs(fract(bands)-.5));
 vec3 ground=mix(vec3(.035,.09,.09),vec3(.24,.39,.31),terrain*.5+.5);
 vec3 color=ground+line*vec3(.55,.72,.46)*.7;
 fragColor=vec4(color*uOpacity,uOpacity);
}