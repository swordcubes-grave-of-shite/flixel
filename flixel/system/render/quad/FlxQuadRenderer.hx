package flixel.system.render.quad;

import flixel.graphics.FlxRenderTexture;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.graphics.FlxBitmap;
import flixel.FlxG;
import flixel.graphics.FlxBitmap;
import flixel.graphics.FlxTexture;
import flixel.system.render.FlxRenderer;
import lime.utils.UInt8Array;

#if FLX_OPENGL_AVAILABLE
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.graphics.opengl.GL;
#end

using flixel.util.FlxColorTransformUtil;

@:access(flixel.FlxCamera)
@:access(flixel.system.render.quad)
@:access(flixel.graphics)
class FlxQuadRenderer extends FlxTypedRenderer<FlxQuadView>
{
	public function new()
	{
		super();
		method = DRAW_TILES;

		#if FLX_OPENGL_AVAILBLE
		if (isGL)
			maxTextureSize = cast GL.getParameter(GL.MAX_TEXTURE_SIZE);
		#end
	}

	public function createCameraView(camera:FlxCamera)
	{
		return new FlxQuadView(camera);
	}

	// No-op, handle will get assigned at upload to avoid reallocating bitmaps
	function createTextureHandle():FlxTextureHandle { return null; }
	function destroyTextureHandle(handle:FlxTextureHandle):Void
	{
		#if FLX_RENDER_DRAWQUADS
		handle.destroy();
		#end
	}

	function destroyTextureBitmap(bitmap:FlxBitmap):Void
	{
		#if (FLX_RENDER_DRAWQUADS && !flash)
		// Since the bitmap is the same as the handle, we don't actually want to destroy it,
		// just get rid of the image buffer
		bitmap.disposeImage();

		// Also force the texture to get updated while we're at it
		bitmap.getTexture(FlxG.stage.context3D);
		#end
	}

	function uploadTextureBitmap(texture:FlxTexture, bitmap:FlxBitmap):Void
	{
		#if FLX_RENDER_DRAWQUADS
		texture.handle = bitmap;
		#end
	}

	function readTexturePixels(texture:FlxTexture, buffer:UInt8Array, ?rect:FlxRect):Void
	{
		#if (FLX_RENDER_DRAWQUADS && FLX_OPENGL_AVAILABLE)
		final gl = FlxG.stage.window.context.webgl;

		@:privateAccess
		final glTexture = texture.handle.getTexture(FlxG.stage.context3D).__getTexture();
		gl.bindTexture(gl.TEXTURE_2D, glTexture);

        // Create dummy framebuffer we'll read from
        var fb = gl.createFramebuffer();
        gl.bindFramebuffer(gl.FRAMEBUFFER, fb);

        // Attach texture to framebuffer and read the pixels from it into the buffer
        gl.framebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, glTexture, 0);
        final x = rect != null ? Std.int(rect.x) : 0;
        final y = rect != null ? Std.int(rect.y) : 0;
        final w = rect != null ? Std.int(rect.width) : texture.width;
        final h = rect != null ? Std.int(rect.height) : texture.height;
        gl.readPixels(x, y, w, h, gl.RGBA, gl.UNSIGNED_BYTE, buffer);

        // Delete the framebuffer
        gl.bindFramebuffer(gl.FRAMEBUFFER, null);
        gl.deleteFramebuffer(fb);

		gl.bindTexture(gl.TEXTURE_2D, null);
		#end
	}

	// No-op, handled in the FlxDrawItems
	function setTextureWrapU(texture:FlxTexture, wrap:FlxTextureWrap):Void {}
	function setTextureWrapV(texture:FlxTexture, wrap:FlxTextureWrap):Void {}
	// function setTextureFilter(texture:FlxTexture, filter:FlxTextureFilter):Void {}

	// No-op, FlxRenderTexture is not supported with this renderer
	function createRenderTargetHandle(texture:FlxRenderTexture, depthStencil:Bool):FlxRenderTargetHandle {return null;}
	function destroyRenderTargetHandle(handle:FlxRenderTargetHandle):Void {}
	function resizeRenderTarget(texture:FlxRenderTexture, width:Int, height:Int):Void {}
	function clearRenderTarget(texture:FlxRenderTexture, color:FlxColor, depth:Bool, stencil:Bool):Void {}
}