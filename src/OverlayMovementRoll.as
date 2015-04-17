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
		
		public function OverlayMovementRoll(aDice:Array, aMoveBonus:int, aCardBonus:int, aTotalRoll:int) 
		{
			timer = 0;
			
			dice = aDice;
			moveBonus = aMoveBonus;
			cardBonus = aCardBonus;
			totalRoll = aTotalRoll;
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			
			var heightOfOverlay:int = 150;
			if (timer < 5) {
				heightOfOverlay = timer * 30;
			} else if (timer > 55) {
				heightOfOverlay = (60 - timer) * 30;
			}
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.66);
			
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