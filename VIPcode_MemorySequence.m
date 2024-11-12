% Memory Game using Psychtoolbox

% Initialize Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

% Set up colors and grid parameters
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gridSize = 3;
squareSize = 200;
spacing = 50;

% Create the window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Define grid positions, centered
[xCenter, yCenter] = RectCenter(windowRect);
gridPositions = zeros(gridSize^2, 2);
for i = 1:gridSize
    for j = 1:gridSize
        gridPositions((i-1)*gridSize + j, :) = ...
            [xCenter - (squareSize + spacing) * (gridSize - 1) / 2 + (j-1) * (squareSize + spacing), ...
             yCenter - (squareSize + spacing) * (gridSize - 1) / 2 + (i-1) * (squareSize + spacing)];
    end
end

% Initialize game variables
pattern = [];
isRunning = true;
responseTimes = {}; % Store response times for each level
highestLevel = 0;

while isRunning
    % Generate a new pattern
    pattern = [pattern randi(gridSize^2)];
    
    % Draw the grid
    for squareIndex = 1:gridSize^2
        Screen('FillRect', window, white, [gridPositions(squareIndex, 1), gridPositions(squareIndex, 2), ...
            gridPositions(squareIndex, 1) + squareSize, gridPositions(squareIndex, 2) + squareSize]);
    end
    Screen('Flip', window);

    % Display the pattern with faster lighting
    for p = 1:length(pattern)
        squareIndex = pattern(p);
        
        % Highlight the current square
        Screen('FillRect', window, [0 255 0], [gridPositions(squareIndex, 1), gridPositions(squareIndex, 2), ...
            gridPositions(squareIndex, 1) + squareSize, gridPositions(squareIndex, 2) + squareSize]);
        
        % Refresh the grid with highlighted square
        for sIndex = 1:gridSize^2
            if sIndex ~= squareIndex
                Screen('FillRect', window, white, [gridPositions(sIndex, 1), gridPositions(sIndex, 2), ...
                    gridPositions(sIndex, 1) + squareSize, gridPositions(sIndex, 2) + squareSize]);
            end
        end
        
        Screen('Flip', window);
        
        % Reduce the wait time for pattern visibility
        WaitSecs(0.5); % Adjust this value to make boxes light up faster
        
        % Unhighlight and re-highlight if the same square is repeated
        if p < length(pattern) && pattern(p) == pattern(p + 1)
            WaitSecs(0.5); % Pause for visibility
            Screen('FillRect', window, white, [gridPositions(squareIndex, 1), gridPositions(squareIndex, 2), ...
                gridPositions(squareIndex, 1) + squareSize, gridPositions(squareIndex, 2) + squareSize]);
            Screen('Flip', window);
            WaitSecs(0.5); % Pause before re-highlighting
            Screen('FillRect', window, [0 255 0], [gridPositions(squareIndex, 1), gridPositions(squareIndex, 2), ...
                gridPositions(squareIndex, 1) + squareSize, gridPositions(squareIndex, 2) + squareSize]);
            Screen('Flip', window);
        end
    end
    
    % Get user input
    userPattern = zeros(1, length(pattern));
    responseTimesForCurrentLevel = zeros(1, length(pattern)); % Initialize response times for current level
    clickedSquares = zeros(1, length(pattern)); % Track which squares were clicked

    for i = 1:length(pattern)
        clicked = false;
        startTime = GetSecs; % Start timing
        while ~clicked
            % Draw the entire grid, keeping it visible
            for squareIndex = 1:gridSize^2
                Screen('FillRect', window, white, [gridPositions(squareIndex, 1), gridPositions(squareIndex, 2), ...
                    gridPositions(squareIndex, 1) + squareSize, gridPositions(squareIndex, 2) + squareSize]);
                
                % Highlight any previously clicked squares
                if ismember(squareIndex, clickedSquares)
                    Screen('FillRect', window, [0 255 0], ...
                        [gridPositions(squareIndex, 1), gridPositions(squareIndex, 2), ...
                         gridPositions(squareIndex, 1) + squareSize, ...
                         gridPositions(squareIndex, 2) + squareSize]);
                end
            end
            Screen('Flip', window);
            
            [x, y, buttons] = GetMouse(window);
            for squareIndex = 1:gridSize^2
                rect = [gridPositions(squareIndex, 1), gridPositions(squareIndex, 2), ...
                        gridPositions(squareIndex, 1) + squareSize, ...
                        gridPositions(squareIndex, 2) + squareSize];
                if buttons(1) && IsInRect(x, y, rect)
                    userPattern(i) = squareIndex;
                    clickedSquares(i) = squareIndex; % Record which square was clicked
                    clicked = true;
                    responseTimesForCurrentLevel(i) = GetSecs - startTime; % Record time taken for this click
                    
                    % Briefly highlight the clicked square
                    Screen('FillRect', window, [0 255 0], rect);
                    Screen('Flip', window);
                    WaitSecs(0.5); % Brief wait for feedback
                end
            end
        end
    end
    
    % Store response times for the current level
    responseTimes{end+1} = responseTimesForCurrentLevel;
    
    % Check user's response
    if any(userPattern ~= pattern)
        isRunning = false; % End the game on mistake
    else
        highestLevel = max(highestLevel, length(pattern)); % Update highest level
    end
end

% Game over message
DrawFormattedText(window, 'Game Over!', 'center', 'center', [255 0 0]);
Screen('Flip', window);
WaitSecs(2);

% Display results
fprintf('Highest Level: %d\n', highestLevel);
fprintf('Response Times (in seconds):\n');
for level = 1:length(responseTimes)
    fprintf('Level %d: ', level);
    disp(responseTimes{level});
end

% Close the window
Screen('CloseAll');
