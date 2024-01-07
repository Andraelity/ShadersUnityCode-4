Shader "StringsFractal"
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


float3 _rot(float3 d, float rot) {
	float3x3 M = {
	  cos(rot),  sin(rot), 0,
	  sin(rot), -cos(rot), 0,
	  0,       0,      1};
	d = mul(M , d).zxy;
	return mul(M , d).xzy;
}

//torus
float torus(float3 p) {
	float  R    = 0.7;
	float  rr   = 0.05;
	float3   d    = abs(fmod(p, 4.0)) - 2.0;
	d           = _rot(d.yxz, 2.2*TIME + p.z);
	float    g  = length(d.xy) - R * R;
	g = (g * g) + (d.z * d.z);
	return sqrt(g) - rr;
}

//rm map
float map(float3 p) {
	float ktt   = TIME;
	float time  = ktt * 3.3 + sin(0.3 * ktt + sin(ktt * 0.5) + p.z * 0.43);
	int   ctime = int(TIME);
	float3  tp    = p;
	float3  up    = p;
	
	if(ctime >= 4*2) {
		p.x        += sin(p.z  * 0.5 + time);
		p.y        += cos(p.z  * 0.4 + time);
		p.z        -= sin(p.x  * 0.7 + time);
	}
	if(ctime >= 48) {
		up         += 0.7;
		up.x       += sin(up.z * 0.20) * 1.5;
		up.x       += cos(up.z * 4.00) * 0.2;
		up.y       -= cos(up.z * 0.15) * 1.0;
		up.y       += cos(up.z * 5.00) * 0.3;
	}
	
	//prim
	float c0   = length(     abs(fmod(p,        8.0) ) - 4.0) - 3.8;
	float c1   = length(     abs(fmod(p.xy,     1.0) ) - 0.5) - 0.5;
	float c2   = length(     abs(fmod(p.xy+0.3,10.0) ) - 5.0) - 5.2;
	float c3   = length(     abs(fmod(p.xy,     5.0) ) - 2.5) - 2.5*0.2;
	float c4   = length(     abs(fmod(up.xy,    4.0) ) - 2.0) - 0.1;
	float k    = 2.7 - dot(abs(p), float3(0.0, 1.0, 0.0));
	//k = max(-c0, k);
	if(ctime >= 12 )	k = max(-c1, k);
	if(ctime >= 16)	k = max(-c2, k);
	if(ctime >= 4*5)	k = max(-c3, k);
	if(ctime >= 4*0)	k = max(-c1, k);
	if(ctime >= 4*8)	k = min( c4, k);
	if(ctime >= 24 )	k = min(torus(tp + 0.3), k);
	return k;
}

//get normal
float3 rnorm(float3 ip) {
  float iit      = map(ip);
  float3  h      = float3(0.01, 0, 0);
  return normalize(float3(
    iit - map(ip + h.xyy),
    iit - map(ip + h.yxy),
    iit - map(ip + h.yyx)));
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

                float time = TIME;

                float2 uv = coordinate;

                float3 dir = normalize(float3(uv * float2(1.0, 0.75), 1.0)).yzx;

                dir = _rot(dir.xyz, TIME * 0.1);
                dir = _rot(dir.yzx, TIME * 0.03);


                float3 pos = float3(TIME * 2.0, 0.0, TIME * 2.0);
                float3 I = pos;
                float t = 0.0;

                for(int i = 0; i < 64; i++)
                {
                	I = pos + dir * t;
                	float h = map(I) * 0.75;

                	if(h < 0.001)break;
                	t += h;
                }

                float3 N = rnorm(pos + dir * t);
                float D = max(dot(pow(N, float3(8.0, 8.0, 8.0)), normalize(float3(-0.5, 0.7, 1.0))), sin(TIME/16) * 0.5);

                float fog = length(I - pos) * 0.03;

                float Scr = 1.0 - dot(uv, uv) * 0.5; 


                float4 color = float4(0.2 * dir + 0.7 * D * lerp(float3(1, 2, 3), float3(4, 2, 1), D) + fog, 1.0) * Scr;
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

























