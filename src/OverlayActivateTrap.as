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
	public class OverlayActivateTrap extends GraphicOverlay 
	{
		private var type:int;
		
		private var trapText1:Text;
		private var trapText2:Text;
		
		public function OverlayActivateTrap(player:Player, trapType:int, evaded:Boolean) 
		{
			fadeOutStartTime = 115;
			fadeOutLength = 5;
			
			timer = 0;
			
			type = trapType;
			
			var trapName:String = "";
			var trapDesc:String = "";
			switch (trapType) {
				case Constants.TRAP_DAMAGE:
					trapName = "damage";
					trapDesc = "They lost some health!";
					break;
				case Constants.TRAP_EMPTY:
					trapName = "empty";
					trapDesc = "They lost all their cards!";
					break;
				case Constants.TRAP_LEG:
					trapName = "leg";
					trapDesc = "They lost their movement bonus!";
					break;
				case Constants.TRAP_STUN:
					trapName = "stun";
					trapDesc = "They can't move for a turn!";
					break;
			}
			
			trapText1 = getText(player.getName() + " stepped on a trap!", 32); // TODO: make this fancier, maybe use name
			
			if (evaded) {
				trapText2 = getText("But they avoided activating it!", 32);
			} else {
				trapText2 = getText(trapDesc, 32);
			}
		}
		
		override public function render(x:int, y:int):void
		{
			startTimerSchedule();
			
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 150 * fadeInForAndDelayAfter(5, 0);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
			
			// these are hardcoded sorry
			trapText1.alpha = fadeInForAndDelayAfter(10, 15);
			Draw.graphic(trapText1, centerX - 112, centerY - 66);
			
			// TODO: no image for now
			
			/*var flagAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 25, 15, 115, 5);
			var flagImage:Image = null;
			if (type == Constants.FLAG_TYPE_POINTS) {
				flagImage = Constants.IMG_OVERLAY_DICE[value];
			}
			flagImage.alpha = flagAlpha;
			Draw.graphic(flagImage, centerX / 2 - flagImage.width / 2, centerY - flagImage.height / 2);*/

			trapText2.alpha = fadeInForAndDelayAfter(10, 0);
			Draw.graphic(trapText2, centerX - 112, centerY - 26);
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