# My Bonzomatic config + Shaders
This folder contain a [bash script](bonzomatic-update.sh) to install Bonzomatic on GNU/Linux.  
There is also a list of shader in the [shader](shaders/) folder.

## Technical doc
To translate **from** shadertoy to Bonzomatic :  
```
vec4 fragColor = out_color;
vec2 fragCoord = gl_FragCoord.xy;
vec2 iResolution = v2Resolution;
float iTime = fGlobalTime;
```
