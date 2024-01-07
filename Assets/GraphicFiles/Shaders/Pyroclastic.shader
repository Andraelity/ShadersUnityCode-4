Shader "Pyroclastic"
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
		    
			HLSLPROGRAM
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
  			
            #define PI 3.1415926535897931
            #define TIME _Time.y
  
            float2 mouseCoordinateFunc(float x, float y)
            {
            	return normalize(float2(x,y));
            }

            /////////////////////////////////////////////////////////////////////////////////////////////
            // Default 
            /////////////////////////////////////////////////////////////////////////////////////////////


// parameters
// be nice if we had sliders for these!
static int _MaxSteps = 64;
static float _StepDistanceScale = 0.5;
static float _MinStep = 100.0;
static float _DistThreshold = 0.5;
static int _VolumeSteps = 32;
static float _StepSize = 100.0; 
static float _Density = 0.1;
static float _SphereRadius = 0.5;
static float _NoiseFreq = 4.0;
static float _NoiseAmp = -0.5;
static float3 _NoiseAnim = float3(0, -1, 0);

// iq's nice integer-less noise function

// matrix to rotate the noise octaves
static  float3x3 m = { 0.00,  0.80,  0.60,
              	  -0.80,  0.36, -0.48,
              	  -0.60, -0.48,  0.64 };

float hash( float n )
{
    return frac(sin(n)*43758.5453);
}


float noise( in float3 x )
{
    float3 p = floor(x);
    float3 f = frac(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = lerp(lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
                        lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
                        lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( float3 p )
{
    float f;
    f = 0.5000*noise( p ); 
    p = mul(m,p*2.02);
    f += 0.2500*noise( p );
    p = mul(m,p*2.03);
    f += 0.1250*noise( p );
    p = mul(m,p*2.01);
    f += 0.0625*noise( p );
    p = mul(m,p*2.02); 
    f += 0.03125*abs(noise( p ));	
    return f/0.9375;
}


// distance field stuff
float sphereDist(float3 p, float4 sphere)
{
    return length(p - sphere.xyz) - sphere.w;
}

// returns signed distance to nearest surface
// displace is displacement from original surface (0, 1)
float distanceFunc(float3 p, out float displace)
{	
	//float d = length(p) - _SphereRadius;	// distance to sphere
	float d = length(p) - (sin(TIME*4.0)+0.5);	// animated radius
	
	// offset distance with pyroclastic noise
	//p = normalize(p) * _SphereRadius;	// project noise point to sphere surface
	displace = fbm(p*_NoiseFreq + _NoiseAnim* TIME);
	d += displace * _NoiseAmp;
	
	return d;
}

// calculate normal from distance field
float3 dfNormal(float3 pos)
{
    float eps = 0.001;
    float3 n;
    float s;
#if elementVaule 
    // central difference
    n.x = distanceFunc( float3(pos.x+eps, pos.y, pos.z), s ) - distanceFunc( float3(pos.x-eps, pos.y, pos.z), s );
    n.y = distanceFunc( float3(pos.x, pos.y+eps, pos.z), s ) - distanceFunc( float3(pos.x, pos.y-eps, pos.z), s );
    n.z = distanceFunc( float3(pos.x, pos.y, pos.z+eps), s ) - distanceFunc( float3(pos.x, pos.y, pos.z-eps), s );
#else
    // forward difference (faster)
    float d = distanceFunc(pos, s);
    n.x = distanceFunc( float3(pos.x+eps, pos.y, pos.z), s ) - d;
    n.y = distanceFunc( float3(pos.x, pos.y+eps, pos.z), s ) - d;
    n.z = distanceFunc( float3(pos.x, pos.y, pos.z+eps), s ) - d;
#endif

    return normalize(n);
}

// color gradient 
// this should be in a 1D texture really
float4 gradient(float x)
{
	const float4 c0 = float4(4, 4, 4, 1);	// hot white
	const float4 c1 = float4(1, 1, 0, 1);	// yellow
	const float4 c2 = float4(1, 0, 0, 1);	// red
	const float4 c3 = float4(0.4, 0.4, 0.4, 4);	// grey
	
	float t = frac(x*3.0);
	float4 c;
	if (x < 0.3333) {
		c =  lerp(c0, c1, t);
	} else if (x < 0.6666) {
		c = lerp(c1, c2, t);
	} else {
		c = lerp(c2, c3, t);
	}
	//return float4(x);
	//return float4(t);
	return c;
}

// shade a point based on position and displacement from surface
float4 shade(float3 p, float displace)
{	
	// lookup in color gradient
	displace = displace*1.5 - 0.2;
	displace = clamp(displace, 0.0, 0.99);
	float4 c = gradient(displace);
	//c.a *= smoothstep(1.0, 0.8, length(p));
	
	// lighting
	float3 n = dfNormal(p);
	float diffuse = n.z*0.5+0.5;
	//float diffuse = max(0.0, n.z);
	c.rgb = lerp(c.rgb, c.rgb*diffuse, clamp((displace-0.5)*2.0, 0.0, 1.0));
	
	//return float4(float3(displace), 1);
	//return float4(dfNormal(p)*float3(0.5)+float3(0.5), 1);
	//return float4(diffuse);
	//return gradient(displace);
	return c;
}

// procedural volume
// maps position to color
float4 volumeFunc(float3 p)
{
	float displace;
	float d = distanceFunc(p, displace);
	float4 c = shade(p, displace);
	return c;
}

// sphere trace
// returns hit position
float3 sphereTrace(float3 rayOrigin, float3 rayDir, out bool hit, out float displace)
{
	float3 pos = rayOrigin;
	hit = false;
	displace = 0.0;	
	float d;
	//float3 hitPos;
	float disp;
	for(int i=0; i<_MaxSteps; i++) {
		d = distanceFunc(pos, disp);
        	if (d < _DistThreshold) {
			hit = true;
			displace = disp;
			//hitPos = pos;
        		//break;	// early exit from loop doesn't work in ES?
        	}
		//d = max(d, _MinStep);
		pos += rayDir*d*_StepDistanceScale;
	}
	
	return pos;
	//return hitPos;
}


// ray march volume from front to back
// returns color
float4 rayMarch(float3 rayOrigin, float3 rayStep, out float3 pos)
{
	float4 sum = float4(0, 0, 0, 0);
	pos = rayOrigin;
	for(int i=0; i<_VolumeSteps; i++) {
		float4 col = volumeFunc(pos);
		col.a *= _Density;
		col.a = min(col.a, 1.0);
		
		// pre-multiply alpha
		col.rgb *= col.a;
		sum = sum + col*(1.0 - sum.a);	
#if elementVaule
		// exit early if opaque
        	if (sum.a > _OpacityThreshold)
            		break;
#endif		
		pos += rayStep;
	}
	return sum;
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
                
                float2 coordinateScale = (coordinate + 1.0 )/ float2(2.0,2.0);
                
                float2 coordinateFull = ceil(coordinateBase);

                //Test Output 
                float3 colBase  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                colBase = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////


			    float2 p = coordinate; 

			    float rotx = 0.0;
			    float roty = 0.2*TIME - (0.0)*4.0;
				
			    // camera
			    float3 ro = 2.0*normalize(float3(cos(roty), cos(rotx), sin(roty)));
			    float3 ww = normalize(	  float3(0.0,0.0,0.0) - ro);
			    float3 uu = normalize(	  cross( float3(0.0,1.0,0.0), ww ));
			    float3 vv = normalize(	  cross(ww,uu));
			    float3 rd = normalize(	   p.x*uu + p.y*vv + 1.5*ww );
			
			    // sphere trace distance field
			    bool hit;
			    float displace;
			    float3 hitPos = sphereTrace(ro, rd, hit, displace);
			
			    float4 col = float4(0, 0, 0, 1);
			    if (hit)
			     {
					// shade
			   		col = shade(hitPos, displace);	// opaque version
					//col = rayMarch(hitPos, rd*_StepSize, hitPos);	// volume render
			    }

				return float4(col);
				//(colBase.x + colBase.y + colBase.z)/3.0
                // return float4(coordinateScale, 0.0, 1.0);
				// return float4(right.x, up2.y, 0.0, 1.0);
				// return float4(coordinate3.x, coordinate3.y, 0.0, 1.0);
				// return float4(ro.xy, 0.0, 1.0);

				// float radio = 0.5;
				// float lenghtRadio = length(offset);

    //             if (lenghtRadio < radio)
    //             {
    //             	return float4(1, 0.0, 0.0, 1.0);
    //             }
    //             else
    //             {
    //             	return 0.0;
    //             }


				
			}

			ENDHLSL
		}
	}
}

























