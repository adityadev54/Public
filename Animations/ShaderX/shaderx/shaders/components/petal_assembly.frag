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
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void main(){
 vec2 p=(FlutterFragCoord().xy-uSize*.5)/min(uSize.x,uSize.y)*2.;
 float c=cos(uRotation),s=sin(uRotation);
 p=mat2(c,-s,s,c)*p/uScale;
 float t=uTime*.392699;
 float grid=18.+uA*50.;
 vec2 cell=floor(p*grid);
 float ink=0.; vec3 pigment=vec3(0.);
 for(int x=-1;x<=1;x++){for(int y=-1;y<=1;y++){
  vec2 id=cell+vec2(float(x),float(y));
  float rnd=hash(id),h=hash(id+19.);
  vec2 q=(id+vec2(rnd,h))/grid;
  vec2 original=q;
  q+=vec2(sin(t+rnd*6.28),cos(t+h*6.28))*(.018+uWarp*.06);
  vec2 touchPoint=(uPointer-.5)*uSize/min(uSize.x,uSize.y)*2.;
  vec2 delta=q-touchPoint;
  q+=normalize(delta+vec2(.001))*exp(-dot(delta,delta)*8.)*uTouch*.14;
  float r=length(original),angle=atan(original.y,original.x);
  vec2 d=(p-q)*grid;
  float mark=exp(-dot(d,d)*9.);
  float mask=1.; vec3 color=vec3(.9,.65,.3);
  float petal=.38+(.14+uB*.18)*cos(angle*6.+sin(t)*.15);
  mask=exp(-pow((r-petal)*17.,2.))+exp(-pow((r-petal*.55)*22.,2.))*.6;
  color=mix(vec3(.64,.22,.32),vec3(1.,.63,.39),rnd);
  float amount=clamp(mark*mask,0.,1.); ink+=amount; pigment+=color*amount;
 }}
 vec3 background=vec3(.055,.025,.04);
 vec3 color=mix(background,pigment/max(ink,.001),clamp(ink,0.,1.));
 float alpha=clamp(ink,0.,1.)*uOpacity;
 fragColor=vec4(pigment/max(ink,.001)*alpha,alpha);
}
