Shader "MyShader/Mirror"
{
    Properties
    {
        _MirrorTex ("Mirror Tex", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma multi_compile_fwdbase
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            sampler2D _MirrorTex;

            struct a2v {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            v2f vert(a2v v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.texcoord;
                // 镜面需要翻转X轴
                o.uv.x = 1 - o.uv.x;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                return tex2D(_MirrorTex, i.uv);
            }

            ENDCG
        }
    }
}
