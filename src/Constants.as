package  
{
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Entity;
	import net.flashpunk.utils.*;
	
	public class Constants
	{
		// Game state
		public static var GSTATE_GAMEOVER:int = -1;
		public static var GSTATE_STARTTURN:int = 0;
		public static var GSTATE_SELECTACTION:int = 1;
		public static var GSTATE_SELECTCARD:int = 2;
		public static var GSTATE_DOROLL:int = 3;
		public static var GSTATE_SELECTMOVE:int = 4;
		public static var GSTATE_MOVING:int = 5;
		public static var GSTATE_ACTIVATESPACE:int = 6;
		public static var GSTATE_COMBAT_DEFENSE_SELECT:int = 7;
		public static var GSTATE_COMBAT_DEFENSE_SELECTCARD:int = 8;
		public static var GSTATE_COMBAT_OFFENSE_SELECTCARD:int = 9;
		public static var GSTATE_COMBAT_RESOLVE:int = 10;
		public static var GSTATE_ENDTURN:int = 11;
		
		// Graphics things
		public static var FRAMES_BETWEEN_SQUARES_MOVED:int = 5;
		public static var PLAYER_IMAGECOLORS:Array = [0xFF8888, 0x8888FF, 0xFFFF88, 0x88FF88];
		
		public static var PLAYERHUD_TYPE_CARDS:int = 0;
		public static var PLAYERHUD_TYPE_ITEMS:int = 1;
		public static var PLAYERHUD_TYPES:Array = [PLAYERHUD_TYPE_CARDS, PLAYERHUD_TYPE_ITEMS];
		
		// Key mappings
		public static var KEYMAP_LEFT:int = Key.LEFT;
		public static var KEYMAP_RIGHT:int = Key.RIGHT;
		public static var KEYMAP_UP:int = Key.UP;
		public static var KEYMAP_DOWN:int = Key.DOWN;
		public static var KEYMAP_FIRE1:int = Key.Z;
		public static var KEYMAP_FIRE2:int = Key.X;
		public static var KEYMAP_FIRE3:int = Key.C;
		public static var KEYMAP_FIRE4:int = Key.A;
		public static var KEYMAP_FIRE5:int = Key.S;
		public static var KEYMAP_FIRE6:int = Key.D;
		public static var KEYMAP_DEBUG:int = Key.R;
		public static var KEYMAP_ARRAY:Array = [KEYMAP_LEFT, KEYMAP_RIGHT, KEYMAP_UP, KEYMAP_DOWN, KEYMAP_FIRE1, KEYMAP_FIRE2, KEYMAP_FIRE3, KEYMAP_FIRE4, KEYMAP_FIRE5, KEYMAP_FIRE6, KEYMAP_DEBUG];
		
		public static var INPUT_NEUTRAL:int = 0;
		public static var INPUT_PRESSED:int = 1;
		public static var INPUT_DOWN:int = 2;
		
		// Keypress array mappings
		public static var KEY_LEFT:int = 0;
		public static var KEY_RIGHT:int = 1;
		public static var KEY_UP:int = 2;
		public static var KEY_DOWN:int = 3;
		public static var KEY_FIRE1:int = 4;
		public static var KEY_FIRE2:int = 5;
		public static var KEY_FIRE3:int = 6;
		public static var KEY_FIRE4:int = 7;
		public static var KEY_FIRE5:int = 8;
		public static var KEY_FIRE6:int = 9;
		public static var KEY_DEBUG:int = 10;
				
		// Player skill point enum
		public static var SKILL_ATK:int = 0;
		public static var SKILL_DEF:int = 1;
		public static var SKILL_MOVE:int = 2;
		public static var SKILL_HP:int = 3;
		
		// Card type enum
		public static var CARD_ATK:int = 0;
		public static var CARD_DEF:int = 1;
		public static var CARD_MOVE:int = 2;
		public static var CARD_TRAP:int = 3;
		public static var TRAP_EMPTY:int = 0; // these have to be zero-indexed for board draw purposes
		public static var TRAP_DAMAGE:int = 1;
		public static var TRAP_STUN:int = 2;
		public static var TRAP_LEG:int = 3;
		public static var ATK_C:int = -1;
		public static var ATK_S:int = -2;
		public static var DEF_A:int = -1;
		public static var DEF_D:int = -2;
		public static var MOVE_EXIT:int = -1;
		
		// Board space type enum
		public static var BOARD_NULL:int = 0;
		public static var BOARD_EMPTY:int = 1;
		//public static var BOARD_PLAYER:int = 2; //DEPRECATED
		public static var BOARD_EXIT:int = 3;
		public static var BOARD_FLAG:int = 4;
		public static var BOARD_BOX:int = 5;
		public static var BOARD_TRAP:int = 6;
		// TODO - enemy?
		
		// Item/treasure type enum
		public static var ITEM_NOEFFECT:int = 0;
		
		[Embed(source = 'assets/font/segoeui.ttf', embedAsCFF = "false", fontFamily = 'Segoe')] private static const FONT_SEGOE:Class;
		
		[Embed(source = 'assets/img/tile/blank.png')] private static const SRC_TILE_BLANK:Class;
		[Embed(source = 'assets/img/tile/null.png')] private static const SRC_TILE_NULL:Class;
		[Embed(source = 'assets/img/tile/enemy.png')] private static const SRC_TILE_ENEMY:Class;
		[Embed(source = 'assets/img/tile/exit.png')] private static const SRC_TILE_EXIT:Class;
		[Embed(source = 'assets/img/tile/flag_0.png')] private static const SRC_TILE_FLAG1:Class;
		[Embed(source = 'assets/img/tile/flag_1.png')] private static const SRC_TILE_FLAG2:Class;
		[Embed(source = 'assets/img/tile/flag_2.png')] private static const SRC_TILE_FLAG3:Class;
		[Embed(source = 'assets/img/tile/flag_3.png')] private static const SRC_TILE_FLAG4:Class;
		[Embed(source = 'assets/img/tile/player_0.png')] private static const SRC_TILE_PLAYER1:Class;
		[Embed(source = 'assets/img/tile/player_1.png')] private static const SRC_TILE_PLAYER2:Class;
		[Embed(source = 'assets/img/tile/player_2.png')] private static const SRC_TILE_PLAYER3:Class;
		[Embed(source = 'assets/img/tile/player_3.png')] private static const SRC_TILE_PLAYER4:Class;
		[Embed(source = 'assets/img/tile/trap.png')] private static const SRC_TILE_TRAP:Class;
		[Embed(source = 'assets/img/tile/treasure.png')] private static const SRC_TILE_BOX:Class;
		
		public static var BOARD_SPRITES:Array;
		public static var PLAYER_SPRITES:Array;
			
		public static function initGraphics():void
		{
			BOARD_SPRITES = [
				[new Image(SRC_TILE_NULL)], 
				[new Image(SRC_TILE_BLANK)],
				[new Image(SRC_TILE_PLAYER1), new Image(SRC_TILE_PLAYER2), new Image(SRC_TILE_PLAYER3), new Image(SRC_TILE_PLAYER4)], //DEPRECATED
				[new Image(SRC_TILE_EXIT)],	
				[new Image(SRC_TILE_FLAG1), new Image(SRC_TILE_FLAG2), new Image(SRC_TILE_FLAG3), new Image(SRC_TILE_FLAG4)],
				[new Image(SRC_TILE_BOX)],
				[new Image(SRC_TILE_TRAP), new Image(SRC_TILE_TRAP), new Image(SRC_TILE_TRAP), new Image(SRC_TILE_TRAP)]
					];
					
			PLAYER_SPRITES = [new Image(SRC_TILE_PLAYER1), new Image(SRC_TILE_PLAYER2), new Image(SRC_TILE_PLAYER3), new Image(SRC_TILE_PLAYER4)];
		
			DECK_BASE =	[
			[[new Image(SRC_CARD_ATK_3), CARD_ATK, 3], 3],
			[[new Image(SRC_CARD_ATK_4), CARD_ATK, 4], 3],
			[[new Image(SRC_CARD_ATK_5), CARD_ATK, 5], 3],
			[[new Image(SRC_CARD_ATK_6), CARD_ATK, 6], 2],
			[[new Image(SRC_CARD_ATK_7), CARD_ATK, 7], 2],
			[[new Image(SRC_CARD_ATK_8), CARD_ATK, 8], 2],
			[[new Image(SRC_CARD_ATK_9), CARD_ATK, 9], 1],
			[[new Image(SRC_CARD_ATK_C), CARD_ATK, ATK_C], 1],
			[[new Image(SRC_CARD_ATK_S), CARD_ATK, ATK_S], 1],
			[[new Image(SRC_CARD_DEF_3), CARD_DEF, 3], 6],
			[[new Image(SRC_CARD_DEF_4), CARD_DEF, 4], 6],
			[[new Image(SRC_CARD_DEF_5), CARD_DEF, 5], 5],
			[[new Image(SRC_CARD_DEF_6), CARD_DEF, 6], 5],
			[[new Image(SRC_CARD_DEF_7), CARD_DEF, 7], 3],
			[[new Image(SRC_CARD_DEF_8), CARD_DEF, 8], 2],
			[[new Image(SRC_CARD_DEF_9), CARD_DEF, 9], 1],
			[[new Image(SRC_CARD_DEF_A), CARD_DEF, DEF_A], 1],
			[[new Image(SRC_CARD_DEF_D), CARD_DEF, DEF_D], 1],
			[[new Image(SRC_CARD_MOVE_1), CARD_MOVE, 1], 18],
			[[new Image(SRC_CARD_MOVE_2), CARD_MOVE, 2], 8],
			[[new Image(SRC_CARD_MOVE_3), CARD_MOVE, 3], 4],
			[[new Image(SRC_CARD_MOVE_E), CARD_MOVE, MOVE_EXIT], 2],
			[[new Image(SRC_CARD_TRAP_D), CARD_TRAP, TRAP_DAMAGE], 5],
			[[new Image(SRC_CARD_TRAP_E), CARD_TRAP, TRAP_EMPTY], 5],
			[[new Image(SRC_CARD_TRAP_L), CARD_TRAP, TRAP_LEG], 5],
			[[new Image(SRC_CARD_TRAP_S), CARD_TRAP, TRAP_STUN], 5]
			];
			
			IMG_NO_CARD = new Image(SRC_CARD_NOCARD);
		}
		
		// Game constants
		public static var PLAYER_COUNT:int = 4;
		public static var HAND_CARD_LIMIT:int = 5;
		public static var BOARD_EXIT_COUNT:int = 1;
		public static var BOARD_BOX_COUNT:int = 8;
		public static var BOARD_FLAG_COUNT:int = 4;
		public static var BOARD_ROLL_LIMIT:int = 6;
		public static var BOARD_ROLL_COUNT:int = 1;
		public static var ATK_ROLL_LIMIT:int = 6;
		public static var ATK_ROLL_COUNT:int = 2;
		public static var FLAG_BASE_POINTS:int = 250;
		public static var FLAG_MULTIPLIERS:Array = [1, 1, 2, 4, 6, 8];
		public static var POINTS_PER_STEP:int = 15;
		public static var POINTS_PER_KO:int = 500;
		public static var POINTS_PER_ATTACK_DAMAGE:int = 25;
		public static var POINTS_PER_HANDICAP_LEVEL:int = 250;
		
		// Deck constants
		public static var DECK_CARD_DATA:int = 0;
		public static var DECK_CARD_COUNT:int = 1;
		public static var DECK_CARD_IMG:int = 0;
		public static var DECK_CARD_TYPE:int = 1;
		public static var DECK_CARD_VALUE:int = 2;
		
		public static var DECK_BASE:Array;
		
		[Embed(source = 'assets/img/card/atk_3.png')] private static const SRC_CARD_ATK_3:Class;
		[Embed(source = 'assets/img/card/atk_4.png')] private static const SRC_CARD_ATK_4:Class;
		[Embed(source = 'assets/img/card/atk_5.png')] private static const SRC_CARD_ATK_5:Class;
		[Embed(source = 'assets/img/card/atk_6.png')] private static const SRC_CARD_ATK_6:Class;
		[Embed(source = 'assets/img/card/atk_7.png')] private static const SRC_CARD_ATK_7:Class;
		[Embed(source = 'assets/img/card/atk_8.png')] private static const SRC_CARD_ATK_8:Class;
		[Embed(source = 'assets/img/card/atk_9.png')] private static const SRC_CARD_ATK_9:Class;
		[Embed(source = 'assets/img/card/atk_C.png')] private static const SRC_CARD_ATK_C:Class;
		[Embed(source = 'assets/img/card/atk_S.png')] private static const SRC_CARD_ATK_S:Class;
		[Embed(source = 'assets/img/card/def_3.png')] private static const SRC_CARD_DEF_3:Class;
		[Embed(source = 'assets/img/card/def_4.png')] private static const SRC_CARD_DEF_4:Class;
		[Embed(source = 'assets/img/card/def_5.png')] private static const SRC_CARD_DEF_5:Class;
		[Embed(source = 'assets/img/card/def_6.png')] private static const SRC_CARD_DEF_6:Class;
		[Embed(source = 'assets/img/card/def_7.png')] private static const SRC_CARD_DEF_7:Class;
		[Embed(source = 'assets/img/card/def_8.png')] private static const SRC_CARD_DEF_8:Class;
		[Embed(source = 'assets/img/card/def_9.png')] private static const SRC_CARD_DEF_9:Class;
		[Embed(source = 'assets/img/card/def_A.png')] private static const SRC_CARD_DEF_A:Class;
		[Embed(source = 'assets/img/card/def_D.png')] private static const SRC_CARD_DEF_D:Class;
		[Embed(source = 'assets/img/card/move_1.png')] private static const SRC_CARD_MOVE_1:Class;
		[Embed(source = 'assets/img/card/move_2.png')] private static const SRC_CARD_MOVE_2:Class;
		[Embed(source = 'assets/img/card/move_3.png')] private static const SRC_CARD_MOVE_3:Class;
		[Embed(source = 'assets/img/card/move_E.png')] private static const SRC_CARD_MOVE_E:Class;
		[Embed(source = 'assets/img/card/trap_D.png')] private static const SRC_CARD_TRAP_D:Class;
		[Embed(source = 'assets/img/card/trap_E.png')] private static const SRC_CARD_TRAP_E:Class;
		[Embed(source = 'assets/img/card/trap_L.png')] private static const SRC_CARD_TRAP_L:Class;
		[Embed(source = 'assets/img/card/trap_S.png')] private static const SRC_CARD_TRAP_S:Class;
		[Embed(source = 'assets/img/card/nocard.png')] private static const SRC_CARD_NOCARD:Class;
		public static var IMG_NO_CARD:Image;
		
		// Item/treasure constants
		[Embed(source = 'assets/img/item/0.png')] private static const SRC_ITEM_0:Class;
		[Embed(source = 'assets/img/item/1.png')] private static const SRC_ITEM_1:Class;
		[Embed(source = 'assets/img/item/2.png')] private static const SRC_ITEM_2:Class;
		[Embed(source = 'assets/img/item/3.png')] private static const SRC_ITEM_3:Class;
		[Embed(source = 'assets/img/item/4.png')] private static const SRC_ITEM_4:Class;
		[Embed(source = 'assets/img/item/5.png')] private static const SRC_ITEM_5:Class;
		[Embed(source = 'assets/img/item/6.png')] private static const SRC_ITEM_6:Class;
		[Embed(source = 'assets/img/item/7.png')] private static const SRC_ITEM_7:Class;
		[Embed(source = 'assets/img/item/8.png')] private static const SRC_ITEM_8:Class;
		[Embed(source = 'assets/img/item/9.png')] private static const SRC_ITEM_9:Class;
		
		public static var TREASURE_DB:Array;
		
		public static function initTreasureDb():void {
			// id, image, effect type, effect value, point value, resale value
			TREASURE_DB = [
				[0, new Image(SRC_ITEM_0), ITEM_NOEFFECT, 0, 1000, 100],
				[1, new Image(SRC_ITEM_1), ITEM_NOEFFECT, 0, 1000, 100],
				[2, new Image(SRC_ITEM_2), ITEM_NOEFFECT, 0, 1000, 100],
				[3, new Image(SRC_ITEM_3), ITEM_NOEFFECT, 0, 1000, 100],
				[4, new Image(SRC_ITEM_4), ITEM_NOEFFECT, 0, 1000, 100],
				[5, new Image(SRC_ITEM_5), ITEM_NOEFFECT, 0, 1000, 100],
				[6, new Image(SRC_ITEM_6), ITEM_NOEFFECT, 0, 1000, 100],
				[7, new Image(SRC_ITEM_7), ITEM_NOEFFECT, 0, 1000, 100],
				[8, new Image(SRC_ITEM_8), ITEM_NOEFFECT, 0, 1000, 100],
				[9, new Image(SRC_ITEM_9), ITEM_NOEFFECT, 0, 1000, 100],
			];
		}
		
		// Combat constants
		[Embed(source = 'assets/img/combat/counter.png')] private static const SRC_COMBAT_COUNTER:Class;
		[Embed(source = 'assets/img/combat/guard.png')] private static const SRC_COMBAT_GUARD:Class;
		[Embed(source = 'assets/img/combat/run.png')] private static const SRC_COMBAT_RUN:Class;
		[Embed(source = 'assets/img/combat/surrender.png')] private static const SRC_COMBAT_SURRENDER:Class;
		public static var COMBAT_DEFENSE_COUNTER:int = 0;
		public static var COMBAT_DEFENSE_GUARD:int = 1;
		public static var COMBAT_DEFENSE_RUN:int = 2;
		public static var COMBAT_DEFENSE_SURRENDER:int = 3;
		public static var COMBAT_DEFENSE_NOTHING:int = 4; // for stunned or if you fail escape
		public static var COMBAT_DEFENSE_OPTIONIMAGES:Array;
		public static function initCombatGraphics():void
		{
			COMBAT_DEFENSE_OPTIONIMAGES = [new Image(SRC_COMBAT_COUNTER), new Image(SRC_COMBAT_GUARD), new Image(SRC_COMBAT_RUN), new Image(SRC_COMBAT_SURRENDER)];
		}
		
		// TODO - doesn't deep copy object inside array but yolo
		public static function deepCopyArray(inArray:Array):Array
		{
			if (inArray == null) 
				return null; 
				
			var outArray:Array = new Array(inArray.length);
			for (var i:int = 0; i < inArray.length; i++)
			{
				outArray[i] = inArray[i];
			}
			
			return outArray;
		}
		
		public static function deepCopyBoardPositionVector(inVector:Vector.<BoardPosition>):Vector.<BoardPosition> {
			if (inVector == null) 
				return null; 
				
			var outVector:Vector.<BoardPosition> = new Vector.<BoardPosition>(inVector.length);
			for (var i:int = 0; i < inVector.length; i++)
			{
				outVector[i] = inVector[i].deepCopy();
			}
			
			return outVector;
		}
	}

}