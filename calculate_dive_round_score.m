function totalScore = calculateDivingScore(scores, difficulty)
    sortedScores = sort(scores, 'ascend');
    middleScores = sortedScores(3:end-2);
    executionScore = sum(middleScores);
    totalScore = executionScore * difficulty;
end

data = readtable('/mnt/data/Diving2000.csv');
uniqueDives = unique(data(:, {'Diver', 'Country', 'DiveNo', 'Difficulty'}), 'rows');

for i = 1:height(uniqueDives)
    % Extract data for each dive
    diveData = data(strcmp(data.Diver, uniqueDives.Diver{i}) & ...
                    data.DiveNo == uniqueDives.DiveNo(i), :);
    
    % Scores and judge nationalities for this dive
    scores = diveData.JScore;
    judgeNationalities = diveData.JCountry;
    diverNationality = uniqueDives.Country{i};
    difficulty = uniqueDives.Difficulty(i);
    
    % Calculate the total score for the dive
    totalScore = calculateDivingScore(scores, difficulty);
    fprintf('Total Score for %s (Country: %s, Dive %d): %.2f\n', ...
            uniqueDives.Diver{i}, diverNationality, uniqueDives.DiveNo(i), totalScore);
    
    % Bias detection: Check if each judge’s nationality matches the diver’s nationality
    for j = 1:length(judgeNationalities)
        if strcmp(judgeNationalities{j}, diverNationality)
            fprintf('Judge from %s scored diver %s from %s\n', ...
                    judgeNationalities{j}, uniqueDives.Diver{i}, diverNationality);
        end
    end
end