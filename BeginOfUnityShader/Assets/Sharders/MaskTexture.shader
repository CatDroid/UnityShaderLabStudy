Shader "Custom/MaskTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)			// 调整 漫反射和环境光反射 整体颜色
		_MainTex("Color Texture",2D) = "white" {}	// 用于漫反射和环境光反射,物体表面的漫反射系数

		_BumpTex("Bump Texture",2D) = "bump" {}		// 切线空间的法线纹理
		_BumpScale("Bump Scaler",Float) = 1.0		

		_MaskTex("Mask Texture",2D) = "while" {}	// 遮罩纹理
		_MaskScale("Mask Scaler",Float) = 1.0 

		_Specular("Specular",Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(0,256)) = 20
       
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


			float4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;

			sampler2D _MaskTex;
			float4 _MaskTex_ST;
			float _MaskScale;

			float4 _Specular;
			float _Gloss;


			struct a2v {
				float4 vertex : POSITION ;
				float3 normal : NORMAL;
				float4 tangent: TANGENT;
				float2 texcoord:TEXCOORD0;

			};

			struct v2f {
				float4 pos : SV_POSITION;

				float4 tex0 : TEXCOORD0;
				float4 tex1 : TEXCOORD1;
			 
				float3 viewDirTangentSpace : TEXCOORD2;
				float3 lightDirTangentSpace: TEXCOORD3;

			};

			v2f vert(a2v input)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(input.vertex);

				// 纹理坐标的平铺系数和偏移系数 
				//float2 main_uv = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				//float2 bump_uv = input.texcoord.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;
				//float2 mask_uv = input.texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				o.tex0.xyz = input.texcoord.x * float3(_MainTex_ST.x, _BumpTex_ST.x, _MaskTex_ST.x) + float3(_MainTex_ST.z, _BumpTex_ST.z, _MaskTex_ST.z);
				o.tex1.xyz = input.texcoord.y * float3(_MainTex_ST.y, _BumpTex_ST.y, _MaskTex_ST.y) + float3(_MainTex_ST.w, _BumpTex_ST.w, _MaskTex_ST.w);
				
				// 如果不设置这个 会警告 Ouput value 'vert' in not complete initilzed
				o.tex0.w = 0.0;
				o.tex1.w = 0.0;


				float3 biTangentNormal = cross(input.normal.xyz, input.tangent.xyz) * input.tangent.w;

				float3x3 objectToTangentSpace = {
					normalize(input.tangent.xyz),
					normalize(biTangentNormal),
					normalize(input.normal)
				};

				float3 posWorld = mul(unity_ObjectToWorld, input.vertex).xyz;
				float3 lightDirWorld = _WorldSpaceLightPos0.xyz;
				float3 viewDirWorld = _WorldSpaceCameraPos.xyz - posWorld;

				float3 lightDirObject = mul(unity_WorldToObject, lightDirWorld);
				float3 viewDirObject = mul(unity_WorldToObject, viewDirWorld);
			
				o.lightDirTangentSpace = mul(objectToTangentSpace, lightDirObject);
				o.viewDirTangentSpace = mul(objectToTangentSpace, viewDirObject);

				return o; 
			}

			float4 frag(v2f input):SV_Target
			{

				float2 main_uv = float2(input.tex0.x, input.tex1.x);
				float2 bump_uv = float2(input.tex0.y, input.tex1.y);
				float2 mask_uv = float2(input.tex0.z, input.tex1.z);

				float3 lightDirTangentSpace = normalize(input.lightDirTangentSpace);
				float3 viewDirTangentSpace = normalize(input.viewDirTangentSpace);
				float3 halfDirTangentSpace = normalize(lightDirTangentSpace+viewDirTangentSpace);


				float3 bump = tex2D(_BumpTex, bump_uv).rgb;
				bump.xy = bump.xy * 2.0 - 1.0;
				bump.xy = bump.xy * _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

				//bump = float3(0.0, 0.0, 1.0); // 这样就没有凹凸效果

				float3 albedo = tex2D(_MainTex, main_uv).rgb * _Color.rgb;

				float specularMaskControl = tex2D(_MaskTex, mask_uv).r * _MaskScale;

			
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
				float3 diffuse = _LightColor0.xyz * albedo *  saturate(dot(lightDirTangentSpace, bump));

				// 只是在之前的基础上 加上遮罩纹理对这个像素的高光反射强度的控制 
				float3 specular = _LightColor0.xyz * _Specular.rgb * pow(saturate(dot(halfDirTangentSpace, bump)), _Gloss) * specularMaskControl;
 
				return float4(ambient + diffuse + specular, 1.0);
			}

			ENDCG

		}

      
    }
    FallBack "Specular"
}

/*



遮罩纹理:

1.如果希望逐个像素来控制物体的表面属性，让美术人员更加精准(像素级别)地控制模型表面的各种性质

2.遮罩纹理的4个通道,可以存放不同的表面属性,比如dato2中,每个模型使用了4个纹理:
	a. 定义模型的颜色
	b. 定义表面法线 ?? 凹凸映射纹理
	c. 两个遮罩纹理 提供了共8种格外的表面属性
	这样使得人物材质自由度更高,可以支持更多高级的模型属性

3.遮罩允许我们可以保护某些区域，使其免于修改; 
	比如之前高光反射都是应用到整个模型的，也就是所有的像素都使用同样的高光强度和高光指数，但希望做得更细腻，是某些区域强些某些弱些
	比如制作地形材质时候需要混合多张图片，比如草地,石头，裸土等几个纹理图，可使用遮罩纹理定义如何混合这些纹理



TGA图片格式:

	TGA是由美国Truevision公司为其显示卡开发的一种图像文件格式，已被国际上的图形、图像工业所接受。 
	
	现已成为数字化图像，以及运用光线跟踪算法所产生的高质量图像的常用格式。 

	TGA文件的扩展名为.tga，该格式支持压缩，使用不失真的压缩算法，可以带通道图，另外还支持行程编码压缩。


*/
