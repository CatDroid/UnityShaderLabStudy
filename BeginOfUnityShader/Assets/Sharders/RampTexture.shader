Shader "Custom/RampTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss", Range(0,256)) = 20

	}
		SubShader
		{
			Pass
			{
				Tags
				{
					"LightMode" = "ForwardBase"
				}

				CGPROGRAM

	#pragma vertex vert
	#pragma fragment frag 

	#include "UnityCG.cginc"
	#include "Lighting.cginc"


			float4 _Color;
			sampler2D _RampTex;
			//float4 _RampTex_ST;
			float4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex : POSITION ;
				//float2 texCoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 pos : SV_POSITION;
				//float2 texCoord : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float3 lightDir : TEXCOORD2;
				//float3 posWorld : TEXCOORD0;
				float3 normalWorld : TEXCOORD3;
			};


			v2f vert (a2v input) 
			{
				v2f o;

				o.pos = UnityObjectToClipPos(input.vertex);

				// #define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
				// o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
				//o.texCoord = input.texCoord * _RampTex_ST.xy + _RampTex_ST.zw;
				
				// UnityObjectToWorldNormal 
				// 如果是 统一放大(UNITY_ASSUME_UNIFORM_SCALING),那么用的还是 UnityObjectToWorldDir
				// 否则用的是 逆的转置
				o.normalWorld = mul(input.normal, unity_WorldToObject).xyz;
				//o.posWorld = mul(unity_ObjectToWorld, input.vertex).xyz;
				
				float3 posWorld = mul(unity_ObjectToWorld, input.vertex).xyz;
				o.viewDir = _WorldSpaceCameraPos.xyz - posWorld ;
				o.lightDir = _WorldSpaceLightPos0.xyz;

				return o;
			
			}

			float4 frag(v2f input):SV_Target
			{
				float3 lightDir = normalize(input.lightDir);
				float3 viewDir = normalize(input.viewDir);

				float3 normalWorld = normalize(input.normalWorld);
				
				//float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - input.posWorld);
				//float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
			
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;


				float halfLambert = 0.5 * dot(lightDir, normalWorld) + 0.5;

				// 对于渐变纹理，采样不是使用顶点的纹理坐标，而是使用半兰伯特的余弦值
				// Ramp_Texture0,Ramp_Texture1,Ramp_Texture2 都是512x64分辨率
				// float3 tampColor = tex2D(_RampTex, float2(halfLambert, halfLambert) ).rgb; 
				float3 tampColor = tex2D(_RampTex, float2(halfLambert, 0.5)).rgb; // 当前使用渐变纹理图的y轴方向颜色不变
				float3 diffuse = _LightColor0.rgb * tampColor * _Color.rgb ; // _Color.rgb 材质颜色 

				float3 halfVector = normalize(lightDir + viewDir);
				float3 specular= _LightColor0.rgb * _Specular.rgb * pow( saturate( dot(halfVector, normalWorld) ), _Gloss);

				return float4(ambient + diffuse + specular , 1.0); //  + specular

			}

			ENDCG

		
		}

    }

    FallBack "specular"
}
