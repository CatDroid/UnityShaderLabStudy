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
			//"RenderType" = "Transparent" "Opaque"
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

				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz); // directional light
				float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);


				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate( dot(lightDir, worldNormal) );

				float3 halfVector = normalize(viewDir + lightDir);
				float3 specular= _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfVector, worldNormal)), _Gloss);

				return float4 (ambient + diffuse + specular  , 1.0 );
			}


			ENDCG 
		}


		/*Pass  
		{
			Tags
			{
				"LightMode" = "ForwardAdd"
			}

			CGPROGRAM

			ENDCG
		}*/

        
    }
    FallBack "Diffuse"
}
