package;
#if sampleTest
import haxe.Timer;

import lime.ui.Window;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;

import peote.view.PeoteGL;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Color;
//import peote.view.Texture;

import elements.ElementSimple;

class Test 
{
	var peoteView:PeoteView;
	var element = new Array<ElementSimple>();
	var buffer:Buffer<ElementSimple>;
	
	var elemNumber:Int = 0;
	
	public function new(window:Window)
	{
		try {
			
			peoteView = new PeoteView(window.context, window.width, window.height);
			
			buffer = new Buffer<ElementSimple>(4, 4, true);

			var display   = new Display(10,10, window.width-20, window.height-20, Color.GREEN);
			var program   = new Program(buffer);
			
			peoteView.addDisplay(display);
			display.addProgram(program);
			
			testTextureMemory();
		
		}
		catch (e:Dynamic) trace("ERROR:", e);
	}
	
	public function testTextureMemory() {
		var gl = peoteView.gl;
		var size = Std.int(gl.getParameter(gl.MAX_TEXTURE_SIZE)/4);
		trace("max-texture-size:", size);
		
		var glTexture = new Array<peote.view.PeoteGL.GLTexture>();
		var randomImage = createRandomImage(size, size);
		
		// did not work for webgl -> texture had to be used to use gpu-mem there
		
		for (i in 0...200) {
			
			peote.view.utils.GLTool.clearGlErrorQueue(gl);
				glTexture[i] = gl.createTexture();
			if (peote.view.utils.GLTool.getLastGlError(gl) != gl.NO_ERROR) throw("ERROR: gl.createTexture");
			
			peote.view.utils.GLTool.clearGlErrorQueue(gl);
				gl.bindTexture(gl.TEXTURE_2D, glTexture[i]);
			if (peote.view.utils.GLTool.getLastGlError(gl) != gl.NO_ERROR) throw("ERROR: gl.bindTexture");
			
			
			peote.view.utils.GLTool.clearGlErrorQueue(gl);
				gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, size, size, 0, gl.RGBA, gl.UNSIGNED_BYTE, 0);
				//gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, size, size, 0, gl.RGBA, gl.UNSIGNED_BYTE, randomImage.data);
			if (peote.view.utils.GLTool.getLastGlError(gl) != gl.NO_ERROR) throw("ERROR: gl.texImage2D");
			
			peote.view.utils.GLTool.clearGlErrorQueue(gl);
				gl.texSubImage2D(gl.TEXTURE_2D, 0, 0, 0, size, size, gl.RGBA, gl.UNSIGNED_BYTE, randomImage.data );
			if (peote.view.utils.GLTool.getLastGlError(gl) != gl.NO_ERROR) throw("ERROR: gl.texSubImage2D");
			
			gl.bindTexture(gl.TEXTURE_2D, null);
			trace(i);
		}		
	}
	// create image with random pixels
	public function createRandomImage(width:Int, height:Int):Image {
		
		var image:Image = null;
		
		trace('Create an Image ($width x $height) with random pixels for texture-data.');
		
		try {
			image = new Image(null, 0, 0, width, height, 0xff0000FF, lime.graphics.ImageType.DATA);
		}
		catch (e:Dynamic) trace("Error while creating lime.graphics.Image", e);
		
		for (x in 0...width) {
			for (y in 0...height) {
				image.setPixel32(x, y, (Std.int(Math.random() * 256) << 24) | Std.random(0x1000000) );
			}
		}
		
		return image;
		
	}
	
	public function onPreloadComplete ():Void { trace("preload complete"); }
	
	public function onMouseDown (x:Float, y:Float, button:MouseButton):Void
	{
		element[elemNumber]  = new ElementSimple(10+elemNumber*50, 10, 40, 40);
		buffer.addElement(element[elemNumber]);
		elemNumber++; trace("elements " + elemNumber);
	}

	public function onMouseMove (x:Float, y:Float):Void {}
	public function onWindowLeave ():Void {}

	public function onKeyDown (keyCode:KeyCode, modifier:KeyModifier):Void
	{
		switch (keyCode) {
			case KeyCode.NUMPAD_PLUS:
				element[elemNumber]  = new ElementSimple(10+elemNumber*50, 10, 40, 40);
				buffer.addElement(element[elemNumber]);
				elemNumber++; trace("elements " + elemNumber);
			case KeyCode.NUMPAD_MINUS:
				elemNumber--;  trace("elements " + elemNumber);
				buffer.removeElement(element[elemNumber]);
				element[elemNumber] = null;
			default:
		}
	}
	
	public function update(deltaTime:Int):Void {}
	public function onMouseUp (x:Float, y:Float, button:MouseButton):Void {}

	public function render()
	{
		peoteView.render();
	}

	public function resize(width:Int, height:Int)
	{
		peoteView.resize(width, height);
	}

}
#end