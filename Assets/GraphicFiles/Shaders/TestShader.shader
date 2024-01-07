Shader "TestShader"
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
    		static const float4 redFull = float4(1.0, 0.0, 0.0, 1.0);
    		static const float4 whiteFull = float4(1.0, 1.0, 1.0, 1.0);

            float2 paintReflectMiddle(float2 coordinate)
            {
            	// float boolPaint = false
            	float2 xAxis = float2(1.0, 0.0);
            	float2 yAxis = float2(0.0, 1.0); //* direction;
            	float2 insideCoordinate = coordinate;

            	float2 outPaint;

            	float2 pointReflect = reflect(insideCoordinate, yAxis);

            	float2 subPoint = abs(insideCoordinate - pointReflect);

            	subPoint *= 0.5;

            	subPoint = -subPoint;

            	// outPaint = insideCoordinate + subPoint;
            	if(insideCoordinate.x < 0.0)
            	{
            		outPaint = pointReflect + subPoint;
            	}
            	else
            	{
            		outPaint = insideCoordinate + subPoint;
            	}

            	return outPaint;
            	
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

                float2x2 rot = {1, 1, -1, 1};

                float4 white = float4(1.0, 1.0, 1.0, 1.0);

               	float4 colorOutput = 0; 
                
                float3 direction = float3(0.5, 1.0, 0.0);

                float3 limite = float3(1.0, 1.0, 0.0);

                float3 variante =  limite - direction;

                float3 position = direction + variante;

                float correlation = 0.1;

                float3 vertiente = float3(cos(PI/2), sin(PI/2), 0.0);
                


                float2 testValue = float2(vertiente.xy) - coordinate;

                float2 coordinateStatus = float2(-0.5, 0.5) - coordinate;

                float valor = length(testValue);

                float valor2 = length(coordinateStatus);


                float valorCenter = length(coordinate);

                colorOutput = float4(0.0, 0.0, 0.0, 1.0);

                float2 xValue = float2(1.0, 0.0);

                float2 yValue = float2(0.0, 1.0);

                float2 coordinateValue = float2(0.7, 0.5);

				float2 intersecta = reflect( xValue, coordinateValue);

				float valorReflect = length(intersecta - coordinate);

				float2 valueMiddle =  intersecta - coordinateValue; 

				float2 valueMiddleHalf = valueMiddle * 0.5;

				float2 positionLine = coordinateValue + valueMiddleHalf;

				float valuePositionLine = length(positionLine - coordinate);

				float valueCoordinate = length(coordinateValue - coordinate);

				float2 testFunction = paintReflectMiddle(float2(_rangeSOne_One, 0.5));

				float valuetestFunction = length(testFunction - coordinate);


				float2 halfCenter = float2(_rangeSOne_One, 0.5);
				float valuehalfCenter = length(halfCenter - coordinate);


				colorOutput = float4(coordinate, 0.0, 1.0);
				if(valuehalfCenter < 0.03)
				{
					colorOutput = white;
				}

				if(valuetestFunction < 0.05)
				{
					colorOutput = redFull ;
				}				

				if(valueCoordinate < 0.1)
				{
					colorOutput = white;
				}
 
				if(valuePositionLine < 0.05)
				{
					colorOutput = white;
				}
 
				if(valorReflect < 0.1)
				{
					colorOutput = white;
				}
 
                if(valor < 0.1)
                {
                	colorOutput = float4(1.0, 1.0, 1.0, 1.0);
                }
 
                if (valorCenter < 0.05)
                {
                	colorOutput = float4(1.0, 1.0, 1.0, 1.0);
                }
 
                if (valor2 < 0.1)
                {
                	colorOutput = float4(1.0, 1.0, 1.0, 1.0);
                }
                


                return float4(colorOutput);


                // return col;
                // return float4(color, 1.0);

                // col = tex2D(_TextureChannel0, coordinate);
                // return float4(col,1.0) ;
                // 
                // if (colFour.x >= 0.01)
                // {
                	// return colFour;
                // }
                // else
                // {
                	// return float4(col2, 1.0);
                // }


				
			}

			ENDCG
		}
	}
}

























