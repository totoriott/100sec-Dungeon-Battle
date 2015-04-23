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
	public class OverlayCombatRoll extends GraphicOverlay 
	{
		private var totalAnimationTime:int = 420;
		private var skipToTime:int = 260;
		
		private var dDice:Array;
		private var dCombatBonus:int;
		private var dCardBonus:int;
		private var dTotalRoll:int;
		private var aDice:Array;
		private var aCombatBonus:int;
		private var aCardBonus:int;
		private var aTotalRoll:int;
		
		// TODO: what if you play exit card lol
		private var dCombatBonusText:Text;
		private var dCardBonusText:Text;
		private var dTotalRollText:Text;
		private var aCombatBonusText:Text;
		private var aCardBonusText:Text;
		private var aTotalRollText:Text;
		
		private var defenseHeaderText:Text;
		private var offenseHeaderText:Text;
		private var successText:Text;
		
		public function OverlayCombatRoll(dPlayer:Player, aPlayer:Player, isGuard:Boolean, isCounter:Boolean)
		{			
			fadeOutStartTime = 405;
			fadeOutLength = 15;
			
			// TODO: refactor other overlays to be nice like this one
			timer = 0;
			
			dDice = dPlayer.getCombatRoll();
			dCombatBonus = dPlayer.getDefense();
			dCardBonus = dPlayer.getCardBonusDefense();
			dTotalRoll = dPlayer.getCombatRollValue(false);
			if (isGuard) {
				dTotalRoll += dPlayer.getDefense(); // double defense for guard
			}
			
			aDice = aPlayer.getCombatRoll();
			aCombatBonus = aPlayer.getAttack();
			aCardBonus = aPlayer.getCardBonusAttack();
			aTotalRoll = aPlayer.getCombatRollValue(true);
			
			if (isGuard) {
				defenseHeaderText = getText(dPlayer.getName() + " guards themselves, raising their defense!", 32); 
			} else {
				defenseHeaderText = getText(dPlayer.getName() + " defends!", 32); 
			}
			
			if (isGuard) {
				dCombatBonusText = getText("+ " +dCombatBonus + " x 2 = " + (dCombatBonus*2) + " defense bonus", 24);
			} else {
				dCombatBonusText = getText("+ " +dCombatBonus + " defense bonus", 24);
			}
			
			if (dCardBonus >= 99999) {
				dCardBonusText = getText("DEF-A card used", 24);
				dTotalRollText = getText("= perfect defense", 32);
			} else {
				var doubleUsed:Boolean = (dPlayer.getLastCombatCard() != null && dPlayer.getLastCombatCard().type == Constants.CARD_DEF && dPlayer.getLastCombatCard().value == Constants.DEF_D);
				if (doubleUsed) {
					dCardBonusText = getText("+ " + dCardBonus + " doubled defense", 24);
				} else {
					dCardBonusText = getText("+ " + dCardBonus + " card bonus", 24);
				}
				
				dTotalRollText = getText("= " + dTotalRoll + " total defense", 32);
			}
			
			if (isCounter) {
				offenseHeaderText = getText(aPlayer.getName() + "'s counterattack!", 32); 
			} else {
				offenseHeaderText = getText(aPlayer.getName() + " attacks!", 32); 
			}
			
			aCombatBonusText = getText("+ " + aCombatBonus + " attack bonus", 24);
			
			var aDoubleUsed:Boolean = (aPlayer.getLastCombatCard() != null && aPlayer.getLastCombatCard().type == Constants.CARD_ATK && aPlayer.getLastCombatCard().value == Constants.ATK_S);
			var aOppUsed:Boolean = (aPlayer.getLastCombatCard() != null && aPlayer.getLastCombatCard().type == Constants.CARD_ATK && aPlayer.getLastCombatCard().value == Constants.ATK_C);
			if (aDoubleUsed) {
				aCardBonusText = getText("+ " + aCardBonus + " double attack", 24);
			} else if (aOppUsed) {
				aCardBonusText = getText("+ " + aCardBonus + " opponent's strength", 24);
			} else {
				aCardBonusText = getText("+ " + aCardBonus + " card bonus", 24);
			}
			aTotalRollText = getText("= " + aTotalRoll + " total attack", 32);
			
			var attackValue:int = aTotalRoll;
			var defenseValue:int = dTotalRoll;
			var damage:int = Math.max(0, attackValue - defenseValue);
			successText = getText(damage + " damage dealt!", 32); 
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			startTimerSchedule();
			
			var heightOfOverlay:int = 400 * fadeInForAndDelayAfter(10, 0);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
			
			// draw offense
			var offenseYrelToCenter:int = -72;
			
			offenseHeaderText.alpha = fadeInForAndDelayAfter(10, 10);
			var aDieImage:Image = Constants.IMG_OVERLAY_DICE[aDice[0] - 1];
			Draw.graphic(offenseHeaderText, centerX / 2 - aDieImage.width / 2 * 3 + 16, centerY + offenseYrelToCenter - 116);
			
			var aDiceAlpha:Number = fadeInForAndDelayAfter(30, 0);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[aDice[0] - 1], aDiceAlpha, 0.75), 
				centerX / 2 - aDieImage.width / 2 * 3 + 32, centerY - aDieImage.height / 2 + offenseYrelToCenter);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[aDice[1] - 1], aDiceAlpha, 0.75), 
				centerX / 2 - aDieImage.width / 2 + 32, centerY - aDieImage.height / 2 + offenseYrelToCenter);
			
			aCombatBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (aCombatBonus > 0) {
				Draw.graphic(aCombatBonusText, centerX - 112, centerY - 76 + offenseYrelToCenter);
			}
			
			aCardBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (aCardBonus > 0) {
				Draw.graphic(aCardBonusText, centerX - 80, centerY - 36 + offenseYrelToCenter);
			}
			
			aTotalRollText.alpha = fadeInForAndDelayAfter(15, 20);
			Draw.graphic(aTotalRollText, centerX - 48, centerY + offenseYrelToCenter);
			
			// draw defense
			var defenseYrelToCenter:int = 88;
			
			defenseHeaderText.alpha = fadeInForAndDelayAfter(10, 10);
			var dDieImage:Image = Constants.IMG_OVERLAY_DICE[dDice[0] - 1];
			Draw.graphic(defenseHeaderText, centerX / 2 - dDieImage.width / 2 * 3 + 16, centerY + defenseYrelToCenter - 116);
			
			var dDiceAlpha:Number = fadeInForAndDelayAfter(30, 0);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[dDice[0] - 1], dDiceAlpha, 0.75), 
				centerX / 2 - dDieImage.width / 2 * 3 + 32, centerY - dDieImage.height / 2 + defenseYrelToCenter);
			Draw.graphic(Constants.imageWithProperties(Constants.IMG_OVERLAY_DICE[dDice[1] - 1], dDiceAlpha, 0.75), 
				centerX / 2 - dDieImage.width / 2 + 32, centerY - dDieImage.height / 2 + defenseYrelToCenter);
			
			dCombatBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (dCombatBonus > 0) {
				Draw.graphic(dCombatBonusText, centerX - 112, centerY + defenseYrelToCenter - 76);
			}
			
			dCardBonusText.alpha = fadeInForAndDelayAfter(15, 0);
			if (dCardBonus > 0) {
				Draw.graphic(dCardBonusText, centerX - 80, centerY + defenseYrelToCenter - 36);
			}
			
			dTotalRollText.alpha = fadeInForAndDelayAfter(15, 30);
			Draw.graphic(dTotalRollText, centerX - 48, centerY + defenseYrelToCenter);

			// draw success
			successText.alpha = fadeInForAndDelayAfter(10, 0);
			Draw.graphic(successText, centerX / 2 - aDieImage.width / 2 * 3 + 16, centerY + defenseYrelToCenter + 40);
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