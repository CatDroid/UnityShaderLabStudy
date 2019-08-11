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


/*
法线纹理两种:
1. 模型空间的法线纹理
	a.相当于顶点自带的法线，只是把表面法线都保存到一个纹理图
	b.彩色的,不同的法线方向代表不同的颜色，比如 (0,1,0)方向映射后就是(0.5,1,0.5)浅绿色; (0,-1,0)方向映射后就是(0.5,0,0.5)紫色 
	c.直观,可以不用模型原始的法线和切线信息,模型的切线一般和UV方向一样(??)
	d......
2. 切线空间的法线纹理
	a.模型的每个顶点都有自己的切线空间，原点是顶点本身，x轴是切线，z轴是法线，y轴是切线和法线的叉乘，副切线 bitangent
	b.浅蓝色，因为每个顶点的切线空间不一样，这种法线纹理存储的起始就是每个点在各自切线空间中的法线扰动方向
	c.如果一个点的法线方向不变(不被扰动),那么在其切线空间中，新法线方向就是z轴方向，没有被扰动，所以 还是(0,0,1),经过映射存在纹理图的是(0.5,0.5,1)浅蓝色
	d.纹理贴图中大片的蓝色说明了，顶点的大部分扰动法线 和 模型本身的法线是一样的，不需要改变的，实际没有被扰动
	优点：
		e.模型空间的法线记录的是绝对法线信息，只可以用在创建它时对应的模型；切线空间的法线记录的是相对法线信息，可以把这纹理应用到其他完全不同的网格也可以得到合理的结果
		f.UV动画；移动一个纹理的UV坐标，实现凹凸移动的效果，比如水流动，火山岩石等效果
		g.可压缩，只需记录x和y，z是可以通过单位向量计算出来，可压缩存储 比如 DXT5nm压缩格式
		k.可重用，一个纹理贴图可以用到一个方砖的6个平面上


切线空间的法线纹理 的光照计算:
1. 在切线空间中(优选)
2. 在世界空间中: 需要更多计算(片元着色器要取法线纹理中的扰动法线转换到世界坐标系)，但使用cubemap进行环境映射的情况下就需要这个



注意:
1. 副法线是 法叉切
2. 优选 切线空间计算  这样计算量少了：把主要计算量从fragment转移到vertex的思想是渲染优化
3. 切向空间下的扰动法线一定是正的
4. 插值寄存器一般是float4，如果有4个float3，可以把4个float3分别装载3个float4中，充分利用空间


Unity3d 4.x 内置shader使用切向空间进行法线映射和光照计算
Unity3d 5.x 内置shader使用世界空间来光照计算，使用更多插值寄存器保存变换矩阵 

*/
