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

float sq(float x) { return x*x; }
float surface(vec2 p) {
 float field=0.;
 for(int i=0;i<4;i++) {
  float k=float(i), x=(k-1.5)*.37;
  float bend=sin(p.y*(2.+uWarp*3.)+uTime*.7+k*1.8)*(.07+.12*(1.-uB));
  vec2 finger=source();
  float reach=exp(-sq(p.y-finger.y)*3.);
  bend+=(finger.x-x-bend)*uTouch*reach*.85;
  bend+=sin(p.y*14.-uTime*3.+k)*uTouch*reach*.045;
  float width=.025+uTouch*reach*.025+uA*.065+(.012+.025*uB)*sin(p.y*5.-uTime*(1.8-uB)+k);
  field+=exp(-sq((p.x-x-bend)/width));
  float dy=mod(p.y-uTime*(.3+.3*(1.-uB))+k*.34,1.65)-.82;
  field+=.8*exp(-sq((p.x-x-bend)/(.05+uA*.035))-sq(dy/(.08+uB*.12)));
 }
 return field;
}
void main() {
 vec2 p=point();float f=surface(p);
 float mask=smoothstep(.22,.48,f);
 float dx=(surface(p+vec2(.004,0.))-surface(p-vec2(.004,0.)))/.008;
 float dy=(surface(p+vec2(0.,.004))-surface(p-vec2(0.,.004)))/.008;
 vec3 n=normalize(vec3(-dx*.09,-dy*.09,1.));
 float light=max(dot(n,normalize(vec3(-.5,-.7,1.))),0.);
 float spec=pow(max(dot(reflect(normalize(vec3(.5,.7,-1.)),n),vec3(0.,0.,1.)),0.),24.);
 vec3 bg=vec3(.075,.035,.045)+.025*exp(-dot(p,p));
 vec3 wet=mix(vec3(.28,.075,.02),vec3(.97,.47,.12),light)+vec3(1.,.9,.65)*spec*.8;
 wet+=vec3(.35,.14,.025)*pow(1.-n.z,2.);
 vec3 color=mix(bg,wet,mask);
 fragColor=vec4(color*uOpacity,uOpacity);
}
