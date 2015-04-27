package  
{
	import flash.display.Graphics;
	import flash.utils.Dictionary;
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.Graphic;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.*;
	
	public class Board extends Entity
	{
		public var deck:Vector.<BoardCard>;
		public var players:Array = [];
		public var board:Vector.<Vector.<BoardSpace>>;
		public var enemies:Vector.<Enemy>;
		
		// TODO - scrolling view?
		// TODO - reset these somewhere
		private var startRow:int = 0;
		private var startCol:int = 0;
		private var viewRows:int = 14;
		private var viewCols:int = 14;
		
		private var gameState:int = Constants.GSTATE_GAMEOVER;
		private var playerHudType:int = Constants.PLAYERHUD_TYPE_CARDS;
		
		private var playerTurn:int = 0; // which player's turn it is
		private var exitSpace:BoardPosition; // where is the exit
		private var keyItemId:int = 0; // which boarditem ID is the key item to win
		
		private var attackPlayer:Player; // if these are populated, combat will happen
		private var defensePlayer:Player;
		private var selectedDefenseOption:int = 0;
		private var selectedDefenseCard:int = 0;
		private var selectedSurrenderItem:int = 0;
		private var selectedAttackCard:int = 0;
	
		private var cardIndex:int = 0; // index of the card the player is selecting
		private var playerWalk:Vector.<BoardPosition>; // the squares that the player is walking this turn
		private var playerPossibleMoves:Vector.<BoardPosition>; // the squares that the player could walk to this turn
		private var playerPossibleWalks:Vector.<Vector.<Vector.<Vector.<BoardPosition>>>>; // the board, where each square is possible walks to that square this turn
		
		private var moveTimer:int = 0; 
		public var overlaysQueue:Vector.<GraphicOverlay>;		
		protected var textCache:Dictionary;
		
		public function Board() 
		{
			initNewGame();
		}	
		
		public function initNewGame():void
		{
			textCache = null; // clear the text cache
			
			createNewDeck();
			
			enemies = new Vector.<Enemy>();
			initBoard();
			initPlayers();
			
			playerTurn = players.length - 1;
			changeState(Constants.GSTATE_STARTTURN);
			
			playerHudType = Constants.PLAYERHUD_TYPE_CARDS;
			
			overlaysQueue = new Vector.<GraphicOverlay>();
			
			queueOverlay(new OverlayKeyItemNotif(keyItemId));
			
			// TODO - decide first player
			// TODO - you turned off flash debugger in tools to increase framerate. LMK if this is weird
		}
		
		public function createNewDeck():void
		{
			deck = new Vector.<BoardCard>();
			
			// TODO - make the card class less BS please
			for each (var cardData:Array in Constants.DECK_BASE)
			{
				for (var i:int = 0; i < cardData[Constants.DECK_CARD_COUNT]; i++) {
					deck.push(BoardCard.BoardCardFromArray(cardData[Constants.DECK_CARD_DATA]));
				}	
			}
			
			FP.shuffle(deck);
		}
		
		public function initPlayers():void 
		{
			// TODO: move persistence of player stats somewhere, maybe load file in Player creation
			
			players = [];
			
			var maxPlayerLevel:int = 0;
			
			for (var i:int = 0; i < Constants.PLAYER_COUNT; i++)
			{
				var newPlayer:Player = new Player(i, "Player " + (i+1), getEmptySpaceOnBoard());
				
				for (var j:int = 0; j < Constants.HAND_CARD_LIMIT; j++)
					newPlayer.giveCard(dealCardFromDeck());
				
				if (newPlayer.level > maxPlayerLevel) {
					maxPlayerLevel = newPlayer.level;
				}
				
				players.push(newPlayer);
			}
			
			for (i = 0; i < Constants.PLAYER_COUNT; i++)
			{ 
				var player:Player = players[i];
				player.setHandicapFromMaxLevel(maxPlayerLevel);
				
				player.initUX();
			}
		}
		
		public function initBoard():void
		{
			trace("Initializing the board.");
			
			// Define the board geography
			var boardRows:int = 14;
			var boardCols:int = 14;
			var boardInitStyle:int = 1;
			switch (boardInitStyle) {
				case 0: // all spaces exist and are empty
					board = new Vector.<Vector.<BoardSpace>>(boardRows, true);
					for (var i:int = 0; i < boardRows; i++)
					{
						board[i] = new Vector.<BoardSpace>(boardCols, true);
						for (var j:int = 0; j < boardCols; j++)
						{
							board[i][j] = new BoardSpace(Constants.BOARD_EMPTY, 0);
						}
					}
					break;
					
				case 1: // remove random 'lakes' as if you're playing minesweeper				
					var boardValid:Boolean = false;
					while (!boardValid) {
						// fill in the board entirely
						board = new Vector.<Vector.<BoardSpace>>(boardRows, true);
						for (i = 0; i < boardRows; i++)
						{
							board[i] = new Vector.<BoardSpace>(boardCols, true);
							for (j = 0; j < boardCols; j++)
							{
								board[i][j] = new BoardSpace(Constants.BOARD_EMPTY, 0);
							}
						}
						
						var lakesCreated:int = 0;
						var lakeSquares:int = 0;
						while (FP.random * (2 * (Math.max(board.length, board[0].length) - lakesCreated)) > 1) { // TODO: tweak this BS formula
							var holeX:int = FP.rand(board.length);
							var holeY:int = FP.rand(board[0].length);
							var spacesInLake:int = 0;
							
							if (getSpace(holeX, holeY).type == Constants.BOARD_EMPTY) {
								var holePos:BoardPosition = new BoardPosition(holeX, holeY);
								var holeStack:Vector.<BoardPosition> = new Vector.<BoardPosition>();
								holeStack.push(holePos);
								
								while (holeStack.length > 0) {
									FP.shuffle(holeStack);
									holePos = holeStack.pop();
									spacesInLake += 1;
									
									if (isValidSpace(holePos) &&
										board[holePos.row][holePos.col].type == Constants.BOARD_EMPTY) {
										board[holePos.row][holePos.col].changeTo(Constants.BOARD_NULL, 0);
										lakeSquares++;
										
										if (FP.random / spacesInLake > 0.1) { // TODO: more bs numbers
											var nextDirection:Vector.<BoardPosition> = new Vector.<BoardPosition>();
											nextDirection.push(new BoardPosition(holePos.row - 1, holePos.col));
											nextDirection.push(new BoardPosition(holePos.row + 1, holePos.col));
											nextDirection.push(new BoardPosition(holePos.row, holePos.col - 1));
											nextDirection.push(new BoardPosition(holePos.row - 1, holePos.col + 1));
											FP.shuffle(nextDirection);
											
											for (var kk:int = 0; kk < nextDirection.length; kk++) {
												if (FP.random > 0.75) {
													holeStack.push(nextDirection[kk]);
												}
											}
										}
									}
								}

								lakesCreated++;
							}
						}
						
						if (lakesCreated >= 6 && lakeSquares > 30) { // otherwise this board is boring
							boardValid = isBoardValid(board);
						}
					}
					break;
			}
			
			// Place the exit
			var emptySpace:BoardPosition = getEmptySpaceOnBoard();
			board[emptySpace.row][emptySpace.col] = new BoardSpace(Constants.BOARD_EXIT, 0);
			exitSpace = emptySpace.deepCopy();
			
			// Place the treasures
			var allTreasureIdsOnBoard:Array = [];
			for (i = 0; i < Constants.BOARD_BOX_COUNT; i++)
			{
				// pick a treasure that's not on the board already
				// TODO: weighted rarity
				var randomTreasureId:int = FP.choose(Constants.TREASURE_DB)[0];
				while (allTreasureIdsOnBoard.indexOf(randomTreasureId) != -1) {
					randomTreasureId = FP.choose(Constants.TREASURE_DB)[0];
				}
				allTreasureIdsOnBoard.push(randomTreasureId);
				
				if (i == 0) {
					keyItemId = randomTreasureId;
				}
				
				emptySpace = getEmptySpaceOnBoard();
				board[emptySpace.row][emptySpace.col] = new BoardSpace(Constants.BOARD_BOX, randomTreasureId);
			}
			
			// Place the flags
			for (i = 0; i < Constants.BOARD_FLAG_COUNT; i++)
			{
				emptySpace = getEmptySpaceOnBoard();
				board[emptySpace.row][emptySpace.col] = new BoardSpace(Constants.BOARD_FLAG, i);
			}
		}
		
				
		// Pops the top card off the deck and returns it
		public function dealCardFromDeck():BoardCard
		{
			if (deck.length == 0) {
				//trace("Deck is empty!");
				return null;
			}
			
			// I'm not sure if this is the "top" or "bottom" of deck but as long as we're consistent
			return deck.pop();
		}
		
		// Gets a random empty board location and returns it as an x-y pair
		public function getEmptySpaceOnBoard():BoardPosition {
			return getEmptySpaceOnSpecificBoard(board);
		}
		
		public function getEmptySpaceOnSpecificBoard(thisBoard:Vector.<Vector.<BoardSpace>>):BoardPosition
		{
			var row:int = -1;
			var col:int = -1;
			var tries:int = 0;
			
			while (row < 0 || col < 0 || thisBoard[row][col].type != Constants.BOARD_EMPTY || isPlayerSpace(new BoardPosition(row, col)) || isEnemySpace(new BoardPosition(row, col)))
			{
				row = FP.rand(thisBoard.length);
				col = FP.rand(thisBoard[0].length);
				
				tries++;
				if (tries > 100000)
				{
					trace("Couldn't find an empty space on the board!");
					row = -1;
					col = -1;
					break;
				}
			}
			
			return new BoardPosition(row, col);
		}
		
		// checks if you're colliding with a player
		public function isPlayerSpace(space:BoardPosition):Boolean
		{
			for (var i:int = 0; i < players.length; i++)
			{
				var player:Player = players[i];
				var playerPos:BoardPosition = player.getPosition();
				if (space.row == playerPos.row && space.col == playerPos.col)
					return true;
			}
			
			return false;
		}
		
		// checks if you're colliding with an enemy
		public function isEnemySpace(space:BoardPosition):Boolean
		{
			for (var i:int = 0; i < enemies.length; i++)
			{
				var enemy:Player = enemies[i];
				var enemyPos:BoardPosition = enemy.getPosition();
				if (space.row == enemyPos.row && space.col == enemyPos.col)
					return true;
			}
			
			return false;
		}
		
		public function playerAtSpace(space:BoardPosition):Player
		{
			for (var i:int = 0; i < players.length; i++)
			{
				var player:Player = players[i];
				var playerPos:BoardPosition = player.getPosition();
				if (space.row == playerPos.row && space.col == playerPos.col)
					return player;
			}
			
			return null;
		}
		
		public function playerOrEnemyAtSpace(space:BoardPosition):Player
		{
			for (var i:int = 0; i < players.length; i++)
			{
				var player:Player = players[i];
				var playerPos:BoardPosition = player.getPosition();
				if (space.row == playerPos.row && space.col == playerPos.col)
					return player;
			}
			
			for (i = 0; i < enemies.length; i++)
			{
				var enemy:Player = enemies[i];
				var enemyPos:BoardPosition = enemy.getPosition();
				if (space.row == enemyPos.row && space.col == enemyPos.col)
					return enemy;
			}
			
			return null;
		}
		
		public function isValidSpace(space:BoardPosition):Boolean {
			if (space.row < 0 || space.row >= board.length)
				return false;
			if (space.col < 0 || space.col >= board[0].length)
				return false;
				
			return true;
		}
		
		// returns true if you can move to that space
		public function isMoveableSpace(space:BoardPosition):Boolean
		{
			if (space.row < 0 || space.row >= board.length)
				return false;
			if (space.col < 0 || space.col >= board[0].length)
				return false;
			if (isPlayerSpace(space)) // can't move to where other players are
				return false;
			if (isEnemySpace(space)) 
				return false;
			
			// can't move to invalid squares
			var unmovableSpaces:Array = [Constants.BOARD_NULL];
			for each (var spaceType:int in unmovableSpaces)
			{
				if (getSpace(space.row,space.col).type == spaceType)
					return false;
			}

			return true;
		}
		
		public function isEmptySpace(space:BoardPosition):Boolean
		{
			if (!isMoveableSpace(space))
				return false;
			if (getSpace(space.row,space.col).type != Constants.BOARD_EMPTY)
				return false;

			return true;
		}
		
		public function changeState(newState:int):void
		{
			switch (newState) // do any Enter State logic
			{
				case Constants.GSTATE_STARTTURN:
					// "NEXT TURN"
					playerTurn++;
					if (playerTurn >= players.length)
						playerTurn = 0;
					
					var curPlayer:Player = players[playerTurn];
					curPlayer.prepareForTurn();
						
					// give them a card if there is one and they need one
					var cards:Vector.<BoardCard> = players[playerTurn].getCards();
					if (cards.length < Constants.HAND_CARD_LIMIT && deck.length > 0)
					{
						players[playerTurn].giveCard(dealCardFromDeck());
					}
					
					playerPossibleWalks = new Vector.<Vector.<Vector.<Vector.<BoardPosition>>>>(board.length, true);
					playerPossibleMoves = new Vector.<BoardPosition>();
					playerWalk = new Vector.<BoardPosition>();
					attackPlayer = null;
					defensePlayer = null;
					break;
					
				case Constants.GSTATE_SELECTACTION:
					break;
					
				case Constants.GSTATE_SELECTCARD:
					// state-specific stuff
					cardIndex = -1;
					break;
									
				case Constants.GSTATE_DOROLL:
					// use the card selected, if one was picked
					if (cardIndex >= 0)
					{
						players[playerTurn].activateCardOnBoard(cardIndex);
					}
					
					//state-specific stuff
					playerWalk = new Vector.<BoardPosition>(); // the squares the current player is walking this turn
					curPlayer = players[playerTurn];
					var playerRoll:int = curPlayer.doMovementRoll();
					
					playerPossibleMoves = getPlayerPossibleMoves(); // the squares the current player could move to this turn
					
					queueOverlay(curPlayer.createMovementRollOverlay()); // TODO: pass it a roll
					break;
					
				case Constants.GSTATE_SELECTMOVE:
					break;
					
				case Constants.GSTATE_MOVING:
					playerPossibleMoves = new Vector.<BoardPosition>();
					playerPossibleWalks = new Vector.<Vector.<Vector.<Vector.<BoardPosition>>>>(board.length, true);
					moveTimer = Constants.FRAMES_BETWEEN_SQUARES_MOVED; // set the time for each move
					break;
					
				case Constants.GSTATE_ACTIVATESPACE:
					break;
					
				case Constants.GSTATE_COMBAT_DEFENSE_SELECT:
					selectedDefenseOption = 0;
					selectedDefenseCard = -1;
					selectedAttackCard = -1;
					selectedSurrenderItem = 0;
					break;
					
				case Constants.GSTATE_COMBAT_DEFENSE_SELECTSURRENDER:
					break;
					
				case Constants.GSTATE_COMBAT_DEFENSE_SELECTCARD:
					break;
					
				case Constants.GSTATE_COMBAT_OFFENSE_SELECTCARD:
					break;
					
				case Constants.GSTATE_COMBAT_RESOLVE:
					performCombat();
					attackPlayer.initUX();
					defensePlayer.initUX(); // will happen automatically for attack player
					break;
				
				case Constants.GSTATE_COMBAT_DEFEATED_SELECTREWARD:
					selectedSurrenderItem = -1;
					break;
					
				case Constants.GSTATE_DOROLL:
					break;
					
				case Constants.GSTATE_ENDTURN:
					if (Math.random() < 0.5) { // TODO: change constant
						addEnemyToBoard();
					}
					break;
			}

			gameState = newState;
		}
		
		override public function update():void
		{
			var inputArray:Array = getInputArray();
			
			// global key things
			
			if (inputArray[Constants.KEY_DEBUG] == Constants.INPUT_PRESSED) // debug button
			{
				initNewGame();
				return;
			}
			
			if (overlaysQueue.length > 0) {
				var overlay:GraphicOverlay = overlaysQueue[0];
				overlay.update(inputArray);
				if (overlay.isDoneShowing()) {
					overlaysQueue.splice(0, 1); // remove the first overlay when it's done
				}
				
				return; // don't update anything while showing overlays
			}
			
			if (inputArray[Constants.KEY_FIRE5] == Constants.INPUT_PRESSED) { // toggle player HUD display
				playerHudType += 1;
				if (playerHudType >= Constants.PLAYERHUD_TYPES.length) {
					playerHudType = 0;
				}
			}
			
			if (inputArray[Constants.KEY_FIRE6] == Constants.INPUT_DOWN) // if we're holding down the camera button
			{
				update_moveCamera(inputArray);
				return;
			}
			
			switch (gameState)
			{
				case Constants.GSTATE_STARTTURN:
					update_startTurn(inputArray);
					
				case Constants.GSTATE_SELECTACTION: // what will you do this turn
					update_selectAction(inputArray);
					break;
					
				case Constants.GSTATE_SELECTCARD: // player is picking a card to play
					update_playerCard(inputArray);
					break;
					
				case Constants.GSTATE_DOROLL: // player is rolling the dice
					update_doRoll(inputArray);
					
				case Constants.GSTATE_SELECTMOVE: // player is deciding where to move
					update_playerMove(inputArray);
					break;
					
				case Constants.GSTATE_MOVING: // the player's move is being performed
					update_moving(inputArray);
					break;
					
				case Constants.GSTATE_ACTIVATESPACE: // the player actually lands on the space and does whatever
					update_activateSpace(inputArray);
					break;
					
				case Constants.GSTATE_COMBAT_DEFENSE_SELECT: // defense is selecting action for combat
					update_combatDefenseSelect(inputArray);
					break;
					
				case Constants.GSTATE_COMBAT_DEFENSE_SELECTSURRENDER:
					update_combatDefenseSelectSurrender(inputArray);
					break;
					
				case Constants.GSTATE_COMBAT_DEFENSE_SELECTCARD: // defense is selecting card for combat
					update_combatDefenseSelectCard(inputArray);
					break;
					
				case Constants.GSTATE_COMBAT_OFFENSE_SELECTCARD: // attack is selecting card for combat
					update_combatOffenseSelectCard(inputArray);
					break;
					
				case Constants.GSTATE_COMBAT_RESOLVE:
					update_combatResolve(inputArray);
					break;
					
				case Constants.GSTATE_COMBAT_DEFEATED_SELECTREWARD:
					update_combatSelectRewards(inputArray);
					break;
					
				case Constants.GSTATE_DOREST:
					update_doRest(inputArray);
					break;
					
				case Constants.GSTATE_ENDTURN: // end turn cleanup
					update_endTurn(inputArray);
					break;
			}
		}
		
		override public function render():void
		{
			super.render();
			
			// TODO - optimize the hell out of everything
			
			// TODO - draw BG
			Draw.rect(0, 0, 800, 600, 0xEEEEEE, 1);
			
			// draw the board
			var boardAlpha:Number = 1;
			if (gameStateIsCombat()) { // dim the board if combat is happening
				boardAlpha = 0.2;
			}
			
			var boardX:int = 16;
			var boardY:int = 16;
			var tileSize:int = 32; // TODO - make this less fragile
			
			for (var i:int = startRow; i < startRow + viewRows; i++)
			{
				for (var j:int = startCol; j < startCol + viewCols; j++)
				{
					if (i >= board.length || j >= board[0].length)
						continue;
						
					var sprite:int = getSpace(i, j).type;
					var frame:int = getSpace(i, j).value;
					if (sprite == Constants.BOARD_BOX) // don't use the treasure value as the frame, use only frame 0
						frame = 0; // TODO - different looking boxes idk refactor that
					
					var boardSprite:Image = Constants.BOARD_SPRITES[sprite][frame];
					boardSprite.alpha = boardAlpha;
					Draw.graphic(boardSprite, boardX + (j - startCol) * tileSize, boardY + (i - startRow) * tileSize);
				}
			}
			
			// draw the scrollbars
			// TODO - hahaha this math is messy as hell
			var scrollbarSize:int = 8;
			if (viewRows < board.length)
			{
				var horizHeight:Number = (1.0 * tileSize * viewRows) * (1.0 * viewRows / board.length);
				var horizX:int = boardX - scrollbarSize;
				var horizY:int = boardY + ((1.0 * tileSize * viewRows) - horizHeight) * (startRow / (board.length - viewRows));
				Draw.rect(horizX, horizY, scrollbarSize, horizHeight, 0x444444, boardAlpha);
			}
			if (viewCols < board[0].length)
			{
				var vertWidth:Number = (1.0 * tileSize * viewCols) * (1.0 * viewCols / board[0].length);
				var vertX:int = boardX + ((1.0 * tileSize * viewCols) - vertWidth) * (startCol / (board[0].length - viewCols));
				var vertY:int = boardY + (tileSize * viewRows);
				Draw.rect(vertX, vertY, vertWidth, scrollbarSize, 0x444444, boardAlpha);
			}
			
			// draw the players on the board
			for (i = 0; i < players.length; i++)
			{
				var player:Player = players[i];
				var playerPos:BoardPosition = player.getPosition();
				
				// adjust for the viewport
				playerPos.row -= startRow;
				playerPos.col -= startCol;
				if (playerPos.row >= 0 && playerPos.row < viewRows) {
					if (playerPos.col >= 0 && playerPos.col < viewCols) {
						var playerSprite:Image = players[i].getPlayerSprite();
						playerSprite.alpha = boardAlpha;
						Draw.graphic(playerSprite, boardX + playerPos.col * tileSize, boardY + playerPos.row * tileSize);
					}
				}
			}
			
			// draw the enemies on the board
			for (i = 0; i < enemies.length; i++)
			{
				var enemy:Player = enemies[i];
				var enemyPos:BoardPosition = enemy.getPosition();
				
				// adjust for the viewport
				enemyPos.row -= startRow;
				enemyPos.col -= startCol;
				if (enemyPos.row >= 0 && enemyPos.row < viewRows) {
					if (enemyPos.col >= 0 && enemyPos.col < viewCols) {
						var enemySprite:Image = enemies[i].getPlayerSprite();
						enemySprite.alpha = boardAlpha;
						Draw.graphic(enemySprite, boardX + enemyPos.col * tileSize, boardY + enemyPos.row * tileSize);
					}
				}
			}
			
			// draw board highlights and stuff
			for each (var space:BoardPosition in playerPossibleMoves) // draw the path the player can walk to
			{
				// TODO - make this nicer or not hardcoded (this is just stolen from below)
				var spaceCopy:BoardPosition = space.deepCopy();
				// adjust for the viewport
				spaceCopy.row -= startRow;
				spaceCopy.col -= startCol;
				if (spaceCopy.row >= 0 && spaceCopy.row < viewRows)
					if (spaceCopy.col >= 0 && spaceCopy.col < viewCols)
						Draw.rect(boardX + spaceCopy.col * tileSize, boardY + spaceCopy.row * tileSize, tileSize, tileSize, 0x0000FF, 0.25 * boardAlpha);
			}
			
			for each (space in playerWalk) // draw the path the player is walking
			{
				// TODO - make this nicer or not hardcoded
				spaceCopy = space.deepCopy();
				// adjust for the viewport
				spaceCopy.row -= startRow;
				spaceCopy.col -= startCol;
				var color:uint = 0x0000FF;
				if (playerWalk.indexOf(space) == playerWalk.length - 1) // last tile in walk
					color = 0x00FFFF;
				if (spaceCopy.row >= 0 && spaceCopy.row < viewRows)
					if (spaceCopy.col >= 0 && spaceCopy.col < viewCols)
						Draw.rect(boardX + spaceCopy.col * tileSize, boardY + spaceCopy.row * tileSize, tileSize, tileSize, color, 0.5 * boardAlpha);
			}
			
			// draw combat overlay if battle is happening
			var combatX:int = 24;
			var combatY:int = 24;
			if (gameStateIsCombat() && gameState == Constants.GSTATE_COMBAT_DEFEATED_SELECTREWARD) { // draw specialized post-battle stuff
				var defeatedString:String = attackPlayer.getName() + " defeated " + defensePlayer.getName() + "!"
				var defeatedString2:String = "Select an item to take from them.";
				Draw.graphic(getText(defeatedString, 24, 0x000000), combatX, combatY);
				combatY += 32;
				Draw.graphic(getText(defeatedString2, 24, 0x000000), combatX, combatY);
				combatY += 16;
				
				// draw defense items that you can steal from
				var dItems:Vector.<BoardItem> = defensePlayer.getItems();
				if (dItems.length <= 4) { // 4 items or less 
					for (j = 0; j < dItems.length + 1; j++) {
						var dItemId:int = j - 1;
						if (dItemId >= 0) {
							var dItem:BoardItem = dItems[dItemId];
							var dItemImage:Image = dItem.image;
						} else {
							dItem = null;
							dItemImage = Constants.IMG_ITEM_NOITEM;
						}
						dItemImage.scale = 0.5; // TODO - hack while i figure card size out (128 / 2 = 64)
						dItemImage.alpha = 1;
						var dItemY:int = combatY + 32;
						if (dItemId == selectedSurrenderItem) {
							Draw.rect(combatX + 72 * j, dItemY, 72, 72, 0xFFFF00, 1);
						}
						
						if (dItem != null && dItem.id == keyItemId && dItem.fromThisBoard) {
							Draw.rect(combatX + 72 * j + 8, dItemY + 8, 56, 56, 0xFF0000, 0.5);
						}
						Draw.graphic(dItemImage, combatX + 72 * j, dItemY);
					}
				} else { // 8 items or less (TODO: if you have more then whoops)
					for (j = 0; j < dItems.length + 1; j++) {
						dItemId = j - 1;
						if (dItemId >= 0) {
							dItem = dItems[dItemId];
							dItem = dItems[dItemId];
							dItemImage = dItem.image;
						} else {
							dItem = null;
							dItemImage = Constants.IMG_ITEM_NOITEM;
						}
						dItemImage.scale = 0.25; // TODO - hack while i figure card size out (128 / 4 = 32)
						dItemImage.alpha = 1;
						dItemY = combatY + 16;
						if (dItemId == selectedSurrenderItem) {
							Draw.rect(combatX + 36 * j, dItemY, 36, 36, 0xFFFF00, 1);
						}
						
						if (dItem != null && dItem.id == keyItemId && dItem.fromThisBoard) {
							Draw.rect(combatX + 36 * j + 4, dItemY + 4, 28, 28, 0xFF0000, 0.5);
						}
						Draw.graphic(dItemImage, combatX + 36 * j, dItemY);
					}
				} 
			} else if (gameStateIsCombat()) {				
				// draw defender
				playerSprite = defensePlayer.getPlayerSprite();
				playerSprite.alpha = 1;
				Draw.graphic(playerSprite, combatX, combatY);
				combatY += 40;
				
				// draw defense options
				var defenseOptionAlpha:Number = gameState == (Constants.GSTATE_COMBAT_DEFENSE_SELECT) ? 1 : 0.5;
				for (i = 0; i < Constants.COMBAT_DEFENSE_OPTIONIMAGES.length; i++) {
					var optionSprite:Image = Constants.COMBAT_DEFENSE_OPTIONIMAGES[i];
					optionSprite.scale = 0.5;
					optionSprite.alpha = defenseOptionAlpha;
					
					if (i == selectedDefenseOption) {
						Draw.rect(combatX + 68 * i, combatY, 72, 72, 0xFFFF00, defenseOptionAlpha);
					}
					
					Draw.graphic(optionSprite, combatX + 68 * i, combatY);
				}
				combatY += 80;
				
				if (selectedDefenseOption == Constants.COMBAT_DEFENSE_SURRENDER) {
					var itemSurrenderAlpha:Number = gameState == (Constants.GSTATE_COMBAT_DEFENSE_SELECTSURRENDER) ? 1 : 0.5;
					
					// draw defender items to surrender
					dItems = defensePlayer.getItems();
					if (dItems.length <= 4) { // 4 items or less 
						for (j = 0; j < dItems.length; j++) {
							dItem = dItems[j];
							dItemImage = dItem.image;
							dItemImage.scale = 0.5; // TODO - hack while i figure card size out (128 / 2 = 64)
							dItemImage.alpha = itemSurrenderAlpha;
							dItemY = combatY + 32;
							if (j == selectedSurrenderItem) {
								Draw.rect(combatX + 72 * j, dItemY, 72, 72, 0xFFFF00, itemSurrenderAlpha);
							}
							
							if (dItem.id == keyItemId && dItem.fromThisBoard) {
								Draw.rect(combatX + 72 * j + 8, dItemY + 8, 56, 56, 0xFF0000, itemSurrenderAlpha * 0.5);
							}
							Draw.graphic(dItemImage, combatX + 72 * j, dItemY);
						}
					} else { // 8 items or less (TODO: if you have more then whoops)
						for (j = 0; j < dItems.length; j++) {
							dItem = dItems[j];
							dItemImage = dItem.image;
							dItemImage.scale = 0.25; // TODO - hack while i figure card size out (128 / 4 = 32)
							dItemImage.alpha = itemSurrenderAlpha;
							dItemY = combatY + 16;
							if (j == selectedSurrenderItem) {
								Draw.rect(combatX + 36 * j, dItemY, 36, 36, 0xFFFF00, itemSurrenderAlpha);
							}
							
							if (dItem.id == keyItemId && dItem.fromThisBoard) {
								Draw.rect(combatX + 36 * j + 4, dItemY + 4, 28, 28, 0xFF0000, itemSurrenderAlpha * 0.5);
							}
							Draw.graphic(dItemImage, combatX + 36 * j, dItemY);
						}
					} 
				} else {
					// draw defender hand
					var defenseCardAlpha:Number = gameState == (Constants.GSTATE_COMBAT_DEFENSE_SELECTCARD) ? 1 : 0.5; 
					var dCards:Vector.<BoardCard> = defensePlayer.getCards();
					for (j = -1; j < dCards.length; j++)
					{
						var dCardImage:Image = Constants.IMG_NO_CARD;
						if (j >= 0) {
							dCardImage = dCards[j].image;
						}
						dCardImage.scale = 0.75; // TODO - hack while i figure card size out
						dCardImage.alpha = defenseCardAlpha;
						if (j >= 0 && !canUseCardForCombat(dCards[j], true)) { // dim it if it's not valid for combat
							dCardImage.alpha *= 0.33;
						}
						
						var dCardY:int = combatY + 20;
						if (selectedDefenseCard == j) // if it's the card selected
							dCardY = combatY;
						Draw.graphic(dCardImage, combatX + 68 * (j + 1), dCardY);
					}
					combatY += 108;
					
					// draw attacker
					playerSprite = attackPlayer.getPlayerSprite();
					playerSprite.alpha = 1;
					Draw.graphic(playerSprite, combatX, combatY);
					combatY += 40;
					
					// draw attacker hand
					var attackCardAlpha:Number = gameState == (Constants.GSTATE_COMBAT_OFFENSE_SELECTCARD) ? 1 : 0.5; 
					var aCards:Vector.<BoardCard> = attackPlayer.getCards();
					for (j = -1; j < aCards.length; j++)
					{
						var aCardImage:Image = Constants.IMG_NO_CARD;
						if (j >= 0) {
							aCardImage = aCards[j].image;
						}
						aCardImage.scale = 0.75; // TODO - hack while i figure card size out
						aCardImage.alpha = attackCardAlpha;
						if (j >= 0 && !canUseCardForCombat(aCards[j], false)) { // dim it if it's not valid for combat
							aCardImage.alpha *= 0.33;
						}
						
						var aCardY:int = combatY + 20;
						if (selectedAttackCard == j) // if it's the card selected
							aCardY = combatY;
						Draw.graphic(aCardImage, combatX + 68 * (j + 1), aCardY);
					}
					combatY += 84;
				}
			}
			
			// draw the HUD
			var hudX:int = 800 - 320 + 16;
			var hudY:int = 16;
			
			var playerHudHeight:int = 130;
			var playerHudMargin:int = 16;
			for (i = 0; i < players.length; i++)
			{
				// TODO - move into own class so it's not massive lag
				player = players[i];
				var cards:Vector.<BoardCard> = player.getCards();
				var items:Vector.<BoardItem> = player.getItems();
				
				var playerY:int = hudY + (playerHudHeight + playerHudMargin) * i;
				
				// TODO - letters are cut off because hilarity
				var headerStr:Text = player.getHeaderStr();
				headerStr.color = 0x000000;
					
				headerStr.alpha = 1;
				if (i == playerTurn) { // draw highlight if it's their turn
					Draw.rect(hudX - 8, playerY , 296, 148, Constants.PLAYER_IMAGECOLORS[i], 0.66);
				}
				if (playerHasKeyItem(player)) { // draw highlight if they have key item 
					Draw.rect(hudX, playerY+8, 208, 16, 0xFFFF00, 1);
				}
				Draw.graphic(headerStr, hudX, playerY);
				Draw.graphic(player.getHpStr(), hudX + 208, playerY);
				Draw.graphic(player.getStatStr(), hudX, playerY + 16);
				Draw.graphic(player.getPointsStr(), hudX + 208, playerY + 16);
				
				switch (playerHudType) {
					case Constants.PLAYERHUD_TYPE_CARDS:
						// draw their hand
						var offsetToDrawNoCard:int = (playerTurn == i)? 1 : 0; // draw the Nocard card if you're picking currently
						var offsetToDrawRestCard:int = (playerTurn == i)? 1 : 0; 
						for (j = 0 - offsetToDrawNoCard; j < cards.length + offsetToDrawRestCard; j++)
						{
							var cardImage:Image = Constants.IMG_NO_CARD;
							if (j == cards.length) {
								cardImage = Constants.IMG_REST_CARD;
							} else if (j >= 0) {
								cardImage = cards[j].image;
							}
							cardImage.scale = 0.75; // TODO - hack while i figure card size out
							cardImage.alpha = 1;
							
							var cardY:int = playerY + 40 + 20;
							if (gameState == Constants.GSTATE_SELECTCARD && i == playerTurn
								&& j == cardIndex) // if it's the card selected
									cardY = playerY + 40;
							Draw.graphic(cardImage, hudX + 36 * (j + offsetToDrawNoCard), cardY);
						}
						break;
						
					case Constants.PLAYERHUD_TYPE_ITEMS:
						// draw their items
						if (items.length <= 4) { // 4 items or less 
							for (j = 0; j < items.length; j++) {
								var item:BoardItem = items[j];
								var itemImage:Image = item.image;
								itemImage.scale = 0.5; // TODO - hack while i figure card size out (128 / 2 = 64)
								itemImage.alpha = 1;
								var itemY:int = playerY + 40;
								
								if (item.id == keyItemId && item.fromThisBoard) {
									Draw.rect(hudX + 72 * j, itemY, 72, 72, 0xFF0000, 0.5);
								}
								Draw.graphic(itemImage, hudX + 72 * j, itemY);
							}
						} else { // 8 items or less (TODO: if you have more then whoops)
							for (j = 0; j < items.length; j++) {
								item = items[j];
								itemImage = item.image;
								itemImage.alpha = 1;
								itemImage.scale = 0.25; // TODO - hack while i figure card size out (128 / 4 = 32)
								itemY = playerY + 40;
								
								if (item.id == keyItemId && item.fromThisBoard) {
									Draw.rect(hudX + 36 * j, itemY, 36, 36, 0xFF0000, 0.5);
								}
								Draw.graphic(itemImage, hudX + 36 * j, itemY);
							}
						} 
						break;
				}
				
			}
			
			// draw the first overlay in the queue
			if (overlaysQueue.length > 0) {
				var overlay:GraphicOverlay = overlaysQueue[0];
				
				overlay.render(0, 0);
			}
			
			// DEBUG TODO - output the framerate
			// Draw.graphic(new Text(FP.frameRate.toString()), 4, 4);
		}
		
		// Returns what keys were pressed this frame
		public function getInputArray():Array
		{
			var inputArray:Array = new Array(Constants.KEYMAP_ARRAY.length);
			for (var i:int = 0; i < Constants.KEYMAP_ARRAY.length; i++)
			{
				if (Input.pressed(Constants.KEYMAP_ARRAY[i])) // TODO - this should probably be an XOR
					inputArray[i] = Constants.INPUT_PRESSED;
				else if (Input.check(Constants.KEYMAP_ARRAY[i]))
					inputArray[i] = Constants.INPUT_DOWN;
				else
					inputArray[i] = Constants.INPUT_NEUTRAL;
			}
			
			return inputArray;
		}
		
		private function update_startTurn(inputArray:Array):void {
			changeState(Constants.GSTATE_SELECTACTION); // TODO: this state
		}
		
		private function update_selectAction(inputArray:Array):void {
			changeState(Constants.GSTATE_SELECTCARD); // TODO: this state
		}
		
		// handles updating for the game state where the player is picking what card to play when moving around the board
		private function update_playerCard(inputArray:Array):void
		{
			var curPlayer:Player = players[playerTurn];
			
			var cards:Vector.<BoardCard> = players[playerTurn].getCards();
			
			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED) // select a card
			{
				if (cardIndex == cards.length) {
					changeState(Constants.GSTATE_DOREST);
				} else {
					changeState(Constants.GSTATE_DOROLL);
				}
			}
			else if (curPlayer.isStunned()) // rest
			{
				// TODO: do resting
			}
			else if (cards.length > 0) // otherwise if they are still selecting their card
			{
				var cardMoveDirection:int = 0;
				var originalIndex:int = cardIndex;
				if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) 
				{
					cardMoveDirection = -1;
				}
				else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED)
				{
					cardMoveDirection = 1;
				}
				
				cardIndex += cardMoveDirection;
				while (cardMoveDirection != 0 && cardIndex != originalIndex 
						&& (cardIndex < -1 || cardIndex > cards.length || (cardIndex >= 0 && cardIndex < cards.length && !canUseCardForRoll(curPlayer.getCards()[cardIndex])))) {		
					cardIndex += cardMoveDirection;
					if (cardIndex > cards.length) // you can go one past end because of rest card
						cardIndex = Math.min(-1, originalIndex); 
					if (cardIndex < Math.min(-1, originalIndex))
						cardIndex = cards.length;
				}
			}
		}
		
		private function update_doRoll(inputArray:Array):void
		{
			var curPlayer:Player = players[playerTurn];
			var playerCard:BoardCard = curPlayer.getActivatedCardBoard();
			if (playerCard != null) {
				// if it was an exit card
				if (playerCard.type == Constants.CARD_MOVE && playerCard.value == Constants.MOVE_EXIT) {
					playerWalk.push(exitSpace);
					changeState(Constants.GSTATE_MOVING);
					return;
				}
				
				// if it was a trap card
				if (playerCard.type == Constants.CARD_TRAP) {
					var playerPos:BoardPosition = curPlayer.getPosition();
					var curSpace:BoardSpace = getSpace(playerPos.row, playerPos.col);
					// place the trap on the board
					if (curSpace.type != Constants.BOARD_EMPTY) {
						trace("Placing a trap on nonempty space??");
					}
					
					curSpace.changeTo(Constants.BOARD_TRAP, playerCard.value);
				}
			}
			
			changeState(Constants.GSTATE_SELECTMOVE);
		}
		
		// handles updating for the game state where the player is deciding where to move
		private function update_playerMove(inputArray:Array):void
		{			
			if (inputArray[Constants.KEY_FIRE3] == Constants.INPUT_DOWN) // if we're holding down the camera button
			{
				update_moveCamera(inputArray);
				return;
			}
			
			var curPlayer:Player = players[playerTurn];
			var newSquareSelected:Boolean = true;
			var newSquare:BoardPosition = new BoardPosition(-99, -99); // the square which we will start moving from
			var playerSpace:BoardPosition = players[playerTurn].getPosition();
			if (playerWalk.length == 0)
				newSquare = playerSpace;
			else
				newSquare = playerWalk[playerWalk.length - 1].deepCopy();

			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED)
			{
				if (playerWalk.length > 0 || playerPossibleMoves.length == 0) // if the player selected a valid move for this turn
				{
					changeState(Constants.GSTATE_MOVING);
					return;
				}
			}
			else if (inputArray[Constants.KEY_FIRE2] == Constants.INPUT_PRESSED) { // press back to go back one square
				playerWalk = playerWalk.slice(0, playerWalk.length - 1);
				return;
			}
			else if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) // otherwise if they are still selecting their move
				newSquare.col -= 1;
			else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED)
				newSquare.col += 1;
			else if (inputArray[Constants.KEY_UP] == Constants.INPUT_PRESSED)
				newSquare.row -= 1;
			else if (inputArray[Constants.KEY_DOWN] == Constants.INPUT_PRESSED)
				newSquare.row += 1;
			else	
				newSquareSelected = false; // if we didn't input anything we don't really care
			
			if (false) // TODO: remove manual walk selecting
			{
				if (newSquareSelected) // check to see if you zeroed out your move
				{
					if (newSquare.row == playerSpace.row && newSquare.col == playerSpace.col) //if you backtraced to the start
						playerWalk = playerWalk.slice(0, 0); // clear the walk
				}
				
				if (newSquareSelected && isMoveableSpace(newSquare)) // now let's talk about other walks
				{
					playerWalk.push(newSquare); // push the square onto the walk
						
					// truncate any loops in the walk
					for (var i:int = 0; i < playerWalk.length - 1; i++) // don't truncate last square
					{
						var walkSpace:Array = playerWalk[i];
						if (walkSpace.row == newSquare.row && walkSpace.col == newSquare.col)
						{
							playerWalk = playerWalk.slice(0, i + 1);
							break;
						}
					}
				}
				
				// shrink the walk to fit how much the player can move
				if (playerWalk.length > curPlayer.getMovementRollValue()) {
					playerWalk = playerWalk.slice(0, curPlayer.getMovementRollValue());
				}
			}
			
			if (newSquareSelected) // check to see if you zeroed out your move
			{
				if (newSquare.row == playerSpace.row && newSquare.col == playerSpace.col) //if you backtraced to the start
					playerWalk = playerWalk.slice(0, 0); // clear the walk
			}
				
			if (newSquareSelected && isValidSpace(newSquare) && playerPossibleWalks[newSquare.row][newSquare.col].length > 0) {
				playerWalk = playerPossibleWalks[newSquare.row][newSquare.col][0];
				//playerWalk = playerPossibleWalks[newSquare.row][newSquare.col][Math.floor(FP.rand(playerPossibleWalks[newSquare.row][newSquare.col].length))];
			}
		}
		
		// handles updating for when the player is moving towards their destination selected
		private function update_moving(inputArray:Array):void
		{
			if (moveTimer > 0)
				moveTimer--; //decrement the timer for moving
				
			if (moveTimer == 0)
			{
				if (playerWalk.length == 0)
				{
					changeState(Constants.GSTATE_ACTIVATESPACE);
					
					moveTimer = -1;
				}
				else
				{
					var curPlayer:Player = players[playerTurn];
					var newSquare:BoardPosition = playerWalk[0];
					playerWalk = playerWalk.slice(1, playerWalk.length);
					
					if (isPlayerSpace(newSquare) || isEnemySpace(newSquare)) { // you're moving onto someone 
						playerWalk = playerWalk.slice(0, 0); // stop moving
						
						// set up the attack. if it's still there after space resolution then fight
						attackPlayer = players[playerTurn];
						defensePlayer = playerOrEnemyAtSpace(newSquare);
					} else {
						curPlayer.incrementStepsWalked(1);
						curPlayer.moveToSpace(newSquare);
						
						// TODO: if the last thing you walk on is a trap it will always be activated. maybe fix
						if (getSpaceForPos(newSquare).type == Constants.BOARD_TRAP && playerWalk.length != 0) {
							var evaded:Boolean = curPlayer.rollToEvadeTrap();
							if (!evaded) {
								playerWalk = playerWalk.slice(0, 0); // whoops it seems your journey has ended here
							} else {
								queueOverlay(new OverlayActivateTrap(curPlayer, 0, evaded));
							}
						}
					}

					moveTimer = Constants.FRAMES_BETWEEN_SQUARES_MOVED;
				}
			}
			
			// no messing with the camera here
		}
		
		// handles updating for when the player is landing on a space and making a thing happen
		private function update_activateSpace(inputArray:Array):void
		{
			// TODO: maybe jump some of these to discrete states rather than instantaneous effects
			
			// no messing with the camera here
			
			var curPlayer:Player = players[playerTurn];
			var playerPos:BoardPosition = players[playerTurn].getPosition();
			var space:BoardSpace = getSpace(playerPos.row, playerPos.col).deepCopy();
			
			switch (space.type)
			{
				case Constants.BOARD_TRAP:
					curPlayer.sufferFromTrap(space.value);
					queueOverlay(new OverlayActivateTrap(curPlayer, space.value, false));
					
					board[playerPos.row][playerPos.col].changeTo(Constants.BOARD_EMPTY, 0); // empty out the space
					break;
					
				case Constants.BOARD_BOX:
					var treasureId:int = space.value;
					// TODO: check if it's key treasure and do things
					curPlayer.giveTreasureWithId(treasureId);					
					board[playerPos.row][playerPos.col].changeTo(Constants.BOARD_EMPTY, 0); // empty out the space
					
					queueOverlay(new OverlayGetItem(curPlayer, treasureId, treasureId == keyItemId));
					break;
					
				case Constants.BOARD_FLAG:
					// award flag points to player
					// TODO: some flags heal you or give extra turn???
					var flagType:int = Constants.FLAG_TYPE_POINTS;
					var flagPoints:int = Constants.FLAG_BASE_POINTS;
					
					var flagValue:int = Math.floor(FP.rand(6));
					if (flagValue == 5 && FP.random < 0.5) {
						flagValue = 1; // kick back from 8x to 1x
					}
					if (flagValue == 0) {
						// TODO: activate trap
					}
					
					flagPoints *= Constants.FLAG_MULTIPLIERS[flagValue];
					curPlayer.awardFlagPoints(flagPoints);
					
					queueOverlay(new OverlayGetFlag(curPlayer, flagType, flagValue));
					
					var newFlag:BoardPosition = getEmptySpaceOnBoard();
					board[playerPos.row][playerPos.col].changeTo(Constants.BOARD_EMPTY, 0); // empty out the old space
					board[newFlag.row][newFlag.col].changeTo(Constants.BOARD_FLAG, space.value); // jump the flag to the new place
					break;
					
				case Constants.BOARD_EXIT:
					if (playerHasKeyItem(players[playerTurn])) {
						// TODO: you win!!
						changeState(Constants.GSTATE_GAMEOVER); // TODO: end of game things
						playerTurn = -1;
						return;
					}
					
					// if you don't have the key item, jump to a random location
					players[playerTurn].moveToSpace(getEmptySpaceOnBoard()); 
					break;
			}
			
			// TODO: confirm attack and defense player are still adjacent
			if (attackPlayer != null && defensePlayer != null) {
				changeState(Constants.GSTATE_COMBAT_DEFENSE_SELECT);
			} else {
				changeState(Constants.GSTATE_ENDTURN);
			}
		}
		
		private function update_combatDefenseSelect(inputArray:Array):void {
			var maxDefenseOption:int = Constants.COMBAT_DEFENSE_OPTIONIMAGES.length - 1;
			if (defensePlayer.getItems().length == 0) { // nothing to surrender
				maxDefenseOption--; // lazy hack but we assume that surrender is always last option
			}
			
			// select which defense option will be used
			if (defensePlayer is Enemy) {
				selectedDefenseOption = Constants.COMBAT_DEFENSE_COUNTER;
				changeState(Constants.GSTATE_COMBAT_DEFENSE_SELECTCARD);
			} 
			else if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED)
			{
				if (selectedDefenseOption == Constants.COMBAT_DEFENSE_SURRENDER) {
					changeState(Constants.GSTATE_COMBAT_DEFENSE_SELECTSURRENDER);
				} else {
					changeState(Constants.GSTATE_COMBAT_DEFENSE_SELECTCARD);
				}
			}
			else if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) {
				selectedDefenseOption--;
				if (selectedDefenseOption < 0) {
					selectedDefenseOption = maxDefenseOption;
				}
			}
			else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED) {
				selectedDefenseOption++;
				if (selectedDefenseOption > maxDefenseOption) {
					selectedDefenseOption = 0;
				}
			}
		}
		
		private function update_combatDefenseSelectSurrender(inputArray:Array):void {
			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED)
			{
				changeState(Constants.GSTATE_COMBAT_RESOLVE);
			}
			else if (inputArray[Constants.KEY_FIRE2] == Constants.INPUT_PRESSED) { // press back to go back one option
				changeState(Constants.GSTATE_COMBAT_DEFENSE_SELECT);
				return;
			}
			else if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) {
				selectedSurrenderItem--;
				if (selectedSurrenderItem < 0) {
					selectedSurrenderItem = defensePlayer.getItems().length - 1;
				}
			}
			else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED) {
				selectedSurrenderItem++;
				if (selectedSurrenderItem > defensePlayer.getItems().length - 1) {
					selectedSurrenderItem = 0;
				}
			}
		}
		
		private function update_combatDefenseSelectCard(inputArray:Array):void {
			// select what defense card will be used
			if (defensePlayer is Enemy) {
				selectedDefenseCard = -1;
				changeState(Constants.GSTATE_COMBAT_OFFENSE_SELECTCARD);
			} 
			else if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED)
			{
				changeState(Constants.GSTATE_COMBAT_OFFENSE_SELECTCARD);
			}
			else if (inputArray[Constants.KEY_FIRE2] == Constants.INPUT_PRESSED) { // press back to go back one option
				changeState(Constants.GSTATE_COMBAT_DEFENSE_SELECT);
				return;
			}
			else if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED || inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED) {
				var cardMoveDirection:int = 0;
				if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) 
				{
					cardMoveDirection = -1;
				}
				else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED)
				{
					cardMoveDirection = 1;
				}
				
				selectedDefenseCard += cardMoveDirection;
				if (selectedDefenseCard >= defensePlayer.getCards().length) {
					selectedDefenseCard = -1;
				}
				if (selectedDefenseCard < -1) {
					selectedDefenseCard = defensePlayer.getCards().length - 1;
				}
				while (selectedDefenseCard != -1 && !canUseCardForCombat(defensePlayer.getCards()[selectedDefenseCard], true)) {
					selectedDefenseCard += cardMoveDirection;
					if (selectedDefenseCard >= defensePlayer.getCards().length) {
						selectedDefenseCard = -1;
					}
					if (selectedDefenseCard < -1) {
						selectedDefenseCard = defensePlayer.getCards().length - 1;
					}
				}
			}
		}
		
		private function update_combatOffenseSelectCard(inputArray:Array):void {
			// select what offense card will be used
			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED)
			{
				changeState(Constants.GSTATE_COMBAT_RESOLVE);
			}
			else if (inputArray[Constants.KEY_FIRE2] == Constants.INPUT_PRESSED && !(defensePlayer is Enemy)) { // press back to go back to defense again
				changeState(Constants.GSTATE_COMBAT_DEFENSE_SELECT);
				return;
			}
			else if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED || inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED) {
				var cardMoveDirection:int = 0;
				if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) 
				{
					cardMoveDirection = -1;
				}
				else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED)
				{
					cardMoveDirection = 1;
				}
				
				selectedAttackCard += cardMoveDirection;
				if (selectedAttackCard >= attackPlayer.getCards().length) {
					selectedAttackCard = -1;
				}
				if (selectedAttackCard < -1) {
					selectedAttackCard = attackPlayer.getCards().length - 1;
				}
				while (selectedAttackCard != -1 && !canUseCardForCombat(attackPlayer.getCards()[selectedAttackCard], false)) {
					selectedAttackCard += cardMoveDirection;
					if (selectedAttackCard >= attackPlayer.getCards().length) {
						selectedAttackCard = -1;
					}
					if (selectedAttackCard < -1) {
						selectedAttackCard = attackPlayer.getCards().length - 1;
					}
				}
			}
		}
		
		private function update_combatResolve(inputArray:Array):void {
			if (defensePlayer.getHp() <= 0) {// defense was defeated in combat. probably no double KOs 
				changeState(Constants.GSTATE_COMBAT_DEFEATED_SELECTREWARD);
			} else {
				changeState(Constants.GSTATE_ENDTURN);
			}
		}

		private function update_endTurn(inputArray:Array):void
		{
			// do end of turn cleanup
			var curPlayer:Player = players[playerTurn];
			curPlayer.finishTurn();
			
			changeState(Constants.GSTATE_STARTTURN);
		}
		
		// a non-state update, for when you're holding down the move button and want to move the camera
		private function update_moveCamera(inputArray:Array):void
		{
			// hold fire3 and press a direction to move the camera
			if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) // otherwise if they are still selecting their move
			{
				if (startCol > 0)
					startCol--;
			}
			else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED)
			{
				if (startCol + viewCols < board[0].length)
					startCol++;
			}
			else if (inputArray[Constants.KEY_UP] == Constants.INPUT_PRESSED)
			{
				if (startRow > 0)
					startRow--;
			}
			else if (inputArray[Constants.KEY_DOWN] == Constants.INPUT_PRESSED)
			{
				if (startRow + viewRows < board.length)
					startRow++;
			}
		}
		
		private function getPlayerPossibleMoves():Vector.<BoardPosition> {
			var curPlayer:Player = players[playerTurn];
			var curPosition:BoardPosition = curPlayer.getPosition();
			var playerRoll:int = curPlayer.getMovementRollValue(); 
			
			var dfsStack:Array = [];
			
			var markedSpaces:Array = new Array(board.length);
			for (var i:int = 0; i < board.length; i++)
			{
				markedSpaces[i] = new Array(board[0].length);
				for (var j:int = 0; j < board[0].length; j++)
				{
					markedSpaces[i][j] = 999999;
				}
			}
			
			// init possible walks (this is used to determine how you walks
			playerPossibleWalks = new Vector.<Vector.<Vector.<Vector.<BoardPosition>>>>(board.length, true);
			for (i = 0; i < board.length; i++)
			{
				playerPossibleWalks[i] = new Vector.<Vector.<Vector.<BoardPosition>>>(board[0].length);
				for (j = 0; j < board[0].length; j++)
				{
					playerPossibleWalks[i][j] = new Vector.<Vector.<BoardPosition>>();
				}
			}
			
			var startPos:BoardPosition = new BoardPosition(curPosition.row - 1, curPosition.col);
			var startWalk:Vector.<BoardPosition> = new Vector.<BoardPosition>();
			startWalk.push(startPos);
			dfsStack.push([startPos, startWalk]); 
			
			startPos = new BoardPosition(curPosition.row + 1, curPosition.col);
			startWalk = new Vector.<BoardPosition>();
			startWalk.push(startPos);
			dfsStack.push([startPos, startWalk]); 
			
			startPos = new BoardPosition(curPosition.row, curPosition.col - 1);
			startWalk = new Vector.<BoardPosition>();
			startWalk.push(startPos);
			dfsStack.push([startPos, startWalk]); 
			
			startPos = new BoardPosition(curPosition.row, curPosition.col + 1);
			startWalk = new Vector.<BoardPosition>();
			startWalk.push(startPos);
			dfsStack.push([startPos, startWalk]); 
			
			while (dfsStack.length > 0) {
				var curNode:Array = dfsStack.pop();
				var curWalk:Vector.<BoardPosition> = curNode[1];
				var curSpace:BoardPosition = curNode[0];
				
				if (curWalk.length <= playerRoll) { // spaces left to move (yes this is off by one because of bad loop logic)
					if (isMoveableSpace(curSpace)) {
						playerPossibleWalks[curSpace.row][curSpace.col].push(curWalk);

						if (curWalk.length < markedSpaces[curSpace.row][curSpace.col]) {
							markedSpaces[curSpace.row][curSpace.col] = curWalk.length;
						
							var newPos:BoardPosition = new BoardPosition(curSpace.row - 1, curSpace.col);
							var newWalk:Vector.<BoardPosition> = Constants.deepCopyBoardPositionVector(curWalk);
							newWalk.push(newPos);
							dfsStack.push([newPos, newWalk]); 
							
							newPos = new BoardPosition(curSpace.row + 1, curSpace.col);
							newWalk = Constants.deepCopyBoardPositionVector(curWalk);
							newWalk.push(newPos);
							dfsStack.push([newPos, newWalk]); 
							
							newPos = new BoardPosition(curSpace.row, curSpace.col - 1);
							newWalk = Constants.deepCopyBoardPositionVector(curWalk);
							newWalk.push(newPos);
							dfsStack.push([newPos, newWalk]); 
							
							newPos = new BoardPosition(curSpace.row, curSpace.col + 1);
							newWalk = Constants.deepCopyBoardPositionVector(curWalk);
							newWalk.push(newPos);
							dfsStack.push([newPos, newWalk]); 
						}
					} 
				}
				
				// you're allowed to 'move' to another player to attack them, one space beyond what you can usually walk
				if ((isPlayerSpace(curSpace) || isEnemySpace(curSpace)) && (curSpace.row != curPosition.row || curSpace.col != curPosition.col)) { 
					markedSpaces[curSpace.row][curSpace.col] = curWalk.length;
					playerPossibleWalks[curSpace.row][curSpace.col].push(curWalk);
				}
			}
			
			playerPossibleMoves = new Vector.<BoardPosition>();
			for (i = 0; i < board.length; i++) 
			{
				for (j = 0; j < board[0].length; j++)
				{
					if (markedSpaces[i][j] < 999999) {
						playerPossibleMoves.push(new BoardPosition(i, j));
					}
				}
			}
			
			// trim walks to just the most efficient ones
			for (i = 0; i < playerPossibleWalks.length; i++)
			{
				for (j = 0; j < playerPossibleWalks[0].length; j++)
				{
					if (playerPossibleWalks[i][j] != null && playerPossibleWalks[i][j].length > 0) {
						var allWalks:Vector.<Vector.<BoardPosition>> = playerPossibleWalks[i][j];
						var minWalk:int = 999999;
						for (var k:int = 0; k < allWalks.length; k++) {
							if (allWalks[k].length < minWalk) {
								minWalk = allWalks[k].length;
							}
						}
						
						playerPossibleWalks[i][j] = new Vector.<Vector.<BoardPosition>>();
						for (k = 0; k < allWalks.length; k++) {
							if (allWalks[k].length == minWalk) {
								playerPossibleWalks[i][j].push(allWalks[k]);
							}
						}
					}
				}
			}
			
			return playerPossibleMoves;
		}

		private function canUseCardForRoll(card:BoardCard):Boolean {
			if (card.type == Constants.CARD_ATK) {
				return false;
			}
			
			return true;
		}
		
		private function canUseCardForCombat(card:BoardCard, isDefender:Boolean):Boolean {
			if (isDefender && selectedDefenseOption != Constants.COMBAT_DEFENSE_COUNTER && card.type == Constants.CARD_ATK) {
				return false; // can only pick attack cards if you are offense or counterattack
			}
			
			if (selectedDefenseOption != Constants.COMBAT_DEFENSE_RUN && card.type == Constants.CARD_MOVE) {
				return false; // can only pick move cards when you're doing escape
			}
			
			if (card.type == Constants.CARD_TRAP) {
				return false;
			}
			
			return true;
		}
		
		// i can't believe as3 won't type this properly otherwise
		private function getSpace(row:int, col:int):BoardSpace {
			return board[row][col];
		}
		
		private function getSpaceForPos(pos:BoardPosition):BoardSpace {
			return board[pos.row][pos.col];
		}
		
		private function playerHasKeyItem(player:Player):Boolean {
			var items:Vector.<BoardItem> = player.getItems();
			for (var i:int = 0; i < items.length; i++) {
				var item:BoardItem = items[i];
				if (item.fromThisBoard && item.id == keyItemId) {
					return true;
				}
			}
			
			return false;
		}
		
		private function isBoardValid(board:Vector.<Vector.<BoardSpace>>):Boolean {
			var markedSpaces:Array = new Array(board.length);
			for (var i:int = 0; i < board.length; i++)
			{
				markedSpaces[i] = new Array(board[0].length);
				for (var j:int = 0; j < board[0].length; j++)
				{
					markedSpaces[i][j] = false;
				}
			}
			
			var dfsStack:Array = [];
			var startPos:BoardPosition = getEmptySpaceOnSpecificBoard(board);
			dfsStack.push(startPos);
			
			while (dfsStack.length > 0) {
				var curSpace:BoardPosition = dfsStack.pop();
				if (isMoveableSpace(curSpace) && !markedSpaces[curSpace.row][curSpace.col]) {
					markedSpaces[curSpace.row][curSpace.col] = true;
					var newPos:BoardPosition = new BoardPosition(curSpace.row - 1, curSpace.col);
					dfsStack.push(newPos);
					
					newPos = new BoardPosition(curSpace.row + 1, curSpace.col);
					dfsStack.push(newPos);; 
					
					newPos = new BoardPosition(curSpace.row, curSpace.col - 1);
					dfsStack.push(newPos);
					
					newPos = new BoardPosition(curSpace.row, curSpace.col + 1);
					dfsStack.push(newPos);
				}
			}
			
			for (i = 0; i < board.length; i++)
			{
				for (j = 0; j < board[0].length; j++)
				{
					if (isMoveableSpace(new BoardPosition(i, j)) && !markedSpaces[i][j]) {
						return false;
					}
				}
			}
			
			return true;
		}
		
		private function gameStateIsCombat():Boolean {
			return gameState == Constants.GSTATE_COMBAT_DEFENSE_SELECT || gameState == Constants.GSTATE_COMBAT_DEFENSE_SELECTCARD || 
				gameState == Constants.GSTATE_COMBAT_DEFENSE_SELECTSURRENDER || gameState == Constants.GSTATE_COMBAT_OFFENSE_SELECTCARD ||
				gameState == Constants.GSTATE_COMBAT_DEFEATED_SELECTREWARD || gameState == Constants.GSTATE_COMBAT_RESOLVE;
		}
		
		// resolves all the combat stuff. outside of changeState bc it's easier
		private function performCombat():void { 
			// TODO: force "nothing" option if defense is stunned
			
			// use the card selected, if one was picked
			if (selectedAttackCard >= 0)
			{
				attackPlayer.activateCardOnCombat(selectedAttackCard, defensePlayer);
			}
			if (selectedDefenseCard >= 0)
			{
				defensePlayer.activateCardOnCombat(selectedDefenseCard, attackPlayer);
			}
			
			if (selectedDefenseOption == Constants.COMBAT_DEFENSE_SURRENDER) {
				trace("Surrendered.");
				// surrender the item
				var transferItem:BoardItem = defensePlayer.removeItem(selectedSurrenderItem);
				attackPlayer.addItem(transferItem);
				
				// defense teleports away
				defensePlayer.moveToSpace(getEmptySpaceOnBoard()); 
				
				queueOverlay(new OverlaySurrenderItem(defensePlayer, attackPlayer, transferItem.id, transferItem.fromThisBoard && transferItem.id == keyItemId, false));
				return; // end combat
			}
			
			if (selectedDefenseOption == Constants.COMBAT_DEFENSE_RUN) {
				var attackEscape:int = attackPlayer.doEscapeRoll();
				var defenseEscape:int = defensePlayer.doEscapeRoll();
				var escapeSucceeded:Boolean = defenseEscape > attackEscape;
				
				queueOverlay(new OverlayEscapeRoll(defensePlayer, attackPlayer, escapeSucceeded)); 
				
				if (!escapeSucceeded) {
					trace("Escape failed!");
					selectedDefenseOption = Constants.COMBAT_DEFENSE_NOTHING;
				} else {
					trace("Escape succeeded!");
					return; // end combat
				}
			}
			
			var attackValue:int = attackPlayer.doCombatRoll(true);
			var defenseValue:int = defensePlayer.doCombatRoll(false);
			
			if (selectedDefenseOption == Constants.COMBAT_DEFENSE_GUARD) {
				defenseValue += defensePlayer.getDefense(); // double defense of defender
				trace(defensePlayer.getName() + " defends. Defense roll is now " + defenseValue);
			}
			
			// do the attack
			var damage:int = Math.max(0, attackValue - defenseValue);
			attackPlayer.incrementDamageGiven(damage);
			trace(damage + " damage dealt.");
			queueOverlay(new OverlayCombatRoll(defensePlayer, attackPlayer, selectedDefenseOption == Constants.COMBAT_DEFENSE_GUARD, false)); 
			defensePlayer.changeHp( -1 * damage);
			
			// TODO: criticals?
			if (defensePlayer.getHp() <= 0) {
				// post battle will happen in separate state
				trace(defensePlayer.getName() + " was defeated!");
				attackPlayer.incrementEnemiesKOed(1);
				return; // end combat 
			}
			
			if (selectedDefenseOption == Constants.COMBAT_DEFENSE_COUNTER) {
				// now the counterattack!
				trace(defensePlayer.getName() + " counterattacks.");
				
				attackValue = defensePlayer.doCombatRoll(true);
				defenseValue = attackPlayer.doCombatRoll(false);

				// do the attack
				damage = Math.max(0, attackValue - defenseValue);
				defensePlayer.incrementDamageGiven(damage);
				trace(damage + " damage dealt.");
				queueOverlay(new OverlayCombatRoll(attackPlayer, defensePlayer, false, true)); 
				attackPlayer.changeHp( -1 * damage);
				
				if (attackPlayer.getHp() <= 0) {
					// post battle will happen in separate state
					trace(attackPlayer.getName() + " was defeated!");
					defensePlayer.incrementEnemiesKOed(1);
					
					var tempPlayer:Player = attackPlayer;
					attackPlayer = defensePlayer;
					defensePlayer = tempPlayer; // switch who 'lost'
					return; // end combat 
				}
			}
			
			trace();
			// combat is over
		}
		
		private function update_combatSelectRewards(inputArray:Array):void {
			if (attackPlayer is Enemy) {
				// TODO: for now enemies do not steal anything. also this code is duped from below
				
				// remove enemy or teleport away player
				if (defensePlayer is Enemy) {
					enemies.splice(enemies.indexOf(defensePlayer), 1);
				} else {
					defensePlayer.respawn();
					defensePlayer.moveToSpace(getEmptySpaceOnBoard()); 
				}

				changeState(Constants.GSTATE_ENDTURN);
			}
			else if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED || defensePlayer.getItems().length == 0)
			{
				if (selectedSurrenderItem >= 0) {
					var transferItem:BoardItem = defensePlayer.removeItem(selectedSurrenderItem);
					attackPlayer.addItem(transferItem);
					
					queueOverlay(new OverlaySurrenderItem(defensePlayer, attackPlayer, transferItem.id, transferItem.fromThisBoard && transferItem.id == keyItemId, true));
				}				
				
				// remove enemy or teleport away player
				if (defensePlayer is Enemy) {
					enemies.splice(enemies.indexOf(defensePlayer), 1);
				} else {
					defensePlayer.respawn();
					defensePlayer.moveToSpace(getEmptySpaceOnBoard()); 
				}

				changeState(Constants.GSTATE_ENDTURN);
			}
			else if (inputArray[Constants.KEY_LEFT] == Constants.INPUT_PRESSED) {
				selectedSurrenderItem--;
				if (selectedSurrenderItem < -1) {
					selectedSurrenderItem = defensePlayer.getItems().length - 1;
				}
			}
			else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED) {
				selectedSurrenderItem++;
				if (selectedSurrenderItem > defensePlayer.getItems().length - 1) {
					selectedSurrenderItem = -1;
				}
			}
		}
		
		private function update_doRest(inputArray:Array):void
		{
			var curPlayer:Player = players[playerTurn];
			
			// TODO: technically if you're emptied you have a turn whre you don't gain cards
			
			for (var i:int = 0; i < Constants.CARDS_PER_REST; i++) {
				if (curPlayer.getCards().length < Constants.HAND_CARD_LIMIT) {
					curPlayer.giveCard(dealCardFromDeck());
				}
			}
			
			// TODO: idk how much you actually here so for now we're full healing
			curPlayer.changeHp(curPlayer.getMaxHp());
			
			// TODO: overlay

			changeState(Constants.GSTATE_ENDTURN);
		}
		
		public function queueOverlay(overlay:GraphicOverlay):void {
			overlaysQueue.push(overlay);
		}
		
		// Caches text strings and returns/creates them intelligently
		public function getText(text:String, size:int, color:uint=0xFFFFFF):Text {
			if (textCache == null) {
				textCache = new Dictionary();
			}
			
			var key:String = text + size + color;
			if (textCache[key] == null) {
				var newText:Text = new Text(text, 0, 0, { "size": size } );
				newText.font = "Segoe";
				newText.color = color;
				textCache[key] = newText;
			}
			
			return textCache[key];
		}
		
		public function addEnemyToBoard():void {
			// enemies will spawn next to players if possible
			var adjacentSpaces:Vector.<BoardPosition> = new Vector.<BoardPosition>();
			var possibleSpawns:Vector.<BoardPosition> = new Vector.<BoardPosition>();
			
			for (var i:int = 0; i < players.length; i++) {
				var curSpace:BoardPosition = (players[i] as Player).getPosition();
				adjacentSpaces.push(new BoardPosition(curSpace.row - 1, curSpace.col));
				adjacentSpaces.push(new BoardPosition(curSpace.row + 1, curSpace.col));
				adjacentSpaces.push(new BoardPosition(curSpace.row, curSpace.col - 1));
				adjacentSpaces.push(new BoardPosition(curSpace.row, curSpace.col + 1));
			}
			
			for (i = 0; i < adjacentSpaces.length; i++) {
				var theSpace:BoardPosition = adjacentSpaces[i];
				if (isEmptySpace(theSpace)) {
					possibleSpawns.push(theSpace);
				}
			}
			
			if (possibleSpawns.length > 0) {
				FP.shuffle(possibleSpawns);
				var enemySpace:BoardPosition = possibleSpawns[0];
				
				enemies.push(new Enemy( -1 * (enemies.length + 1), "Enemy", enemySpace, 0)); //TODO: enemy id // add the enemy
			} else {
				trace("No spaces adjacent to players to spawn an enemy!");
			}
		}
	}
}