Shader "Triforce"
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
			static const float side = 0.3;
			static const float angle = PI*1.0/3.0;
			static const float sinA = 0.86602540378;
			static const float cosA = 0.5;
			static const float3 zero = 0.0;
			static const float3 one  = 1.0;
			
			// generates the colors for the rays in the background
			float4 rayColor(float2 fragToCenterPos, float2 fragCoord) {
				float d = length(fragToCenterPos);
				fragToCenterPos = normalize(fragToCenterPos);
					
				float multiplier = 0.0;
				const float loop = 60.0;
				const float dotTreshold = 0.90;
				const float timeScale = 0.75;
				const float fstep = 10.0;
				
				// generates "loop" directions, summing the "contribution" of the fragment to it. (fragmentPos dot direction)
				float c = 0.5/(d*d);
				float freq = 0.25;		
				for (float i = 1.0; i < loop; i++) {
					float attn = c;
					attn *= 1.85*(sin(i * 0.3 * TIME)*0.5+0.5);
					float t = TIME * timeScale - fstep*i;
					float2 dir = float2(cos(freq*t), sin(freq*t));
					float m = dot(dir, fragToCenterPos);
					m = pow(abs(m), 4.0);
					m *= float((m) > dotTreshold);
					multiplier += 0.5*attn*m/(i);
				}
			
				// radius for the rings around the triforce
				const float r0 = 0.345;
				const float r1 = r0 + 0.02;
				const float r2 = r1 + 0.005;
				
				// "f" controls the intensity of the ray color
				float f = 1.0;
				if (d < r0) f = smoothstep(0.0, 1.0, d/r0);
				else if (d < r1) f = 0.75;//(d - r0) / (r1 - r0);
				else if (d < r2) f = 1.2;
					
			
				const float4 rayColor = float4(0.9, 0.7, 0.3, 1.0);
					
				// Applies the pattern
				float pat = abs(sin(10.0 * fmod(fragCoord.y*fragCoord.x, 1.5)));
				f += pat;
				float4 color = f*multiplier*rayColor;
				return color;
			}
			
			// from "Real Time Collision Detection": compute barycentric coordinates for p with respect to triangle (a,b,c)
			void barycentric(float3 a, float3 b, float3 c, float3 p, out float u, out float v, out float w) {
				float3 v0 = b - a;
				float3 v1 = c - a;
				float3 v2 = p - a;
				
				float d00 = dot(v0, v0);
				float d01 = dot(v0, v1);
				float d11 = dot(v1, v1);	
				float d20 = dot(v2, v0);
				float d21 = dot(v2, v1);
				
				float denom = d00 * d11 - d01 * d01;
				
				v = (d11 * d20 - d01*d21) / denom;
				w = (d00 * d21 - d01*d20) / denom;
				u = 1.0 - v - w;
			}
			
			bool all_set(float3 vec) {
				float prod = vec.x * vec.y * vec.z;
				return (vec.x == 1.0 && vec.y == 1.0 && vec.z == 1.0);
			}
			
			float insideTriforce(float3 pos, float aspect, out float u, out float v, out float w) {
				// 1st triangles - vertices
				float3 v0 = float3(0.5*aspect, 0.8, 1.0);
				float3 v1 = v0 + float3(-side*cosA, -side*sinA, 0.0);
				float3 v2 = v1 + float3(2.0 * (v0.x - v1.x), 0.0, 0.0);
				
				// test if inside 1st triangle
				barycentric(v0, v1, v2, pos, u, v, w);
				float3 uvw = float3(u,v,w);
				float3 inside = step(zero, uvw) * (1.0 - step(one, uvw));
			
				if (all_set(inside))
					return 1.0;
			
				// 2nd triangles - vertices
				float dx = v1.x - v0.x;	// half-side in x
				float dy = v1.y - v0.y;	// half-side in y
				v0 -= float3(-dx, -dy, 0.0);
				v1 = v0 + float3(-side*cosA, -side*sinA, 0.0);
				v2 = v1 + float3(2.0 * (v0.x - v1.x), 0.0, 0.0);	
				
				// test if inside 2nd triangle
				barycentric(v0, v1, v2, pos, u, v, w);
				uvw = float3(u,v,w);
				inside = step(zero, uvw) * (1.0 - step(one, uvw));
				if (all_set(inside))
					return 1.0;
				
				// 3rd triangles - vertices	
				v0 += float3(-dx*2.0, 0.0, 0.0);
				v1 = v0 + float3(-side*cosA, -side*sinA, 0.0);
				v2 = v1 + float3(2.0 * (v0.x - v1.x), 0.0, 0.0);	
			
				// test if inside 3rd triangle
				barycentric(v0, v1, v2, pos, u, v, w);
				uvw = float3(u,v,w);
				inside = step(zero, uvw) * (1.0 - step(one, uvw));
				if (all_set(inside))
					return 1.0;
				
				return 0.0;
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

				float3 pos = float3(coordinateScale, 1.0);
				
				float2 fragToCenterPos = coordinate;
				float4 rayCol = rayColor(fragToCenterPos,pos);
				
				// barycentric coordinates of pos with respect to the triangle of the triforce it lies inside
				float u, v, w;
				float c = insideTriforce(pos, 1.0, u, v, w);	
			
				float lim = 0.075;
				
				float3 normal = float3(0.0, 0.0, 1.0);
				float3 uNormalContrib = 0.0;
				float3 vNormalContrib = 0.0;
				float3 wNormalContrib = 0.0;
					
				// on the edge of each triangle, "bend" the normal in the direction of the edge
				if (u < lim) {
					float uNorm = u/lim;
					float offset = cos(0.5*PI*uNorm);
					offset *= offset;
					uNormalContrib = float3(0.0, -offset, 0.0);
				}
				if (v < lim) {
					float vNorm = v/lim;
					float offset = -cos(0.5*PI*vNorm);
					offset *= offset;
					vNormalContrib = float3(offset*cosA, offset*sinA, 0.0);
				}
				if (w < lim) {
					float wNorm = w/lim;
					float offset = cos(0.5*PI*wNorm);
					offset *= offset;
					wNormalContrib = float3(-offset*cosA, offset*sinA, 0.0);
				}
				
				// sums all the contributions to form the normal
				normal += uNormalContrib + vNormalContrib + wNormalContrib;
				normal = normalize(normal);
				
				// generate a position for the view: on a circle around the center of the screen
				float freq = 1.5 * TIME;
				float3 view = float3(0.5, 0.5, 0.0) + float3(sin(freq), cos(freq), 2.0);
				view = normalize(view);
				
				// Apply lambertian light
				float light = dot( view, normal );
				
				// when the barycentric coordinate falls into the [minW, maxW] interval, shade with a lighter tone
				float minW = fmod(1.15 * TIME, 4.0);
				float maxW = minW + 0.3;
				float s = 1.0;
				if (w > minW && w < maxW)
					s += 0.1;
			
				float4 triforceColor = light * c * float4(s, s, 0.0, 0.0);
				float4 fragColor = lerp(rayCol, triforceColor, c);
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

























