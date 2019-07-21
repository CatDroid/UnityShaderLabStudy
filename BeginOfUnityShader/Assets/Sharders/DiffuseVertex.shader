// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DiffuseVertex"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        //LOD 100

        Pass
        {
			Tags{ "LightMode" = "ForwardBase" }  // 需要Unity传入光照属性到管线中本shader

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
           

            #include "UnityCG.cginc"
			#include "Lighting.cginc"			// 需要得到一些Unity的内置变量

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
				float3 color : COLOR;			// 顶点着色器直接就计算好 散射光+环境光 的颜色
				float4 vertex : SV_POSITION;	// 顶点着色器 输出给渲染管线 
            };

			float4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                
				o.vertex = UnityObjectToClipPos(v.vertex);

				float3 normalWorld = mul(v.normal,(float3x3)unity_WorldToObject); 
				normalWorld = normalize(normalWorld);
				// 法线变换是顶点模型变换矩阵的逆的转置 
				// 这里避免转置,所以前后调换 nw = w2o^T * n(列) =  [ n(列)^T * w2o^T^T ]^T = [n(行) * w2o]^T  由于nw nw^T n(行) n(列) 都是一样的 
				// 顶点模型变换矩阵  就是  _Object2World , 逆就是  _World2Object 

				float3 lightWorld = normalize(_WorldSpaceLightPos0.xyz); 
				
				// 需要在 tag 中指定 LightMode = ForwardBase 得到内置变量  
				// 光源的方向 《Unity Shader入门精要》FAQ http://candycat1992.github.io/unity_shaders_book/unity_shaders_book_faq.html
				
				// _WorldSpaceLightPos0 是指向光源的方向,平行光 
				// _WorldSpaceLightPos0.w可以表明该光源的类型，如果为0表示是平行光，为1表示是点光源或者聚光灯光源; if(_WorldSpaceLightPos0.w!=0){

				float diffuseResult = max(0, dot(normalWorld, lightWorld)); // saturate(dot(normalWorld, lightWorld))
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * diffuseResult;
				// _LightColor0 光源的颜色(内置)  
				// _Diffuse	材质漫反射颜色 

				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; // Unity内置变量环境光 Lighting.cginc + "LightMode" = "ForwardBase"

				o.color = ambient + diffuse;

                return o;
            }

			float4 frag (v2f i) : SV_Target
            {
                return float4( i.color, 1.0 );
            }
            ENDCG
        }
    }
}
