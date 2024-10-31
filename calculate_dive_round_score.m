function totalScore = calculateDivingScore(scores, difficulty, judgeNationalities, diverNationality)
    % Adjustment factor B
    B = 0.9;

    % Adjust scores for nationality
    for i = 1:length(scores)
        if strcmp(judgeNationalities{i}, diverNationality)
            scores(i) = B * scores(i);
        end
    end

    % Remove two highest and two lowest scores
    sortedScores = sort(scores, 'ascend');
    middleScores = sortedScores(3:end-2);
    
    % Total score calculation
    executionScore = sum(middleScores);
    totalScore = executionScore * difficulty;
end
data = readtable('data/Diving2000.csv');
uniqueDives = unique(data(:, {'Event', 'Round', 'Diver', 'Country', 'Rank', 'DiveNo', 'Difficulty'}), 'rows');
for i = 1:height(uniqueDives)
    diveData = data(strcmp(data.Diver, uniqueDives.Diver{i}) & ...
                    data.DiveNo == uniqueDives.DiveNo(i), :);
    
    % scores and judge nationalities for this dive
    scores = diveData.JScore;
    judgeNationalities = diveData.JCountry;
    diverNationality = uniqueDives.Country{i};
    DD = uniqueDives.Difficulty(i);
    
    roundScore = calculateDivingScore(scores, DD, judgeNationalities, diverNationality);
    
    fprintf('Original Score for %s (Country: %s, DiveNo %d): %.2f\n', ...
            uniqueDives.Diver{i}, diverNationality, uniqueDives.DiveNo(i), roundScore);
end