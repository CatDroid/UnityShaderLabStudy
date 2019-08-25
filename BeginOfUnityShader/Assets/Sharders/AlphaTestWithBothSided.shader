Shader "Custom/AlphaTestWithBothSided"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Cutoff("Cutoff", Range(0,1)) = 0.55
	}
	SubShader
	{
		Tags
		{
			"Queue" = "AlphaTest"
			"IgnoreProjector" = "True"
			"RenderType" = "TransparentCutout"
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			ZWrite On
			Cull   Off // 关闭背面剔除

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag 

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST; 
			float _Cutoff;



			struct a2v
			{
				float4 position: POSITION;
				float4 normal : NORMAL; 
				float2 texCoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_Position;
				float2 texCoord : TEXCOORD0;
				float3 worldNormal :TEXCOORD1;
				float3 worldLightDir:TEXCOORD2;
			};

			v2f vert(a2v input)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(input.position);
				o.texCoord = input.texCoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

				o.worldNormal = mul(input.normal, unity_WorldToObject);
				o.worldLightDir = _WorldSpaceLightPos0.xyz;

				return o; 
			}

			float4 frag(v2f input):SV_Target
			{

				float4 texColor = tex2D(_MainTex, input.texCoord);
				
				if (texColor.a < _Cutoff) {
					discard;
				}

				float3 albedo = texColor.rgb * _Color.rgb;
				float3 worldNormal = normalize(input.worldNormal);
				float3 worldLightDir = normalize(input.worldLightDir);

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));

				return float4(ambient+ diffuse, 1.0);
			}

			ENDCG


		}
    }
    FallBack "Transparent/Cutout/VertexLit"
}
