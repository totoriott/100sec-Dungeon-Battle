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
	public class OverlayEndGame extends GraphicOverlay 
	{
		private var totalAnimationTime:int = 630;
		private var skipToTime:int = 600; // TODO - adjust this
		private var accepted:Boolean = false;
		
		private var players:Array;
		
		public function OverlayEndGame(tPlayers:Array)
		{			
			fadeOutStartTime = 615;
			fadeOutLength = 15;
			
			timer = 0;
			
			players = tPlayers;
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			startTimerSchedule();
			
			var heightOfOverlay:int = (Constants.GAME_HEIGHT - 196) * fadeInForAndDelayAfter(15, 0);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.95);
			
			var overlayX:int = 16;
			var overlayY:int = centerY -  (Constants.GAME_HEIGHT - 196) / 2 + 16;
			
			// draw player sprites
			var spriteAlpha:Number = fadeInForAndDelayAfter(15, 15);
			for (var playerNum:int = 0; playerNum < players.length; playerNum++) {
				var player:Player = players[playerNum];
				var playerSprite:Image = player.getPlayerSprite();
				playerSprite.alpha = spriteAlpha;
				Draw.graphic(playerSprite, overlayX + 104 + 144 * (playerNum+1), overlayY);
			}
				
			overlayY += 40;
			// draw scores
			// TODO: maybe make total score more dramatic
			var scoreTypes:Array = ["Handicap", "Movement", "Attack", "Flags", "Items", "Total Score"];
			for (var k:int = 0; k < scoreTypes.length; k++) {
				var typeGraphic:Image = getText(scoreTypes[k], 32);
				var typeAlpha:Number = fadeInForAndDelayAfter(15, 15);
				typeGraphic.alpha = typeAlpha;
				Draw.graphic(typeGraphic, overlayX, overlayY);
				
				for (playerNum = 0; playerNum < players.length; playerNum++) {
					player = players[playerNum];
					var scoreGraphic:Image = getText(player.getScoreArray()[k], 32);
					scoreGraphic.alpha = typeAlpha;
					Draw.graphic(scoreGraphic, overlayX + 120 - scoreGraphic.width / 2 + 144 * (playerNum+1), overlayY);
				}
				
				overlayY += 48;
			}
			
			// draw positions
			var positionStr:Array = ["1ST", "2ND", "3RD", "4TH"];
			
			var allScores:Array = [];
			for (playerNum = 0; playerNum < players.length; playerNum++) {
				player = players[playerNum];
				allScores.push(player.calculateTotalPoints() + 0.1 - 0.01 * playerNum); // this is a lazy hack to break ties
			}
			var allScoresSorted:Array = Constants.deepCopyArray(allScores);
			allScoresSorted.sort(Array.NUMERIC);
			allScoresSorted.reverse();
			var playerWithPosition:Array = [];
			for (var w:int = 0; w < allScoresSorted.length; w++) {
				var aScore:Number = allScoresSorted[w];
				playerWithPosition.push(allScores.indexOf(aScore));
			}

			for (var position:int = players.length - 1; position >= 0; position--) {
				var posGraphic:Image = getText(positionStr[position], 32);
				posGraphic.alpha = fadeInForAndDelayAfter(15, 15);
				var whichPlayer:int = playerWithPosition[position];
				Draw.graphic(posGraphic, overlayX + 88 + 144 * (whichPlayer+1), overlayY);
			}
		}
			
		override public function update(inputArray:Array):void 
		{
			timer++;
			if (!accepted && timer > skipToTime) { // don't advance until user says so
				timer = skipToTime;
			}
			
			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED) // skip animation
			{
				if (timer < skipToTime) {
					timer = skipToTime;
				} else {
					accepted = true;
				}
			}
		}
		
		override public function isDoneShowing():Boolean 
		{
			return timer > totalAnimationTime;
		}
	}

}