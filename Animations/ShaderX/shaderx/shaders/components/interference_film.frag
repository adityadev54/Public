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
 float film=(sin(p.x*(2.+uB*5.)+sin(t))+.65*cos(p.y*3.+cos(t))+.35*sin(p.x*p.y*4.+sin(t)));
 float thickness=film*(1.+uA*4.);
 vec3 color=.5+.5*cos(vec3(0.,2.1,4.2)+thickness);
 float gleam=pow(max(0.,1.-abs(sin(film*2.))),12.);
 color=color*.68+gleam*.22;
 color*=.65+.35*exp(-length(p)*.6);
 fragColor=vec4(color*uOpacity,uOpacity);
}