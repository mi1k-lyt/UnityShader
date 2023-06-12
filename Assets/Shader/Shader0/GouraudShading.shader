// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/GouraudShading"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Tags {"LightMode" = "ForwardBase"}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR;
            };

            v2f vert(a2v v) {
                v2f o;

                // 将顶点从模型空间通过MVP变换到裁剪空间
                o.pos = UnityObjectToClipPos(v.vertex);

                // 获得环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 将法线从模型空间变换到世界空间
                fixed3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));
                // 获得世界空间下的顶点
                fixed3 worldVertex = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 获得世界空间下的光照方向
                fixed3 worldLight = normalize(UnityWorldSpaceLightDir(worldVertex));
                // 计算漫反射项
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));
                // 获得世界空间下的反射方向
                fixed3 reflectDir = normalize(reflect(-worldLight, worldNormal));
                // 获得世界空间下的观察方向
                fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldVertex);
                // 计算高光反射项
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);

                o.color = ambient + diffuse + specular;

                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                return fixed4(i.color, 1.0);
            };

            ENDCG
        }
    }

    Fallback "Specular"
}
