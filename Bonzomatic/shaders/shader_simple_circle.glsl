#version 430 core

uniform float fGlobalTime; // in seconds
uniform vec2 v2Resolution; // viewport resolution (in pixels)

uniform sampler1D texFFT; // towards 0.0 is bass / lower freq, towards 1.0 is higher / treble freq
uniform sampler1D texFFTSmoothed; // this one has longer falloff and less harsh transients
uniform sampler2D texChecker;
uniform sampler2D texNoise;
uniform sampler2D texTex1;
uniform sampler2D texTex2;
uniform sampler2D texTex3;
uniform sampler2D texTex4;

#define TWO_PI 3.283185
#define NUMBALLS 50.0

float d = -TWO_PI/36.0;
layout(location = 0) out vec4 out_color; // out_color must be written in order to see anything


/*
Shader translated from shadertoy to bonzomatic.
Source : http://glslsandbox.com/e#24832.0
*/
void main( void ) {

    vec2 p = (2.0*gl_FragCoord.xy - v2Resolution)/min(v2Resolution.x, v2Resolution.y); // vec2 p = (2.*gl_FragCoord.xy - resolution)/min(resolution.x, resolution.y);
    vec3 c = vec3(0); //ftfy
  
    for(float i = 0; i < NUMBALLS; i++) {
        float t = TWO_PI * i/NUMBALLS + fGlobalTime; // float t = TWO_PI * i/NUMBALLS + time;
        float x = cos(t) ;
        float y = sin(t);
        vec2 q = 0.8*vec2(x, y);
        c += 0.009/distance(p, q) * vec3(0.5* abs(x), 0, abs(y));
    }
    out_color = vec4(c, 2.0);
}


