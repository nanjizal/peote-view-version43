package peote.view;

import peote.view.PeoteGL.GLTexture;
import peote.view.PeoteGL.Image;


class Texture 
{
	public var gl(default, null):PeoteGL = null;
	
	public var colorChannels(default, null):Int=4;
	
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var slots(default, null):Int = 1;

	public var createMipmaps:Bool = false;
	public var magFilter:Int = 0;
	public var minFilter:Int = 0;

	public function new(width:Int, height:Int, slots:Int=1, colorChannels:Int=4, createMipmaps:Bool=false, magFilter:Int=0, minFilter:Int=0)
	{
		this.width = width;
		this.height = height;
		this.slots = slots;
		this.createMipmaps = createMipmaps;
		this.magFilter = magFilter;
		this.minFilter = minFilter;
		this.colorChannels = colorChannels;
	}
	
	public static inline function createEmptyTexture(gl:PeoteGL, width:Int, height:Int, colorChannels:Int=4, slots:Int=1, createMipmaps:Bool=false, magFilter:Int=0, minFilter:Int=0):GLTexture
	{
		var glTexture:GLTexture = gl.createTexture();
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		
		gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, null);
		// sometimes 32 float is essential for multipass-rendering (needs extension EXT_color_buffer_float)
		// gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA32F, width, height, 0, gl.RGBA, gl.FLOAT, null);
		
		
		// TODO: outsource into other function ?
		// magnification filter (only this values are usual):
		switch (magFilter) {
			default:gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST); //bilinear
			case 1: gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);  //trilinear
		}
		
		// minification filter:
		if (createMipmaps)
		{
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.NICEST);
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.FASTEST);
			switch (minFilter) {
				default:gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_NEAREST); //bilinear
				case 1: gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);  //trilinear
				case 2:	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_NEAREST);
				case 3:	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST_MIPMAP_LINEAR);				
			}
		}
		else
		{
			switch (minFilter) {
				default:gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				case 1:	gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);
			}
		}
		
		// firefox needs this texture wrapping for gl.texSubImage2D if imagesize is non power of 2 
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
		gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);

		if (createMipmaps) gl.generateMipmap(gl.TEXTURE_2D);
		
		gl.bindTexture(gl.TEXTURE_2D, null);
		return glTexture;
	}

	public function addImage(image:Image, ?slot:Int) {
		// put image into a Map: key:image, value:slot
		// create texture if is not already
		// copy if gl is there
		// put slot-parameters into a vector where slot is the index and value: {isCopyed, width, height, isRotated}
	}
	
	private inline function imageDataToTexture(gl:PeoteGL, glTexture:PeoteGL.GLTexture, x:Int, y:Int, w:Int, h:Int, data:PeoteGL.DataPointer, createMipmaps:Bool = false):Void
	{
		gl.bindTexture(gl.TEXTURE_2D, glTexture);
		gl.texSubImage2D(gl.TEXTURE_2D, 0, x, y, w, h, gl.RGBA, gl.UNSIGNED_BYTE,  data );
		
		if (createMipmaps) { // re-create for full texture ?
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.NICEST);
			//GL.hint(GL.GENERATE_MIPMAP_HINT, GL.FASTEST);
			gl.generateMipmap(gl.TEXTURE_2D);
		}
		gl.bindTexture(gl.TEXTURE_2D, null);
	}
	
	public inline function optimalTextureSize(slots:Int, slotWidth:Int, slotHeight:Int, ?maxTextureSize:Int):Dynamic
    {
		//if (maxTextureSize == null) maxTextureSize = GL.getParameter(GL.MAX_TEXTURE_SIZE);
        maxTextureSize = Math.ceil( Math.log(maxTextureSize) / Math.log(2) );
        //trace('maxTextureSize: ${1<<maxTextureSize}');
        //trace('Texture-slots:${slots}');
        //trace('slot width : ${slotWidth}');
        //trace('slot height: ${slotHeight}');
        
        var a:Int = Math.ceil( Math.log(slots * slotWidth * slotHeight ) / Math.log(2) );  //trace(a);
        var r:Int; // unused area -> minimize!
        var w:Int = 1;
        var h:Int = a-1;
        var delta:Int = Math.floor(Math.abs(w - h));
        var rmin:Int = (1 << maxTextureSize) * (1 << maxTextureSize);
        var found:Bool = false;
        var n:Int = Math.floor(Math.min( maxTextureSize, a ));
		var m:Int;
        
        while ((1 << n) >= slotWidth)
        {
 	        m = Math.floor(Math.min( maxTextureSize, a - n + 1 ));
            while ((1 << m) >= slotHeight)
            {	//trace('  $n,$m - ${1<<n} w ${1<<m}');  
                if (Math.floor((1 << n) / slotWidth) * Math.floor((1 << m) / slotHeight) < slots) break;
                r = ( (1 << n) * (1 << m) ) - (slots * slotWidth * slotHeight);    //trace('$r');   
				if (r < 0) break;
                if (r <= rmin)
                {
                    if (r == rmin)
                    {
                        if (Math.abs(n - m) < delta)
                        {
                            delta = Math.floor(Math.abs(n - m));
                            w = n; h = m;
                            found = true;
                        }
                    }
                    else
                    {
                        w = n; h = m;
                        rmin = r;
                        found = true;
                    } 
                    //trace('$r  -  $n,$m - ${1<<n} w ${1<<m}');
                }
                m--;
            }
            n--;
        }
    	
		var param:Dynamic = {};
        if (found)
        {	//trace('optimal:$w,$h - ${1<<w} x ${1<<h}');
            param.sx = Math.floor((1 << w) / slotWidth);
            param.sy = Math.floor((1 << h) / slotHeight);
			param.slots = param.sx * param.sy;
			param.w = 1 << w;
			param.h = 1 << h;
            trace('${param.sx * param.sy} Slots (${param.sx} * ${param.sy}) on ${1<<w} x ${1<<h} Texture'); 
        }
        else
		{
			param = null;
			throw("Error: texture size can not be calculated");			
		}
		return(param);
		
    }

}