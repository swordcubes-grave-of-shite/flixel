package flixel.graphics;

import flixel.graphics.FlxBitmap;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.Image;
import lime.graphics.ImageBuffer;
import lime.utils.UInt8Array;

/**
 * Underlying representation of the texture.
 * The actual type is dependant on the renderer, and is determined at compile time.
 */
typedef FlxTextureHandle = FlxBitmap;

/**
 * Represents a GPU texture used for rendering.
 * While it is a reference to a GPU texture at its core, `FlxTexture` also provides some helper
 * methods to allow for easier read & write operations.
 *
 * ### Reading texture pixels
 * There are two options for reading pixels from a texture:
 * 1. Use the `texture.readPixels[...]()` method to read the pixels of the texture (or a specified region) into a specific user managed buffer.
 * 2. Use the `texture.getBitmap()` method to read the entire texture into an internal `FlxBitmap`. The bitmap is managed internally by the texture.
 *    Any changes made to the provided bitmap will be applied to the texture once `texture.apply()` is called. You can also optionally destroy the
 *    internal bitmap when applying changes, to free memory.
 */
class FlxTexture implements IFlxDestroyable
{
    /**
     * The default value of the `readable` parameter in the upload methods.
     * Defaults to `true` for backwards compatibility.
     */
    public static var defaultReadable:Bool = true;

    // TODO: expose in 7.0.0 once sprite.antialiasing is removed
    /**
     * The initial value of `texture.filter`, for all textures.
     * Defaults to `NEAREST`.
     */
    // public static var defaultFilter:FlxTextureFilter = NEAREST;

    /**
     * Creates a `FlxTexture` and uploads pixel data to it from the provided `bitmap`.
     *
     * @param   bitmap     The `FlxBitmap` to upload data from.
     * @param   readable   Whether the bitmap should be kept, to allow for read/write operations.
     *                     Set this to `true` if you plan on constantly read/writing pixels, otherwise
     *                     set it to `false` for a noticable decrease in memory usage.
     * @return  The newly created `FlxTexture`.
     */
    public static function fromBitmap(bitmap:FlxBitmap, ?readable:Bool):FlxTexture
    {
        var texture:FlxTexture = new FlxTexture(bitmap.width, bitmap.height);
        texture.uploadBitmap(bitmap, readable);
        return texture;
    }

    /**
     * The underlying representation of the texture, you probably shouldn't mess with this!
     * The actual type varies depending on the used renderer backend.
     */
    public var handle(default, null):FlxTextureHandle;

    /**
     * The current status of the texture.
     */
    public var status(get, null):FlxTextureStatus;

    /**
     * The width of the texture, in pixels.
     */
    public var width(default, null):Int;

    /**
     * The height of the texture, in pixels.
     */
    public var height(default, null):Int;

    /**
     * The texture wrapping mode for the horizontal (U) axis.
     * Default value is `CLAMP`.
     *
     * @see `FlxTextureWrap`
     */
    public var wrapU(default, set):FlxTextureWrap = CLAMP;

    /**
     * The texture wrapping mode for the vertical (V) axis.
     * Default value is `CLAMP`.
     *
     * @see `FlxTextureWrap`
     */
    public var wrapV(default, set):FlxTextureWrap = CLAMP;

    // TODO: expose in 7.0.0 once sprite.antialiasing is removed
    /**
     * The texture filtering mode used when scaling the texture.
     *
     * @see `FlxTextureFilter`
     */
    // public var filter(default, set):FlxTextureFilter = defaultFilter;

    /**
     * Reference to the internal bitmap, which is used to allow read/write operations when the texture is readable.
     */
    var _bitmap:FlxBitmap;

    /**
     * Helper, used to track changes between the internal bitmap and the texture.
     */
    var _version:Int;

    /**
     * Helper to indicate whether the texture was uploaded once.
     * Used by some renderers to make subsequent uploads faster.
     */
    var _allocated:Bool = false;

    /**
     * Creates a new `FlxTexture` instance.
     * The texture is NOT ready to be used yet, make sure to upload data to it before using it.
     *
     * @param   width    The width of the texture, in pixels.
     * @param   height   The height of the texture, in pixels.
     */
    public function new(width:Int, height:Int)
    {
        this.width = width;
        this.height = height;
        status = INVALID;

        if (width <= 0 || height <= 0)
            FlxG.log.error('Invalid texture dimensions (${width}x${height})');

        final max = FlxG.renderer.maxTextureSize;
        if (max > 0)
        {
        	if (width > max || height > max)
        		FlxG.log.error('Texture dimensions (${width}x${height}) exceed the maximum allowed size (${max}x${max})');
        }

        handle = FlxG.renderer.createTextureHandle();

        // Invoke the setters to properly set up the texture state
        set_wrapU(wrapU);
        set_wrapV(wrapV);
        // set_filter(filter);
    }

    /**
     * Destroys all data related to this texture.
     */
    public function destroy():Void
    {
        if (handle != null)
        {
            FlxG.renderer.destroyTextureHandle(handle);
            handle = null;
        }

        if (_bitmap != null)
        {
            _bitmap.destroy();
            _bitmap = null;
        }

        status = INVALID;
    }

    /**
     * Uploads texture data from a `FlxBitmap`.
     * The bitmap should match the texture in size.
     *
     * @param   bitmap     The `FlxBitmap` to upload data from.
     * @param   readable   Whether the bitmap should be kept, to allow for read/write operations.
     *                     Set this to `true` if you plan on constantly read/writing pixels, otherwise
     *                     set it to `false` for a noticable decrease in memory usage.
     */
    public function uploadBitmap(bitmap:FlxBitmap, ?readable:Bool):Void
    {
        if (readable == null)
            readable = defaultReadable;

        FlxG.renderer.uploadTextureBitmap(this, bitmap);
        #if !flash
        if(bitmap.image != null)
        	_version = bitmap.image.version;
        #end

        if (!_allocated)
            _allocated = true;

        if (readable || FlxG.renderer.blit)
            _bitmap = bitmap;
        #if FLX_RENDER_DRAWQUADS
        else if (!readable)
        {
            handle.disposeImage();
        }
        #end
    }

    /**
     * Reads the texture pixels into a `UInt8Array` buffer.
     * The read pixels will be in `RGBA` format.
     *
     * @param   rect     Optional, the region of the texture to read from. If left
     *                   unspecified, the entire texture is read.
     * @param   buffer   Optional, the buffer to read into. If left unspecified,
     *                   a new buffer with the size of `width * height * 4` is created.
     * @return  A `UInt8Array` buffer containing the pixels.
     */
    public function readPixels(?rect:FlxRect, ?buffer:UInt8Array):UInt8Array
    {
        final width:Int = rect == null ? this.width : Std.int(rect.width);
        final height:Int = rect == null ? this.height : Std.int(rect.height);

        if (buffer == null)
            buffer = new UInt8Array(width * height * 4);

        FlxG.renderer.readTexturePixels(this, buffer, rect);
        return buffer;
    }

    /**
     * Returns a `FlxBitmap` instance associated with this texture.
     *
     * `FlxBitmap` provides methods to read and manipulate the pixel data of the image.
     * After you're done editing the bitmap, you must call `texture.apply()` in order to apply the changes
     * and update the hardware texture.
     *
     * If the texture's status is `HARDWARE`, the pixel data will be downloaded from the GPU.
     * This can be a very slow operation, so it's recommended to not do it often.
     *
     * **NOTE:** This function is not thread-safe, and should only be called on the main thread!
     *
     * @return   A `FlxBitmap` containing the pixel data of this texture.
     */
    public function getBitmap():FlxBitmap
    {
        if (_bitmap == null)
        {
            final pixels = readPixels();

            #if (FLX_RENDER_DRAWQUADS && !flash)
            if (FlxG.renderer.tile)
            {
                var image = new Image(new ImageBuffer(pixels, width, height, 32, RGBA32));
                @:privateAccess image.version = _version;
                @:privateAccess handle.__fromImage(image);

                _bitmap = handle;
            }
            else
            #end
            {
                _bitmap = FlxBitmap.fromBytes(pixels.toBytes());
                #if !flash
                _bitmap.image.version = _version;
                #end
            }
        }

        return _bitmap;
    }

    /**
     * Applies the changes made to this texture's bitmap and updates the texture.
     *
     * **NOTE:** This function is not thread-safe, and should only be called on the main thread!
     *
     * @param   destroyBitmap   Whether the internal bitmap should be destroyed. Set this to `true`
     *                          if you don't plan on read/writing pixels afterwards, for a noticable decrease in memory usage.
     *                          You can always get a reference to the bitmap back via `texture.getBitmap()`.
     */
    public function apply(destroyBitmap:Bool = false)
    {
        if (_bitmap != null)
        {
            uploadBitmap(_bitmap);

            if (destroyBitmap && !FlxG.renderer.blit)
            {
                FlxG.renderer.destroyTextureBitmap(_bitmap);
                _bitmap = null;
            }
        }
    }

    /**
	 * `FlxBitmap` synced the bitmap and texture automatically while `FlxTexture` requires you to manually apply your changes.
     * This is called by draw methods to avoid a breaking change between the two, and should be removed in the next major version.
     */
    @:allow(flixel.system.render)
    @:noCompletion function applyIfNeeded():Void
    {
        switch (status)
        {
            case READABLE(synced):
                if (!synced)
                {
                    FlxG.log.warn("Automatic texture-bitmap syncing is deprecated and will be removed in the next major version. Use texture.apply() to apply changes made to the texture's bitmap.");
                    apply(false);
                }

            default:
        }
    }

    function get_status():FlxTextureStatus
    {
        if (handle == null && _bitmap == null)
            status = INVALID;
        else if (_bitmap == null)
            status = HARDWARE;
        #if !flash
        else if (_bitmap.image != null && _bitmap.image.version > _version)
            status = READABLE(false);
        #end
        else
            status = READABLE(true);

        return status;
    }

    function set_wrapU(value:FlxTextureWrap):FlxTextureWrap
    {
        if (wrapU != value)
        {
            FlxG.renderer.setTextureWrapU(this, value);
            wrapU = value;
        }
        return value;
    }

    function set_wrapV(value:FlxTextureWrap):FlxTextureWrap
    {
        if (wrapV != value)
        {
            FlxG.renderer.setTextureWrapV(this, value);
            wrapV = value;
        }
        return value;
    }

    // TODO: expose in 7.0.0 once sprite.antialiasing is removed
    // function set_filter(value:FlxTextureFilter):FlxTextureFilter
    // {
    //     if (filter != value)
    //     {
    //         FlxG.renderer.setTextureFilter(this, value);
    //         filter = value;
    //     }
    //     return value;
    // }
}

/**
 * An enum representing the current status of the texture.
 */
enum FlxTextureStatus
{
    /**
     * The texture has no data.
     */
    INVALID;

    /**
     * The texture exists in RAM and can be read and edited.
     *
     * @param   synced     Whether the texture and its bitmap are synced (have the same pixel data).
     */
    READABLE(synced:Bool);

    /**
     * The texture only exists in VRAM.
     *
     * It can't be read from, or edited, without calling `texture.getBitmap()` first
     * to download the pixel data back from the GPU.
     */
    HARDWARE;
}

/**
 * An enum representing the wrapping mode of the texture.
 * In other words, determines how the texture should be sampled when accessing texture coordinates
 * outside of the normalized bounds (0...1).
 */
enum FlxTextureWrap
{
    /**
     * Clamps the texture to the last pixel at the edge.
     */
    CLAMP;

    /**
     * Repeats (tiles) the texture.
     */
    REPEAT;

    // MIRRORED_REPEAT;
}

// TODO: expose in 7.0.0 once sprite.antialiasing is removed
/**
 * The texture filtering mode used when scaling the texture.
 */
// enum FlxTextureFilter
// {
//     /**
//      * Picks the pixel closest to the current texture coordinate. Produces a sharp, pixelated look.
//      */
//     NEAREST;

//     /**
//      * Interpolates between the neighbouring pixels at the current texture coordinate. Produces a blurry, smooth (antialiased) look.
//      */
//     LINEAR;
// }