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
 float ridge=sin(p.x*(3.+uB*10.)+sin(p.y*2.+sin(t))*(.5+uA*3.));
 float relief=pow(.5+.5*ridge,2.);
 float fold=exp(-abs(ridge)*7.);
 vec3 color=mix(vec3(.16,.06,.08),vec3(.94,.54,.39),relief);
 color+=vec3(.8,.66,.42)*fold*.25;
 color*=.7+.3*cos(p.y*.7+cos(t));
 fragColor=vec4(color*uOpacity,uOpacity);
}