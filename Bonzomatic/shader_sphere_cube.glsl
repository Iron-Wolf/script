#version 410 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)
uniform float fFrameTime; // duration of the last frame, in seconds

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler1D texFFTIntegrated; // this is continually increasing
uniform sampler2D texPreviousFrame; // screenshot of the previous frame

in vec2 out_texcoord;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything

/*
Simple shader to learn how it works.
Based on the Revision seminar : https://www.youtube.com/watch?v=uFFR31t1WMM
Camera rotation from : https://www.shadertoy.com/view/4lSXzh

TODO ?
- glitchy stuff
- text
*/

// Variables
float time = fGlobalTime;
int gridSize = 3;
bool movingCam = true;
float speed = 3;

// 2D rotation. Always handy.
mat2 rotation(float th){
  float cs = cos(th), si = sin(th);
  return mat2(cs, -si, si, cs);
}

float sphere(vec3 p, float radius) {
  return length(p) - radius;
}

vec3 sphereNormal(vec3 p, float radius) {
  vec2 eps = vec2(.001, 0.);
  return normalize(
    vec3(sphere(p+eps.xyy, radius) - sphere(p-eps.xyy, radius),
      sphere(p+eps.yxy, radius) - sphere(p-eps.yxy, radius),
      sphere(p+eps.yyx, radius) - sphere(p-eps.yyx, radius)));
}

float box(vec3 p, vec3 b)
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float diffuseDirectional(vec3 n, vec3 l) {
  return dot(n, normalize(l))*.5+.5;
}


void main(void)
{
  // mendatory stuff to draw on the scene.
  // "uv" refer to the axes of the 2D plane, 
  // as oppossed to the X,Y,Z of the 3D plane.
  vec2 uv = out_texcoord;
  uv -= .5;
  uv /= vec2(v2Resolution.y / v2Resolution.x, 1);
  
  
  // switch between 2 camera angle
  bool cam1 = mod(time, 10) >= 0 && mod(time, 10) < 4;
  if (movingCam) {
    if (cam1)
      // movement around the center (somewhat an 8 shape)
      uv += vec2(.5*cos(time*.4), .25*sin(time*.6));
    else
      // tweaked position (no movement)
      uv += vec2(.5);
  }
  
  // camera movement in space
  vec2 cameraXY = vec2(.8*cos(time*.4), .8*sin(time*.6));
  if (cam1)
    // left
    cameraXY.x -= time;
  else
    // right
    cameraXY.x += time;
  float cameraZ = time*speed;
  
  //RayMarching stuff
  vec3 ro = movingCam ? vec3(cameraXY, cameraZ) : vec3(0, 0, -3);
  vec3 p = ro;
  vec3 rd = normalize(vec3(uv,1));
  
  // bumpy effect with the sound input
  float fft = texture( texFFT, p.x ).r * 100;
  //rd.z += fft;
  
  // look around
  if (movingCam) {
    rd.xy *= rotation((time*.25)*.5); 
    rd.xz *= rotation((time*.25)*.5);
  }
  
  // screen color initialized to black
  vec3 color = vec3(0);
  vec3 colorNormal;
  
  bool hit = false;
  float shading = 0;
  float rayDepth = 40;
  
  for (float i=0; i<rayDepth; i++) {
    // position with modulo (to get a repetitive pattern)
    vec3 pMod = mod(p, gridSize)-gridSize*.5;
    
    float d = 0;
    // alternate shape every even modulo of the girdSize
    if (mod(p.y, gridSize*2) >= 0 && mod(p.y, gridSize*2) < gridSize) {
      // sphere with offset animation (along the uv.x axe)
      float radiusOffset = sin(uv.x+time)*.8;
      d = sphere(pMod, radiusOffset);
      // calculate the normal of the same sphere
      colorNormal = sphereNormal(pMod, radiusOffset);
      // if the sphere is "invisible", set d to be unreachable
      // (used to get rid of the noise !)
      if (d > 1) d=1;
    }
    else {
      // box
      // vec3 => width / height / length
      d = box(pMod, vec3(1.47, .3, .3));
      // simple shading
      colorNormal = vec3(1-shading);
    }
    
    if (d < .01) {
      hit = true;
      shading = i/100;
      break;
    }
    p += d*rd;
  }
  
  if (hit) {
    vec3 light = vec3(.5, 2, -20);
    vec3 dd = vec3(diffuseDirectional(colorNormal, light));
    color = mix(vec3(.2,.1,.5), vec3(.8,.2,.4), dd);
  }
  
  // fog
  float t = length(ro-p);
  color = mix(color, vec3(.1, .1, .2), 1-exp(-.002*t*t));
  
  // output
  out_color = vec4(color, 1.);
}
