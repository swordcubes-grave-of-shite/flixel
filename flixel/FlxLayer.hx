package flixel;

import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.geom.ColorTransform;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;

import flixel.math.FlxMatrix;
import flixel.system.FlxAssets.FlxShader;

using flixel.util.FlxColorTransformUtil;

@:access(flixel.FlxCamera)
class FlxLayer extends FlxBasic
{
	var _cachedDraws:Array<PendingDraw> = [
		{camera: null, matrix: null}
	];
	var _pendingDraw:Int = 0;

	public function new()
	{
		super();
		FlxG.signals.preDraw.add(clearDrawStack);
	}

	override function destroy():Void
	{
		FlxG.signals.preDraw.remove(clearDrawStack);
		super.destroy();
	}

	function clearDrawStack():Void
	{
		_pendingDraw = 0;
	}

	public function drawPixels(camera:FlxCamera, ?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
			?shader:FlxShader):Void
	{
		if (!cameras.contains(camera))
		{
			FlxG.log.warn('Camera ${camera} is not added to the layer, drawing normally');
			camera.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
			return;
		}
		final pendingDraw:PendingDraw = _cachedDraws[_pendingDraw++];
		pendingDraw.camera = camera;
		pendingDraw.matrix = matrix;
		pendingDraw.frame = frame;
		pendingDraw.pixels = pixels;
		pendingDraw.transform = transform;
		pendingDraw.blend = blend;
		pendingDraw.smoothing = smoothing;
		pendingDraw.shader = shader;

		// if next cached draw is null, create one
		if(_cachedDraws[_pendingDraw] == null)
			_cachedDraws[_pendingDraw] = {camera: null, matrix: null};
	}

	override function draw():Void
	{
		for(i in 0..._pendingDraw)
		{
			final drawData:PendingDraw = _cachedDraws[i];
			drawData.camera.drawPixels(drawData.frame, drawData.pixels, drawData.matrix, drawData.transform, drawData.blend, drawData.smoothing, drawData.shader);
		}
	}
}

@:structInit
class PendingDraw {
	public var camera:FlxCamera;
	public var matrix:FlxMatrix;

	@:optional
	public var frame:FlxFrame;

	@:optional
	public var pixels:BitmapData;

	@:optional
	public var transform:ColorTransform;

	@:optional
	public var blend:BlendMode;

	@:optional
	public var smoothing:Bool = false;

	@:optional
	public var shader:FlxShader;
}