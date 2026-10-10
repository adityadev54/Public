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
 float n=3.+uA*7.; float m=2.+uA*3.+.25*sin(t);
 float field=sin(p.x*n)*sin(p.y*m)-sin(p.y*n)*sin(p.x*m);
 float sand=exp(-abs(field)*(12.+uB*32.));
 float grain=noise(p*(180.-uB*100.));
 vec3 color=mix(vec3(.055,.065,.075),vec3(.82,.68,.41),sand*(.65+.35*grain));
 color+=vec3(.16,.12,.065)*pow(grain,8.);
 fragColor=vec4(color*uOpacity,uOpacity);
}
