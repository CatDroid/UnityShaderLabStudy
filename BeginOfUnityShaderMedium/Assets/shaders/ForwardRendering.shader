// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'

Shader "Custom/ForwardRendering"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1,1,1,1)
		_Gloss("Smoothness", Range(8,255)) = 20
		_Specular("Specular",Color) = (1,1,1,1)
	}

 
	SubShader
	{
		Tags
		{
			"Queue" = "Geometry"
			//"IgnoreProjector" = "True"
			"RenderType" = "Opaque" // "Transparent"  "TransparentCutout"
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

#pragma multi_compile_fwdbase  // 编译指导命令 内置光照衰减变量被正确赋值
#pragma vertex vert
#pragma fragment frag


			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;
			

			struct a2v
			{
				float4 pos : POSITION ;
				float4 normal  : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_Position;
				float3 normal : TEXCOORD0;
				float3 pos : TEXCOORD1;
			};

			v2f vert(a2v input)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(input.pos);
				o.normal = mul(input.normal, unity_WorldToObject).xyz;
				o.pos = mul(unity_ObjectToWorld, input.pos).xyz;
				return o;
			}

			float4 frag(v2f input): SV_Target
			{
				float3 worldPos = input.pos;
				float3 worldNormal = normalize(input.normal);

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);  
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);

				// 环境光/自发光 只在BasePass处理一次 不在AddtionalPass计算
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// _LightColor0 已经是光源的强度和颜色相乘后的结果
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot(lightDir, worldNormal) );

				float3 halfVector = normalize(viewDir + lightDir);
				float3 specular= _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfVector, worldNormal)), _Gloss);

				// 平行光可以认为是没有衰减
				fixed attenuation = 1.0;

				return float4 (ambient + (diffuse + specular)*attenuation, 1.0 );
			}


			ENDCG
		}


		Pass
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			// Forward Base 使用Blend  去掉环境光/自发光/逐顶点/SH光照部分 增加对不同的光源处理

			// 不同光源的处理, 光源的五个属性: 强度 颜色  位置  方向 衰减

			Blend One One

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

#pragma multi_compile_fwdadd
#pragma vertex vert
#pragma fragment frag

			float4 _Diffuse;
			float4 _Specular;
			float _Gloss;

			struct a2v 
			{
				float4 vertex : POSITION ;
				float4 normal : NORMAL;
			};
	
			struct v2f
			{
				float4 pos: SV_Position;
				float3 worldNormal : TEXCOORD0 ;
				float3 worldPos : TEXCOORD1 ;
			};

			v2f vert(a2v input)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.vertex);
				o.worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;
				o.worldNormal = mul(input.normal, unity_WorldToObject).xyz;
				return o;
			}

			float4 frag(v2f input):SV_Target
			{
				float3 worldNormal = normalize(input.worldNormal);
				float3 worldPos = input.worldPos;

				float3 lightDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);

 
#ifdef USING_DIRECTION_LIGHT 
				// _WorldSpaceLightPos0 对于平行光 .z = 0 是平行光的方向向量; 对于其他光源，是光源的位置 .z!=0
				float3 viewDir = normalize(_WorldSpaceLightPos0.xyz) ;
#else
				float3 viewDir = normalize(_WorldSpaceLightPos0.xyz - worldPos);
#endif 

				float3 halfVector = normalize(lightDir + viewDir);


				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot(lightDir, worldNormal) );

				float3 specular = _LightColor0.rgb * _Specular.rgb * pow(dot(halfVector, worldNormal) , _Gloss );

#ifdef USING_DIRECTION_LIGHT
				float attenuation = 1.0;
#else
	 
#if defined (POINT)
				// 顶点位置 从世界空间 转 光源空间  unity_WorldToLight 替换掉了 _LightMatrix0
				float3 lightCoord = mul(unity_WorldToLight, float4(worldPos, 1)).xyz;
				fixed attenuation = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#elif defined (SPOT)
				float4 lightCoord = mul(unity_WorldToLight, float4(worldPos, 1));
				fixed attenuation = (lightCoord.z > 0) *
					tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w 
					* 
					tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
#else
				// 对于非  聚光灯 点光源 ，其他光源衰减都是1.0   
				fixed attenuation = 1.0;
#endif // POINT SPOT

#endif // USING_DIRECTION_LIGHT


				return float4( (diffuse + specular) * attenuation , 1.0);
			}

			ENDCG
		}        
    }
    FallBack "Diffuse"
}
