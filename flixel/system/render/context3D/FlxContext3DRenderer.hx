package flixel.system.render.context3D;

#if FLX_RENDER_CONTEXT3D
import lime.utils.UInt8Array;
import flixel.FlxG;

import flixel.math.FlxRect;
import flixel.util.FlxColor;

import flixel.graphics.FlxBitmap;
import flixel.graphics.FlxTexture;
import flixel.graphics.FlxRenderTexture;

import flixel.system.render.FlxRenderer;

#if FLX_OPENGL_AVAILABLE
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.graphics.opengl.GL;
#end

using flixel.util.FlxColorTransformUtil;

class FlxContext3DRenderer extends FlxTypedRenderer<FlxContext3DView> {
	public function new()
	{
		super();
		method = CONTEXT3D;

		#if FLX_OPENGL_AVAILBLE
		if (isGL)
			maxTextureSize = cast GL.getParameter(GL.MAX_TEXTURE_SIZE);
		#end
	}

	public function createCameraView(camera:FlxCamera)
	{
		return new FlxContext3DView(camera);
	}

	// =============================================================================
	//{region                             TEXTURES
	// =============================================================================

	// life cycle
	function createTextureHandle():FlxTextureHandle {
		return null;
	}

	function destroyTextureHandle(handle:FlxTextureHandle):Void {}

	function destroyTextureBitmap(bitmap:FlxBitmap):Void {}

	// upload
	function uploadTextureBitmap(texture:FlxTexture, bitmap:FlxBitmap):Void {}

	// download
	function readTexturePixels(texture:FlxTexture, buffer:UInt8Array, ?rect:FlxRect):Void {}

	// properties
	function setTextureWrapU(texture:FlxTexture, wrap:FlxTextureWrap):Void {}

	function setTextureWrapV(texture:FlxTexture, wrap:FlxTextureWrap):Void {}

	// TODO: expose in 7.0.0 once sprite.antialiasing is removed
	// function setTextureFilter(texture:FlxTexture, filter:FlxTextureFilter):Void {}

	function createRenderTargetHandle(texture:FlxRenderTexture, depthStencil:Bool):FlxRenderTargetHandle {
		return null;
	}

	function destroyRenderTargetHandle(handle:FlxRenderTargetHandle):Void {}

	function resizeRenderTarget(texture:FlxRenderTexture, width:Int, height:Int):Void {}

	function clearRenderTarget(texture:FlxRenderTexture, color:FlxColor, depth:Bool, stencil:Bool):Void {}

	// =============================================================================
	//}endregion                           TEXTURES
	// =============================================================================
}
#end