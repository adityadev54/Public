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
vec2 source() {
 vec2 p=(uPointer*uSize-uSize*.5)/min(uSize.x,uSize.y)*2.;
 float c=cos(uRotation),s=sin(uRotation);
 return mat2(c,-s,s,c)*p/uScale;
}
vec2 point() {
 vec2 p=(FlutterFragCoord().xy-uSize*.5)/min(uSize.x,uSize.y)*2.;
 float c=cos(uRotation),s=sin(uRotation);
 return mat2(c,-s,s,c)*p/uScale;
}

float smoothUnion(float a,float b,float k) {
 float h=clamp(.5+.5*(b-a)/k,0.,1.);return mix(b,a,h)-k*h*(1.-h);
}
float field(vec3 p) {
 float d=10.;
 for(int i=0;i<5;i++) {
  float k=float(i),a=k*1.256637+uTime*.3;
  vec3 center=vec3(cos(a)*.38,sin(a)*.48,sin(a*2.+uTime*.2)*.22);
  vec2 finger=source();
  float influence=exp(-dot(center.xy-finger,center.xy-finger)*.8);
  center.xy=mix(center.xy,finger,uTouch*influence*.88);
  center.z+=sin(k*2.+uTime*2.)*uTouch*.15;
  float sphere=length(p-center)-(.12+uA*.15);
  d=smoothUnion(d,sphere,.07+uWarp*.2);
 }
 return d;
}
void main() {
 vec2 uv=point(); vec3 ro=vec3(uv,2.4),rd=vec3(0.,0.,-1.);
 float travel=0.; vec3 pos=ro; bool hit=false;
 for(int i=0;i<42;i++) {
  pos=ro+rd*travel;float d=field(pos);
  if(d<.002){hit=true;break;} travel+=d*.85;if(travel>4.)break;
 }
 vec3 color=vec3(.105,.11,.125)+.04*exp(-dot(uv,uv)*1.5);
 if(hit) {
  vec2 e=vec2(.002,0.);
  vec3 n=normalize(vec3(field(pos+e.xyy)-field(pos-e.xyy),field(pos+e.yxy)-field(pos-e.yxy),field(pos+e.yyx)-field(pos-e.yyx)));
  vec3 r=reflect(rd,n);
  float bands=smoothstep(.25,.29+(.18*(1.-uB)),abs(r.y+.2*r.x));
  vec3 environment=mix(vec3(.045,.055,.075),vec3(.86,.88,.9),bands);
  float strip=pow(max(0.,1.-abs(r.x+.4*r.y)*2.),12.+uB*35.);
  float rim=pow(1.-max(n.z,0.),3.);
  color=environment*(.55+.45*max(n.z,0.))+vec3(.95,.83,.69)*strip*.85+rim*.16;
 }
 fragColor=vec4(color*uOpacity,uOpacity);
}
