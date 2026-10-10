#include <flutter/runtime_effect.glsl>
precision highp float;
uniform vec2 uSize;
uniform float uTime;
uniform float uScale;
uniform float uRotation;
uniform float uWarp;
uniform float uPull;
uniform float uDensity;
uniform float uOpacity;
uniform vec2 uPointer;
uniform float uTouch;
uniform vec3 uColor;
out vec4 fragColor;
const float TAU=6.28318530718;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){
 vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);
 return mix(mix(hash(i),hash(i+vec2(1.,0.)),f.x),mix(hash(i+vec2(0.,1.)),hash(i+vec2(1.,1.)),f.x),f.y);
}
void main(){
 float t=uTime*TAU/16.;
 vec2 aspect=uSize/min(uSize.x,uSize.y);
 vec2 p=(FlutterFragCoord().xy/uSize-.5)*aspect*2.;
 vec2 finger=(uPointer-.5)*aspect*2.;
 vec2 delta=p-finger;
 float influence=uTouch*exp(-dot(delta,delta)*2.);
 // Local tangential force bends the flow; the center follows only partially.
 p-=finger*uTouch*.26;
 p+=vec2(-delta.y,delta.x)*influence*.65;
 p/=uScale;
 float c=cos(uRotation),s=sin(uRotation);p=mat2(c,-s,s,c)*p;
 float radius=length(p),r=max(radius,.025),angle=atan(p.y,p.x);
 float twist=log(r+.08)*(3.+uPull*5.);
 vec3 color=vec3(.025,.014,.033);
 float atmosphere=exp(-r*.45)*(.5+.5*noise(p*1.4+vec2(sin(t),cos(t))));
 color+=vec3(.07,.025,.06)*atmosphere;
 for(int i=0;i<5;i++){
  float depth=float(i),a=angle+twist+t*(1.+depth)+depth*1.7;
  vec2 ring=vec2(cos(a),sin(a))*(2.5+depth*.8);
  float cloud=noise(ring+vec2(log(r+.08)*2.,depth*7.));
  cloud+=.35*noise(ring*2.7+vec2(sin(t),cos(t))*2.);
  float streak=.5+.5*sin(a*(3.+floor(uDensity*5.))+cloud*5.+uWarp*sin(angle*3.));
  float filament=pow(streak,14.-uDensity*8.);
  float breakup=smoothstep(.3,.95,cloud);
  float body=filament*(.2+breakup)*exp(-depth*.28);
  float opening=smoothstep(.07+depth*.008,.19+depth*.018,r);
  float illumination=body*opening*(.32+.28*cos(angle-depth*.5));
  vec3 tint=mix(uColor*.3,uColor,depth/4.);
  color+=tint*illumination*.7;
  color+=vec3(1.,.83,.58)*pow(streak,45.)*breakup*opening*.09;
 }
 float lip=exp(-abs(radius-.15)*25.);
 color+=uColor*lip*.16;
 color*=smoothstep(.025,.125,r);
 color=vec3(1.)-exp(-color*1.55);
 fragColor=vec4(color*uOpacity,uOpacity);
}
