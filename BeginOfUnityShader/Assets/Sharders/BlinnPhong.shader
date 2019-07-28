Shader "Custom/BlinnPhong"
{
    Properties
    {
        _Diffuse ("Diffuse" , Color) = (1,1,1,1)
		_Specular("Specular", Color) = (1,1,1,1) 
        _Gloss ("Gloss", Range(8,256)) = 20
    }

    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        //LOD 200

		Pass {
			Tags { "LightMode" = "ForwardBase" }
		
			CGPROGRAM
	 
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

#pragma vertex vert
#pragma fragment frag

			struct a2v {
				float4 pos : POSITION;
				float3 normal : NORMAL;

			};

			struct v2f {
				float4 pos : SV_POSITION ;
				float3 worldNormal : NORMAL;
				//float3 worldPos : POSITION; // 不能同时有SV_POSITON和POSION 错误Duplicate system value sematic defintion
				float3 worldPos : TEXCOORD1;
			};

			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;
			
			v2f vert(a2v input) 
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.pos);
				o.worldNormal = mul(input.normal, (float3x3)unity_WorldToObject);
				o.worldPos    = mul(unity_ObjectToWorld, input.pos).xyz;
				return o;
			}

			float4 frag(v2f input):SV_Target
			{

				float3 worldLight  = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldNormal = normalize(input.worldNormal); // 注意: !!! 之前在顶点着色器没有做归一化 
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - input.worldPos); 

				float3 halfVector = normalize(viewDir + _WorldSpaceLightPos0.xyz);


				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max( 0, dot(worldNormal, worldLight) );
				float3 specular = _LightColor0.rgb * _Specular.rgb * pow( max(0,dot(worldNormal, halfVector)) , _Gloss);

				return float4(ambient+ diffuse+ specular, 1.0);

			}



			ENDCG
		}

    }
    FallBack "Specular"
}
