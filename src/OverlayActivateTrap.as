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
		private var timer:int = 0;
		
		private var type:int;
		
		private var trapText1:Text;
		private var trapText2:Text;
		
		public function OverlayActivateTrap(player:Player, trapType:int) 
		{
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
			
			trapText1 = new Text(player.getName() + " activated a " + trapName + " trap!", 0, 0, { "size": 32 });
			trapText1.font = "Segoe";
			trapText1.color = 0xFFFFFF;
			
			trapText2 = new Text(trapDesc, 0, 0, { "size": 32 });
			trapText2.font = "Segoe";
			trapText2.color = 0xFFFFFF;
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 150 * Constants.graphicsAnimationPercentFromTiming(timer, 0, 5, 115, 5);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
			
			// these are hardcoded sorry
			trapText1.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 5, 5, 115, 5);
			Draw.graphic(trapText1, centerX - 112, centerY - 66);
			
			// TODO: no image for now
			
			/*var flagAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 25, 15, 115, 5);
			var flagImage:Image = null;
			if (type == Constants.FLAG_TYPE_POINTS) {
				flagImage = Constants.IMG_OVERLAY_DICE[value];
			}
			flagImage.alpha = flagAlpha;
			Draw.graphic(flagImage, centerX / 2 - flagImage.width / 2, centerY - flagImage.height / 2);*/

			trapText2.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 10, 5, 115, 5);
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