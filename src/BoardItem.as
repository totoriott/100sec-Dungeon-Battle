package  
{
	import net.flashpunk.graphics.Image;
	/**
	 * the treasure things you find on the board
	 */
	public class BoardItem
	{
		public var id:int;
		public var name:String;
		
		public var image:Image;
		public var type:int;
		public var value:int;
		
		public var pointValue:int;
		public var creditValue:int;
		public var fromThisBoard:Boolean; // whether we picked up this item on this run
		
		public function BoardItem(theId:int, tName:String, i:Image, t:int, v:int, pt:int, sale:int) 
		{
			id = theId;
			name = tName;
			
			image = i;
			type = t;
			value = v;
			
			pointValue = pt;
			creditValue = sale;
			
			fromThisBoard = false;
		}
		
		public static function BoardItemFromId(id:int):BoardItem {
			return BoardItemFromArray(Constants.TREASURE_DB[id]);
		}
		
		public static function BoardItemFromArray(a:Array):BoardItem {
			return new BoardItem(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
		}
		
		public function deepCopy():BoardItem {
			return new BoardItem(id, name, image, type, value, pointValue, creditValue);
		}
		
		public function getAttackBonus():int
		{
			if (type == Constants.ITEM_ATK) {
				return value;
			}
			
			return 0;
		}
		
		public function getDefenseBonus():int
		{
			if (type == Constants.ITEM_DEF) {
				return value;
			}
			
			return 0;
		}
		
		public function getMoveBonus():int
		{
			if (type == Constants.ITEM_MOVE) {
				return value;
			}
			
			return 0;
		}
		
	}

}