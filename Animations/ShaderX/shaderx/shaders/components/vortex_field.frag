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
uniform vec2 uPointer;
uniform float uTouch;
out vec4 fragColor;
void main(){
 vec2 center=mix(uSize*.5,uPointer*uSize,uTouch);
 vec2 p=(FlutterFragCoord().xy-center)/min(uSize.x,uSize.y)*2./uScale;
 float r=length(p)+.01;
 float angle=atan(p.y,p.x)+uRotation;
 float curl=angle+(1.+uA*5.)/(r+.25)+sin(uTime*.392699)*.8;
 float wave=.5+.5*sin(curl*(2.+floor(uB*7.))-r*8.+uWarp*sin(angle*4.));
 float glow=pow(wave,5.)*exp(-r*.65);
 vec3 ink=vec3(.10,.035,.07);
 vec3 color=mix(ink,vec3(.94,.42,.22),glow);
 color+=vec3(.72,.66,.28)*pow(wave,18.)*.45;
 fragColor=vec4(color*uOpacity,uOpacity);
}
