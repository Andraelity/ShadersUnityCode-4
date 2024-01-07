Shader "Stars"
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



    #define time ( _Time.y+46.0)

    #define CONTRAST 1.1
    #define SATURATION 1.15
    #define BRIGHTNESS 1.03

    static const float3x3 m = { 0.30,  0.90,  0.60,
                  -0.90,  0.36, -0.48,
                  -0.60, -0.48,  0.34 };
    //----------------------------------------------------------------------
    float hash( float n )
    {
        return frac(sin(n)*43758.5453123);
    }

    float hash2( float2 p )
    {
        return frac(sin(p.x+1131.1*p.y)*3751.5453);
    }
    //----------------------------------------------------------------------
    float noise( in float2 x )
    {
        float2 p = floor(x);
        float2 f = frac(x);

        f = f*f*(3.0-2.0*f);

        float n = p.x + p.y*57.0;

        float res = lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
                         lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);

        return res;
    }

    //----------------------------------------------------------------------
    // float noise( in float3 x )
    // {
     
    //     // Use 2D texture...
    //     float3 p = floor(x);
    //     float3 f = frac(x);
    //     f = f*f*(3.0-2.0*f);

    //     float2 uv = (p.xy + float2(37.0,17.0)*p.z) + f.xy;
    //     float2 rg = tex2D( _TextureChannel0, (uv+ 0.5)/256.0).yx;
    //     return lerp( rg.x, rg.y, f.z );


    // }

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




    //----------------------------------------------------------------------
    float fbm( float3 p )
    {
        float f;
        f  = 1.600*noise( p ); 
        p = mul(m,p*2.02);
        f += 0.3500*noise( p );
        p = mul(m, p*2.33);
        f += 0.2250*noise( p );
        p = mul(m,p*2.03);
        f += 0.0825*noise( p );
        p = mul(m,p*2.01);
        return f;
    }

    //----------------------------------------------------------------------
    float4 map( in float3 p )
    {
        float d = 0.01- p.y;

        float f= fbm( p*1.0 - float3(.4,0.3,-0.3)*time);
        d += 4.0 * f;

        d = clamp( d, 0.0, 1.0 );

        float4 res = float4( d, d, d, d );
        res.w = pow(res.y, .1);

        res.xyz = lerp( .7 * float3(1.0,0.4,0.2), float3(0.2,0.0,0.2), res.y * 1.);
        res.xyz = res.xyz + pow(abs(.95-f), 26.0) * 1.85;
        return res;
    }


    //----------------------------------------------------------------------
    static const float3 sundir = float3(1.0,0.4,0.0);
    float4 raymarch( in float3 ro, in float3 rd, in float2 uv)
    {
        float4 sum = float4(0, 0, 0, 0);

        //float t = texture(iChannel3, rd.xy*3131.).x*.2;
        float t = hash2(uv*11.*rd.xy)*.1;
        float3 pos = float3(0.0, 0.0, 0.0);
        for(int i=0; i<130; i++)
        {
            if (sum.a > 0.8 || pos.y > 9.0 || pos.y < -2.0) continue;
            pos = ro + t*rd;

            float4 col = map( pos );

            // Accumulate the alpha with the colour...
            col.a *= 0.08;
            col.rgb *= col.a;

            sum = sum + col*(1.0 - sum.a);	
            t += max(0.1,0.02*t);
        }
        sum.xyz /= (0.003+sum.w);

        return clamp( sum, 0.0, 1.0 );
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
	float2 mo = 1.0;
 
    // Camera code...
    float3 ro = 5.6*normalize(float3(cos(2.75-3.0*mo.x), .4-1.3*(mo.y-2.4), sin(2.75-2.0*mo.x)));
	float3 ta = float3(.0, 5.6, 2.4);
    float3 ww = normalize( ta - ro);
    float3 uu = normalize(cross( float3(0.0,1.0,0.0), ww ));
    float3 vv = normalize(cross(ww,uu));
    float3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

	// Ray march into the clouds adding up colour...
    float4 res = raymarch( ro, rd, coordinateScale );
    // float4 res = 0.0;
	

	float sun = clamp( dot(sundir,rd), 0.0, 2.0 );
	float3 col = lerp(float3(.3,0.0,0.05), float3(0.2,0.2,0.3), sqrt(max(rd.y, 0.001)));
	col += .4 * float3(.4,.2,0.67)*sun;
	col = clamp(col, 0.0, 1.0);
	col += 0.43 * float3(.4,0.4,0.2)*pow( sun, 21.0 );
	
	// Do the stars...
	float v = 1.0/( 2. * ( 1. + rd.z ) );
	float2 xy = float2(rd.y * v, rd.x * v);
    rd.z += time*.002;
    float s = noise(rd.xz*134.0);
	s += noise(rd.xz* 370.);
	s += noise(rd.xz*870.);
	s = pow(s,19.0) * 0.00000001 * max(rd.y, 0.0);
	if (s > 0.0)
	{
		float3 backStars = float3((1.0-sin(xy.x*20.0+time*13.0*rd.x+xy.y*30.0))*.5*s,s, s); 
		col += backStars;
	}

	// Mix in the clouds...
	col = lerp( col, res.xyz, res.w*1.3);
	
    float insideVariable = dot(float3(.2125, .7154, .0721), col*BRIGHTNESS);
	col = lerp(float3(0.5, 0.5, 0.5), lerp(float3(insideVariable, insideVariable, insideVariable), col*BRIGHTNESS, SATURATION), CONTRAST);
    
    float4 fragColor = float4( col, 1.0 );


					


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

























