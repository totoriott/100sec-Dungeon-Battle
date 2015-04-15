package  
{
	/**
	 * ...
	 * @author ...
	 */
	public class BoardPosition 
	{
		public var row:int;
		public var col:int;
		
		public function BoardPosition(r:int, c:int) 
		{
			row = r;
			col = c;
		}
		
		public function deepCopy():BoardPosition {
			return new BoardPosition(row, col);
		}
		
	}

}