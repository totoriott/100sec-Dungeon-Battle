package  
{
	public class BoardSpace 
	{
		public var type:int;
		public var value:int;
		
		public var row:int;
		public var col:int;
		
		public function BoardSpace(t:int, v:int) {
			type = t;
			value = v;
		}
		
		// here in case you ever need to have logic for it
		public function changeTo(t:int, v:int):void {
			type = t;
			value = v;
		}
		
		public function deepCopy():BoardSpace {
			return new BoardSpace(type, value);
		}	
	}

}