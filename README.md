<picture>
  <source media="(prefers-color-scheme: dark)" srcset="./icon_bright.png">
  <source media="(prefers-color-scheme: light)" srcset="./icon.png">
  <img alt="Palette OS" src="./icon.png" height=128>
</picture>

# *Basalt Version Alpha* #
[**Basalt**](https://github.com/Pyroxenium/Basalt) is a UI Framework of CC:Tweaked made by [*Pyroxenium*](https://github.com/Pyroxenium/), it is still an unstable framework with low update and bugfix frequencies.

**Palette OS** requires the *1.6.6* version, it is not the latest version because 1.7.* version has some **serious bugs** (for example: [the issue 106](https://github.com/Pyroxenium/Basalt/issues/106)) which forces Palette OS to choose the older version.



## Install
We **doesn't** recommend you to install this unstable version, but if you want to, here's the steps:

* Download the source code [here](https://github.com/PaperCake-Studio/Palette-OS/archive/refs/heads/basalt.zip).
* Unzip the **basalt.zip**.
* Move **startup.lua & system folder** into your **CC:T** computer.
* Restart your **CC:T** computer to check the result.

Again, we **doesn't** recommend you to install, but if you'd like to be our one of our bug testers, we'll appreciate that.

## Import APIs into your programs
We opened the api for every developers, to use it in your project or app, you need to `require` it.

```lua
require(" api path here ")
```

Here are the list of all apis and paths we have, *just choose one in the two forms of paths*:

* Basalt Framework
  * system.basalt
  * /system/basalt
* Palette Utilities
  * system.apis.utils
  * /system/apis/utils
* Base64 Operations
  * system.apis.base64
  * /system/apis/base64
* AES Operations
  * system.apis.aes
  * /system/apis/aes
* zzlib (zip utils)
  * system.apis.zzlib
  * /system/apis/zzlib
* AUKit (audio utils)
  * system.apis.aukit
  * /system/apis/aukit

Note: the first form of path is the **relative path**. For example: if you're already in the *system* folder and you want to use the *Palette Utilities*, just write **apis.utils**.

---

*Note: this Basalt version is what we're working on, the legacy version is still supported until we've eventually finished the work here.*
