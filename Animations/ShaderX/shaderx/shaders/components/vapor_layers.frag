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
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float noise(vec2 p) {
 vec2 i=floor(p),f=fract(p); f=f*f*(3.-2.*f);
 return mix(mix(hash(i),hash(i+vec2(1.,0.)),f.x),mix(hash(i+vec2(0.,1.)),hash(i+vec2(1.,1.)),f.x),f.y);
}
vec2 point() {
 vec2 p=(FlutterFragCoord().xy-uSize*.5)/min(uSize.x,uSize.y)*2.;
 float c=cos(uRotation),s=sin(uRotation);
 p=mat2(c,-s,s,c)*p/uScale;
 float t=uTime*TAU/16.;
 return p+uWarp*.22*vec2(sin(p.y*4.+sin(t)),cos(p.x*3.+cos(t)));
}
void main() {
 vec2 p=point(); float t=uTime*TAU/16.;
 vec2 q=p*vec2(1.3,2.8)+vec2(sin(t),cos(t))*(.15+uB*.55);
 float cloud=noise(q)*.55+noise(q*2.1)*.28+noise(q*4.3)*.12+noise(q*8.6)*.05;
 float billow=smoothstep(.2,.8,cloud+uA*.3);
 float glow=exp(-length(p-vec2(-.45,-.55))*1.1);
 vec3 color=mix(vec3(.28,.15,.25),vec3(.86,.63,.51),billow);
 color=mix(color,vec3(.96,.84,.67),glow*.5);
 fragColor=vec4(color*uOpacity,uOpacity);
}
