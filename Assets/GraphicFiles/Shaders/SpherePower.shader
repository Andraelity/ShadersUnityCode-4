Shader "SpherePower"
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

            const int _VolumeSteps = 128;
            const float _StepSize = 0.02; 
            const float _Density = 0.2;
            
            const float _SphereRadius = 1.0;
            const float _NoiseFreq = 2.0;
            const float _NoiseAmp = 1.0;
            const float3 _NoiseAnim = float3(0, -1, 0);

            // float noise( in float3 x )
            // {
                // float3 p = floor(x);
                // float3 f = frac(x);
                // f = f*f*(3.0-2.0*f);
                // 
                // float2 uv = (p.xy + float2(37.0,17.0)*p.z) + f.xy;
                // float2 rg = tex2D( _TextureChannel0, x.xy).yx;
                // return lerp( rg.x, rg.y, f.z )*2.0-1.0;
            // }

            float hash(float3 p) {
                
                return frac(abs(sin(sin(123.321 + p.x) * (p.y + 321.123)) * 456.654));
            }

            float fbm( float3 p )
            {
                float f = 0.0;
                float amp = 0.5;
                for(int i=0; i<4; i++)
                {
                    // f += abs(noise(p)) * amp;
                    f += hash(p) * amp;
                    p *= 2.03;
                    amp *= 0.5;
                }
                return f;
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
                float3 col  = 0.0;
                float3 col2 = float3(coordinate.x + coordinate.y, coordinate.y - coordinate.x, pow(coordinate.x,2.0f));
				//////////////////////////////////////////////////////////////////////////////////////////////
				///	DEFAULT
				//////////////////////////////////////////////////////////////////////////////////////////////
	
                col = 0.0;
                //////////////////////////////////////////////////////////////////////////////////////////////

                float4 colFour = 0.0;

                float2 pCor = coordinateScale2;
                float3 spherCor = float3( 0.5, 0.5, 10.0);
                
                float sphereRadius = 0.25;
                float3 spherCorNormal = float3(spherCor.xy, spherCor.z - sphereRadius);
                float3 spherCorTangent = float3(spherCor.x + sphereRadius, spherCor.y, spherCor.z);
                float3 hipotenuseVector = spherCorTangent - spherCorNormal; 
                float sphereHipotenuseLength = length(hipotenuseVector);
                float step = 0.01;
                float MAXDIS = 50.0;
                float3 direcNorm = float3(pCor.x, pCor.y, step);

                float3 currentDirection = direcNorm;
                float distanceToSphere = 0;

                for(float i = 0; i < MAXDIS; i += step)
                {

                	distanceToSphere = length(spherCor - currentDirection);
                	if(distanceToSphere < sphereRadius)
                	{
                            //d += fbm(p*_NoiseFreq + _NoiseAnim*iTime) * _NoiseAmp;

                        float distanceToSphere2 = distanceToSphere + fbm(currentDirection * _NoiseFreq + _NoiseAnim * TIME) * _NoiseAmp; 
                        // float distanceToSphere2 = distanceToSphere;
                		/////////////////PHONG/////////////////////////////////////
                        // float value = length(spherCorNormal - currentDirection);
                        // value = value/sphereHipotenuseLength;
                		// value = lerp(value, 1, 0.01);
                		// 
                		// colFour = float4(1 - value, 0.0, 0.0 ,1.0);
                        /////////////////PHONG/////////////////////////////////////
                        if(distanceToSphere2 > 0.20)
                        {
                            colFour += lerp(float4(0.025, 0.0, 0.0, 0.05),float4(0.05, 0.0, 0.0, 0.1), 0.02) ;
                        }
                        if(distanceToSphere2 > 0.15 && distanceToSphere2 < 0.20)
                        {
                            colFour += lerp(float4(0.0, 0.025, 0.0, 0.05),float4(0.0, 0.025, 0.0, 0.1), 0.01);
                            
                        }
                        currentDirection = float3(currentDirection.x, currentDirection.y, currentDirection.z + step);
                        
                        if(i > 10.0)
                        {
                         break;
                        }

                	}
                	else
                	{
                		currentDirection = float3(currentDirection.x, currentDirection.y, currentDirection.z + step);
                	}	

                }

                // col = tex2D(_TextureChannel0, coordinate);
                // return float4(col,1.0) ;
                // 
                if (colFour.x >= 0.01)
                {
                	return colFour;
                }
                else
                {
                	return float4(col2, 1.0);
                }


				
			}

			ENDCG
		}
	}
}

























