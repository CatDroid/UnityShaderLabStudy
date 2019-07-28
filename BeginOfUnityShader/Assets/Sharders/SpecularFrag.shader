Shader "Custom/SpecularFrag"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (0.25,0.25,0.25,0.25)
        _Gloss ("Glossiness", Range(8,256)) = 20  // _Glossiness 是内置变量??不能使用 
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        // LOD 200

        Pass{

            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
 
           
            #pragma vertex vert
            #pragma fragment frag 

            #include "lighting.cginc"
            #include "UnityCG.cginc"

            float4 _Diffuse ;
            float4 _Specular;
            float _Gloss;

            struct appData {
                  float4 vertex : POSITION ;
                  float3 normal : NORMAL ;
            };

            struct v2f {
                float3 normalWorld : TEXCOORD0 ;
                float3 vertexWorld : TEXCOORD1 ;
                float4 postion : SV_POSITION ; 
            };

            v2f vert ( appData input )
            {
                v2f output ;
                output.postion = UnityObjectToClipPos( input.vertex );

                output.normalWorld = mul( input.normal, (float3x3)unity_WorldToObject );
                output.vertexWorld = mul( unity_ObjectToWorld, input.vertex ).xyz; // 只保留xyz  

                return output ;
            }

            float4 frag ( v2f input ) : SV_Target 
            {

                float3 lightWorld = normalize( _WorldSpaceLightPos0.xyz );
                float3 normalWorld = normalize( input.normalWorld ); // 之前在顶点着色器没有做归一化 
                float3 reflectDir = normalize( reflect( -lightWorld, normalWorld) );        // 反射向量 
                float3 viewDir =  normalize( _WorldSpaceCameraPos.xyz - input.vertexWorld); // 视线方向 


                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz ;
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max( 0, dot( lightWorld, normalWorld ) );
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow( max( 0, dot( reflectDir, viewDir) ), _Gloss);

                return float4(ambient + diffuse + specular, 1.0 ) ;  
   
            }

 
            ENDCG

        }
        
    }

    FallBack "Specular"
}
