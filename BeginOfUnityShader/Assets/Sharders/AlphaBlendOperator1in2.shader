Shader "Custom/AlphaBlendOperator1in2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0,1) ) = 0.5 
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
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			ColorMask RGBA
			
			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_Position;
				float2 texcoord : TEXCOORD0;
			};


			v2f vert(a2v input)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.vertex);
				o.texcoord = input.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;


				return o;
			}

			float4 frag(v2f input):SV_Target
			{

				float4 texColor = tex2D(_MainTex, input.texcoord );

				return float4(texColor.rgb * _Color.rgb, texColor.a *_AlphaScale );
			}

			ENDCG


		}
    }
    FallBack "Diffuse"
}
