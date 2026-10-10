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
 float bend=.1*sin(p.y*2.+sin(t)); float x=p.x-bend;
 float spacing=3.+uA*6.;
 float branches=abs(sin((p.y-abs(x)*.65+.06*sin(x*5.))*spacing));
 float vein=exp(-branches*32.)*exp(-abs(x)*.7);
 float stem=exp(-abs(x)*65.);
 float fine=exp(-abs(sin((p.y+abs(x)*.25)*spacing*3.))*45.)*.25;
 float surface=.5+.5*sin(x*1.6+p.y*.3);
 vec3 color=mix(vec3(.11,.19,.13),vec3(.52,.64,.32),surface);
 color+=vec3(.38,.38,.16)*(vein+stem+fine)*(.3+uB*.7);
 color+=vec3(.08,.12,.03)*noise(p*12.);
 fragColor=vec4(color*uOpacity,uOpacity);
}
