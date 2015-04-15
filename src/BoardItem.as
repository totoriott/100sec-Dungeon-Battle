package  
{
	import net.flashpunk.graphics.Image;
	/**
	 * the treasure things you find on the board
	 */
	public class BoardItem
	{
		public var id:int;
		
		public var image:Image;
		public var type:int;
		public var value:int;
		
		public var pointValue:int;
		public var creditValue:int;
		public var fromThisBoard:Boolean; // whether we picked up this item on this run
		
		public function BoardItem(theId:int, i:Image, t:int, v:int, pt:int, sale:int) 
		{
			id = theId;
			
			image = i;
			type = t;
			value = v;
			
			pointValue = pt;
			creditValue = sale;
			
			fromThisBoard = false;
		}
		
		public static function BoardItemFromId(id:int):BoardItem {
			return BoardCardFromArray(Constants.TREASURE_DB[id]);
		}
		
		public static function BoardCardFromArray(a:Array):BoardItem {
			return new BoardItem(a[0], a[1], a[2], a[3], a[4], a[5]);
		}
		
		public function deepCopy():BoardItem {
			return new BoardItem(id, image, type, value, pointValue, creditValue);
		}
		
	}

}