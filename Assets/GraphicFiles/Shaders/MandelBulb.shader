Shader "MandelBulb"
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


float3 rotate( float3 pos, float x, float y, float z )
{
	float3x3 rotX = { 1.0, 0.0, 0.0, 0.0, cos( x ), -sin( x ), 0.0, sin( x ), cos( x ) };
	float3x3 rotY = { cos( y ), 0.0, sin( y ), 0.0, 1.0, 0.0, -sin(y), 0.0, cos(y) };
	float3x3 rotZ = { cos( z ), -sin( z ), 0.0, sin( z ), cos( z ), 0.0, 0.0, 0.0, 1.0 };

	return mul(mul(mul(rotX ,rotY), rotZ ), pos);
}

float hit( float3 r )
{
	r = rotate( r, sin(TIME), cos(TIME), 0.0 );
	float3 zn = float3( r.xyz );
	float rad = 0.0;
	float hit = 0.0;
	float p = 8.0;
	float d = 1.0;
	for( int i = 0; i < 10; i++ )
	{
		
			rad = length( zn );

			if( rad > 2.0 )
			{	
				hit = 0.5 * log(rad) * rad / d;
			}else{

			float th = atan2( length( zn.xy ), zn.z );
			float phi = atan2( zn.y, zn.x );		
			float rado = pow(rad,8.0);
			d = pow(rad, 7.0) * 7.0 * d + 1.0;
			


			float sint = sin( th * p );
			zn.x = rado * sint * cos( phi * p );
			zn.y = rado * sint * sin( phi * p );
			zn.z = rado * cos( th * p ) ;
			zn += r;
			}
			
	}
	
	return hit;

}

static const float3 eps = float3( 0.1, 0.0, 0.0 );

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


                float2 pos = coordinate;

                float3 ro = float3(pos, -1.2);
                float3 la = float3(0.0, 0.0, 1.0);


                float3 cameraDir = normalize(la - ro);

                float3 cameraRight = normalize(cross(cameraDir, float3(0.0, 1.0, 0.0)));

                float3 cameraUp = normalize(cross(cameraRight, cameraDir));

                float3 rd = normalize(cameraDir + float3(pos, 0.0));


                float t = 0.0;

                float d = 200.0;

                float3 r;

                float3 color = float3(0.0, 0.0, 0.0);

                for(int i = 0; i < 100; i++)
                {
                	if(d > 0.001)
                	{
                		r = ro + rd * t;

                		d = hit(r);
                		t += d;
                	}
                }

                float3 n = float3(hit(r + eps) - hit(r - eps), hit(r + eps.yxz) - hit(r - eps.yxz), hit(r + eps.zyx) - hit(r - eps.zyx));

                float3 mat = float3(0.5, 0.1, 0.3);
                float3 light = float3(0.5, 0.5, -2.0);
                float3 lightCol = float3(0.6, 0.4, 0.5);

                float3 ldir = normalize(light - r);
                float3 diff = dot(ldir, n) * lightCol * 60.0;

                color = diff * mat;

				return float4(color, 1.0);
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

























