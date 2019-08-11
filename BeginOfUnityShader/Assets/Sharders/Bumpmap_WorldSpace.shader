Shader "Custom/Bumpmap_WorldSpace"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Color Texture", 2D) = "white" {}
		_BumpMapTex("Bump Normal Texture", 2D) = "bump" {}
		_BumpScale("Bump Scale",Float) = 1.0
		_Specular("Specular", Color) = (1,1,1,1)
        _Gloss  ("Gloss", Range(8,256)) = 20
    
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

#include "UnityCG.cginc"
#include "Lighting.cginc"

#pragma vertex vert
#pragma fragment frag 

			float4		_Color ;
			sampler2D	_MainTex;
			float4		_MainTex_ST ;
			sampler2D	_BumpMapTex;
			float4		_BumpMapTex_ST ;
			float		_BumpScale;
			float4		_Specular;  // 材质的高光/镜面反射系数  材质的漫反射系数或者环境光系数 从纹理贴图中获取
			float		_Gloss;


			struct a2v {
				float4 position : POSITION;
				float3 normal   : NORMAL;
				float4 tangent  : TANGENT;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 position : SV_POSITION;
				float4 texuvst  : TEXCOORD0;
				float3 objectSpaceTangent    : TEXCOORD1;
				float3 objectSpaceBiTangent  : TEXCOORD2;
				float3 objectSpaceNormal	 : TEXCOORD3;
				float3 posWorld : TEXCOORD4;
			};


			v2f vert(a2v input)
			{
				v2f o;
				o.position = UnityObjectToClipPos(input.position);

				o.posWorld = mul(unity_ObjectToWorld,input.position).xyz;

				o.texuvst.xy = input.texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
				o.texuvst.zw = input.texcoord * _BumpMapTex_ST.xy + _BumpMapTex_ST.zw;

				float3 biTangent	 = cross(input.normal, input.tangent.xyz) * input.tangent.w;  // 法x切=副切
				o.objectSpaceTangent	 = input.tangent.xyz ;
				o.objectSpaceBiTangent	 = biTangent ;
				o.objectSpaceNormal		 = input.normal;

				return o;

			}

			float4 frag(v2f input):SV_Target
			{

				float3 normalTangentSpace = tex2D(_BumpMapTex, input.texuvst.zw);
				normalTangentSpace.xy = normalTangentSpace.xy * 2.0 - 1.0;
				normalTangentSpace.xy = normalTangentSpace.xy * _BumpScale; // _BumpScale之后 会导致法线纹理中的法线不是单位向量
				normalTangentSpace.z = sqrt( 1.0 - saturate(dot(normalTangentSpace.xy, normalTangentSpace.xy))  );
				// saturate =  opengl clamp(x,0.0,1.0) 

				float3x3 TangentToObject = 
					float3x3(
						normalize(input.objectSpaceTangent),
						normalize(input.objectSpaceBiTangent),
						normalize(input.objectSpaceNormal) );
				
				// transpose( reverse( TangentToObject ) )  TangentToObject 是正交矩阵 逆的转置 就是原来 
				float3 normalObjectSpace = mul(normalTangentSpace, TangentToObject);

				// UnityWorldToObject 是 ObjectToWorld的逆矩阵, 再转置, 即使法向量的模型到世界的变换矩阵 
				float3 normalWorldSpace = mul(normalObjectSpace, (float3x3)unity_WorldToObject);

				 
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 viewDir   = normalize(_WorldSpaceCameraPos.xyz - input.posWorld );

				float3 texColor = tex2D(_MainTex, input.texuvst.xy);

				float3 halfVector = normalize(viewDir + lightDir);

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * texColor ;
				float3 diffuse = _LightColor0.rgb * texColor * max(0, dot( lightDir, normalWorldSpace) );
				float3 specular = _LightColor0.rgb * _Specular.rgb * pow( max(0, dot(halfVector, normalWorldSpace)), _Gloss);

				return float4(ambient + diffuse + specular, 1.0);

			}
			ENDCG
		}
    }
    FallBack "Specular"

}
