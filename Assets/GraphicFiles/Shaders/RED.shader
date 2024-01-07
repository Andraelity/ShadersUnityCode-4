Shader "RED"
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

static float j;
static float k;
static float g=acos(-1.0);
static float h= sqrt( 0.75 );
static float expand;;
 
 
float2 r(float2 v,float y)
{
    return cos(y)*v+sin(y)*float2(-v.y,v.x);
}
 
void s(inout float2 v,float x, float y) 
{
    float z = fmod(atan2(v.y,v.x),y)-y*.5;
    v=(length(v))*float2(cos(z),sin(z));
    v.x-=x;
}
 
float l(float3 p,float f) 
{
    return length(float2(length(p.xz) - f,p.y));
}
 
float i( float2 p, float y, float z )
{
    return length( max( abs(p) - float2(y,y) + float2(z,z), 0.0 ) ) - z;
}
 
float u( float3 p )
{
    return frac( sin( p.x * 151.0 + p.y * 33.0 + p.z ) * 11.0 );
}
 
float w(float3 p) 
{
    float2 e = float2(1.0, 0.0);
    float3 o= smoothstep(0.0,1.0, frac( p ));
    p= floor( p );
 
    float4 n= lerp(
        float4(
            u( p+e.yyy),//n000, 
            u( p+e.xyy),//n100, 
            u( p+e.yxy),//n010, 
            u( p+e.xxy)),//n110),
        float4(
            u( p+e.yyx),//n001, 
            u( p+e.xyx),//n101, 
            u( p+e.yxx),//n011, 
            u( p+e.xxx)),//n111),
        o.z);
    e = lerp(n.xy, n.zw, o.y);
    return lerp(e.x, e.y, o.x);    
}
 
float A(float3 p)
{
    float3 o= p;
    p.x= fmod( p.x + step( 2.0 * h, fmod( p.y, 4.0 * h ) ), 2.0 ) - 1.0;
    p.y= fmod( p.y, 2.0 * h )- h;
 
    o-= p;
    p.z-= (k == 10.0 ? 0.0 : 44.0) + 2.0 * smoothstep( -0.3, 0.3, cos( o.x * 0.03 + cos( o.y * 0.03 ) + j * 4.0 ) * cos( o.y * 0.01 + cos( o.x * 0.02 ) ) );
    float z= length( p )- 1.5;
    s( p.xy, 0.7, g/3.0);
    return max( z, p.x );
}
 
float B(float3 p)
{
 
    return length( p + float3(sin( j* 3.0) * 22.0,j * 11.0,-22.0))- 22.0;
}
 
float C(float3 p)
{
    float3 o= p;
    p.x= fmod( p.x + step( 2.0 * h, fmod( p.y, 4.0 * h ) ), 2.0 ) - 1.0;
    p.y= fmod( p.y, 2.0 * h )- h;
 
    return max( abs( p.z + 1.0 ) - 0.2, h - length( p.xy ) );
}
 
float D(float3 p)
{
    return length( p - float3(22.0,22.0,-14.0))- expand * 33.0 - 12.0;
}
 
float f(float3 p)
{
    float z= min( min( A(p), B(p) ), C(p) );
    return max(length(p) - 77.0, min( z, max( 0.5 - z, D(p) ) ) );
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

       float CurTime= fmod( TIME, 60.0 );
        j= CurTime / 12.0;
 
    float3 q = float3(coordinateBase,1.0);
 
    float3 p;
        k= 0.0;
    if( j < 1.0 )
    {
                expand= 0.0;
                k= 10.0;
        p= float3( 33.0, 33.0, -11.0 + j * 5.0);
        q.yz= r( q.yz, 0.8 - j );
        q.xz= r( q.xz, 0.5 + j );
    }
    else if( j < 2.0 )
    {
                j-= 1.0;
                expand= j*j;
        p= float3(-11.0, -11.0, -11.0);
        q.yz= r( q.yz, -j * 0.7  );
        q.xz= r( q.xz, -j );
    }
    else if( j < 3.0 )
    {
                j-= 2.0;
                expand= j*j;
        p= float3(33.0, 11.0, 33.0);
        q.yz= r( q.yz, j * 0.4  );
        q.xz= r( q.xz, 1.2 + j * 0.6);
    }
    else
    {
                j= ( j - 3.0 ) * 0.5;
                expand= j*j * 2.0;
        p= float3( lerp( 22.0 - 88.0 * expand, -44.0 * j, j), 22.0, 6.0 );
        q.yz= r( q.yz, j * 0.2 );
        q.xz= r( q.xz, 3.4 + sqrt(j) * 1.4 );
    }
 
    q = normalize(q);
 
    float3 b= float3( .0,.0,.0 );
    float a=1.0;
    
    float t=w( q*666.0 )*0.5,y,z,d;
        float m= 0.0;
    for(int mm= 0; mm < 2; ++mm)
    {
                for( int tt= 0; tt < 256; ++tt )
                {
                        d = f(p+q*t);
                        t+=max( 0.01, d+0.01);
                        if( !(t<66.0 && d>t*.003) )
                        {
                               break;
                        }
                }
        
        if( t > 66.0 )
        {
            break;
        }
 
                m+= 1.0;
 
        p+= q*t;
 
        float2 e = float2(0.04, 0.0);
        float3 n = float3( f(p + e.xyy) - f(p - e.xyy), f(p + e.yxy) - f(p - e.yxy), f(p + e.yyx) - f(p - e.yyx) );
        n= normalize(n);
 
        z= A(p);
 
        float3 c = float3(0.8,.0,.0 );
        float k= .15;
 
        if( z > D(p) )
        {
            z= D(p);
            c = float3(1.0,0.0,0.0 );
        }
        if( z > B(p) )
        {
            z= B(p);
            c = float3(0.05,.1,.2 );
            k= .7;
            e.y= 0.3;
        }
        if( z > C(p) )
        {
            z= C(p);
            c = float3(0.0,0.6,0.8 ) * (0.9 - 0.15 / clamp(dot( n, q ), -1.0, -0.05));
            //k= .2;
            e.y= 2.0;
        }
            
        n+= (w( p * e.y ) + w( p * e.y * 2.0 ) + w( p * e.y * 4.0 )) * e.x;
        n= normalize(n);
        q= reflect( q, n );
 
        z= 1.0;
        for (float yy=6.0;yy>0.;yy--)
        { 
            z-=(yy*.5-f(p+n*yy*.5))/exp2(yy);
        }
        c*= z;
 
        n.yz= r( n.yz, 0.6 );
        
        c*= .4 + .3 * ( 1.0 - abs( n.y - .9 ) );
 
 
        b+= a*c;
        a*= k;
        t= 0.3;
    }
    
    q.yz= r( q.yz, 0.6 );
    float value = 0.7 + q.y * 0.2;
        p= float3(value, value, value);
    if( m < 1.0 )
    {
        p*= float3( 0.95, 1.1, 1.2);
    }
    
    if( q.y > 0.0 )
    {
		float f=  0.0;
		float ra= 0.0;
		q.xz= r(q.xz,ra);
        s(q.xz, 0.3 + f* 0.22, g/8.0);
        q.x= abs( q.x ) - .15 - 0.27* f;
        p+= (0.6 + 4.0 * f )* pow( smoothstep(.2, .0, lerp( abs(q.z),length(q.xz), step(0.0, q.x) ) ), 22.0 );
    }
    
    colBase = (b + a*p);
    return float4(colBase, 1.0);


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

























