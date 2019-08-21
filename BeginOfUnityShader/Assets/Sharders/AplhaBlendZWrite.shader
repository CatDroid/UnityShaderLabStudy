Shader "Custom/AplhaBlendZWrite"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _AlphaScale ("Alpha Scale",Range(0,1)) = 0.5 
    }
    SubShader
    {
		Tags 
		{
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
			 
		Pass
		{
			ZWrite On
			ColorMask 0  // ColorMask A | RGB | 0 
			// 不需要shader去做片元着色 只是写入深度信息
		} 

		Pass
		{
			Tags 
			{
				"LightMode" = "ForwardBase"
			}
			ZWrite Off
			ColorMask RGBA
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

#include "UnityCG.cginc"
#include "Lighting.cginc"

#pragma vertex vert
#pragma fragment frag


			float3 _Color;
			sampler2D  _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_Position;
				float2 texcoord: TEXCOORD0;
				float3 worldLightDir : TEXCOORD1;
				float3 worldNormal : TEXCOORD2;
			};

			v2f vert(a2v input)
			{
				v2f o ;

				o.pos = UnityObjectToClipPos(input.vertex);

				o.texcoord = input.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;

				o.worldNormal = mul(input.normal, unity_WorldToObject);

				o.worldLightDir = _WorldSpaceLightPos0.xyz;

				return o;
			}

			float4 frag(v2f input):SV_Target
			{
				float3 worldNormal = normalize(input.worldNormal);
				float3 worldLightDir = normalize(input.worldLightDir);

				float4 texColor = tex2D(_MainTex, input.texcoord);

				float3 albedo = texColor.rgb * _Color.rgb;

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

				float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir) ) ;

				return float4(ambient + diffuse, texColor.a * _AlphaScale );
			}



			ENDCG
		}
        
     
    }
    FallBack "Transparent/VertexLit"
}
