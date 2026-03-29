package flixel.graphics;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxImageFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxBitmap;

/**
 * `FlxBitmap` wrapper which is used for rendering.
 * It stores info about all frames, generated for specific `FlxBitmap` object.
 */
class FlxGraphic implements IFlxDestroyable
{
	/**
	 * The default value for the `persist` variable at creation if none is specified in the constructor.
	 * @see [FlxGraphic.persist](https://api.haxeflixel.com/flixel/graphics/FlxGraphic.html#persist)
	 */
	public static var defaultPersist:Bool = false;

	/**
	 * Creates and caches FlxGraphic object from openfl.Assets key string.
	 *
	 * @param   Source   `openfl.Assets` key string. For example: `"assets/image.png"`.
	 * @param   Unique   Ensures that the `FlxBitmap` uses a new slot in the cache.
	 *                   If `true`, then `FlxBitmap` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  Cached `FlxGraphic` object we just created.
	 */
	public static function fromAssetKey(Source:String, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var bitmap:FlxBitmap = null;

		if (!Cache)
		{
			bitmap = FlxG.assets.getBitmapData(Source);
			if (bitmap == null)
				return null;
			return createGraphic(bitmap, Key, Unique, Cache);
		}

		var key:String = FlxG.bitmap.generateKey(Source, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		bitmap = FlxG.assets.getBitmapData(Source);
		if (bitmap == null)
			return null;

		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsKey = Source;
		return graphic;
	}

	/**
	 * Creates and caches `FlxGraphic` object from a specified `Class<FlxBitmap>`.
	 *
	 * @param   Source   `Class<FlxBitmap>` to create `FlxBitmap` for `FlxGraphic` from.
	 * @param   Unique   Ensures that the `FlxBitmap` uses a new slot in the cache.
	 *                   If `true`, then `FlxBitmap` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  `FlxGraphic` object we just created.
	 */
	public static function fromClass(Source:Class<FlxBitmap>, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var bitmap:FlxBitmap = null;
		if (!Cache)
		{
			bitmap = FlxAssets.getBitmapFromClass(Source);
			return createGraphic(bitmap, Key, Unique, Cache);
		}

		var key:String = FlxG.bitmap.getKeyForClass(Source);
		key = FlxG.bitmap.generateKey(key, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		bitmap = FlxAssets.getBitmapFromClass(Source);
		graphic = createGraphic(bitmap, key, Unique);
		graphic.assetsClass = Source;
		return graphic;
	}

	/**
	 * Creates and caches `FlxGraphic` object from specified `FlxBitmap` object.
	 *
	 * @param   Source   `FlxBitmap` for `FlxGraphic` to use.
	 * @param   Unique   Ensures that the `FlxBitmap` uses a new slot in the cache.
	 *                   If `true`, then `FlxBitmap` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  `FlxGraphic` object we just created.
	 */
	public static function fromBitmapData(Source:FlxBitmap, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		if (!Cache)
			return createGraphic(Source, Key, Unique, Cache);

		var key:String = FlxG.bitmap.findKeyForBitmap(Source);

		var assetKey:String = null;
		var assetClass:Class<FlxBitmap> = null;
		var graphic:FlxGraphic = null;
		if (key != null)
		{
			graphic = FlxG.bitmap.get(key);
			assetKey = graphic.assetsKey;
			assetClass = graphic.assetsClass;
		}

		key = FlxG.bitmap.generateKey(key, Key, Unique);
		graphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		graphic = createGraphic(Source, key, Unique);
		graphic.assetsKey = assetKey;
		graphic.assetsClass = assetClass;
		return graphic;
	}

	/**
	 * Creates and (optionally) caches a `FlxGraphic` object from the specified `FlxFrame`.
	 * It uses frame's `FlxBitmap`, not the `frame.parent.bitmap`.
	 *
	 * @param   Source   `FlxFrame` to get the `FlxBitmap` from.
	 * @param   Unique   Ensures that the bitmap data uses a new slot in the cache.
	 *                   If `true`, then `FlxBitmap` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @param   Cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  `FlxGraphic` object we just created.
	 */
	public static function fromFrame(Source:FlxFrame, Unique:Bool = false, ?Key:String, Cache:Bool = true):FlxGraphic
	{
		var key:String = Source.name;
		if (key == null)
			key = Source.frame.toString();
		key = Source.parent.key + ":" + key;
		key = FlxG.bitmap.generateKey(key, Key, Unique);
		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		var bitmap:FlxBitmap = Source.paint();
		graphic = createGraphic(bitmap, key, Unique, Cache);
		var image:FlxImageFrame = FlxImageFrame.fromGraphic(graphic);
		image.getByIndex(0).name = Source.name;
		return graphic;
	}

	/**
	 * Creates and caches a FlxGraphic object from the specified `FlxFramesCollection`.
	 * It uses `frames.parent.bitmap` as a source for the `FlxGraphic`'s `FlxBitmap`.
	 * It also copies all the frames collections onto the newly created `FlxGraphic`.
	 *
	 * @param   Source   `FlxFramesCollection` to get the `FlxBitmap` from.
	 * @param   Unique   Ensures that the `FlxBitmap` uses a new slot in the cache.
	 *                   If `true`, then `FlxBitmap` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @return  Cached `FlxGraphic` object we just created.
	 */
	public static inline function fromFrames(Source:FlxFramesCollection, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		return fromGraphic(Source.parent, Unique, Key);
	}

	/**
	 * Creates and caches a `FlxGraphic` object from the specified `FlxGraphic` object.
	 * It copies all the frame collections onto the newly created `FlxGraphic`.
	 *
	 * @param   Source   `FlxGraphic` to get the `FlxBitmap` from.
	 * @param   Unique   Ensures that the `FlxBitmap` uses a new slot in the cache.
	 *                   If `true`, then `FlxBitmap` for this `FlxGraphic` will be cloned, which means extra memory.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @return  Cached `FlxGraphic` object we just created.
	 */
	public static function fromGraphic(Source:FlxGraphic, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		if (!Unique)
			return Source;

		var key:String = FlxG.bitmap.generateKey(Source.key, Key, Unique);
		var graphic:FlxGraphic = createGraphic(Source.texture.getBitmap(), key, Unique);
		graphic.unique = Unique;
		graphic.assetsClass = Source.assetsClass;
		graphic.assetsKey = Source.assetsKey;
		return FlxG.bitmap.addGraphic(graphic);
	}

	/**
	 * Generates and caches new `FlxGraphic` object with a colored rectangle.
	 *
	 * @param   Width    How wide the rectangle should be.
	 * @param   Height   How high the rectangle should be.
	 * @param   Color    What color the rectangle should have (`0xAARRGGBB`).
	 * @param   Unique   Ensures that the `FlxBitmap` uses a new slot in the cache.
	 * @param   Key      Force the cache to use a specific key to index the bitmap.
	 * @return  The `FlxGraphic` object we just created.
	 */
	public static function fromRectangle(Width:Int, Height:Int, Color:FlxColor, Unique:Bool = false, ?Key:String):FlxGraphic
	{
		var systemKey:String = Width + "x" + Height + ":" + Color;
		var key:String = FlxG.bitmap.generateKey(systemKey, Key, Unique);

		var graphic:FlxGraphic = FlxG.bitmap.get(key);
		if (graphic != null)
			return graphic;

		var bitmap = new FlxBitmap(Width, Height, Color);
		return createGraphic(bitmap, key);
	}

	/**
	 * Helper method for cloning specified `FlxBitmap` if necessary.
	 *
	 * @param   Bitmap   `FlxBitmap` to process
	 * @param   Unique   Whether we need to clone specified `FlxBitmap` object or not
	 * @return  Processed `FlxBitmap`
	 */
	static inline function getBitmap(Bitmap:FlxBitmap, Unique:Bool = false):FlxBitmap
	{
		return Unique ? Bitmap.clone() : Bitmap;
	}

	/**
	 * Creates and caches the specified `FlxBitmap` object.
	 *
	 * @param   bitmap   `FlxBitmap` to use as a graphic source for the new `FlxGraphic`.
	 * @param   key      Key to use as a cache key for the created `FlxGraphic`.
	 * @param   unique   Whether the new `FlxGraphic` object uses a unique `FlxBitmap` or not.
	 *                   If `true`, the specified `FlxBitmap` will be cloned.
	 * @param   cache    Whether to use graphic caching or not. Default value is `true`, which means automatic caching.
	 * @return  Created `FlxGraphic` object.
	 */
	static function createGraphic(bitmap:FlxBitmap, key:String, unique:Bool = false, cache:Bool = true):FlxGraphic
	{
		bitmap = FlxGraphic.getBitmap(bitmap, unique);
		var texture = FlxTexture.fromBitmap(bitmap);
		var graphic:FlxGraphic = null;

		if (cache)
		{
			graphic = new FlxGraphic(key, texture);
			graphic.unique = unique;
			FlxG.bitmap.addGraphic(graphic);
		}
		else
		{
			graphic = new FlxGraphic(null, texture);
		}

		return graphic;
	}

	/**
	 * Key used in the `BitmapFrontEnd` cache.
	 */
	public var key(default, null):String;

	/**
	 * The cached `FlxBitmap` object.
	 */
	@:deprecated("graphic.bitmap is deprecated, use graphic.texture.getBitmap() instead.")
	public var bitmap(get, set):FlxBitmap;

	/**
	 * The cached `FlxTexture` object.
	 */
	public var texture(default, set):FlxTexture;

	/**
	 * Width of the cached `FlxBitmap`.
	 */
	public var width(default, null):Int = 0;

	/**
	 * Height of the cached `FlxBitmap`.
	 */
	public var height(default, null):Int = 0;

	/**
	 * Asset name from `openfl.Assets`.
	 */
	public var assetsKey(default, null):String;

	/**
	 * Class name for the `FlxBitmap`.
	 */
	public var assetsClass(default, null):Class<FlxBitmap>;

	/**
	 * Whether this graphic object should stay in the cache after state changes or not.
	 * `destroyOnNoUse` has no effect when this is set to `true`.
	 */
	public var persist:Bool = false;

	/**
	 * Whether this `FlxGraphic` should be destroyed when `useCount` becomes zero (defaults to `true`).
	 * Has no effect when `persist` is `true`.
	 */
	public var destroyOnNoUse(default, set):Bool = true;

	/**
	 * Whether the `FlxBitmap` of this graphic object has been loaded or not.
	 */
	public var isLoaded(get, never):Bool;

	/**
	 * Whether `destroy` was called on this graphic
	 * @since 5.6.0
	 */
	public var isDestroyed(get, never):Bool;

	/**
	 * Whether the `FlxBitmap` of this graphic object can be refreshed.
	 * This is only the case for graphics with an `assetsKey` or `assetsClass`.
	 */
	public var canBeRefreshed(get, never):Bool;

	@:deprecated("`canBeDumped` is deprecated, use `canBeRefreshed`")
	public var canBeDumped(get, never):Bool;

	/**
	 * GLSL shader for this graphic. Only used if utilizing sprites do not define a shader
	 * Avoid changing it frequently as this is a costly operation.
	 */
	public var shader(default, null):FlxShader;

	/**
	 * Usage counter for this `FlxGraphic` object.
	 */
	public var useCount(default, null):Int = 0;

	/**
	 * `FlxImageFrame` object for the whole bitmap.
	 */
	public var imageFrame(get, null):FlxImageFrame;

	/**
	 * Atlas frames for this graphic.
	 * You should fill it yourself with one of `FlxAtlasFrames`'s static methods
	 * (like `fromTexturePackerJson()`, `fromTexturePackerXml()`, etc).
	 */
	public var atlasFrames(get, never):FlxAtlasFrames;

	/**
	 * Storage for all available frame collection of all types for this graphic object.
	 */
	var frameCollections:Map<FlxFrameCollectionType, Array<Dynamic>>;

	/**
	 * All types of frames collection which had been added to this graphic object.
	 * It helps to avoid map iteration, which produces a lot of garbage.
	 */
	var frameCollectionTypes:Array<FlxFrameCollectionType>;

	/**
	 * Shows whether this object unique in cache or not.
	 *
	 * Whether undumped `FlxBitmap` should be cloned or not.
	 * It is `false` by default, since it significantly increases memory consumption.
	 */
	public var unique:Bool = false;

	#if FLX_TRACK_GRAPHICS
	/**
	 * **Debug only**
	 * Any info about the creation or intended usage of this graphic, for debugging purposes
	 * @since 5.9.0
	 */
	public var trackingInfo:String = "";
	#end

	/**
	 * Internal var holding `FlxImageFrame` for the whole bitmap of this graphic.
	 * Use public `imageFrame` var to access/generate it.
	 */
	@:deprecated("_imageFrame is deprecated, use imageFrame")
	var _imageFrame(get, set):FlxImageFrame;
	inline function get__imageFrame() return imageFrame;
	inline function set__imageFrame(value:FlxImageFrame) return imageFrame = value;

	@:deprecated('_useCount is deprecated, use incrementUseCount and decrementUseCount')
	var _useCount(get, set):Int;
	inline function get__useCount() return useCount;
	inline function set__useCount(value:Int) return useCount = value;

	@:deprecated('_destroyOnNoUse is deprecated, use destroyOnNoUse')
	var _destroyOnNoUse(get, set):Bool;
	inline function get__destroyOnNoUse() return destroyOnNoUse;
	inline function set__destroyOnNoUse(value:Bool) return destroyOnNoUse = value;
	/**
	 * `FlxGraphic` constructor
	 *
	 * @param   key       Key string for this graphic object, with which you can get it from bitmap cache.
	 * @param   texture   `FlxTexture` for this graphic object.
	 * @param   persist   Whether or not this graphic stay in the cache after resetting it.
	 *                    Default value is `false`, which means that this graphic will be destroyed at the cache reset.
	 */
	function new(key:String, texture:FlxTexture, ?persist:Bool)
	{
		this.key = key;
		this.persist = (persist != null) ? persist : defaultPersist;

		frameCollections = new Map<FlxFrameCollectionType, Array<Dynamic>>();
		frameCollectionTypes = new Array<FlxFrameCollectionType>();
		this.texture = texture;

		@:privateAccess texture._graphic = this;

		shader = new FlxShader();
	}

	/**
	 * Refreshes the `FlxBitmap` of this graphic.
	 */
	@:haxe.warning("-WDeprecated")
	public function refresh():Void
	{
		var newBitmap:FlxBitmap = getBitmapFromSystem();
		if (newBitmap != null)
			bitmap = newBitmap;
	}

	@:deprecated("`undump` is deprecated, use `refresh`")
	public function undump():Void
	{
		refresh();
	}

	/**
	 * Asset reload callback for this graphic object.
	 * It regenerates its bitmap data.
	 */
	public function onAssetsReload():Void
	{
		if (!canBeRefreshed)
			return;

		refresh();
	}

	/**
	 * Trying to free the memory as much as possible
	 */
	public function destroy():Void
	{
		texture = FlxDestroyUtil.destroy(texture);

		shader = null;

		assetsClass = null;
		imageFrame = FlxDestroyUtil.destroy(imageFrame);

		if (frameCollections == null) // no need to destroy frame collections if it's already null
			return;

		var collections:Array<FlxFramesCollection>;
		for (collectionType in frameCollectionTypes)
		{
			collections = cast frameCollections.get(collectionType);
			FlxDestroyUtil.destroyArray(collections);
		}

		frameCollections = null;
		frameCollectionTypes = null;
	}

	/**
	 * Stores specified `FlxFrame` collection in internal map (this helps reduce object creation).
	 *
	 * @param   collection   frame collection to store.
	 */
	public function addFrameCollection(collection:FlxFramesCollection):Void
	{
		if (collection.type != null)
		{
			final collections = getFramesCollections(collection.type);
			if (collections.contains(collection))
				FlxG.log.warn('Attempting to add already added collection');
			else
				collections.push(collection);
		}
	}

	/**
	 * Searches frame collections of specified type for this `FlxGraphic` object.
	 *
	 * @param   type   The type of frames collections to search for.
	 * @return  Array of available frames collections of specified type for this object.
	 */
	public inline function getFramesCollections(type:FlxFrameCollectionType):Array<Dynamic>
	{
		if (this.isDestroyed)
		{
			FlxG.log.warn('Invalid call to getFramesCollections on a destroyed graphic');
			return [];
		}

		var collections:Array<Dynamic> = frameCollections.get(type);
		if (collections == null)
		{
			collections = new Array<FlxFramesCollection>();
			frameCollections.set(type, collections);
		}
		return collections;
	}

	/**
	 * Creates empty frame for this graphic with specified size.
	 * This method could be useful for tile frames, in case when you'll need empty tile.
	 *
	 * @param   size   dimensions of the frame to add.
	 * @return  Empty frame with specified size which belongs to this `FlxGraphic` object.
	 */
	public inline function getEmptyFrame(size:FlxPoint):FlxFrame
	{
		var frame = new FlxFrame(this);
		frame.type = FlxFrameType.EMPTY;
		frame.frame = FlxRect.get();
		frame.sourceSize.copyFrom(size);
		return frame;
	}

	/**
	 * Gets the `FlxBitmap` for this graphic object from OpenFL.
	 * This method is used for refreshing bitmaps.
	 */
	function getBitmapFromSystem():FlxBitmap
	{
		var newBitmap:FlxBitmap = null;
		if (assetsClass != null)
			newBitmap = FlxAssets.getBitmapFromClass(assetsClass);
		else if (assetsKey != null)
			newBitmap = FlxG.assets.getBitmapData(assetsKey);

		if (newBitmap != null)
			return FlxGraphic.getBitmap(newBitmap, unique);

		return null;
	}

	inline function get_isLoaded()
	{
		final bitmap = texture.getBitmap();
		return bitmap != null && !bitmap.rect.isEmpty();
	}

	inline function get_isDestroyed()
	{
		return shader == null;
	}

	inline function get_canBeRefreshed():Bool
	{
		return assetsClass != null || assetsKey != null;
	}

	inline function get_canBeDumped():Bool
	{
		return canBeRefreshed;
	}

	public function incrementUseCount()
	{
		useCount++;
	}

	public function decrementUseCount()
	{
		useCount--;

		checkUseCount();
	}

	function checkUseCount()
	{
		if (useCount <= 0 && destroyOnNoUse && !persist)
			FlxG.bitmap.remove(this);
	}

	function set_destroyOnNoUse(value:Bool):Bool
	{
		this.destroyOnNoUse = value;

		checkUseCount();

		return value;
	}

	function get_imageFrame():FlxImageFrame
	{
		if (imageFrame == null)
			imageFrame = FlxImageFrame.fromRectangle(this);

		return imageFrame;
	}

	function get_atlasFrames():FlxAtlasFrames
	{
		return FlxAtlasFrames.findFrame(this, null);
	}

	inline function get_bitmap():FlxBitmap
	{
		return texture.getBitmap();
	}

	function set_bitmap(value:FlxBitmap):FlxBitmap
	{
		if (value != null)
			texture = FlxTexture.fromBitmap(value);

		return value;
	}

	function set_texture(value:FlxTexture):FlxTexture
	{
		if (value != null)
		{
			texture = value;
			width = value.width;
			height = value.height;
		}

		return value;
	}
}