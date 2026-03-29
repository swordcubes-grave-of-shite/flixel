package flixel.graphics;

import haxe.io.Bytes;
import lime.utils.UInt8Array;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

/**
 * A FlxBitmap provides methods to read and manipulate the pixel data of the image.
 * Currently an abstract over `BitmapData`; in the next major version it will be changed to a seperate class.
 */
@:forward
@:forwardStatics
abstract FlxBitmap(BitmapData) from BitmapData to BitmapData
{
    public static inline function fromBytes(bytes:Bytes):FlxBitmap
    {
        return BitmapData.fromBytes(bytes);
    }

    /**
     * The pixel data of this bitmap, as a `UInt8Array`.
     */
    public var data(get, set):UInt8Array;
    inline function get_data():UInt8Array
        return this.image.data;
    inline function set_data(value:UInt8Array):UInt8Array
        return this.image.data = value;

    public function new(width:Int, height:Int, ?fillColor:FlxColor = FlxColor.WHITE)
    {
        this = new BitmapData(width, height, true, fillColor);
    }

    public inline function destroy():Void
    {
        this.dispose();
    }
}