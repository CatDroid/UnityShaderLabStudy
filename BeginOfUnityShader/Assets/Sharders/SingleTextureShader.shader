Shader "Custom/SingleTextureShader"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)   // 控制物体整体的色调 
		_MainTex("Main Tex", 2D) = "white" {} // "white" 内置纹理的名字 全白纹理 花括号作为初始值 
		//_Diffuse("Diffuse" , Color) = (1,1,1,1) // 材质的漫反射系数 改成了 使用纹理的颜色
		_Specular("Specular", Color) = (1,1,1,1)
		_Gloss("Gloss", Range(8,256)) = 20
	}

	SubShader
	{
		Pass{
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			#pragma vertex vert
			#pragma fragment frag

			struct a2v {
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 texcoord: TEXCOORD0; // 使用Unity语义 TEXCOORD0 声明，Unity会将模型的第一组纹理坐标存储在该变量中
			};
		
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			//float4 _Diffuse;	// 材质的漫反射系数改成了纹理颜色
			float4 _Specular;
			float _Gloss;
			sampler2D _MainTex;  // 纹理
			float4 _MainTex_ST;  // 纹理属性(缩放S和位移T) 变量名字一定是 纹理名字_ST xy是缩放 zw是位移 

			v2f vert(a2v input)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.pos);
				o.worldNormal = mul(input.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld, input.pos).xyz;
				o.uv = input.texcoord * _MainTex_ST.xy + _MainTex_ST.zw; // 根据材质面板定义的 变换纹理坐标

				return o;
			}

			float4 frag(v2f input) :SV_Target
			{

				float3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldNormal = normalize(input.worldNormal);
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - input.worldPos);

				float3 halfVector = normalize(viewDir + _WorldSpaceLightPos0.xyz);

				float3 texColor = tex2D(_MainTex, input.uv).rgb;

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * texColor;
				float3 diffuse = _LightColor0.rgb * texColor * max(0, dot(worldNormal, worldLight));
				float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal, halfVector)), _Gloss);

				return float4(ambient + diffuse + specular, 1.0);

			}

			ENDCG
		}
	
	}

	// 1. Unity和OpenGL一样都是左下角为原点
	// 2. 纹理映射坐标 uv坐标
	// 3. Pass Tags{"LightMode"="ForwardBase"} 在Unity光照流水线的角色
	// 4. 纹理属性 名字_ST 用来缩放s和平移t
	// 5. 顶点着色器使用语义TEXCOORD0 会把模型的第一组坐标 设置到该变量
	// 6. 平铺方式wrap mode Repeat Clamp  滤波方式 Point(最邻近) Binear(双线性) Trilinear(Mimap) 
	// 7. Mipmap用于缩小 通常会增加33%内存
	FallBack "Specular"
}

