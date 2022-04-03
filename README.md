# Peote View - 2D Render Library (haxe/lime/opengl)

This library is to simplify opengl-usage for 2D rendering and to easy  
handle procedural shadercode and imagedata from texture-atlases.
  
It's written in [Haxe](http://haxe.org) and runs multiplatform with [Lime](https://github.com/haxelime/lime)s [GL-context](https://github.com/haxelime/lime/tree/develop/src/lime/graphics/opengl) and environment.  

## Installation:
```
haxelib git peote-view https://github.com/maitag/peote-view
```


## Features

- runs native on linux/bsd/windows/android, neko/hashlink-vm, javascript-webbrowser
  (macOS and iOS should run but not much tested yet)  
- can be compiled for a special OpenGL version (ES 2/3 - webgl 1/2) or with version-detection at runtime
  
- optimized to draw many elements thats sharing the same shader and textures
- simple usage of textureatlases (parted into slots and tiles)
- multitexture usage per shader
- supports shadertemplates and opengl-extensions
- simple formula- and glslcode-injection
- animation by gpu transition-rendering of vertexattributes
- opengl-picking for fast detection of elements that hits a point at screen
- renderToTextures (framebuffer)
- ...


## Scenegraph and Namespace

![scenegraph](doc/PeoteView.png?raw=true)

`PeoteView`
- main screenarea that contains all Displays
- zoom- and scrollable


`Display`
- rectangle area inside the View (using gl-scissoring for masking)
- contains Programs to render
- zoom- and scrollable
- content can be rendered into a texture

	  
`Element`
- rectangle graphics like Sprites
- can have position, size and many other kind of attributes to render inside displayarea
- different types of Element-classes with rquivalent shadertemplate is macro-generated by meta-data
- only properties/shaderattribures that is need will be generated (to have optimized types of Elements for any purpose)


`Buffer`
- depends on type of generated Element
- stores many Element-instances to build up an equivalent gl-vertexbuffer
- can be dynamically grow/shrink
- using fast opengl instance-drawing for all contained Elements
- can be bind to one or many Programs 


`Program`
- combines Textures and shadercode for one Buffer
- can use formulas for fragmentshader to compose Texturedata 
- can use formulas to change other attributes inside shader
- can inject GLSL-code directly into shader


`Texture`
- to store imagedata or textureatlases
- can be splitted into Slots to store many images, calculates best size for gl-texture
- Slots can be parted into Tiles


`TextureCache`
- handle multiple textures, imageloading and texture reusage






## Todo
- better Readme, more documentation and api-generation
- better texture/imagehandling and more texture-colortypes
- better blendmode handling
- z-depth via texture-channel
- normal-mapping
- uv-mapping
- multiwindows (did not work with textures yet)