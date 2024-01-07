Shader "2DAnimation"
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
			// #define pi 3.1415927
			#define pi PI
float _pow(float x, float y) { return pow(abs(x), y); }
float _sin(float x) { return (x < 0.0) ? 0.0 : sin(x); }
float _cos(float x) { return (x < 0.0) ? 0.0 : cos(x); }
float _sqrt(float x) { return sqrt(abs(x)); }

float3 orange_laser2(float f)	{ return (float3(1.3,0.7,0.2)) / _pow(0.9 + abs(f)*2.0, 1.1); }
float3 orange_laser(float f)	{ return (float3(1.3,0.7,0.2)) / _pow(0.9 + abs(f)*80.0, 1.1); }
float3 blue_laser(float f)		{ return (float3(0.5,0.5,1.25)) / _pow(0.5 + abs(f)*40.0, 1.1); }
float3 faint_blue_laser(float f){ return (float3(0.5,0.5,1.25)) / _pow(1.6 + abs(f)*80.0, 1.1); }
float3 red_laser(float f)		{ return (float3(1.25,0.5,0.5)) / _pow(0.0 + abs(f)*60.0, 1.3); }
float3 green_laser(float f)		{ return (float3(0.5,1.25,0.5)) / _pow(0.0 + abs(f)*80.0, 1.1); }
float3 violet_laser(float f)	{ return (float3(1.25,0.5,1.25)) / _pow(0.0 + abs(f)*80.0, 1.1); }
float3 cyan_laser(float f)		{ return (float3(0.5,1.25,1.25)) / _pow(0.0 + abs(f)*80.0, 1.1); }
float3 _main(float2 fragCoord) {
	float3 res = float3(0,0,0);
	float rtime= TIME;
	float2 p = fragCoord;
	
	// grid
	//res += blue_laser(abs(p.x)); res += blue_laser(abs(p.y));
	//res += faint_blue_laser(abs(sin(p.x*pi))); res += faint_blue_laser(abs(sin(p.y*pi)));

	//res += orange_laser((sin(p.x)-p.y) / 15.0);
	//res += sqrt(blue_laser(p.x*_pow(sin(p.x)*cos(p.x),0.9)-p.y));

	
	//light saber duel!
	//res.rgb += red_laser((cross(p.xyy, vec3(sin(rtime), cos(rtime), tan(rtime))).y) / 20.0);
	//res.rgb += green_laser((cross(p.xyy, vec3(sin(-rtime), cos(rtime), tan(rtime))).y) / 20.0);
    //return res;
	

	if (true)
	{
		// blue balls
		float sum = 0.0;
		for (float i = 0.0; i <= 100.0; i +=pi*0.31){
			float t = i * (1.0 + 0.08*sin(0.2*rtime));
			// float value = t * cos(t-rtime*0.2)
			float f = distance(p, 0.1 * float2(t * cos(t-rtime*0.2), t * sin(t-rtime*0.2)));
			sum += 1.0/_pow(f, 2.0);
		}
		res.rgb += cos(rtime) * faint_blue_laser((5.0-sum*0.2) / 50.0);
	}

	// cyan target
	if (true)
	if (sin(rtime)>0.0)
		res.rgb += sin(rtime) * cyan_laser((p.x*sin(3.*p.x)-p.y*sin(3.*p.y)) / 2.0);
	
	// orange balls
	if (true)
	res.rgb += -sin(rtime) * orange_laser2(1.9*sin(rtime*0.9)+p.x*sin(10.0*p.x)+p.y*cos(10.0*p.y));

	// green stuff
	if (true)
	if (-cos(rtime)>0.0)
		res.rgb += -cos(rtime) * green_laser((tan(p.x*p.y*rtime)) / 5.0); // resize your window for a new effect
	
	// 2 curved violet lasers
	if (true)
	res.rgb += violet_laser((distance(p, float2(0.0, 0.0)) - sin(0.1+0.5*rtime)*_pow(p.x, 1.05)) / 2.0);
		
	// 4 red circles
	if (true)
	res.rgb += 
		red_laser((distance(p, float2(0.0,0.0)) - _pow(sin(0.9+0.25*TIME), 3.0)*_sqrt(p.y-p.x)) / 2.0) +
		red_laser((distance(p, float2(0.0,0.0)) - _pow(sin(0.9+0.25*TIME), 3.0)*_sqrt(p.y+p.x)) / 1.0);
	return res;
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
                float4 fragColor = float4(_main(coordinate * 8.0).xyz, 1.0);
				// return float4(color.xyz, (color.x + color.y + color.z)/3.0);
				return float4(fragColor.xyz, 1.0);
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

























