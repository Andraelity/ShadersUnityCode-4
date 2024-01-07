Shader "MirrorCube"
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


static const float3 up = float3(0.0, 1.0, 0.0);

float intersectfloor(float3 ro, float3 rd, float height, out float t0)
{	
	if (rd.y==0.0) {
		t0 = 100000.0;
		return 0.0;
	}
	
	t0 = -(ro.y - height)/rd.y;
	t0 = min(100000.0,t0);
	return t0;
}

float intersectbox(float3 ro, float3 rd, float size, out float t0, out float t1, out float3 normal)
// Calculate intersections with origin-centred axis-aligned cube with sides length size
// Returns positive value if there are intersections
{
    float3 ir = 1.0/rd;
    float3 tb = ir * (float3(-size*.5,-size*.5, -size*.5)-ro);
    float3 tt = ir * (float3(size*.5,size*.5,size*.5)-ro);
    float3 tn = min(tt, tb);
    float3 tx = max(tt, tb);
    float2 t = max(tn.xx, tn.yz);
    t0 = max(t.x, t.y);
    t = min(tx.xx, tx.yz);
    t1 = min(t.x, t.y);
	float d = (t1-t0);
	float3 i = ro + t0*rd;
	normal = step(size*.499,abs(i))*sign(i);
	if (t0<-0.01) d = t0;
	return d;
}

float intersect(float3 boxPos, float3 ro, float3 rd, out float3 intersection, out float3 normal, out int material, out float t) 
{
	float tb0=0.0;
	float tb1=0.0;
	float3 boxnormal;
	float dbox = intersectbox(ro-boxPos,rd,1.,tb0,tb1,boxnormal);
	float tf = 0.0;
	float dfloor = intersectfloor(ro,rd,0.,tf);
	t = tf;
	float d = dfloor;
	material = 0; // Sky
	if (d>=0.) {
		normal = float3(0.,1.,0.);
		material = 2; // Floor
	}
	if (dbox>=0.) {
		t = tb0;
		d = dbox;
		normal = boxnormal;
		material = 1; // Box
		if (t<0.) d=-0.1;
	}
	intersection = ro+t*rd;
	return d;
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

				float rotspeed = TIME *1.0;
				float3 light = float3(5.,4.+3.*sin(-rotspeed*.4),2.);
				float radius = sin(rotspeed*.1)*2.+4.;
				float3 boxPos = float3(0.3,1.5+sin(rotspeed),0.2);
				float3 eye = float3(radius*sin(rotspeed),2.*sin(.1*rotspeed)+2.5+2.* 1.0, radius * cos(rotspeed*1.));
				float3 screen = float3((radius-1.)*sin(rotspeed),1.5 * sin(.1*rotspeed) + 2. + 2. * 1.0,(radius-1.) * cos(rotspeed*1.));
			    
				float2 offset = coordinateBase;
				float3 right = cross(up,normalize(screen - eye));
				float3 ro = screen + offset.y*up + offset.x*right;
				float3 rd = normalize(ro - eye);
				float3 newi = 0.0;
				float3 n = 0.0;
				int m,m2;
				float d,lightd,ra,global,direct,shade,t,tlight;
				float3 lrd,i2,n2;
				float3 c = (0.0);
				float3 ca= (0.0);
				float lra=1.;
				for (int reflections=0;reflections<10;reflections++) {
					// Find the direct ray hit
					d = intersect(boxPos,ro,rd,newi,n,m,t);
					// Check for shadows to the light
					lrd = normalize(light-newi);
					tlight = length(light-newi);
					lightd = smoothstep(.5*length(newi-i2),.0,intersect(boxPos,newi,lrd,i2,n2,m2,t));
					if (t>tlight) lightd=1.0;
					// Colouring
					global = .3;
					direct = max( (10./length(lrd)) * dot( lrd, n) ,0.0);
					shade = global + direct*lightd;
					if (m==0) { ra=0.0; c = float3(0.9,2.0,2.5); }
					if (m==1) { ra=0.2; c = shade*(.5+.5*(newi-boxPos)); }
					if (m==2) {
						ra = 0.3;
						float2 mxz = abs(frac(newi.xz)*2.-1.);
						float fade = clamp(1.-length(newi.xz)*.05,0.,1.);
						float fc = lerp(.5,smoothstep(1.,.9,mxz.x+mxz.y),fade);
						c = float3(fc*shade, fc*shade, fc*shade);
					}
					// Calculate any reflection on the next iteration
					ca += lra*c;
					lra *= ra;
					rd = reflect(rd,n);
					ro = newi+0.01*rd;
				}
				float4 fragColor = float4(ca/(1.+ca),1.);

				return float4(fragColor);
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

























