package peote.text;

#if !macro
@:genericBuild(peote.text.FontProgram.FontProgramMacro.build())
class FontProgram<T> {}
#else

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.TypeTools;

class FontProgramMacro
{
	public static var cache = new Map<String, Bool>();
	
	static public function build()
	{	
		switch (Context.getLocalType()) {
			case TInst(_, [t]):
				switch (t) {
					case TInst(n, []):
						var g = n.get();
						var superName:String = null;
						var superModule:String = null;
						var s = g;
						while (s.superClass != null) {
							s = s.superClass.t.get(); //trace("->" + s.name);
							superName = s.name;
							superModule = s.module;
						}
						var missInterface = true;
						if (s.interfaces != null) for (i in s.interfaces) if (i.t.get().module == "peote.view.Element") missInterface = false;
						if (missInterface) throw Context.error('Error: Type parameter for FontProgram need to be generated by implementing "peote.view.Element"', Context.currentPos());
						
						return buildClass("FontProgram",  g.pack, g.module, g.name, superModule, superName, TypeTools.toComplexType(t) );
					case t: Context.error("Class expected", Context.currentPos());
				}
			case t: Context.error("Class expected", Context.currentPos());
		}
		return null;
	}
	
	static public function buildClass(className:String, elementPack:Array<String>, elementModule:String, elementName:String, superModule:String, superName:String, elementType:ComplexType):ComplexType
	{		
		className += "_" + elementName;
		var classPackage = Context.getLocalClass().get().pack;
		
		if (!cache.exists(className))
		{
			cache[className] = true;
			
			var elemField:Array<String>;
			if (superName == null) elemField = elementModule.split(".").concat([elementName]);
			else elemField = superModule.split(".").concat([superName]);
			
			#if peoteview_debug_macro
			trace('generating Class: '+classPackage.concat([className]).join('.'));	
			
			trace("ClassName:"+className);           // FontProgram_ElementSimple
			trace("classPackage:" + classPackage);   // [peote,view]	
			
			trace("ElementPackage:" + elementPack);  // [elements]
			trace("ElementModule:" + elementModule); // elements.ElementSimple
			trace("ElementName:" + elementName);     // ElementSimple
			
			trace("ElementType:" + elementType);     // TPath({ name => ElementSimple, pack => [elements], params => [] })
			trace("ElemField:" + elemField);
			
			#end
			
			var c = macro		
// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------

class $className extends peote.view.Program
{
	public var font:Gl3Font;
	public var style:peote.text.GlyphStyle;
	
	var _buffer:peote.view.Buffer<$elementType>;
		
	public function new(font:Gl3Font, glyphStyle:peote.text.GlyphStyle)
	{
		_buffer = new peote.view.Buffer<$elementType>(100);		
		super(_buffer);
		
		style = glyphStyle;
		if (style.width == null) {
			// todo use default from Font
			style.width = 16.0;
		}
		if (style.height == null) {
			// todo use default from Font
			style.height = 16.0;
		}
		
		
		this.font = font;
		
		// inject global fontsize and color into shader
		$p{elemField}.setGlobalStyle(this, style);
		
	}
	
	public function add(glyph:$elementType):Void {
		_buffer.addElement(glyph);
	}
	public function remove(glyph:$elementType):Void {
		_buffer.removeElement(glyph);
	}
	
	
}


// -------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------			
			//Context.defineModule(classPackage.concat([className]).join('.'),[c],Context.getLocalImports());
			Context.defineModule(classPackage.concat([className]).join('.'),[c]);
			//Context.defineType(c);
		}
		return TPath({ pack:classPackage, name:className, params:[] });
	}
}
#end