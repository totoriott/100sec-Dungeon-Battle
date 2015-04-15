package  
{
	import net.flashpunk.FP;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.utils.*;
	
	public class Board extends Entity
	{
		public var deck:Array = [];
		public var players:Array = [];
		public var board:Vector.<Vector.<BoardSpace>>;
		
		// TODO - scrolling view?
		// TODO - reset these somewhere
		private var startRow:int = 0;
		private var startCol:int = 0;
		private var viewRows:int = 14;
		private var viewCols:int = 14;
		
		private var gameState:int = Constants.GSTATE_GAMEOVER;
		private var playerTurn:int = 0; // which player's turn it is
	
		private var cardIndex:int = 0; // index of the card the player is selecting
		private var playerWalk:Array = []; // the squares that the player is walking this turn
		private var playerPossibleMoves:Array = []; // the squares that the player could walk to this turn
		private var playerPossibleWalks:Array = []; // the board, where each square is possible walks to that square this turn
		
		private var moveTimer:int = 0; 
		
		public function Board() 
		{
			initNewGame();
		}	
		
		public function initNewGame():void
		{
			createNewDeck();
			
			initBoard();
			initPlayers();
			
			playerTurn = players.length - 1;
			changeState(Constants.GSTATE_SELECTCARD);
			
			// TODO - decide first player
		}
		
		public function createNewDeck():void
		{
			deck = [];	
			
			// TODO - make the card class less BS please
			for each (var card:Array in Constants.DECK_BASE)
			{
				for (var i:int = 0; i < card[Constants.DECK_CARD_COUNT]; i++) {
					deck.push(Constants.deepCopyArray(card[Constants.DECK_CARD_DATA]));
				}	
			}
			
			FP.shuffle(deck);
		}
		
		public function initPlayers():void 
		{
			// TODO: move persistence of player stats somewhere, maybe load file in Player creation
			
			players = [];
			
			for (var i:int = 0; i < Constants.PLAYER_COUNT; i++)
			{
				var newPlayer:Player = new Player("Player " + (i+1), getEmptySpaceOnBoard());
				
				for (var j:int = 0; j < Constants.HAND_CARD_LIMIT; j++)
					newPlayer.giveCard(dealCardFromDeck());
				
				players.push(newPlayer);
			}
		}
		
		public function initBoard():void
		{
			trace("Initializing the board.");
			
			// Define the board geography
			// TODO - make the board more interesting than this
			var boardRows:int = 14;
			var boardCols:int = 14;
			board = new Vector.<Vector.<BoardSpace>>(boardRows, true);
			for (var i:int = 0; i < boardRows; i++)
			{
				board[i] = new Vector.<BoardSpace>(boardCols, true);
				for (var j:int = 0; j < boardCols; j++)
				{
					board[i][j] = new BoardSpace(Constants.BOARD_EMPTY, 0, i, j);
				}
			}
			
			// Place the exit
			var emptySpace:Array = getEmptySpaceOnBoard();
			board[emptySpace[0]][emptySpace[1]] = new BoardSpace(Constants.BOARD_EXIT, 0, emptySpace[0], emptySpace[1]);
			
			// Place the treasures
			// TODO - put something in the treasures
			for (i = 0; i < Constants.BOARD_BOX_COUNT; i++)
			{
				emptySpace = getEmptySpaceOnBoard();
				board[emptySpace[0]][emptySpace[1]] = new BoardSpace(Constants.BOARD_BOX, 0, emptySpace[0], emptySpace[1]);
			}
			
			// Place the flags
			for (i = 0; i < Constants.BOARD_FLAG_COUNT; i++)
			{
				emptySpace = getEmptySpaceOnBoard();
				board[emptySpace[0]][emptySpace[1]] = new BoardSpace(Constants.BOARD_FLAG, i, emptySpace[0], emptySpace[1]);
			}
		}
		
				
		// Pops the top card off the deck and returns it
		public function dealCardFromDeck():Array
		{
			if (deck.length == 0) {
				//trace("Deck is empty!");
				return null;
			}
			
			// I'm not sure if this is the "top" or "bottom" of deck but as long as we're consistent
			return deck.pop();
		}
		
		// Gets a random empty board location and returns it as an x-y pair
		public function getEmptySpaceOnBoard():Array
		{
			var row:int = -1;
			var col:int = -1;
			var tries:int = 0;
			
			while (row < 0 || col < 0 || getSpace(row, col).type != Constants.BOARD_EMPTY || isPlayerSpace([row, col]))
			{
				row = FP.rand(board.length);
				col = FP.rand(board[0].length);
				
				tries++;
				if (tries > 100000)
				{
					trace("Couldn't find an empty space on the board!");
					row = -1;
					col = -1;
					break;
				}
			}
			
			return [row, col];
		}
		
		// checks if you're colliding with a player
		public function isPlayerSpace(space:Array):Boolean
		{
			for (var i:int = 0; i < players.length; i++)
			{
				var player:Player = players[i];
				var playerPos:Array = player.getPosition();
				if (space[0] == playerPos[0] && space[1] == playerPos[1])
					return true;
			}
			
			return false;
		}
		
		// returns true if you can move to that space
		public function isMoveableSpace(space:Array):Boolean
		{
			if (space[0] < 0 || space[0] >= board.length)
				return false;
			if (space[1] < 0 || space[1] >= board[0].length)
				return false;
			if (isPlayerSpace(space)) // can't move to where other players are
				return false;
			
			// can't move to invalid squares
			var unmovableSpaces:Array = [Constants.BOARD_NULL];
			for each (var spaceType:int in unmovableSpaces)
			{
				if (getSpace(space[0],space[1]).type == spaceType)
					return false;
			}

			return true;
		}
		
		public function changeState(newState:int):void
		{
			switch (newState) // do any Enter State logic
			{
				case Constants.GSTATE_SELECTCARD:
					// "NEXT TURN"
					// TODO: other turn start things
					playerTurn++;
					if (playerTurn >= players.length)
						playerTurn = 0;
						
					// give them a card if there is one and they need one
					var cards:Array = players[playerTurn].getCards();
					if (cards.length < Constants.HAND_CARD_LIMIT && deck.length > 0)
					{
						players[playerTurn].giveCard(dealCardFromDeck());
					}
						
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
					playerWalk = []; // the squares the current player is walking this turn
					var playerRoll:int = players[playerTurn].doMovementRoll();
					
					playerPossibleMoves = getPlayerPossibleMoves(); // the squares the current player could move to this turn
					break;
					
				case Constants.GSTATE_SELECTMOVE:
					break;
					
				case Constants.GSTATE_MOVING:
					playerPossibleMoves = [];
					moveTimer = Constants.FRAMES_BETWEEN_SQUARES_MOVED; // set the time for each move
					break;
					
				case Constants.GSTATE_ACTIVATESPACE:
					break;
			}

			gameState = newState;
		}
		
		override public function update():void
		{
			var inputArray:Array = getInputArray();
			
			switch (gameState)
			{
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
			}
		}
		
		override public function render():void
		{
			super.render();
			
			// TODO - optimize the hell out of everything
			
			// TODO - draw BG
			Draw.rect(0, 0, 800, 600, 0xEEEEEE, 1);
			
			// draw the board
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
					
					Draw.graphic(Constants.BOARD_SPRITES[sprite][frame], boardX + (j - startCol) * tileSize, boardY + (i - startRow) * tileSize);
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
				Draw.rect(horizX, horizY, scrollbarSize, horizHeight, 0x444444, 1);
			}
			if (viewCols < board[0].length)
			{
				var vertWidth:Number = (1.0 * tileSize * viewCols) * (1.0 * viewCols / board[0].length);
				var vertX:int = boardX + ((1.0 * tileSize * viewCols) - vertWidth) * (startCol / (board[0].length - viewCols));
				var vertY:int = boardY + (tileSize * viewRows);
				Draw.rect(vertX, vertY, vertWidth, scrollbarSize, 0x444444, 1);
			}
			
			
			// draw the players on the board
			for (i = 0; i < players.length; i++)
			{
				var player:Player = players[i];
				var playerPos:Array = player.getPosition();
				
				// adjust for the viewport
				playerPos[0] -= startRow;
				playerPos[1] -= startCol;
				if (playerPos[0] >= 0 && playerPos[0] < viewRows)
					if (playerPos[1] >= 0 && playerPos[1] < viewCols)
						Draw.graphic(Constants.PLAYER_SPRITES[i], boardX + playerPos[1] * tileSize, boardY + playerPos[0] * tileSize);
			}
			
			// draw board highlights and stuff
			for each (var space:Array in playerPossibleMoves) // draw the path the player can walk to
			{
				// TODO - make this nicer or not hardcoded (this is just stolen from below)
				var spaceCopy:Array = Constants.deepCopyArray(space);
				// adjust for the viewport
				spaceCopy[0] -= startRow;
				spaceCopy[1] -= startCol;
				if (spaceCopy[0] >= 0 && spaceCopy[0] < viewRows)
					if (spaceCopy[1] >= 0 && spaceCopy[1] < viewCols)
						Draw.rect(boardX + spaceCopy[1] * tileSize, boardY + spaceCopy[0] * tileSize, tileSize, tileSize, 0x0000FF, 0.25);
			}
			
			for each (space in playerWalk) // draw the path the player is walking
			{
				// TODO - make this nicer or not hardcoded
				spaceCopy = Constants.deepCopyArray(space);
				// adjust for the viewport
				spaceCopy[0] -= startRow;
				spaceCopy[1] -= startCol;
				var color = 0x0000FF;
				if (playerWalk.indexOf(space) == playerWalk.length - 1) // last tile in walk
					color = 0x00FFFF;
				if (spaceCopy[0] >= 0 && spaceCopy[0] < viewRows)
					if (spaceCopy[1] >= 0 && spaceCopy[1] < viewCols)
						Draw.rect(boardX + spaceCopy[1] * tileSize, boardY + spaceCopy[0] * tileSize, tileSize, tileSize, color, 0.5);
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
				var cards:Array = player.getCards();
				
				var playerY:int = hudY + (playerHudHeight + playerHudMargin) * i;
				
				// TODO - letters are cut off because hilarity
				var headerStr:Text = player.getHeaderStr();
				if (i == playerTurn)
					headerStr.color = 0xFF0000;
				else
					headerStr.color = 0x000000;
					
				headerStr.alpha = 1;
				Draw.graphic(headerStr, hudX, playerY);
				Draw.graphic(player.getHpStr(), hudX + 208, playerY);
				Draw.graphic(player.getStatStr(), hudX, playerY + 16);
				Draw.graphic(player.getPointsStr(), hudX + 208, playerY + 16);
				
				// draw their hand
				for (j = 0; j < cards.length; j++)
				{
					var cardImage:Image = cards[j][0];
					cardImage.scale = 0.75; // TODO - hack while i figure card size out
					
					var cardY:int = playerY + 40;
					if (gameState == Constants.GSTATE_SELECTCARD && i == playerTurn
						&& j == cardIndex) // if it's the card selected
							cardY = playerY + 40 + 20;
					Draw.graphic(cardImage, hudX + 36 * j, cardY);
				}
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
		
		// handles updating for the game state where the player is picking what card to play when moving around the board
		private function update_playerCard(inputArray:Array):void
		{
			var curPlayer:Player = players[playerTurn];
			
			if (inputArray[Constants.KEY_DEBUG] == Constants.INPUT_DOWN) // debug button
			{
				initNewGame();
				return;
			}
			
			if (inputArray[Constants.KEY_FIRE3] == Constants.INPUT_DOWN) // if we're holding down the camera button
			{
				update_moveCamera(inputArray);
				return;
			}
			
			var cards:Array = players[playerTurn].getCards();
			
			if (inputArray[Constants.KEY_FIRE1] == Constants.INPUT_PRESSED) // select a card
			{
				changeState(Constants.GSTATE_DOROLL);
			}
			else if (inputArray[Constants.KEY_FIRE2] == Constants.INPUT_PRESSED) // cancel
			{
				cardIndex = -1;
				changeState(Constants.GSTATE_DOROLL);
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
						&& (cardIndex < 0 || cardIndex >= cards.length || !canUseCardForRoll(curPlayer.getCards()[cardIndex]))) {		
					cardIndex += cardMoveDirection;
					if (cardIndex >= cards.length)
						cardIndex = Math.min(0, originalIndex); 
					if (cardIndex < Math.min(0, originalIndex))
						cardIndex = cards.length - 1;
				}
			}
		}
		
		private function update_doRoll(inputArray:Array):void
		{
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
			var newSquare:Array = [ -99, -99]; // the square which we will start moving from
			var playerSpace:Array = players[playerTurn].getPosition();
			if (playerWalk.length == 0)
				newSquare = playerSpace;
			else
				newSquare = Constants.deepCopyArray(playerWalk[playerWalk.length - 1]);

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
				newSquare[1] -= 1;
			else if (inputArray[Constants.KEY_RIGHT] == Constants.INPUT_PRESSED)
				newSquare[1] += 1;
			else if (inputArray[Constants.KEY_UP] == Constants.INPUT_PRESSED)
				newSquare[0] -= 1;
			else if (inputArray[Constants.KEY_DOWN] == Constants.INPUT_PRESSED)
				newSquare[0] += 1;
			else	
				newSquareSelected = false; // if we didn't input anything we don't really care
			
			// TODO: moving onto other players to battle them???
			
			if (false) // TODO: remove manual walk selecting
			{
				if (newSquareSelected) // check to see if you zeroed out your move
				{
					if (newSquare[0] == playerSpace[0] && newSquare[1] == playerSpace[1]) //if you backtraced to the start
						playerWalk = playerWalk.slice(0, 0); // clear the walk
				}
				
				if (newSquareSelected && isMoveableSpace(newSquare)) // now let's talk about other walks
				{
					playerWalk.push(newSquare); // push the square onto the walk
						
					// truncate any loops in the walk
					for (var i:int = 0; i < playerWalk.length - 1; i++) // don't truncate last square
					{
						var walkSpace:Array = playerWalk[i];
						if (walkSpace[0] == newSquare[0] && walkSpace[1] == newSquare[1])
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
				if (newSquare[0] == playerSpace[0] && newSquare[1] == playerSpace[1]) //if you backtraced to the start
					playerWalk = playerWalk.slice(0, 0); // clear the walk
			}
				
			if (newSquareSelected && isMoveableSpace(newSquare)) {
				if (playerPossibleWalks[newSquare[0]][newSquare[1]].length > 0) { 
					var thing:Array = playerPossibleWalks[newSquare[0]][newSquare[1]];
					playerWalk = playerPossibleWalks[newSquare[0]][newSquare[1]][0];
				}
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
					var newSquare:Array = playerWalk[0];
					playerWalk = playerWalk.slice(1, playerWalk.length);
					
					players[playerTurn].moveToSpace(newSquare);
					
					// TODO: do traps
					
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
			
			var playerPos:Array = players[playerTurn].getPosition();
			var space:BoardSpace = getSpace(playerPos[0], playerPos[1]).deepCopy();
			
			switch (space.type)
			{
				case Constants.BOARD_BOX:
					// TODO: get the box
					
					board[playerPos[0]][playerPos[1]].changeTo(Constants.BOARD_EMPTY, 0); // empty out the space
					break;
					
				case Constants.BOARD_FLAG:
					// TODO: get the flag
					
					var newFlag:Array = getEmptySpaceOnBoard();
					board[playerPos[0]][playerPos[1]].changeTo(Constants.BOARD_EMPTY, 0); // empty out the old space
					board[newFlag[0]][newFlag[1]].changeTo(Constants.BOARD_FLAG, space.value); // jump the flag to the new place
					break;
					
				case Constants.BOARD_EXIT:
					// TODO: key item check
					
					// if you don't have the key item, jump to a random location
					players[playerTurn].moveToSpace(getEmptySpaceOnBoard()); 
					break;
			}
			
			changeState(Constants.GSTATE_SELECTCARD);
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
		
		private function getPlayerPossibleMoves():Array {
			var curPlayer:Player = players[playerTurn];
			var curPosition:Array = curPlayer.getPosition();
			var playerRoll:int = curPlayer.getMovementRollValue(); 
			
			var dfsStack:Array = [];
			var possibleSpaces:Array = [];
			
			var markedSpaces:Array = new Array(board.length);
			for (var i:int = 0; i < board.length; i++)
			{
				markedSpaces[i] = new Array(board[0].length);
				for (var j:int = 0; j < board[0].length; j++)
				{
					markedSpaces[i][j] = -1;
				}
			}
			
			// init possible walks (this is used to determine how you walks
			playerPossibleWalks = new Array(board.length);
			for (i = 0; i < board.length; i++)
			{
				playerPossibleWalks[i] = new Array(board[0].length);
				for (j = 0; j < board[0].length; j++)
				{
					playerPossibleWalks[i][j] = [];
				}
			}
			
			// TODO: logic got bad because of reasons
			
			var nextPos:Array = [[curPosition[0] - 1, curPosition[1]]];
			dfsStack.push([curPosition[0] - 1, curPosition[1], nextPos]); 
			
			nextPos = [[curPosition[0] + 1, curPosition[1]]];
			dfsStack.push([curPosition[0] + 1, curPosition[1], nextPos]); 
			
			nextPos = [[curPosition[0], curPosition[1] - 1]];
			dfsStack.push([curPosition[0], curPosition[1] - 1, nextPos]); 
			
			nextPos = [[curPosition[0], curPosition[1] + 1]];
			dfsStack.push([curPosition[0], curPosition[1] + 1, nextPos]); 
			
			while (dfsStack.length > 0) {
				var curNode:Array = dfsStack.pop();
				var curWalk:Array = curNode[2];

				if (curWalk.length <= playerRoll) { // spaces left to move (yes this is off by one because of bad loop logic)
					var curSpace:Array = curNode.splice(0, 2);
					if (isMoveableSpace(curSpace)) {
						markedSpaces[curSpace[0]][curSpace[1]] = 1; // for now just mark 1 to indicate it can be traveled to
						playerPossibleWalks[curSpace[0]][curSpace[1]].push(curWalk);
						
						var newWalk:Array = Constants.deepCopyArray(curWalk);
						newWalk.push([curSpace[0] - 1, curSpace[1]]);
						dfsStack.push([curSpace[0] - 1, curSpace[1], newWalk]); 
						
						newWalk = Constants.deepCopyArray(curWalk);
						newWalk.push([curSpace[0] + 1, curSpace[1]]);
						dfsStack.push([curSpace[0] + 1, curSpace[1], newWalk]); 
						
						newWalk = Constants.deepCopyArray(curWalk);
						newWalk.push([curSpace[0], curSpace[1] - 1]);
						dfsStack.push([curSpace[0], curSpace[1] - 1, newWalk]); 
						
						newWalk = Constants.deepCopyArray(curWalk);
						newWalk.push([curSpace[0], curSpace[1] + 1]);
						dfsStack.push([curSpace[0], curSpace[1] + 1, newWalk]); 
					}
				}
			}
			
			playerPossibleMoves = [];
			// TODO: save path so you don't have to walk path manually
			for (i = 0; i < board.length; i++) 
			{
				for (j = 0; j < board[0].length; j++)
				{
					if (markedSpaces[i][j] >= 0) {
						playerPossibleMoves.push([i, j]);
					}
				}
			}
			
			// trim walks to just the most efficient ones
			for (i = 0; i < playerPossibleWalks.length; i++)
			{
				for (j = 0; j < playerPossibleWalks[0].length; j++)
				{
					if (playerPossibleWalks[i][j] != null && playerPossibleWalks[i][j].length > 0) {
						var allWalks:Array = Constants.deepCopyArray(playerPossibleWalks[i][j]);
						var minWalk:int = 999999;
						for (var k:int = 0; k < allWalks.length; k++) {
							if (allWalks[k].length < minWalk) {
								minWalk = allWalks[k].length;
							}
						}
						
						playerPossibleWalks[i][j] = [];
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

		private function canUseCardForRoll(card:Array):Boolean {
			if (card[Constants.DECK_CARD_TYPE] == Constants.CARD_ATK) {
				return false;
			}
			
			return true;
		}
		
		// i can't believe as3 won't type this properly otherwise
		private function getSpace(row:int, col:int):BoardSpace {
			return board[row][col];
		}
	}
}