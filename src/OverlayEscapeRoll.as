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
		private var totalAnimationTime:int = 420;
		private var skipToTime:int = 260;
		
		private var dDice:Array;
		private var dEscapeBonus:int;
		private var dCardBonus:int;
		private var dTotalRoll:int;
		private var aDice:Array;
		private var aEscapeBonus:int;
		private var aCardBonus:int;
		private var aTotalRoll:int;
		
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
			fadeOutStartTime = 405;
			fadeOutLength = 15;
			
			// TODO: refactor other overlays to be nice like this one
			timer = 0;
			
			dDice = dPlayer.getEscapeRoll();
			dEscapeBonus = dPlayer.getMoveBonus();
			dCardBonus = dPlayer.getCardBonusEscape();
			dTotalRoll = dPlayer.getEscapeRollValue();
			
			aDice = aPlayer.getEscapeRoll();
			aEscapeBonus = aPlayer.getMoveBonus();
			aCardBonus = aPlayer.getCardBonusEscape();
			aTotalRoll = aPlayer.getEscapeRollValue();
			
			dEscapeBonusText = getText("+ " +dEscapeBonus + " escape bonus", 24);
			if (dCardBonus >= 99999) { // EXIT card used
				dCardBonusText = getText("EXIT card used", 24);
				dTotalRollText = getText("= Perfect escape", 32);
			} else {
				dCardBonusText = getText("+ " + dCardBonus + " card bonus", 24);
				dTotalRollText = getText("= " + dTotalRoll + " total escape", 32);
			}

			aEscapeBonusText = getText("+ " + aEscapeBonus + " escape bonus", 24);
			if (aCardBonus >= 99999) { // EXIT card used
				aCardBonusText = getText("EXIT card used", 24);
				aTotalRollText = getText("= Perfect escape", 32);
			} else {
				aCardBonusText = getText("+ " + aCardBonus + " card bonus", 24);
				aTotalRollText = getText("= " + aTotalRoll + " total escape", 32);
			}
			
			defenseHeaderText = getText(dPlayer.getName() + " tries to escape!", 32); 
			offenseHeaderText = getText(aPlayer.getName() + " pursues them!", 32); 
			
			if (escapeSuccess) {
				successText = getText(dPlayer.getName() + " escaped successfully!", 32); 
			} else {
				successText = getText(dPlayer.getName() + " couldn't escape!", 32); 
			}
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			startTimerSchedule();
			
			var heightOfOverlay:int = 400 * fadeInForAndDelayAfter(10, 0);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
			
			// draw defense
			var defenseYrelToCenter:int = -72;
			
			defenseHeaderText.alpha = fadeInForAndDelayAfter(10, 10);
			var dDieImage:Image = Constants.IMG_OVERLAY_DICE[dDice[0] - 1];
			Draw.graphic(defenseHeaderText, centerX / 2 - dDieImage.width / 2 * 3 + 16, centerY + defenseYrelToCenter - 116);
			
			var dDiceAlpha:Number = fadeInForAndDelayAfter(30, 0);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[dDice[0] - 1], dDiceAlpha, 0.75), 
				centerX / 2 - dDieImage.width / 2 * 3 + 32, centerY - dDieImage.height / 2 + defenseYrelToCenter);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[dDice[1] - 1], dDiceAlpha, 0.75), 
				centerX / 2 - dDieImage.width / 2 + 32, centerY - dDieImage.height / 2 + defenseYrelToCenter);
			
			dEscapeBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (dEscapeBonus > 0) {
				Draw.graphic(dEscapeBonusText, centerX - 112, centerY + defenseYrelToCenter - 76);
			}
			
			dCardBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (dCardBonus > 0) {
				Draw.graphic(dCardBonusText, centerX - 80, centerY + defenseYrelToCenter - 36);
			}
			
			dTotalRollText.alpha = fadeInForAndDelayAfter(15, 30);
			Draw.graphic(dTotalRollText, centerX - 48, centerY + defenseYrelToCenter);

			// draw offense
			var offenseYrelToCenter:int = 88;
			
			offenseHeaderText.alpha = fadeInForAndDelayAfter(10, 10);
			var aDieImage:Image = Constants.IMG_OVERLAY_DICE[aDice[0] - 1];
			Draw.graphic(offenseHeaderText, centerX / 2 - aDieImage.width / 2 * 3 + 16, centerY + offenseYrelToCenter - 116);
			
			var aDiceAlpha:Number = fadeInForAndDelayAfter(30, 0);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[aDice[0] - 1], aDiceAlpha, 0.75), 
				centerX / 2 - aDieImage.width / 2 * 3 + 32, centerY - aDieImage.height / 2 + offenseYrelToCenter);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[aDice[1] - 1], aDiceAlpha, 0.75), 
				centerX / 2 - aDieImage.width / 2 + 32, centerY - aDieImage.height / 2 + offenseYrelToCenter);
			
			aEscapeBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (aEscapeBonus > 0) {
				Draw.graphic(aEscapeBonusText, centerX - 112, centerY - 76 + offenseYrelToCenter);
			}
			
			aCardBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (aCardBonus > 0) {
				Draw.graphic(aCardBonusText, centerX - 80, centerY - 36 + offenseYrelToCenter);
			}
			
			aTotalRollText.alpha = fadeInForAndDelayAfter(15, 20);
			Draw.graphic(aTotalRollText, centerX - 48, centerY + offenseYrelToCenter);
			
			// draw success
			successText.alpha = fadeInForAndDelayAfter(10, 0);
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