Shader "Custom/Specular"
{
    Properties
    {
        //_Ambient ("Ambient", Color) = (1,1,1,1)     // 所有物体都使用的环境光
        _Diffuse ("Diffuse", Color) = (1,1,1,1)     // 物体表面的漫反射系数  Cdiffuse = (Clight * Mdiffuse) max (0, n * l)
        _Specular ("Specular", Color) = (0.25,0.25,0.25,0.25)   // 物体表面的镜面系数    Cspecular= (Clight * Mspecular) max (0, r * l)^(Mgloss) 
        _Glossiness ("Glossiness", Range(8.0,256.0)) = 20.0 // 物体表面的光泽度/反光度 Mgloss 控制高光区域的亮点 Mgloss越大亮点越小  
    }
    SubShader
    {
        //Tags { "RenderType"="Opaque" }
        //LOD 200

        Pass {

            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            #pragma vertex vert  // 编译指示
            #pragma fragment frag 


            // float4 _Ambient ;
            float4 _Diffuse ;
            float4 _Specular;
            float _Glossiness;

            struct appData {
                float4 vertex : POSITION ; 
                float3 normal : NORMAL ;
            };

            struct v2f {
                float4 pos  : SV_POSITION ; 
                float3 color: COLOR ; 
            };


            v2f vert(appData input )
            {
                v2f output ;

                output.pos = UnityObjectToClipPos( input.vertex );

                
                float3 directionLight = normalize( _WorldSpaceLightPos0.xyz );
                float3 worldNormal = normalize( mul( input.normal, (float3x3)unity_WorldToObject) );
                float3 reflectDir = normalize( reflect( -directionLight, worldNormal ) ); // 光照方向是指向光源 而reflect是入射光指向物体表面点 反射光是从表面点指向外
                float3 viewDir = normalize( _WorldSpaceCameraPos.xyz - mul( (float3x3)unity_ObjectToWorld, input.vertex ) ); // 视线向量 

                //float3 ambient = _Ambient ;
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max( 0, dot( worldNormal, directionLight ) ) ;
                float3 specular =  _LightColor0.rgb * _Specular.rgb * pow( max( 0, dot( viewDir, reflectDir ) ), _Glossiness);


                output.color = ambient + diffuse + specular ;

                return output ;
            } 
            // 高光反射部分是个非线性计算 在顶点着色器中计算光照再插值的过程是线性的 破坏了源计算的非线性  高光部分不平滑


            float4 frag(v2f input): SV_Target 
            {
                return float4( input.color, 1.0 );
            }


            ENDCG
        }
       
    }
    FallBack "Specular" // 回调Shader设置为内部的Specular 
}
