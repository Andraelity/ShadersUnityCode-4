# Unity Shaders Compilation Study Case
Repo on Unity Shaders Study Case

![](InGameShaders.gif)

# CHECK

new update on the creation of shaders, new update on the creation of projects of game style code shaders, design, elements based on the structure of content creation, and content validation, effects and elements on model environmnet.


It appears that the language design within unity, does not allow const variable to be used and keep its constantness, for some reason the values that are used with in runtime are not the correct ones just by its ´const´ modifier, so instead if you want to make use of the values you must make them static, this is an exaple of what I am trying to explain.


THIS IS SOMETHING REALLLY PARTICULAR!, we must take in consideratioon this representation, due to its error prone status.


```c++

    /////////////////////////////
    // WORKS CORRECT
    /////////////////////////////

        static float time;
        static float2 mouse;
        static float2 resolution;
        
        static const int iters = 256;
        
        static const float origin_z = 0.0;
        static const float plane_z = 4.0;
        static const float far_z = 64.0;
        
        static const float step = (far_z - plane_z) / float(iters) * 0.025;
        
        static const float color_bound = 0.0;
        static const float upper_bound = 1.0;
        
        static const float scale = 32.0;
        
        static const float disp = 0.25;
```

``` c++

    /////////////////////////////
    // !!!!!!!!!!!!!!!!!DOES NOT WORK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    /////////////////////////////

        float time;
        float2 mouse;
        float2 resolution;
        
         const int iters = 256;
        
        const float origin_z = 0.0;
        const float plane_z = 4.0;
        const float far_z = 64.0;
        
        const float step = (far_z - plane_z) / float(iters) * 0.025;
        
        const float color_bound = 0.0;
        const float upper_bound = 1.0;
        
        const float scale = 32.0;
        
        const float disp = 0.25;


``