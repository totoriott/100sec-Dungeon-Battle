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
	public class OverlayGetItem extends GraphicOverlay 
	{
		private var timer:int = 0;
		
		private var isKeyItem:Boolean;
		private var item:BoardItem;
		
		private var getItemText:Text;
		private var keyItemText:Text;
		
		public function OverlayGetItem(player:Player, mItem:int, keyItem:Boolean) 
		{
			timer = 0;
			
			item = BoardItem.BoardItemFromId(mItem);
			isKeyItem = keyItem;
			
			getItemText = new Text(player.getName() + " got an item!", 0, 0, { "size": 32 });
			getItemText.font = "Segoe";
			getItemText.color = 0xFFFFFF;
			
			keyItemText = new Text("It's the key item! Get to the exit!", 0, 0, { "size": 32 });
			keyItemText.font = "Segoe";
			keyItemText.color = 0xFFFFFF;
		}
		
		override public function render(x:int, y:int):void
		{
			var centerY:int = Constants.GAME_HEIGHT / 2;
			var centerX:int = Constants.GAME_WIDTH / 2;
			
			var heightOfOverlay:int = 150 * Constants.graphicsAnimationPercentFromTiming(timer, 0, 5, 115, 5);
			Draw.rect(0, centerY - heightOfOverlay / 2, Constants.GAME_WIDTH, heightOfOverlay, 0x444444, 0.80);
				
			// these are hardcoded sorry
			getItemText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 5, 5, 115, 5);
			Draw.graphic(getItemText, centerX - 112, centerY - 66);
			
			var itemAlpha:Number = Constants.graphicsAnimationPercentFromTiming(timer, 25, 15, 115, 5);
			var itemImage:Image = item.image;
			itemImage.alpha = itemAlpha;
			Draw.graphic(itemImage, centerX / 2 - itemImage.width / 2, centerY - itemImage.height / 2);

			if (isKeyItem) {
				keyItemText.alpha = Constants.graphicsAnimationPercentFromTiming(timer, 45, 5, 115, 5);
				Draw.graphic(keyItemText, centerX - 112, centerY - 26);
			}
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