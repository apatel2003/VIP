% Chimpanzee Test using Psychtoolbox

% Initialize Psychtoolbox
Screen('Preference', 'SkipSyncTests', 1);
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);

% Set up colors and parameters
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
numLevels = 10; % Number of levels
squareSize = 100; % Size of squares
reactionTimes = zeros(numLevels, numLevels + 2); % Store reaction times
highestLevel = 0;

% Create the window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[xCenter, yCenter] = RectCenter(windowRect);

% Function to generate non-overlapping positions
function positions = generateNonOverlappingPositions(numSquares, squareSize, windowRect)
    positions = zeros(numSquares, 2)
    for i = 1:numSquares
        overlap = true;
        while overlap
            % Generate random position
            x = randi([squareSize/2, windowRect(3) - squareSize/2]);
            y = randi([squareSize/2, windowRect(4) - squareSize/2]);
            positions(i, :) = [x, y];

            % Check for overlap with existing squares
            overlap = false;
            for j = 1:i-1
                if norm(positions(i, :) - positions(j, :)) < squareSize
                    overlap = true; % If the squares overlap, regenerate
                    break;
                end
            end
        end
    end
end

% Game loop
isRunning = true;
while isRunning && highestLevel < numLevels
    highestLevel = highestLevel + 1; % Increment level
    numSquares = highestLevel + 2; % Start with 3 squares, then add one each level
    
    % Generate non-overlapping positions for squares
    positions = generateNonOverlappingPositions(numSquares, squareSize, windowRect);

    % Draw squares with sequential numbers
    numbers = 1:numSquares; % Create sequential numbers
    for i = 1:numSquares
        Screen('FillRect', window, white, ...
            [positions(i,1) - squareSize/2, positions(i,2) - squareSize/2, ...
             positions(i,1) + squareSize/2, positions(i,2) + squareSize/2]);
        DrawFormattedText(window, num2str(numbers(i)), 'center', 'center', black, [], [], [], [], [], ...
            [positions(i,1) - squareSize/2, positions(i,2) - squareSize/2, ...
             positions(i,1) + squareSize/2, positions(i,2) + squareSize/2]);
    end
    Screen('Flip', window);
    
    % Wait for user input
    userPattern = zeros(1, numSquares);
    for i = 1:numSquares
        clicked = false;
        startTime = GetSecs; % Start timing
        while ~clicked
            [x, y, buttons] = GetMouse(window);
            for j = 1:numSquares
                rect = [positions(j,1) - squareSize/2, positions(j,2) - squareSize/2, ...
                        positions(j,1) + squareSize/2, positions(j,2) + squareSize/2];
                if buttons(1) && IsInRect(x, y, rect)
                    userPattern(i) = j; % Record clicked index (1 to numSquares)
                    reactionTimes(highestLevel, i) = GetSecs - startTime; % Record reaction time
                    clicked = true;

                    % Clear the number on the clicked square (but keep square visible)
                    Screen('FillRect', window, white, ...
                        [positions(j,1) - squareSize/2, positions(j,2) - squareSize/2, ...
                         positions(j,1) + squareSize/2, positions(j,2) + squareSize/2]);
                    Screen('Flip', window);
                    WaitSecs(0.5); % Brief pause before next input
                    break;
                end
            end
        end
        
        % Check if the user clicked the correct square
        if userPattern(i) ~= i
            isRunning = false; % End game on mistake
            break;
        end
    end
    
    % Provide feedback if the level is completed
    if isRunning
        Screen('FillRect', window, black);
        DrawFormattedText(window, 'Level Complete!', 'center', 'center', white);
        Screen('Flip', window);
        WaitSecs(1); % Wait before next level
    end
end

% End of test
Screen('FillRect', window, black);
DrawFormattedText(window, 'Game Over!', 'center', 'center', white);
Screen('Flip', window);
WaitSecs(2);

% Display results
fprintf('Highest Level: %d\n', highestLevel);
fprintf('Reaction Times (in seconds):\n');
for level = 1:highestLevel
    fprintf('Level %d: ', level);
    disp(reactionTimes(level, 1:level + 2));
end

% Close the window
Screen('CloseAll');

