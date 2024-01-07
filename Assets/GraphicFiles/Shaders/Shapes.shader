Shader "Shapes"
{
	Properties
	{
		_TextureChannel0 ("Texture", 2D) = "gray" {}
		_TextureChannel1 ("Texture", 2D) = "gray" {}
		_TextureChannel2 ("Texture", 2D) = "gray" {}
		_TextureChannel3 ("Texture", 2D) = "gray" {}


	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" "DisableBatching" ="true" }
		LOD 100

		Pass
		{
		    ZWrite Off
		    Cull off
		    Blend SrcAlpha OneMinusSrcAlpha
		    
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
                  #pragma multi_compile_instancing
			
			#include "UnityCG.cginc"

			struct vertexPoints
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                  UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct pixel
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

                  UNITY_INSTANCING_BUFFER_START(CommonProps)
                  UNITY_DEFINE_INSTANCED_PROP(fixed4, _FillColor)
                  UNITY_DEFINE_INSTANCED_PROP(float, _AASmoothing)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZero_Ten)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeSOne_One)
                  UNITY_DEFINE_INSTANCED_PROP(float, _rangeZoro_OneH)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_x)
                  UNITY_DEFINE_INSTANCED_PROP(float, _mousePosition_y)

                  UNITY_INSTANCING_BUFFER_END(CommonProps)

            

			pixel vert (vertexPoints v)
			{
				pixel o;
				
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.vertex.xy;
				return o;
			}
            
                sampler2D _TextureChannel0;
                sampler2D _TextureChannel1;
                sampler2D _TextureChannel2;
                sampler2D _TextureChannel3;
      			
                #define PI 3.1415927
                #define TIME _Time.y
      
                float2 mouseCoordinateFunc(float x, float y)
                {
                	return normalize(float2(x,y));
                }
            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////
float _union(float a, float b)
{
    return min(a, b);
}

float intersect(float a, float b)
{
    return max(a, b);
}

float diff(float a, float b)
{
    return max(a, -b);
}

// primitive functions
// these all return the distance to the surface from a given point

float plane(float3 p, float3 planeN, float3 planePos)
{
    return dot(p - planePos, planeN);
}

float box( float3 p, float3 b )
{
  	float3 d = abs(p) - b;
  	return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sphere(float3 p, float r)
{
    return length(p) - r;
}

// https://iquilezles.org/articles/distfunctions

float sdCone( float3 p, float2 c )
{
    // c must be normalized
    float q = length(p.xz);
    return dot(c, float2(q, p.y));
}

float sdTorus( float3 p, float2 t )
{
  float2 q = float2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

// transforms
float3 rotateX(float3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    float3 r;
    r.x = p.x;
    r.y = ca*p.y - sa*p.z;
    r.z = sa*p.y + ca*p.z;
    return r;
}

float3 rotateY(float3 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    float3 r;
    r.x = ca*p.x + sa*p.z;
    r.y = p.y;
    r.z = -sa*p.x + ca*p.z;
    return r;
}

// distance to scene
float scene(float3 p)
{	
    float d;
    d = sphere(p, sin(TIME)*0.5+0.5);

    float3 pr = p - float3(1.5, 0.0, 0.0);
    pr = rotateX(pr, TIME);
    pr = rotateY(pr, TIME*0.3);	
    d= _union(d, diff(box(pr , float3(0.6, 0.6, 0.6)), sphere(pr, 0.7)) );

    d = _union(d, sdCone(p + float3(0.0, -0.5, 5.0), float2(1.0, 0.5)));
    pr = p + float3(1.5, 0.0, 0.0);
    pr = rotateX(pr, TIME);
    d = _union(d, sdTorus(pr, float2(0.5, 0.25)));
	
    // d = _union(d, plane(p, float3(0.0, 1.0, 0.0), float3(0.0, -1.0, 0.0)) );
    return d;
}

// calculate scene normal
float3 sceneNormal(float3 pos )
{
    float eps = 0.0001;
    float3 n;
    float d = scene(pos);
    n.x = scene( float3(pos.x+eps, pos.y, pos.z) ) - d;
    n.y = scene( float3(pos.x, pos.y+eps, pos.z) ) - d;
    n.z = scene( float3(pos.x, pos.y, pos.z+eps) ) - d;

    return normalize(n);
}

// ambient occlusion approximation
float ambientOcclusion(float3 p, float3 n)
{
    const int steps = 3;
    const float delta = 0.5;

    float a = 0.0;
    float weight = 1.0;
    for(int i=1; i<=steps; i++) {
        float d = (float(i) / float(steps)) * delta; 
        a += weight*(d - scene(p + n*d));
        weight *= 0.5;
    }
    return clamp(1.0 - a, 0.0, 1.0);

}

// lighting
float3 shade(float3 pos, float3 n, float3 eyePos)
{
    const float3 lightPos = float3(4.0, 3.0, 5.0);
    const float3 color =    float3(sin(TIME), sin(TIME * 90745), sin(TIME/735 * 29357));
    const float shininess = 40.0;

    float3 l = normalize(lightPos - pos);
    float3 v = normalize(eyePos - pos);
    float3 h = normalize(v + l);
    float diff = dot(n, l);
    float spec = max(0.0, pow(dot(n, h), shininess)) * float(diff > 0.0);
    diff = max(0.0, diff);
    //diff = 0.5+0.5*diff;

    float fresnel = pow(1.0 - dot(n, v), 5.0);
    float ao = ambientOcclusion(pos, n);


    return float3(diff*ao, diff * ao, diff * ao)*color;	
}

// trace ray using sphere tracing
float3 trace(float3 ro, float3 rd, out bool hit)
{
    const int maxSteps = 128;
    const float hitThreshold = 0.001;
    hit = false;
    float3 pos = ro;
    float3 hitPos = ro;

    for(int i=0; i<maxSteps; i++)
    {
        float d = scene(pos);
	//d = max(d, 0.000001);
        if (d < hitThreshold) {
            hit = true;
            hitPos = pos;
            //return pos;
        }
        pos += d*rd;
    }
    return hitPos;
}



float3 background(float3 rd)
{
     //return mix(vec3(1.0), vec3(0.0), rd.y);
     return lerp(float3(1.0, 1.0, 1.0), float3(0.0, 0.5, 1.0), abs(rd.y));
     //return vec3(0.0);
}




            fixed4 frag (pixel i) : SV_Target
			{
				
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////

			    UNITY_SETUP_INSTANCE_ID(i);
			    
		    	float aaSmoothing = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _AASmoothing);
			    fixed4 fillColor = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _FillColor);
			   	float _rangeZero_Ten = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZero_Ten);
				float _rangeSOne_One = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeSOne_One);
			    float _rangeZoro_OneH = UNITY_ACCESS_INSTANCED_PROP(CommonProps,_rangeZoro_OneH);
                float _mousePosition_x = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_x);
                float _mousePosition_y = UNITY_ACCESS_INSTANCED_PROP(CommonProps, _mousePosition_y);

                float2 mouseCoordinate = mouseCoordinateFunc(_mousePosition_x, _mousePosition_y);
                float2 mouseCoordinateScale = (mouseCoordinate + 1.0)/ float2(2.0,2.0);

                
                float2 coordinate = i.uv;
                
                float2 coordinateBase = i.uv/(float2(2.0, 2.0));
                
                float2 coordinateScale2 = (coordinate + 1.0 )/ float2(2.0,2.0);
                
                float2 coordinateFull = ceil(coordinateBase);

                //Test Output 
                float3 colBase  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                colBase = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

				float2 pixel = coordinate;

			    // compute ray origin and direction
			    float asp = 1.0;
			    float3 rd = normalize(float3(asp*pixel.x, pixel.y, -2.0));
			    float3 ro = float3(0.0, 0.0, 4.0);
			    ro += rd*2.0;

				float2 mouse = mouseCoordinate;

				float2 a = float2(0.0, 0.0);
				// if (mouse.x > 0.0) {
					// a.x = -(1.0 - mouse.y)*1.5;
				    // a.y = 4.5 -(mouse.x-0.5)*3.0;
				// }

			    rd = rotateX(rd, a.x);
			    ro = rotateX(ro, a.x);

			    rd = rotateY(rd, a.y);
			    ro = rotateY(ro, a.y);

			    // trace ray
			    bool hit;
			    float3 pos = trace(ro, rd, hit);
			    float3 n = 0;
			    // float3 pos = voxelTrace(ro, rd, hit, n);
                // Var outputVoxTracer = voxelTrace(ro, rd, hit, n);
                // float3 pos = outputVoxTracer.pos;
                // n = outputVoxTracer.hitNormal;

			    float3 rgb;

			    if(hit)
			    {
    		    // calc normal
    		        float3 n = sceneNormal(pos);
                    rgb = float3(smoothstep(col2.z * sin(TIME), col2.y, 0.1), smoothstep(col2.y,col2.x * sin(TIME),0.1), smoothstep(col2.z * sin(TIME), col2.x, 0.1)); 

    		    // shade
    		    	// rgb = shade(pos, n, ro);

				}
				else
				{
					rgb = background(rd);
				}


                return float4(rgb, 1.0);


				
			}

			ENDCG
		}
	}
}

























