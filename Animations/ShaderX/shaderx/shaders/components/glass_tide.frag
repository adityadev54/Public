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
float height(vec2 p){
 float t=uTime*.392699;
 float wave=sin(p.x*3.+sin(t)+sin(p.y*2.-t)*.6)*.35;
 wave+=sin(p.y*4.+cos(t)+p.x*1.5)*.2;
 wave+=sin(p.x*8.+p.y*5.+t*2.)*.06;
 vec2 finger=(uPointer-.5)*uSize/min(uSize.x,uSize.y)*2./uScale;
 float c=cos(uRotation),s=sin(uRotation);finger=mat2(c,-s,s,c)*finger;
 float r=length(p-finger);
 wave+=sin(r*17.-t*4.)*exp(-r*2.)*uTouch*.3;
 return wave*(.3+uA)+uWarp*sin(p.y*7.)*.07;
}
void main(){
 vec2 p=(FlutterFragCoord().xy-uSize*.5)/min(uSize.x,uSize.y)*2./uScale;
 float c=cos(uRotation),s=sin(uRotation);p=mat2(c,-s,s,c)*p;
 float h=height(p);
 float dx=(height(p+vec2(.004,0.))-height(p-vec2(.004,0.)))/.008;
 float dy=(height(p+vec2(0.,.004))-height(p-vec2(0.,.004)))/.008;
 vec3 n=normalize(vec3(-dx,-dy,1.));
 float lighting=max(dot(n,normalize(vec3(-.6,-.8,1.))),0.);
 float folds=.5+.5*sin(p.y*2.+p.x+h*4.);
 vec3 color=mix(vec3(.105,.035,.15),vec3(.56,.28,.36),folds*.7);
 color=mix(color,vec3(.93,.7,.47),pow(lighting,3.)*.55);
 float caustic=pow(max(0.,1.-abs(dx+dy*.4)*.65),22.)*uB;
 color+=vec3(1.,.84,.61)*caustic*.34;
 float fresnel=pow(1.-n.z,3.);color+=vec3(.46,.28,.52)*fresnel;
 fragColor=vec4(color*uOpacity,uOpacity);
}
