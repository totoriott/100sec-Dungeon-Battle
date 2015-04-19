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
	public class OverlayKeyItemNotif extends GraphicOverlay 
	{
		private var timer:int = 0;
		
		private var item:BoardItem;
		
		private var notifText1:Text;
		private var notifText2:Text;
		
		public function OverlayKeyItemNotif(mItem:int) 
		{
			timer = 0;
			
			item = BoardItem.BoardItemFromId(mItem);
			
			notifText1 = new Text("Here's this round's key item!", 0, 0, { "size": 32 });
			notifText1.font = "Segoe";
			notifText1.color = 0xFFFFFF;
			
			notifText2 = new Text("Find it and get to the exit to win!", 0, 0, { "size": 32 });
			notifText2.font = "Segoe";
			notifText2.color = 0xFFFFFF;
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 150 * Constants.graphicsAnimationPercentFromTiming(timer, 0, 5, 115, 5);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
				
			// these are hardcoded sorry
			notifText1.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 5, 5, 115, 5);
			Draw.graphic(notifText1, centerX - 112, centerY - 66);
			
			var itemAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 25, 15, 115, 5);
			var itemImage:Image = item.image;
			itemImage.alpha = itemAlpha;
			itemImage.scale = 1;
			Draw.graphic(itemImage, centerX / 2 - itemImage.width / 2, centerY - itemImage.height / 2);
			
			notifText2.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 45, 10, 115, 5);
			Draw.graphic(notifText2, centerX - 112, centerY - 26);
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