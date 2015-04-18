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
	public class OverlayMovementRoll extends GraphicOverlay 
	{
		private var timer:int = 0;
		
		private var dice:Array;
		private var moveBonus:int;
		private var cardBonus:int;
		private var totalRoll:int;
		
		// TODO: what if you play exit card lol
		private var moveBonusText:Text;
		private var cardBonusText:Text;
		private var totalRollText:Text;
		
		public function OverlayMovementRoll(aDice:Array, aMoveBonus:int, aCardBonus:int, aTotalRoll:int) 
		{
			timer = 0;
			
			dice = aDice;
			moveBonus = aMoveBonus;
			cardBonus = aCardBonus;
			totalRoll = aTotalRoll;
			
			moveBonusText = new Text("+ " + moveBonus + " move bonus");
			moveBonusText.font = "Segoe";
			moveBonusText.color = 0xFFFFFF;
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 150 * Constants.graphicsAnimationPercentFromTiming(timer, 0, 55, 5);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.66);
			
			var diceAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 5, 45, 10);
			var dieImage:Image = Constants.IMG_OVERLAY_DICE[dice[0] - 1]; // we're going to assume you only rolled one die
			dieImage.alpha = diceAlpha;
			Draw.graphic(dieImage, centerX / 2 - dieImage.width / 2, centerY - dieImage.height / 2);
			
			//moveBonusText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 5, 45, 10);
			Draw.graphic(moveBonusText, centerX - 96, centerY - 64);
			Draw.graphic(moveBonusText, centerX - 64, centerY - 32);
			Draw.graphic(moveBonusText, centerX - 32, centerY);
			
			// TODO: draw roll stats
		}
			
		override public function update(inputArray:Array):void 
		{
			timer++;
		}
		
		override public function isDoneShowing():Boolean 
		{
			return timer > 60;
		}
	}

}