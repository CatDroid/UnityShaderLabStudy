// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/SimpleShader"
{
	Properties{
		_Color("Color Base", Color) = (0.5, 0.5, 0.5, 0.5)
	} // 注意 材质面板会默认设置为1.0,1.0,1.0,1.0 而不是按这里的值

		SubShader{
			Pass {
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag

		float4 _Color;

		struct a2v {
			float4 myVertex: POSITION;
			float3 myNormal: NORMAL;
			float4 myTexCoord: TEXCOORD0;
			float3 myTangent: TANGENT;
		};

		struct v2f {
			float4 myPos: POSITION;
			float3 myColor : COLOR0;
		};

		v2f vert(a2v v) { // : SV_POSITION 
			v2f o;
			o.myPos = UnityObjectToClipPos(v.myVertex); // mul(UNITY_MATRIX_MVP,*) 
			//o.myColor = v.myNormal * 0.5 + float3(0.5, 0.5, 0.5);
			o.myColor = v.myNormal * 0.5 + _Color ;
			
			return o;
		}

		float4 frag(v2f i) : SV_Target {
			return float4(i.myColor, 1.0);
		}

		ENDCG
	}
	}
}
