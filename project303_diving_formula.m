function totalScore = calculateDivingScore(judgeScores, degreeOfDifficulty)
    
    % remove two highest and two lowest scores
    judgeScores = sort(judgeScores, 'ascend');
    middleScores = judgeScores(3:end-2);
    
    % sum of the middle scores
    sumMiddleScores = sum(middleScores);
    
    % total score
    totalScore = sumMiddleScores * degreeOfDifficulty * 0.6;
end

% Main program to read data and calculate scores
data = readtable('data/Diving2000.csv');
uniqueDives = unique(data(:, {'Diver', 'Country', 'DiveNo', 'Difficulty'}), 'rows');

for i = 1:height(uniqueDives)
    % Extract data for each dive
    diveData = data(strcmp(data.Diver, uniqueDives.Diver{i}) & ...
                     data.DiveNo == uniqueDives.DiveNo(i), :);

    % Check if the diver is "XIONG Ni" and rank is 1
    if strcmp(uniqueDives.Diver{i}, "XIONG Ni") && any(diveData.Rank == 1)
        % Scores and degree of difficulty for this dive
        scores = diveData.JScore;
        diverNationality = uniqueDives.Country{i};
        DD = uniqueDives.Difficulty(i);

        % Calculate the total score for the dive
        totalScore = calculateDivingScore(scores, DD);
        fprintf('Total Score for %s (Country: %s, Dive %d): %.2f\n', ...
                uniqueDives.Diver{i}, diverNationality, uniqueDives.DiveNo(i), totalScore);
    end
end