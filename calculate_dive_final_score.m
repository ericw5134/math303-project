function totalScore = calculateDivingScore(judgeScores, degreeOfDifficulty)
    % check if there are enough scores to calculate a valid total score
    if length(judgeScores) < 7
        error('Not enough scores to calculate a diving score.');
    end
    
    % remove two highest and two lowest scores
    judgeScores = sort(judgeScores, 'ascend');
    middleScores = judgeScores(3:end-2);

    % sum of the middle scores
    executionScore = sum(middleScores);

    % total score
    totalScore = executionScore * degreeOfDifficulty;
end

% Main program to read data and calculate scores
data = readtable('data/Diving2000.csv');

% Get unique dives based on Event, Round, Diver, Country, and Rank
uniqueDives = unique(data(:, {'Event', 'Round', 'Diver', 'Country', 'Rank', 'DiveNo', 'Difficulty'}), 'rows');

% Initialize total scores for XIONG Ni
totalPrelimScore = 0;
totalSemiFinalScore = 0;
totalFinalScore = 0;

% Loop through each unique dive entry
for i = 1:height(uniqueDives)
    if strcmp(uniqueDives.Diver{i}, "XIONG Ni")
        % Extract data for each round
        diveDataPrelim = data(strcmp(data.Event, uniqueDives.Event{i}) & ...
                              strcmp(data.Round, 'Prelim') & ...
                              strcmp(data.Diver, uniqueDives.Diver{i}) & ...
                              strcmp(data.Country, uniqueDives.Country{i}) & ...
                              uniqueDives.DiveNo(i) == data.DiveNo, :);
    
        diveDataSemi = data(strcmp(data.Event, uniqueDives.Event{i}) & ...
                            strcmp(data.Round, 'Semi') & ...
                            strcmp(data.Diver, uniqueDives.Diver{i}) & ...
                            strcmp(data.Country, uniqueDives.Country{i}) & ...
                            uniqueDives.DiveNo(i) == data.DiveNo, :);
    
        diveDataFinal = data(strcmp(data.Event, uniqueDives.Event{i}) & ...
                             strcmp(data.Round, 'Final') & ...
                             strcmp(data.Diver, uniqueDives.Diver{i}) & ...
                             strcmp(data.Country, uniqueDives.Country{i}) & ...
                             uniqueDives.DiveNo(i) == data.DiveNo, :);

        % Check if there are enough scores for each round
        if ~isempty(diveDataPrelim)
            scoresPrelim = diveDataPrelim.JScore;
            DD_P = uniqueDives.Difficulty(i);  % Difficulty for Prelim
            prelimRoundScore = calculateDivingScore(scoresPrelim, DD_P);
            totalPrelimScore = totalPrelimScore + prelimRoundScore;
        end
        
        if ~isempty(diveDataSemi)
            scoresSemi = diveDataSemi.JScore;
            DD_S = uniqueDives.Difficulty(i);  % Difficulty for Semi
            semiRoundScore = calculateDivingScore(scoresSemi, min(DD_S, 9.5));  % Limit for Semi
            totalSemiFinalScore = totalSemiFinalScore + semiRoundScore;
        end

        if ~isempty(diveDataFinal)
            scoresFinal = diveDataFinal.JScore;
            DD_F = uniqueDives.Difficulty(i);  % Difficulty for Final
            finalRoundScore = calculateDivingScore(scoresFinal, DD_F);
            totalFinalScore = totalFinalScore + finalRoundScore;
        end

        % Display scores for each round
        fprintf('Scores for %s (Country: %s, DiveNo: %d): Prelim: %.2f, Semi: %.2f, Final: %.2f\n', ...
                uniqueDives.Diver{i}, uniqueDives.Country{i}, uniqueDives.DiveNo(i), ...
                prelimRoundScore, semiRoundScore, finalRoundScore);
    end
end

% Calculate the final total score for XIONG Ni based on Semi and Final scores
finalTotalScore = totalSemiFinalScore + totalFinalScore;

% Display the final total score for XIONG Ni
fprintf('Final Total Score for XIONG Ni: %.2f\n', finalTotalScore);