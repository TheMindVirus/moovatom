# Collision Shader

![screenshot](/IntelUnityShaderLabSDK_Tests/MiscDarkRoomShaders/Collision/collision.png)

This is what a Compute Shader for Mesh Colliders might look like. \
Could also be called Mesh Shader, might collide with Hull Shaders, \
Useful beside Geometry Shaders, one step closer to Physics Shaders. \
It could also be written as an actual Compute Shader, but this would \
potentially decrease its performance.

The C# Script has been formed directly out of having written the same \
methods as a traditional Vertex/Fragment Shader (without Geometry step). \

This will only run in games that allow C# scripts (likely not Tabletop Simulator). \
The same is required for actual GPU Compute Shaders to even start operations. \
Mesh Colliders are used by the part of the Physics Engines in games that are \
responsible for picking and placing objects as well as deciding their trajectory.
