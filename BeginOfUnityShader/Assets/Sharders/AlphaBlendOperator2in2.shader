Shader "Custom/AlphaBlendOperator2in2"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0,1)) = 0.5
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

				ColorMask RGBA
				ZWrite Off

			// 正常 (Normal)
			//BlendOp Add
			//Blend SrcAlpha OneMinusSrcAlpha //,One Zero // RGB 和 Alpha 通道分开混合

			// 柔和相加 (Soft Additive)
			//BlendOp Add 
			//Blend OneMinusDstColor One

			// 正片叠底 (Multiply) 就是源和目标rgba通道各自相乘  不会超过1 
			//BlendOp Add
			//Blend DstColor Zero

			// 两倍相乘 (2x Multiply)
			//BlendOp Add
			//Blend SrcColor DstColor

			// 变暗 (Darken)  源和目标 rgb通道分别选择一个更暗的颜色  Min和Max Blend的因子不起作用 
			//BlendOp Min     
			//Blend One One

			// 变亮 (Lighten)  对于 Red(255,0,0) 和 Blue(0,0,255) Max就是(255,0,255)
			//BlendOp Max
			//Blend One Zero

			// 滤色(Screen)     ( 1 - 0.4 ) * 0.75 + 0.4 ??  0.4是dst 0.75是src
			//Blend OneMinusDstColor One  // 相当于 One OneMinusSrcColor

			// 线性减淡(Linear Dodge)
			Blend One One

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
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_Position;
				float2 texcoord: TEXCOORD0;
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

				return float4( texColor.rgb * _Color.rgb , texColor.a * _AlphaScale);
			}


			ENDCG 
		}
    }
    FallBack "Transparent/VertexLit"
}
