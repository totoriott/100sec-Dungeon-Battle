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
	public class OverlaySurrenderItem extends GraphicOverlay 
	{
		private var isKeyItem:Boolean;
		private var item:BoardItem;
		
		private var getItemText:Text;
		private var keyItemText:Text;
		
		public function OverlaySurrenderItem(fromPlayer:Player, toPlayer:Player, mItem:int, keyItem:Boolean, defeatedInBattle:Boolean) 
		{
			timer = 0;
			
			item = BoardItem.BoardItemFromId(mItem);
			isKeyItem = keyItem;
			
			//  TODO: Sizing on this sucks
			if (defeatedInBattle) {
				getItemText = getText(toPlayer.getName() + " took an item from " + fromPlayer.getName() + "!", 24);
			} else {
				getItemText = getText(fromPlayer.getName() + " surrendered an item to " + toPlayer.getName() + ".", 24);
			}
			
			keyItemText = getText("It's the key item! Get to the exit!", 24);
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
			itemImage.scale = 1;
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