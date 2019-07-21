Shader "Custom/DiffuseFrag"
{
    Properties
    {
		_Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
		Pass{
			Tags { "LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"


			struct appdata	// 传入管线 
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f		// 顶点着色器输出
			{
				float4 vertex : SV_POSITION; // 输出给给渲染管线 	  
				float3 normalWorld : NORMAL;
			};

			float4 _Diffuse;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normalWorld = mul(v.normal, (float3x3)unity_WorldToObject);
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{

				//float3 normalWorld = mul(i.normal, (float3x3)unity_WorldToObject);
				//normalWorld = normalize(normalWorld);
				float3 normalWorld = normalize(i.normalWorld);

				float3 lightWorld = normalize(_WorldSpaceLightPos0.xyz);


				float diffuseResult = max(0, dot(normalWorld, lightWorld)); 
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * diffuseResult;


				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				float3 color = ambient + diffuse;


				return float4(color, 1.0);
			}

			ENDCG
		}
    }
    FallBack "Diffuse"
}
