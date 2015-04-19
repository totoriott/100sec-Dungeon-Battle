package  
{
	import flash.display.Graphics;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class OverlayGetFlag extends GraphicOverlay 
	{
		private var timer:int = 0;
		
		private var type:int;
		private var value:int;
		
		private var getFlagText:Text;
		private var flagInfoText:Text;
		
		public function OverlayGetFlag(player:Player, flagType:int, flagValue:int) 
		{
			timer = 0;
			
			type = flagType;
			value = flagValue;
			
			getFlagText = new Text(player.getName() + " got a flag!", 0, 0, { "size": 32 });
			getFlagText.font = "Segoe";
			getFlagText.color = 0xFFFFFF;
			
			if (flagType == Constants.FLAG_TYPE_POINTS) {
				var flagPoints:int = Constants.FLAG_MULTIPLIERS[flagValue] * Constants.FLAG_BASE_POINTS;
				flagInfoText = new Text("Gained " + flagPoints + " points!", 0, 0, { "size": 32 });
				flagInfoText.font = "Segoe";
				flagInfoText.color = 0xFFFFFF;
			}
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 150 * Constants.graphicsAnimationPercentFromTiming(timer, 0, 5, 115, 5);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
				

			// these are hardcoded sorry
			getFlagText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 5, 5, 115, 5);
			Draw.graphic(getFlagText, centerX - 112, centerY - 66);
			
			var flagAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 25, 15, 115, 5);
			var flagImage:Image = null;
			if (type == Constants.FLAG_TYPE_POINTS) {
				flagImage = Constants.IMG_OVERLAY_DICE[value];
			}
			flagImage.alpha = flagAlpha;
			Draw.graphic(flagImage, centerX / 2 - flagImage.width / 2, centerY - flagImage.height / 2);

			flagInfoText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 45, 5, 115, 5);
			Draw.graphic(flagInfoText, centerX - 112, centerY - 26);
		}
			
		override public function update(inputArray:Array):void 
		{
			timer++;
			
			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED && timer < 90) // skip animation
			{
				timer = 90;
			}
		}
		
		override public function isDoneShowing():Boolean 
		{
			return timer > 120;
		}
	}

}