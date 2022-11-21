# Depth Processing
![screenshot0](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot0.png)
![screenshot1](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot1.png)
![screenshot2](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot2.png)
![screenshot3](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot3.png)
![screenshot4](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot4.png)
![screenshot5](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot5.png)
![screenshot6](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot6.png)
![screenshot7](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot7.png)
![screenshot8](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Depth/screenshot8.png)
```hs
//Experimental View 4
half3 inter = rotate(input.vertex.xyz, half3(output.viewport.x * (_Debug.x * _Debug.w), output.viewport.y * (_Debug.y * _Debug.w), (_Debug.z * _Debug.w)));
half4 matmv = mul(UNITY_MATRIX_MV, half4(0.0f, 0.0f, 0.0f, 1.0f)) + half4(inter, 0.0f);
```
