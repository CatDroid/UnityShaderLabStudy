Shader "Custom/AlphaBlendWithBothSided"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
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
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Front

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert 
			#pragma fragment frag 

			float4 _Color ;
			sampler2D _MainTex ;
			float4 _MainTex_ST ; 

			struct a2v 
			{
				float4 position : POSITION ;
				float4 normal : NORMAL ;
				float2 texCoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_Position ;
				float3 worldNormal : TEXCOORD0;
				float3 worldLight : TEXCOORD1 ;
				float2 texCoord : TEXCOORD2 ;
			};


			v2f vert (a2v input)
			{
				v2f o ;

				o.vertex = UnityObjectToClipPos(input.position);

				o.texCoord = input.texCoord * _MainTex_ST.xy + _MainTex_ST.zw ;

				o.worldNormal = mul(input.normal, unity_WorldToObject).xyz;

				o.worldLight = _WorldSpaceLightPos0.xyz ;

				return o;
			}

			float4 frag (v2f input):SV_Target
			{

				float3 worldNormal = normalize(input.worldNormal);

				float3 worldLight = normalize(input.worldLight);

				float4 texColor = tex2D (_MainTex, input.texCoord);

				float3 albedo = texColor.rgb * _Color.rgb ;

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo ;

				float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLight));


				return float4( ambient + diffuse , texColor.a );
			}


			ENDCG

		}

		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}

			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Back

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert 
			#pragma fragment frag 

			float4 _Color ;
			sampler2D _MainTex ;
			float4 _MainTex_ST ; 

			struct a2v 
			{
				float4 position : POSITION ;
				float4 normal : NORMAL ;
				float2 texCoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_Position ;
				float3 worldNormal : TEXCOORD0;
				float3 worldLight : TEXCOORD1 ;
				float2 texCoord : TEXCOORD2 ;
			};


			v2f vert (a2v input)
			{
				v2f o ;

				o.vertex = UnityObjectToClipPos(input.position);

				o.texCoord = input.texCoord * _MainTex_ST.xy + _MainTex_ST.zw ;

				o.worldNormal = mul(input.normal, unity_WorldToObject).xyz;

				o.worldLight = _WorldSpaceLightPos0.xyz ;

				return o;
			}

			float4 frag (v2f input):SV_Target
			{

				float3 worldNormal = normalize(input.worldNormal);

				float3 worldLight = normalize(input.worldLight);

				float4 texColor = tex2D (_MainTex, input.texCoord);

				float3 albedo = texColor.rgb * _Color.rgb ;

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo ;

				float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLight));


				return float4( ambient + diffuse , texColor.a );
			}


			ENDCG


		}

    }
    FallBack "Transparent/VertexLit"
}
