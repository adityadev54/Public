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
 vec2 p=point()*(3.+(1.-uA)*6.); float t=uTime*TAU/16.;
 vec2 cell=floor(p),f=fract(p),chosen=vec2(0.); float d=10.,second=10.;
 for(int y=-1;y<=1;y++) { for(int x=-1;x<=1;x++) {
  vec2 g=vec2(float(x),float(y)); vec2 id=cell+g;
  vec2 offset=vec2(hash(id),hash(id+19.));
  float dist=length(g+offset-f);
  if(dist<d) {second=d;d=dist;chosen=id;} else {second=min(second,dist);}
 }}
 float shade=.5+.5*cos(hash(chosen)*TAU+sin(t)*.8+p.x*.14);
 vec3 color=mix(vec3(.19,.12,.26),vec3(.74,.62,.77),shade);
 float edge=exp(-(second-d)*55.);
 color+=vec3(.33,.29,.27)*edge*uB;
 color+=vec3(.21,.18,.12)*pow(shade,10.)*uB;
 fragColor=vec4(color*uOpacity,uOpacity);
}
