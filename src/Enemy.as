package  
{
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.*;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Enemy extends Player 
	{
		public function Enemy(mId:int, mName:String, mPosition:BoardPosition, mEnemyId:int) 
		{
			skillPoints = [0,0,0,0]; // TODO: temporary
			super(mId, mName, mPosition);
		}
		
		override public function getPlayerSprite():Image {
			return Constants.ENEMY_SPRITES[0]; // TODO: more than one sprite?
		}
		
		public function getSpaceToMoveTo(board:Board, possibleSpaces:Vector.<BoardPosition>):BoardPosition {
			// TODO: enemies take turn after player, select enemy path from this space selection, do the thing
			return possibleSpaces[0]; // TODO: more complex logic
		}
	}

}