Shader "BlobGoo"
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


#define NUM_BLOBS     120
#define BLOB_SIZE_INV 8.0

float samplev (float2 normFragPos, float aspect)
{
  float valueAll = 0.0;
  for (int i=0; i!=NUM_BLOBS; ++i)
  {
    // create a particle
    float3 particlePos;
    particlePos.x = sin(sin(TIME * 0.05 + float(i*i)))
                  * 0.5 + 0.5;

    particlePos.y = cos(TIME * 0.016 + float(i)*0.1)
                    * 0.5 + 0.5;

    // calculate its influence
    float normDist = length(normFragPos/float2(1.0, aspect)-particlePos.xy);
    normDist = 1.0 - normDist*BLOB_SIZE_INV;
    normDist *= normDist*normDist*(0.5 - abs(0.5 - particlePos.y));
    valueAll += max(0.0, normDist);
  }
    
  return valueAll;
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
	

    float aspect      = 1.0;
    float2  normFragPos = coordinateScale;
      
    float pixelStepX  = 1.0;
    float pixelStepY  = 1.0;
      
      
    float sampleXL = samplev(normFragPos + float2(-pixelStepX, 0.0), aspect);
    float sampleXR = samplev(normFragPos + float2( pixelStepX, 0.0), aspect);
      
    float diffX = sampleXL - sampleXR;
      
    float sampleYB = samplev(normFragPos + float2( 0.0, -pixelStepY), aspect);
    float sampleYU = samplev(normFragPos + float2( 0.0, pixelStepY), aspect);
      
    float diffY = sampleYB - sampleYU;
      
    float3 gradien = float3(diffX*5.0, diffY*5.0, 0.125);
    gradien = normalize(gradien);
  
  
    float sampleCenter = samplev(normFragPos, aspect);
      
      
    // lighting
    float3 lightPos = float3(1.0, 1.5, 2.5);
    float3 lightDir = normalize(lightPos - float3(normFragPos, 0.0));
      
    // diffuse
    float nDotL   = max(0.0, dot(gradien, lightDir));
    float diffuse = nDotL;
      
    // specular
    float3  reflectionDir  = normalize( ( ( 2.0 * gradien ) * nDotL ) - lightDir );
    float3  viewDir        = normalize((float3(normFragPos, 1.2)));
    float reflectDotView = max( 0.0, dot( reflectionDir,  viewDir) );
    float specular = max(0.0, pow(reflectDotView, 15.0));
      
    float value = samplev(normFragPos, aspect);

  //fragColor = vec4(gradien,1.0);
    float4 fragColor = tex2D(_TextureChannel0,
                           float2(sampleCenter, 0.495)) * diffuse + specular;




					


				return float4(fragColor);	
				// return float4(vPixel/GetWindowResolution(), 0.0, 1.0);


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

























