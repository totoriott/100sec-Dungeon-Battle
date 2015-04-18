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
			
			moveBonusText = new Text("+ " + moveBonus + " move bonus", 0, 0, { "size": 32 });
			moveBonusText.font = "Segoe";
			moveBonusText.color = 0xFFFFFF;
			
			cardBonusText = new Text("+ " + cardBonus + " card bonus", 0, 0, { "size": 32 });
			cardBonusText.font = "Segoe";
			cardBonusText.color = 0xFFFFFF;
			
			totalRollText = new Text("= " + totalRoll + " total movement", 0, 0, { "size": 40 });
			totalRollText.font = "Segoe";
			totalRollText.color = 0xFFFFFF;
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 150 * Constants.graphicsAnimationPercentFromTiming(timer, 0, 5, 115, 5);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
			
			var diceAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 5, 10, 115, 5);
			var dieImage:Image = Constants.IMG_OVERLAY_DICE[dice[0] - 1]; // we're going to assume you only rolled one die
			dieImage.alpha = diceAlpha;
			Draw.graphic(dieImage, centerX / 2 - dieImage.width / 2, centerY - dieImage.height / 2);
			
			// these are hardcoded sorry
			moveBonusText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 15, 10, 115, 5);
			if (moveBonus > 0) {
				Draw.graphic(moveBonusText, centerX - 112, centerY - 66);
			}
			
			cardBonusText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 25, 10, 115, 5);
			if (cardBonus > 0) {
				Draw.graphic(cardBonusText, centerX - 80, centerY - 26);
			}
			
			totalRollText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 35, 10, 115, 5);
			Draw.graphic(totalRollText, centerX - 48, centerY + 10);
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