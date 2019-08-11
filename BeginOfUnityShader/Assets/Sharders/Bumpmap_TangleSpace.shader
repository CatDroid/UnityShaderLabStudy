Shader "Custom/Bumpmap_TangleSpace"
{
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1) 
		_MainTex("Main Tex", 2D) = "white" {}  
		_BumpMapTex("Normal Bump Tex",2D) = "bump" {}	// 用于凹凸映射的法线纹理 bump内置法线纹理 没有提供的话 bump对应模型自带的法线信息
		_BumpScale("Bump Scale",Float) = 1.0			// 控制凹凸程度
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

			float4 _Color;		// 控制材质漫反射系数的大小 = 色调控制*纹理图颜色 
			sampler2D _MainTex;	// 纹理
			float4 _MainTex_ST;	// 纹理属性(缩放S和位移T) 变量名字一定是 纹理名字_ST xy是缩放 zw是位移 
			sampler2D _BumpMapTex;	// 凹凸法线纹理
			float4 _BumpMapTex_ST;	// 纹理属性(缩放S和位移T)
			float _BumpScale;		// 控制凹凸程度
			float4 _Specular;
			float _Gloss;

			struct a2v {
				float4 vertex:		POSITION;	//  顶点的位置坐标
				float3 normal:		NORMAL;		//	法线
				float4 tangent:		TANGENT;	//	切线 TANGENT语义 Unity会把顶点切线方向填充到tangent变量 类型一定是float4, tangent.w决定切向空间副切线的方向
				float4 texcoord:	TEXCOORD0;	//	纹理坐标
			};

			struct v2f {
				float4 pos:			SV_POSITION;
				float4 uv :			TEXCOORD0;	// 纹理坐标xy + 凹凸纹理坐标zw
				float3 lightDir:	TEXCOORD1;
				float3 viewDir :	TEXCOORD2;
			};


			// Unity3d 里面  点击摄像机 显示的是 摄像机的模型空间坐标轴 而不是 摄像机的观察空间 (z轴相反的!!)
			// Unity3d 如果把一个图片作为法线纹理图 就会去掉b通道，通过r和b通道计算 r = r*2-1 g=g*2-1 b=sqrt( max( 1-r*r-g*g, 0) )  b=(b+1)/2
			v2f vert(a2v input)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(input.vertex);
				 
				o.uv.xy = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = input.texcoord.xy * _BumpMapTex_ST.xy + _BumpMapTex_ST.zw; // 使用同样的纹理坐标 


				float3 worldPos = mul(unity_ObjectToWorld, input.vertex).xyz;


				float3 biTangent = cross(
					normalize(input.normal), 
					normalize(input.tangent.xyz)
					) * input.tangent.w; 
				// ??? 为什么一定是 法叉切 normal 叉乘 tangent
				// ??? 不能直接按照右手螺旋,而是乘以.w,来确定副法方向

				// 模型空间到切线空间 只是做位移和旋转  所以 逆矩阵 等于 转置矩阵 
				// float3x3(float3,float3,float3)按行存储
				// https://developer.download.nvidia.cn/cg/Cg_language.html
				// This operator builds a matrix from multiple rows(行)
				//		float3x3(1, 2, 3, 4, 5, 6, 7, 8, 9)
				//		float3x3(float3, float3, float3)
				float3x3 transpose_model2obj = float3x3(
					normalize(input.tangent.xyz), 
					normalize(biTangent), 
					normalize(input.normal));

				float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
				o.lightDir = mul( transpose_model2obj, mul((float3x3)unity_WorldToObject,worldLightDir) );
				o.viewDir = mul( transpose_model2obj, mul((float3x3)unity_WorldToObject,worldViewDir) );

				//float3 objLightPos  = mul((float3x3)unity_WorldToObject, _WorldSpaceLightPos0.xyz );
				//float3 objCameraPos = mul((float3x3)unity_WorldToObject, _WorldSpaceCameraPos.xyz);
				//o.lightDir = mul(transpose_model2obj, objLightPos) ;
				//o.viewDir = mul(transpose_model2obj, objCameraPos - input.vertex.xyz ) ;
				return o;
			}

			float4 frag(v2f input) :SV_Target
			{
				float3 bump;
				bump.xy = tex2D(_BumpMapTex, input.uv.zw).xy ; // 0~1 
				bump.xy = bump.xy * 2.0 - 1.0;	// tangentNormal = UnpackNormal(packedNormal);
				bump.xy *= _BumpScale;			// _BumpScale = 0 那么z=1 就是0,0,1 跟模型法线一致
				bump.z = 1.0 - sqrt( max(0.0 , dot(bump.xy, bump.xy))); // z = sqrt(1- (x^2+y^2))

				// 如果Unity把纹理图设置为法线纹理图(NormalMap)，而不是普通纹理图(Default)
				// UnpackNormal
				//		那么可以通过 UnpackNormal 把rgb(0~1)转换成xyz(-1~1),但不会计算BumpScale,
				//		如果支持DXT5NM,会从x,y计算出z的,否则法线纹理图rgb存放的就是法线xyz
				// UNITY_NO_DXT5nm 
				//		is set when compiling shader for platform that do not support DXT5NM, 
				//		meaning that normal maps will be encoded in RGB instead.

				float3 texColor = tex2D(_MainTex, input.uv.xy).rgb * _Color.rgb;
				
				float3 lightDir = normalize(input.lightDir);
				float3 viewDir = normalize(input.viewDir);

				float3 halfVector = normalize(viewDir + lightDir);

				// 镜面光没有使用纹理贴图的颜色，但是漫反射和环境光都使用纹理贴图颜色
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * texColor;
				float3 diffuse = _LightColor0.rgb * texColor * max(0, dot(bump, lightDir));
				float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(bump, halfVector)), _Gloss);


				return float4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}

	}

	FallBack "Specular"
}