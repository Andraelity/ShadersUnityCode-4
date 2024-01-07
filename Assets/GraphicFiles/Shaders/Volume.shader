Shader "Volume"
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


			// const float PI = 3.141592654;
			static const float3x3 m = { 0.00,  0.80,  0.60,
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
			    f  = 0.5000*noise( p );
			    p = mul(m,p*2.02);
			    f += 0.2500*noise( p );
			    p = mul(m,p*2.03);
			    f += 0.1250*noise( p );

			    return f;
			}
			
			
			//-----------------------------------------------------------------------------
			// Main functions
			//-----------------------------------------------------------------------------
			float scene(float3 p)
			{	
				return .1-length(p)*.05+fbm(p*.3);
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

			    float2 v = coordinate;
			
				float2 mo = float2(TIME*.1,cos(TIME*.25)*3.);
			
			
			    // camera by iq
			    float3 org = 25.0*normalize(float3(cos(2.75-3.0*mo.x), 0.7-1.0*(mo.y-1.0), sin(2.75-3.0*mo.x)));
				float3 ta = float3(0.0, 1.0, 0.0);
			    float3 ww = normalize( ta - org);
			    float3 uu = normalize(cross( float3(0.0,1.0,0.0), ww ));
			    float3 vv = normalize(cross(ww,uu));
			    float3 dir = normalize( v.x*uu + v.y*vv + 1.5*ww );
				float4 color = float4(0.0, 0.0, 0.0, 0.0);
				
				
				
				const int nbSample = 64;
				const int nbSampleLight = 6;
				
				float zMax         = 40.;
				float step         = zMax/float(nbSample);
				float zMaxl         = 20.;
				float stepl         = zMaxl/float(nbSampleLight);
			    float3 p             = org;
			    float T            = 1.;
			    float absorption   = 100.;
				float3 sun_direction = normalize( float3(1.,.0,.0) );
			    
				for(int i=0; i<nbSample; i++)
				{
					float density = scene(p);
					if(density>0.)
					{
						float tmp = density / float(nbSample);
						T *= 1. -tmp * absorption;
						if( T <= 0.01)
							break;
							
							
						 //Light scattering
						float Tl = 1.0;
						for(int j=0; j<nbSampleLight; j++)
						{
							float densityLight = scene( p + normalize(sun_direction)*float(j)*stepl);
							if(densityLight>0.)
			                	Tl *= 1. - densityLight * absorption/float(nbSample);
			                if (Tl <= 0.01)
			                    break;
						}
						
						//Add ambiant + light scattering color
						color += float4(1.0, 1.0, 1.0, 1.0)*50.*tmp*T +  float4(1.,.7,.4,1.)*80.*tmp*T*Tl;
					}
					p += dir*step;
				}    

				return color;
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

























