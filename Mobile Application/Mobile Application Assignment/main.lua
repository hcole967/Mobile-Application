-----------------------------------------------------------------------------------------
-- made by Harrison Cole 10632167
-- 611 lines of actual code

-- I fully read the marking key at a point in time where it was difficult to turn back from my implemented solution
-- therefore, i have unfortunately not used scenes and composer and instead used groups.

d = display
local widget = require("widget")

--initialising the variables

isHardMode = false
Xwinner = false
Owinner = false
local isReplaying = false
local Owincount = 0
local Xwincount = 0
local gameplay = {}
local drawing = {}

--setting groups for each screen (used groups instead of scenes)
local startup = d.newGroup()
local game = d.newGroup()
local gameend = d.newGroup()
local XandO = d.newGroup()

game.isVisible = false
gameend.isVisible = false


local NaughtsAndCrosses
--coordinates for placing aspects of the game

local centerX = d.contentCenterX
local centerY = d.contentCenterY
local screenLeft = d.screenOriginX
local screenWidth = d.contentWidth - screenLeft * 2
local screenRight = screenLeft + screenWidth
local screenTop = d.screenOriginY
local screenHeight = d.contentHeight - screenTop * 2
local screenBottom = screenTop + screenHeight



--the win condition (every line of 3 accounted for)
local WinCon = {
	{1, 2, 3},
	{4, 5, 6},
	{7, 8, 9},
	{1, 4, 7},
	{2, 5, 8},
	{3, 6, 9},
	{1, 5, 9},
	{3, 5, 7}
}




	--creating the board lines
	w20 = d.contentWidth * .2
	h20 = d.contentHeight * .2
	w40 = d.contentWidth * .4
	h40 = d.contentHeight * .4
	w60 = d.contentWidth * .6
	h60 = d.contentHeight * .6
	w80 = d.contentWidth * .8
	h80 = d.contentHeight * .8

	----draw board
	local board = {}

		-- Place board compartments in table

	
	--creating the board functionality
	local function createBoard()
		board = {{"tl", 1, w20, h40, w40, h20, 0}, {"tm", 2, w40, h40, w60, h20, 0}, {"tr", 3, w60, h40, w80, h20, 0},

				{"ml", 4, w20, h60, w40, h40, 0}, {"mm", 5, w40, h60, w60, h40, 0}, {"mr", 6, w60, h60, w80, h40, 0},

				{"bl", 7, w20, h80, w40, h60, 0}, {"bm", 8, w40, h80, w60, h60, 0}, {"br", 9, w60, h80, w80, h60, 0}}
	end
	--Set 'O' to play first move
	local EMPTY, X, O = 0, 1, 2
	local whichTurn = O

	--check if every board square has been filled up
	local function filledBoard()
		for i = 1, 9 do
			if board[i][7] == EMPTY then
				return false  
			end
		end
		return true 
	end

	--using the win condition to determine if somebody wins
	local function Winner()
		for i = 1, #WinCon do
			local combo = WinCon[i]
			if board[combo[1]][7] == whichTurn and
			board[combo[2]][7] == whichTurn and
			board[combo[3]][7] == whichTurn then
				return true
			end
		end
		return false
	end
	
	--Hard logic for computer player
	local function playhard()
		-- find winning move for X
		for i = 1, #WinCon do
			local combo = WinCon[i]
			if board[combo[1]][7] == X and board[combo[2]][7] == X and board[combo[3]][7] == EMPTY then
				return combo[3]
			elseif board[combo[1]][7] == X and board[combo[3]][7] == X and board[combo[2]][7] == EMPTY then
				return combo[2]
			elseif board[combo[2]][7] == X and board[combo[3]][7] == X and board[combo[1]][7] == EMPTY then
				return combo[1]
			end
		end
		-- block human player
		for i = 1, #WinCon do
			local combo = WinCon[i]
			if board[combo[1]][7] == O and board[combo[2]][7] == O and board[combo[3]][7] == EMPTY then
				return combo[3]
			elseif board[combo[1]][7] == O and board[combo[3]][7] == O and board[combo[2]][7] == EMPTY then
				return combo[2]
			elseif board[combo[2]][7] == O and board[combo[3]][7] == O and board[combo[1]][7] == EMPTY then
				return combo[1]
			end
		end
		-- pick the center square if available
		if board[5][7] == EMPTY then
			return 5
		end
		-- pick a corner if no center
		local corner = {1, 3, 7, 9}
		for i = 1, #corner do
			if board[corner[i]][7] == EMPTY then
				return corner[i]
			end
		end
		-- otherwise pick an edge
		local edge = {2, 4, 6, 8}
		for i = 1, #edge do
			if board[edge[i]][7] == EMPTY then
				return edge[i]
			end
		end
		-- no moves left
		return nil
	end
	



--background image as created by me
local background = d.newImage( "bground2.png" )
background.width = screenWidth
background.height = screenHeight
background.x = centerX
background.y = centerY
background.alpha = 0.4 		--make it semi transparent (it was too bright and contrasting with other elements)
startup:insert(background)


-- move sections off screen
local function offScreen(object)
    object.x = -object.width - 1000
    object.y = -object.height - 1000
end


--create the title screen text lines and buttons
local titleScreen = d.newText({
    text = "Welcome To",
    x = d.contentCenterX,
    y = screenTop + 100,  
    font = native.systemFontBold,
    fontSize = 24
})
titleScreen:setFillColor(1, 1, 1, 1) 
startup:insert(titleScreen)

local titleScreen2 = d.newText({
    text = "Naughts and Crosses",
    x = d.contentCenterX,
    y = screenTop + 130, 
    font = native.systemFontBold,
    fontSize = 30
})
titleScreen2:setFillColor(1, 1, 1, 1)  
startup:insert(titleScreen2)


local titleScreen3 = d.newText({
    text = "By Harrison Cole",
    x = d.contentCenterX,
    y = screenTop + 160,  
    font = native.systemFontBold,
    fontSize = 20
})
titleScreen3:setFillColor(1, 1, 1, 1)  
startup:insert(titleScreen3)

local roundedRect = d.newRoundedRect(
	d.contentCenterX,
	d.contentCenterY + 200,
	300,
	50,
	20
)
roundedRect:setFillColor(0, 0.6, 0.7)
startup:insert(roundedRect)

local startGame = d.newText({
	text = "Start Game",
	x = d.contentCenterX,
	y = d.contentCenterY + 200,
	font = native.systemFontBold,
	fontSize = 20,
	labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} }
})
startup:insert(startGame)



--hardmode button logic
local hardmode = d.newRoundedRect(
	d.contentCenterX,
	d.contentCenterY + 275,
	300,
	50,
	20
)
hardmode:setFillColor(0, 0.4, 0.5)
startup:insert(hardmode)

local function startHard(event)
	if ( "began" == event.phase ) then
		isHardMode = true
		print("Hard mode activated")
	end
end

local hardButton = widget.newButton({
	label = 'Trigger Hard Mode',
	id = "onEvent",
	x = d.contentCenterX,
	y = d.contentCenterY + 275,
	width = 278,
	height = 32,
	font = native.systemFontBold,
	fontSize = 20,
	labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} },
	onEvent = startHard 
})
startup:insert(hardButton)

--restart the entire game
local function restart()
	
	game:insert(background)
	game:insert(titleScreen2)
	if gameend then
		gameend:removeSelf()  
		gameend = d.newGroup()
	end
	XandO:removeSelf()
	XandO = d.newGroup()

	for i = 1, 9 do
		board[i][7] = EMPTY  		
	end
	Xwinner = false
	Owinner = false
	whichTurn = O
	createBoard()
	
    Runtime:addEventListener("touch", NaughtsAndCrosses)
end





--show the ending screen and all its functionality
local function endScreen( event )
	local EMPTY, X, O = 0, 1, 2
	local whichTurn = O
	gameend.isVisible = true
	game.isVisible = false
	startup.isVisible = false

	if Owinner then	

		gameend:insert(background)

		background:toFront()
		

		local OWinText1 = d.newText({
			text = "Player O",
			x = d.contentCenterX,
			y = screenTop + 130, 
			font = native.systemFontBold,
			fontSize = 50
		})
		gameend:insert(OWinText1)

		local OWinText2 = d.newText({
			text = "Wins!!!",
			x = d.contentCenterX,
			y = screenTop + 180, 
			font = native.systemFontBold,
			fontSize = 50
		})
		gameend:insert(OWinText2)

		local OWinStreak = d.newText({
			text = "Win Count: " .. tostring(Owincount),
			x = d.contentCenterX,
			y = screenTop + 350, 
			font = native.systemFontBold,
			fontSize = 40
		})
		gameend:insert(OWinStreak)


	
	elseif Xwinner then

		background:toFront()

		gameend:insert(background)
		

		local XWinText1 = d.newText({
			text = "Player X",
			x = d.contentCenterX,
			y = screenTop + 130, 
			font = native.systemFontBold,
			fontSize = 50
		})
		gameend:insert(XWinText1)

		local XWinText2 = d.newText({
			text = "Wins!!!",
			x = d.contentCenterX,
			y = screenTop + 180, 
			font = native.systemFontBold,
			fontSize = 50
		})
		gameend:insert(XWinText2)

		local XWinStreak = d.newText({
			text = "Win Count: " .. tostring(Xwincount),
			x = d.contentCenterX,
			y = screenTop + 350, 
			font = native.systemFontBold,
			fontSize = 40
		})
		gameend:insert(XWinStreak)
		
		
	end
	local resetrect = d.newRoundedRect (
			d.contentCenterX,
			d.contentCenterY + 275,
			300,
			50,
			20
		)
		resetrect:setFillColor(0, 0.4, 0.5)
		gameend:insert(resetrect)

	local resetgame = widget.newButton({
		label = 'Reset Game',
		id = "onPress",
		x = d.contentCenterX,
		y = d.contentCenterY + 275,
		width = 278,
		height = 32,
		font = native.systemFontBold,
		fontSize = 20,
		labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} },
		onPress = function()
			print("reset button is working")
			gameend:removeSelf()
			gameplay = {}
			restart()
		end
	})
	gameend:insert(resetgame)

	--replay the last game by turn
	local function replaylogic()
		local replaytext = d.newText({
			text = "Instant Replay",
			x = d.contentCenterX,
			y = screenTop + 160,  
			font = native.systemFontBold,
			fontSize = 20
		})
		replaytext:setFillColor(1, 1, 1, 1)  
		for index, t in ipairs(gameplay) do
			local delay = 500 * index  -- Add a delay for each move
			timer.performWithDelay(delay, function()
				if index % 2 == 1 then
					--place O for odd moves, X for even
					s = d.newCircle(board[t][3] + 3, board[t][6] + 20, w20 / 2.5, h20 / 2.5)
					s:setFillColor(0, 0, 0, 0)
					s:setStrokeColor(0.29, 0.58, 0.80)
					s.strokeWidth = 5
					s.anchorX = 0
					s.anchorY = 0
					XandO:insert(s)
					
					print("Replay O in space:", t)
				else
					local centerX = (board[t][3] + board[t][5]) / 2
					local centerY = (board[t][4] + board[t][6]) / 2
					local size = 30
	
					r = d.newLine(centerX - 20, centerY - size, centerX + 20, centerY + size) 
					r:setStrokeColor(1, 0.1, 0.2)  
					r.strokeWidth = 5 
					r.anchorX = 0
					r.anchorY = 0 
					XandO:insert(r)
					r = d.newLine(centerX - 20, centerY + size, centerX + 20, centerY - size) 
					r:setStrokeColor(1, 0.1, 0.2)  
					r.strokeWidth = 5 
					r.anchorX = 0
					r.anchorY = 0
					print("Computer plays in space:", t) 
					XandO:insert(r)
					
					
				end
				--if the replay is over (#gameplay (table length has been run through) expended)
				if index == #gameplay then
					Runtime:addEventListener("touch", NaughtsAndCrosses)
					local done1 = d.newRoundedRect(
						d.contentCenterX,
						d.contentCenterY + 275,
						300,
						50,
						20
					)
					done1:setFillColor(0, 0.4, 0.5)
					local Done = widget.newButton({
						label = 'Done',
						id = "onPress",
						x = d.contentCenterX,
						y = d.contentCenterY + 275,
						width = 278,
						height = 32,
						font = native.systemFontBold,
						fontSize = 20,
						labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} },
						onPress = function()
							offScreen(replaytext)
							gameend:insert(background)
							XandO.isVisible = false
							gameend.isVisible = true
							isReplaying = false
							gameend:removeSelf()
							gameplay = {}
							restart()
							
						end
						
							
					})
					
					gameend:insert(done1)
					gameend:insert(Done)

				
				end
				
			end)
		end
	end

	local replayrect = d.newRoundedRect (
			d.contentCenterX,
			d.contentCenterY + 200,
			300,
			50,
			20
		)
		replayrect:setFillColor(0, 0.6, 0.7)
		gameend:insert(replayrect)

	local replayGame = widget.newButton ({
		label = 'Instant Replay',
		id = "onPress",
		x = d.contentCenterX,
		y = d.contentCenterY + 200,
		width = 278,
		height = 32,
		font = native.systemFontBold,
		fontSize = 20,
		labelColor = { default={1, 1, 1, 1}, over={1, 1, 1, 1} },
		onPress = function()
			print("instant replay button working")
			isReplaying = true
			restart() 
			replaylogic()
		end
	})
	gameend:insert(replayGame)
	end





--full game functionality
function NaughtsAndCrosses(event)
	

	if #board == 0 then
		createBoard()
	end
	
	
	startup.isVisible = false
	game.isVisible = true

	--when the event starts (runtime touch event triggered)
	if event.phase == "began" then
		
		
		
		
		game:insert(background)
		game:insert(titleScreen2)
		--create an undo button
		local undoButton = widget.newButton({
			
			id = 'undoButton',
			defaultFile = 'undo.png',
			width = 45,
			height = 45,
			onPress = function()
				print("Undoing last move...")
				if #gameplay > 0 then
					local lastMove = table.remove(gameplay)
					board[lastMove][7] = EMPTY
					local lastplay = table.remove(drawing)
						if lastplay then
							if type(lastplay) == "table" then
								for _, line in ipairs(lastplay) do
									d.remove(line)
								end
							end
						end
						
					whichTurn = whichTurn == X and O or X 
				end
			end
			
		})
		undoButton.x = d.contentCenterX + 130
		undoButton.y = d.contentCenterY - 175
		game:insert(undoButton)
		offScreen(titleScreen)
		titleScreen2:setFillColor(1,1,1,1)
		offScreen(titleScreen3)
		offScreen(startGame)
		offScreen(roundedRect)
		offScreen(hardButton)
		offScreen(hardmode)

			-- draw the physical board
		local lline = d.newLine(w40, h20, w40, h80)
		lline.strokeWidth = 3

		local rline = d.newLine(w60, h20, w60, h80)
		rline.strokeWidth = 3

		local bline = d.newLine(w20, h40, w80, h40)
		bline.strokeWidth = 3

		local tline = d.newLine(w20, h60, w80, h60)
		tline.strokeWidth = 3
		game:insert(lline)
		game:insert(rline)
		game:insert(bline)
		game:insert(tline)
		lline:toFront()
		rline:toFront()
		bline:toFront()
		tline:toFront()

		tap = 0
		
		-- naming each square (purely for console outputs)
		for t = 1, 9 do
			if t == 1 then
				bspace = "Top Left Square"
			elseif t==2 then
				bspace = "Top Middle Square"
			elseif t==3 then
				bspace = "Top Right Square"
			elseif t==4 then
				bspace = "Middle Left Square"
			elseif t==5 then
				bspace = "Middle Square"
			elseif t==6 then
				bspace = "Middle Right Square"
			elseif t==7 then
				bspace = "Bottom Left Square"
			elseif t==8 then
				bspace = "Bottom Middle Square"
			elseif t==9 then
				bspace = "Bottom Right Square"
			end
				
			if event.x > board[t][3] and event.x < board[t][5] then
				if event.y < board[t][4] and event.y > board[t][6] then
					if board[t][7] == EMPTY then
						board[t][7] = whichTurn
						if whichTurn == O then
							if isReplaying then
								replaylogic()
							else
							--Create circle and place it in the specified location
								s = d.newCircle(board[t][3] + 3, board[t][6] + 20, w20 / 2.5, h20 / 2.5)
								s:setFillColor(0, 0, 0, 0) 
								s:setStrokeColor(0.29, 0.58, 0.80)  
								s.strokeWidth = 5 
								s.anchorX = 0
								s.anchorY = 0 
								print("O plays in space:", t, bspace)
								XandO:insert(s)
								table.insert(gameplay, t)
								table.insert(drawing, {s})
							end
							
							--check if win condition is met
							if filledBoard() then
								print("game ends in a draw")
								endScreen()
							end
							--if the win condition is met, take it to the end screen
							if Winner() then
								
								
								print("Player O is the Winner!!!")
								Runtime:removeEventListener("touch", NaughtsAndCrosses)
								timer.performWithDelay(1000, function()
									offScreen(XandO)
									Owinner = true
									print(table.concat(gameplay, ", "))
									Owincount = Owincount + 1
									endScreen() 
								end)
							else
							
								--change to X turn (computer)
							
								whichTurn = X
								
								if not isHardMode then		--its not in hard mode
										
									local playableSpace = {}
									for i = 1, 9 do
										if board[i][7] == EMPTY then
											table.insert(playableSpace, i)
										end
									end

									if #playableSpace > 0 then
										local randomiser = math.random(#playableSpace)
										local compChoice = playableSpace[randomiser]
										board[compChoice][7] = X

										--Create cross and place it in random location
										local centerX = (board[compChoice][3] + board[compChoice][5]) / 2
										local centerY = (board[compChoice][4] + board[compChoice][6]) / 2
										local size = 30


										r = d.newLine(centerX - 20, centerY - size, centerX + 20, centerY + size) 
										r:setStrokeColor(1, 0.1, 0.2)  
										r.strokeWidth = 5 
										r.anchorX = 0
										r.anchorY = 0 
										XandO:insert(r)
											
										r1 = d.newLine(centerX - 20, centerY + size, centerX + 20, centerY - size) 
										r1:setStrokeColor(1, 0.1, 0.2)  
										r1.strokeWidth = 5 
										r1.anchorX = 0
										r1.anchorY = 0
										print("Computer plays in space:", compChoice, bspace) 
										XandO:insert(r1)
										table.insert(gameplay, compChoice)
										table.insert(drawing, {r, r1})
										if Winner() then
											Runtime:removeEventListener("touch", NaughtsAndCrosses)
											print("Computer X is the Winner!!!")
											timer.performWithDelay(1000, function()
												offScreen(XandO)
												Xwinner = true
												print(table.concat(gameplay, ", "))
												Xwincount = Xwincount + 1
													
												endScreen() 
													
											end)
										else
										end
									end

								else		-- if isHardMode = true
										
									local playableSpace = {}
									for i = 1, 9 do
										if board[i][7] == EMPTY then
											table.insert(playableSpace, i)
										end
									end

									if #playableSpace > 0 then
										local compChoice = playhard()
										board[compChoice][7] = X
												
											
												

										--Create cross and place it in random location
										local centerX = (board[compChoice][3] + board[compChoice][5]) / 2
										local centerY = (board[compChoice][4] + board[compChoice][6]) / 2
										local size = 30


										r = d.newLine(centerX - 20, centerY - size, centerX + 20, centerY + size) 
										r:setStrokeColor(1, 0.1, 0.2)  
										r.strokeWidth = 5 
										r.anchorX = 0
										r.anchorY = 0 
										XandO:insert(r)
											
										r1 = d.newLine(centerX - 20, centerY + size, centerX + 20, centerY - size) 
										r1:setStrokeColor(1, 0.1, 0.2)  
										r1.strokeWidth = 5 
										r1.anchorX = 0
										r1.anchorY = 0
										print("Computer plays in space:", compChoice, bspace) 
										XandO:insert(r1)
										table.insert(drawing, {r, r1})
										table.insert(gameplay, compChoice)
											
									end
										if Winner() then			--check if win condition has been met
											Runtime:removeEventListener("touch", NaughtsAndCrosses)
											print("Computer X is the Winner!!!")
											timer.performWithDelay(1000, function()
												Xwinner = true
												Xwincount = Xwincount + 1
												print(table.concat(gameplay, ", "))
												offScreen(XandO)
												game.isVisible = false
												gameend.isVisible = true
												endScreen()		
											end)
										else
									end
										
								end
									
								whichTurn = O		--switch back to player (O)
									
							end	
						end
					end
				end
			end
		end
		
	end
end
Runtime:addEventListener("touch", NaughtsAndCrosses)



