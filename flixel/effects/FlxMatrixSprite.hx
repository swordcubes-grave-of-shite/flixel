package flixel.effects;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;

/**
 * A sprite that uses a `renderMatrix` to transform its rendering
 * @since 6.2.0
 */
class FlxMatrixSprite extends FlxSprite
{
	/**
	 * The matrix used to transform how this sprite is rendered
	 *
	 * @since 6.2.0
	 */
	public final renderMatrix:FlxMatrix;

	public function new (x = 0.0, y = 0.0, ?simpleGraphic)
	{
		renderMatrix = new FlxMatrix();

		super(x, y, simpleGraphic);

		if (FlxG.renderer.blit)
			FlxG.log.warn("FlxMatrixSprites do not work on blit targets");
	}

	override function isSimpleRenderBlit(?cam)
	{
		return super.isSimpleRenderBlit(cam) && renderMatrix.isIdentity();
	}

	override function prepareComplexMatrix(matrix:FlxMatrix, frame:FlxFrame, camera:FlxCamera):FlxMatrix
	{
		frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		matrix.translate(-origin.x, -origin.y);

		var _animOffset:FlxPoint = animation.curAnim?.offset ?? FlxPoint.weak();
		if (frameOffsetAngle != null && frameOffsetAngle != angle)
		{
			var angleOff = (-angle + frameOffsetAngle) * FlxAngle.TO_RAD;
			matrix.rotate(-angleOff);
			matrix.translate(-(frameOffset.x + _animOffset.x), -(frameOffset.y + _animOffset.y));
			matrix.rotate(angleOff);
		}
		else
			matrix.translate(-(frameOffset.x + _animOffset.x), -(frameOffset.y + _animOffset.y));

		matrix.scale(scale.x, scale.y);

		if (bakedRotationAngle <= 0)
		{
			updateTrig();

			if (angle != 0)
				matrix.rotateWithTrig(_cosAngle, _sinAngle);
		}
		matrix.concat(renderMatrix);

		final screenPos = getScreenPosition(camera).subtract(offset);
		screenPos.add(origin.x, origin.y);
		matrix.translate(screenPos.x, screenPos.y);
		screenPos.put();

		if (isPixelPerfectRender(camera))
		{
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}
		_animOffset.putWeak();
		return matrix;
	}
}