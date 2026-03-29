package flixel.system.render.context3D;

import lime.graphics.opengl.GL;

import openfl.display.Sprite;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.ColorTransform;

import flixel.util.FlxColor;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.FlxRenderTexture;
import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxBitmap;

import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;

import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.context3D.FlxDrawData;
import flixel.system.render.quad.FlxDrawTrianglesItem.DrawData;

@:access(flixel.FlxCamera)
class FlxContext3DView extends FlxCameraView
{
	var dummySprite:Sprite = new Sprite();

	public function new(camera:FlxCamera)
    {
        super(camera);

        dummySprite.visible = false;
        camera.flashSprite = dummySprite;
    }

    override function destroy():Void
    {
        super.destroy();
    }

    // =============================================================================
	//{ region                            RENDERING
	// =============================================================================

	override function clear():Void {
		// TODO: implement
	}

	override function render():Void {
		// TODO: implement
	}

	override function fill(color:FlxColor, blendAlpha:Bool = true):Void {
		// TODO: implement
	}

	override function drawPixels(pixels:FlxBitmap, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		// TODO: implement
	}

	override function copyPixels(pixels:FlxBitmap, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
		smoothing:Bool = false, ?shader:FlxShader)
	{
		// TODO: implement
	}

	override function drawFrame(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false, ?shader:FlxShader)
	{
		// TODO: implement
	}

	override function copyFrame(frame:FlxFrame, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		// TODO: implement
	}

	override function drawTriangles(graphic:FlxGraphic, vertices:FlxVector2d<Float>, indices:FlxVector2d<Int>, uvtData:FlxVector2d<Float>, ?colors:FlxVector2d<Int>,
		?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader)
	{
		// TODO: implement
	}

    // =============================================================================
	//} endregion                          RENDERING
	// =============================================================================

    public function offsetView(x:Float, y:Float):Void {}

    function updateScale():Void {}

    function updatePosition():Void {}

    function updateInternals():Void {}

    function updateOffset():Void {}

    function updateScrollRect():Void {}

    // =============================================================================
	//{ region                             DEBUG DRAW
	// =============================================================================

	public function beginDrawDebug():Void {}

	public function endDrawDebug():Void {}

	#if FLX_DEBUG
	public function getDebugBuffer():FlxCanvas
	{
		return debugLayer.graphics;
	}

	static final toDebugHelper = new openfl.geom.Point();
	function worldToDebugX(worldX:Float)//TODO: rename?
	{
		toDebugHelper.setTo(worldX, 0);
		return canvas.localToGlobal(toDebugHelper).x;
	}

	function worldToDebugY(worldY:Float)//TODO: rename?
	{
		toDebugHelper.setTo(worldY, 0);
		return canvas.localToGlobal(toDebugHelper).y;
	}
	#end

	// =============================================================================
	//} endregion                          DEBUG DRAW
	// =============================================================================

    function get_display():DisplayObjectContainer
    {
        return dummySprite;
    }
}