# Bonzomatic config + Shaders
This folder contain a [bash script](bonzomatic-update.sh) to install Bonzomatic on GNU/Linux.  
There is also a list of shader in the [shader](shaders/) folder.

## Handy code
To translate a shader **from** shadertoy to Bonzomatic :  
```
vec4 fragColor = out_color;
vec2 fragCoord = gl_FragCoord.xy;
vec2 iResolution = v2Resolution;
float iTime = fGlobalTime;
```

## The Raymarching Algorithm
Let me show you a picture :
```
      y                                                                             
      ▲                                                                             
      │                                                                             
z ◄───┘                                          z                                  
     /                                           │                                  
    ◣ x         ro =          rd =               ▼         ┌─SURFACE_DIST           
               (0,0,5)       normalize(vec3(uv, -1.0))─┐   │                        
                  │                                    │   │   ───────┐             
                  ▼                                    │   │  /      /│             
          ┌────┐                                       ▼   ▼ ┌──────┐ │             
          │    ├┐ p                             p1      p2   │      │ │             
          │    ├┘ |─────────────────────────────|──────►|◄──►│      │ │             
          └────┘  d0        dS                     dS'    dS"│      │/              
                            ▲                      ▲      ▲  └──────┘               
                            │                      │      │                         
                    scene(p)=dS            scene(p1)=dS'  │   dS" < SURFACE_DIST    
                   shortest distance                      └─ the ray is stopped     
                   to a surface, returned                    and we draw the pixel  
                   by the SDF function                                              
```

## References
Ressources found on the path of my journey :
- https://blog.maximeheckel.com/posts/painting-with-math-a-gentle-study-of-raymarching/ simple yet powerfull tuto, with unique visuals
- https://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/ another explaining, a little more complicated
- https://michaelwalczyk.com/blog-ray-marching.html more explaining, with cool example of the distortion effect
