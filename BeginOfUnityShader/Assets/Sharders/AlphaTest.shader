Shader "Custom/AlphaTest"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_CutAlpha("Alpha CutOff Level",Range(0,1)) = 0.5
	}
		SubShader
		{
			Tags
			{
				"Queue" = "AlphaTest"
				"IgnoreProjector" = "True"
				"RenderType" = "TransparentCutout"
				/* 
				>>>>Queue 渲染队列

				渲染队列，指定对象什么时候渲染，每个队列其实都是利用一个整数进行索引的

				Background	值为1000，此队列的对象最先进行渲染 
				Geometry	Queue的默认值，值为2000，通常用于不透明对象，比如场景中的物件与角色等
				AlphaTest	值为2450，	要么完全透明要么完全不透明，多用于利用贴图来实现边缘透明的效果，也就是美术常说的透贴。
				Transparent 值为3000，	常用于半透明对象，渲染时从后往前进行渲染，建议需要混合的对象放入此队列。
				Overlay		值为4000,	此渲染队列用于叠加效果。最后渲染的东西应该放在这里
				
				自定义渲染队列  Tags{ "Queue" = "Geometry+1" } 
 
				渲染队列直接影响性能中的重复绘制，合理的队列可极大的提升渲染效率。
				
				在Unity中，
				
				渲染队列小于2500的对象都被认为是不透明的物体,（如“Background”，“Geometry”，“AlphaTest”），
				这些物体是从前往后绘制的，
				
				而使用其他的队列（如“Transparent”，“Overlay”）的物体则是
				从后往前绘制的。
				
				这意味着，我们需要尽可能地把物体的队列设置为不透明物体的渲染队列，而尽量避免重复绘制 ????????

				>>>>IgnoreProjector 

				是否忽略Projector投影器的影响，Projector是Unity中内置的组件，可用于实现贴花等功能 ????


				>>>>RenderType 

					Opaque
					Transparent
					TransparentCutout
					Background
					Overlay
					TreeOpaque
					TreeTransparentCutout
					TreeBillboard
					Grass
					GrassBillboard

				   一种内部的约定，用来区别这个Shader要渲染的对象是属于什么类别的
				   你可以想像成是我们把各种不同的物体进行分类一样
				   当然你也可以改成自定义的名称，这样并不会影响到Shader的效果。
				   它的作用是可以利用Camera.SetReplacementShader来更改最终的渲染效果
				   
				   camera.SetReplacementShader("shaderA","RenderType") // Unity的脚本API，需要在C#脚本中进行调用

				   由于这里Tag为"RenderType",所以先查看场景中的shader中是否有RenderType参数，
				   如果有，再看RenderType中的值,是否与shaderA中的RenderType值相等，
				   相等则使用shaderA渲染，否则就不渲染

				   https://zhuanlan.zhihu.com/p/51080323 
				   
				   
				   */
			}

			Pass
			{
				Tags
				{
					"LightMode" = "ForwardBase"

				}
				CGPROGRAM

				#include "UnityCG.cginc"
				#include "Lighting.cginc"

				#pragma vertex vert
				#pragma fragment frag 

				float4 _Color;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _CutAlpha;

				struct a2v {
					float4 pos : POSITION;
					float3 normal: NORMAL;
					float2 texcoord: TEXCOORD0;

				};

				struct v2f {
					float4 vertex : SV_Position;
					float3 normal: TEXCOORD0;
					float2 texcoord: TEXCOORD1;
				};


				v2f vert(a2v input)
				{
					v2f o;

					o.vertex = UnityObjectToClipPos(input.pos);

					o.normal = mul(input.normal, (float3x3)unity_WorldToObject );

					o.texcoord = input.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;

					return o;
				}


				float4 frag(v2f input) : SV_Target
				{

					float3 normal = normalize(input.normal);
					float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

					float4 textureColor = tex2D(_MainTex, input.texcoord);

					// clip(textureColor.a - _CutAlpha)  clip(alpha)  alpha < 0 discard  
					if (textureColor.a < _CutAlpha) {
						discard;
					} // _CutAlpha = 0.502 ??  才能把 50%的颜色去掉???

					float3 albedo = _Color.rgb * textureColor.rgb;


					float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo ;
					float3 diffuse = _LightColor0.rgb * albedo * saturate( dot(lightDir, normal) ) ;

					return float4(ambient + diffuse, 1.0);
				}



			ENDCG
		}

    }
    FallBack "Transparent/Cutout/VertexLit" // ???
}
