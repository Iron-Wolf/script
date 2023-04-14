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
Shader translated from shadertoy to bonzomatic.
Source : https://www.shadertoy.com/view/Mlj3WV

Simple shader used to configure/test audio setup.
*/
void main(void)
{
    // create pixel coordinates
    vec2 uv = out_texcoord; //vec2 uv = fragCoord.xy / iResolution.xy;

    // quantize coordinates
    const float bands = 30.0;
    const float segs = 40.0;
    vec2 p;
    p.x = floor(uv.x*bands)/bands;
    p.y = floor(uv.y*segs)/segs;

    // read frequency data from first row of texture
    float fft = texture( texFFT, p.x ).r * 100; //float fft  = texture( iChannel0, vec2(p.x,0.0) ).x;

    // led color
    vec3 color = mix(vec3(0.0, 2.0, 0.0), vec3(2.0, 0.0, 0.0), sqrt(uv.y));

    // mask for bar graph
    float mask = (p.y < fft) ? 1.0 : 0.1;

    // led shape
    vec2 d = fract((uv - p) *vec2(bands, segs)) - 0.5;
    float led = smoothstep(0.5, 0.35, abs(d.x)) *
                smoothstep(0.5, 0.35, abs(d.y));
    vec3 ledColor = led*color*mask;

    // output final color
    out_color = vec4(ledColor, 1.0); //fragColor = vec4(ledColor, 1.0);
}
