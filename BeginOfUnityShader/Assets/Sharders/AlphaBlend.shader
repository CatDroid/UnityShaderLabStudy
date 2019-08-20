Shader "Custom/AlphaBlend"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_AlphaScale("Alpha Scaler", Range(0.0,1.0)) = 0.5

	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"ignoreProjector" = "True"
			"RenderType" = "Transparent"
		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
				
				
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct a2v 
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				float4 texcoord:TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_Position;
				float3 worldLightDir: TEXCOORD0;
				float3 worldNormal : TEXCOORD1;
				float2 texcoord : TEXCOORD2;
			};

			float3 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			v2f vert(a2v input)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.vertex);

				o.worldNormal = mul(input.normal, unity_WorldToObject).xyz;

				o.worldLightDir = _WorldSpaceLightPos0.xyz;

				o.texcoord = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.wz;

				return o;
			}

			float4 frag(v2f input):SV_Target
			{
				float3 worldNormal = normalize( input.worldNormal );
				float3 worldLightDir = normalize(input.worldLightDir);

				float4 texColor = tex2D(_MainTex, input.texcoord);
				float3 albedo = texColor.rgb * _Color.rgb;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				float3 diffuse = _LightColor0.rgb * albedo * saturate( dot(worldNormal, worldLightDir) ) ;


				float alpha = texColor.a * _AlphaScale;

				return float4(ambient + diffuse, alpha);
			}


			ENDCG

		}
    }
    FallBack "Transparent/VertexLit"
}
