<br>
<p align="center">
    <a href="https://github.com/Melioli/HoyoToon"><img src="https://hoyotoon.com/images/HoyoToonBannerLite.png" alt="HoyoToon"/></a>
</p><br>

<p align="center">
    <a href="https://github.com/Melioli/HoyoToon/blob/main/LICENSE"><img alt="GitHub license" src="https://img.shields.io/badge/License-GPL--3.0-702963?style=for-the-badge"></a><br>
    <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/Melioli/HoyoToon?style=for-the-badge"
"></a>
    <img alt="Discord" src="https://img.shields.io/discord/1129811149416824934?style=for-the-badge"
"></a>
    <img alt="GitHub issues" src="https://img.shields.io/github/issues/Melioli/HoyoToon?style=for-the-badge"
"></a>
</p>


---

## Wiki
> [!WARNING]
> Please remember to read the [Wiki](https://github.com/Melioli/HoyoToon/wiki) for the approriate information about how to use the shader and the accompanying scripts. 


## Unity Prerequisites 
> [!IMPORTANT]
> The Built-in Rendering Pipeline in Unity projects uses the Gamma option for color management by default, which is **different** from what Hoyoverse uses. To ensure that colors are accurate, it is recommended to **set the Color Space to Linear** in the Project Settings. **Edit > Project Settings > Player > Other Settings > Color Space** You can find more information on how to do this in the [Unity documentation.](https://docs.unity3d.com/Manual/LinearRendering-LinearOrGammaWorkflow.html#:~:text=To%20do%20this%2C%20set%20Color,in%20the%20gamma%20color%20space.
)
> These shaders are designed to work with the datamined models only. MMD or other sources may not work properly with these shaders. However, we do not condone datamining and encourage users to respect the intellectual property.



## Texture Prerequisites
> [!IMPORTANT]
> For best results, ensure that your texture import settings match the table below:
The *sRGB* property should be turned on for diffuse textures, shadow ramps, and specular ramps, but turned off for all other textures. Additionally, the *Wrap Mode* property should be set to *Clamp* for shadow ramps, weapon pattern, and scan pattern textures, but set to *Repeat* for normal maps and the MaterialIDValuesLUT texture. Finally, the *Compression* property should be turned off for all textures except for light maps, stockings, and the MaterialIDValuesLUT texture, which should have no compression.

| Texture | sRGB | Non-Power of 2 Scaling | Generate Mip Maps | Wrap Mode | Compression |
| :-----: | :--: | :--------------------: | :---------------: | :-------: | :---------: |
| Diffuse |  On  |       Leave as is      |        Off        |  Repeat   |     Off     |
| Light Maps | Off |       Leave as is      |        Off        |  Repeat   |     Off     | 
| Stockings | Off |       Leave as is      |        Off        |  Repeat   |     Off     | 
| Shadow Ramps | On |     Leave as is      |        Off        |   Clamp   |     Off     | 
| Specular Ramps | Off |  Leave as is      |        Off        |   Clamp   |     Off     | 
| Normal Maps | Off |     Leave as is      |        Off        |  Repeat   |     Off     | 
| Metal Maps | On |     Leave as is      |        Off        |  Repeat   |     Off     |
| MaterialIDValuesLUT | Off | None |        Off        |  Repeat   |     Off     | 
| Weapon Pattern <br>(**Eff_WeaponsTotem_Grain_00.png**)</br> | Off | Leave as is | Off | Repeat | Off |
| Weapon Dissolve <br>(**Eff_WeaponsTotem_Dissolve_00.png**)</br> | Off | Leave as is | Off | Clamp | Off |
| Scan Pattern <br>(**Eff_Gradient_Repeat_01.png**)</br> | Off | Leave as is | Off | Repeat | Off |


## Custom Tangents
If you're working with Genshin Impact models, you may need to generate custom tangents for your models to work properly with HoyoToon. To make this process easier, we have included built-in scripts that you can access through the HoyoToon option at the top of the screen or by right-clicking on an FBX or a game object that contains a mesh.

Using these scripts will generate a new mesh in a folder named `Tangent Mesh`, which will automatically be assigned to the model in the scene for you. This will ensure that your models work properly with HoyoToon and look their best.

## Materials / Jsons
We understand that copying over the settings from the in-game models to the HoyoToon materials can be a tedious and time-consuming task. To make this process easier, we have created custom tools that can automatically generate materials for you.

All you need to do is right-click on a JSON file and select either the **Generate HSR Materials** or **Generate GI Materials** option under the HoyoToon tab. This will automatically generate the materials you need to use HoyoToon with your models, saving you time and effort.

## Contact
- [Discord server](https://discord.gg/meliverse)
- [Meliodas's Twitter](https://twitter.com/Meliodas7DL)
- [Manashiku's Twitter](https://twitter.com/Manashiku)

## Issues
- If you encounter any issues while using HoyoToon, please don't hesitate to reach out to us. You can contact us directly on Discord, or you can [create an issue](https://github.com/Melioli/HoyoToon/issues/new/choose) on our GitHub repository. We are always happy to help and will do our best to resolve any problems you may have.

## Rules
- The [GPL-3.0 License](https://github.com/Melioli/HoyoToon/blob/main/LICENSE) applies.
- If you decide to use this shader in its original form for VRChat avatars, renders, animations, or any other medium that does not involve modifying the shader, please give credit to the original creator.
- If you use this shader as a basis for creating your own shader, please be sure to give credit to the us.
- In compliance with the license, you are free to redistribute the files as long as you attach a link to the source repository.

## Contributing
We welcome contributions to the HoyoToon project! If you notice any issues or have ideas for new features, please feel free to create a pull request. We appreciate any help we can get, and we will do our best to review and merge your contributions as soon as possible.

## Special thanks
All of this wouldn't be possible if it weren't for:
- [Meliodas](https://github.com/Melioli)
- [Manashiku](https://github.com/Manashiku)
- [Chips](https://github.com/Elysia-simp)
- [Razmoth](https://github.com/Razmoth)

