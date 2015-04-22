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
	public class OverlayEscapeRoll extends GraphicOverlay 
	{
		private var timer:int = 0;
		private var totalAnimationTime:int = 420;
		private var fadeOutStartTime:int = 405;
		private var fadeOutLength:int = 15;
		private var skipToTime:int = 260;
		
		private var dDice:Array;
		private var dEscapeBonus:int;
		private var dCardBonus:int;
		private var dTotalRoll:int;
		private var aDice:Array;
		private var aEscapeBonus:int;
		private var aCardBonus:int;
		private var aTotalRoll:int;
		
		// TODO: what if you play exit card lol
		private var dEscapeBonusText:Text;
		private var dCardBonusText:Text;
		private var dTotalRollText:Text;
		private var aEscapeBonusText:Text;
		private var aCardBonusText:Text;
		private var aTotalRollText:Text;
		
		private var defenseHeaderText:Text;
		private var offenseHeaderText:Text;
		private var successText:Text;
		
		public function OverlayEscapeRoll(dPlayer:Player, aPlayer:Player, escapeSuccess:Boolean)
		{
			timer = 0;
			
			dDice = dPlayer.getEscapeRoll();
			dEscapeBonus = dPlayer.getMoveBonus();
			dCardBonus = dPlayer.getCardBonusEscape();
			dTotalRoll = dPlayer.getEscapeRollValue();
			
			aDice = aPlayer.getEscapeRoll();
			aEscapeBonus = aPlayer.getMoveBonus();
			aCardBonus = aPlayer.getCardBonusEscape();
			aTotalRoll = aPlayer.getEscapeRollValue();
			
			dEscapeBonusText = new Text("+ " +dEscapeBonus + " escape bonus", 0, 0, { "size": 24 });
			dEscapeBonusText.font = "Segoe";
			dEscapeBonusText.color = 0xFFFFFF;
			
			dCardBonusText = new Text("+ " + dCardBonus + " card bonus", 0, 0, { "size": 24 });
			dCardBonusText.font = "Segoe";
			dCardBonusText.color = 0xFFFFFF;
			
			dTotalRollText = new Text("= " + dTotalRoll + " total escape", 0, 0, { "size": 32 });
			dTotalRollText.font = "Segoe";
			dTotalRollText.color = 0xFFFFFF;
			
			aEscapeBonusText = new Text("+ " + aEscapeBonus + " escape bonus", 0, 0, { "size": 24 });
			aEscapeBonusText.font = "Segoe";
			aEscapeBonusText.color = 0xFFFFFF;
			
			aCardBonusText = new Text("+ " + aCardBonus + " card bonus", 0, 0, { "size": 24 });
			aCardBonusText.font = "Segoe";
			aCardBonusText.color = 0xFFFFFF;
			
			aTotalRollText = new Text("= " + aTotalRoll + " total escape", 0, 0, { "size": 32 });
			aTotalRollText.font = "Segoe";
			aTotalRollText.color = 0xFFFFFF;
			
			defenseHeaderText = new Text(dPlayer.getName() + " tries to escape!", 0, 0, { "size": 32 } ); 
			defenseHeaderText.font = "Segoe";
			defenseHeaderText.color = 0xFFFFFF; 
			
			offenseHeaderText = new Text(aPlayer.getName() + " pursues them!", 0, 0, { "size": 32 } ); 
			offenseHeaderText.font = "Segoe";
			offenseHeaderText.color = 0xFFFFFF; 
			
			if (escapeSuccess) {
				successText = new Text(dPlayer.getName() + " escaped successfully!", 0, 0, { "size": 32 } ); 
			} else {
				successText = new Text(dPlayer.getName() + " couldn't escape!", 0, 0, { "size": 32 } ); 
			}
			successText.font = "Segoe";
			successText.color = 0xFFFFFF; 
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 400 * Constants.graphicsAnimationPercentFromTiming(timer, 0, 10, fadeOutStartTime, fadeOutLength);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
			
			// draw defense
			var defenseYrelToCenter:int = -72;

			var dDieImage:Image = Constants.IMG_OVERLAY_DICE[dDice[0] - 1];
			
			defenseHeaderText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 10, 10, fadeOutStartTime, fadeOutLength);
			Draw.graphic(defenseHeaderText, centerX / 2 - dDieImage.width / 2 * 3 + 16, centerY + defenseYrelToCenter - 116);
			
			var dDiceAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 30, 30, fadeOutStartTime, fadeOutLength);
			dDieImage.alpha = dDiceAlpha;
			dDieImage.scale = 0.75;
			Draw.graphic(dDieImage, centerX / 2 - dDieImage.width / 2 * 3 + 32, centerY - dDieImage.height / 2 + defenseYrelToCenter);
			dDieImage = Constants.IMG_OVERLAY_DICE[dDice[1] - 1];
			dDieImage.alpha = dDiceAlpha;
			dDieImage.scale = 0.75;
			Draw.graphic(dDieImage, centerX / 2 - dDieImage.width / 2 + 32, centerY - dDieImage.height / 2 + defenseYrelToCenter);
			
			dEscapeBonusText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 60, 15, fadeOutStartTime, fadeOutLength);
			if (dEscapeBonus > 0) {
				Draw.graphic(dEscapeBonusText, centerX - 112, centerY + defenseYrelToCenter - 76);
			}
			
			dCardBonusText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 75, 15, fadeOutStartTime, fadeOutLength);
			if (dCardBonus > 0) {
				Draw.graphic(dCardBonusText, centerX - 80, centerY + defenseYrelToCenter - 36);
			}
			
			dTotalRollText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 90, 15, fadeOutStartTime, fadeOutLength);
			Draw.graphic(dTotalRollText, centerX - 48, centerY + defenseYrelToCenter);
			
			var offenseYrelToCenter:int = 88;
			
			// draw offense
			var aDieImage:Image = Constants.IMG_OVERLAY_DICE[aDice[0] - 1];
			
			offenseHeaderText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 135, 10, fadeOutStartTime, fadeOutLength);
			Draw.graphic(offenseHeaderText, centerX / 2 - aDieImage.width / 2 * 3 + 16, centerY + offenseYrelToCenter - 116);
			
			var aDiceAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 155, 30, fadeOutStartTime, fadeOutLength);
			aDieImage.alpha = aDiceAlpha;
			aDieImage.scale = 0.75;
			Draw.graphic(aDieImage, centerX / 2 - aDieImage.width / 2 * 3 + 32, centerY - aDieImage.height / 2 + offenseYrelToCenter);
			aDieImage = Constants.IMG_OVERLAY_DICE[aDice[1] - 1];
			aDieImage.alpha = aDiceAlpha;
			aDieImage.scale = 0.75;
			Draw.graphic(aDieImage, centerX / 2 - aDieImage.width / 2 + 32, centerY - aDieImage.height / 2 + offenseYrelToCenter);
			
			aEscapeBonusText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 185, 15, fadeOutStartTime, fadeOutLength);
			if (aEscapeBonus > 0) {
				Draw.graphic(aEscapeBonusText, centerX - 112, centerY - 76 + offenseYrelToCenter);
			}
			
			aCardBonusText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 200, 15, fadeOutStartTime, fadeOutLength);
			if (aCardBonus > 0) {
				Draw.graphic(aCardBonusText, centerX - 80, centerY - 36 + offenseYrelToCenter);
			}
			
			aTotalRollText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 215, 15, fadeOutStartTime, fadeOutLength);
			Draw.graphic(aTotalRollText, centerX - 48, centerY + offenseYrelToCenter);
			
			// draw success
			successText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 250, 10, fadeOutStartTime, fadeOutLength);
			Draw.graphic(successText, centerX / 2 - aDieImage.width / 2 * 3 + 16, centerY + offenseYrelToCenter + 40);
		}
			
		override public function update(inputArray:Array):void 
		{
			timer++;
			
			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED && timer < skipToTime) // skip animation
			{
				timer = skipToTime;
			}
		}
		
		override public function isDoneShowing():Boolean 
		{
			return timer > totalAnimationTime;
		}
	}

}