# sakura_blizzard

(en)Japanese ver is [here](https://github.com/MasahideMori-SimpleAppli/sakura_blizzard/blob/main/README_JA.md).  
(ja)この解説の日本語版は[ここ](https://github.com/MasahideMori-SimpleAppli/sakura_blizzard/blob/main/README_JA.md)にあります。

## Overview
This is a 3D effect related to cherry blossom flower petals in Flutter. 
This package is created using [simple_3d_renderer](https://pub.dev/packages/simple_3d_renderer) and its related packages,
and is also a simple example of how to use simple_3d_renderer.
By default, animations of cherry blossom petals and cubes are included,
but by using ElementsFlowView, you can make any [Sp3dObj](https://pub.dev/packages/simple_3d) have a falling animation.

![Sakura](https://raw.githubusercontent.com/MasahideMori-SimpleAppli/simple_3d_images/main/SakuraBlizzard/sakura_blizzard_sakura_sample.png)

![Cube](https://raw.githubusercontent.com/MasahideMori-SimpleAppli/simple_3d_images/main/SakuraBlizzard/sakura_blizzard_cube_sample.png)

## Usage
Please check out the sample code tab.
You can also check the screen displayed when you run the sample code from the sample app below.  
The sample app uses both a front layer and a back layer, with a child widget, the TextWidget, in between.  
[Web Sample](https://sakurablizzard.web.app/)

## Support
If you need paid support for any reason, please contact my company.  
This package is developed by me personally, but may be supported via the company.  
[SimpleAppli Inc.](https://simpleappli.com/en/index_en.html)

## About version control
The C part will be changed at the time of version upgrade.  
However, versions less than 1.0.0 may change the file structure regardless of the following rules.  
- Changes such as adding variables, structure change that cause problems when reading previous files.
    - C.X.X
- Adding methods, etc.
    - X.C.X
- Minor changes and bug fixes.
    - X.X.C

## License
This software is released under the MIT License, see LICENSE file.

## Copyright notice
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.