function totalScore = calculateDivingScore(judgeScores, degreeOfDifficulty, judgeNationalities, diverNationality, B)
    % Adjust scores for nationality
    for i = 1:length(judgeScores)
        if strcmp(judgeNationalities{i}, diverNationality)
            judgeScores(i) = B * judgeScores(i);
        end
    end

    judgeScores = sort(judgeScores, 'ascend');
    
    % Remove two highest and two lowest scores
    middleScores = judgeScores(3:end-2);
    
    % Sum of the middle scores
    sumMiddleScores = sum(middleScores);
    
    % Calculate total score
    totalScore = sumMiddleScores * degreeOfDifficulty * 0.6;
end

% Examples
judgeScoresExample1 = [8.0, 8.5, 7.5, 8.0, 8.5, 7.5, 8.0];
degreeOfDifficulty1 = 2.5;
judgeNationalitiesExample1 = {'USA', 'USA', 'CAN', 'GBR', 'GBR', 'AUS', 'AUS'};
diverNationality1 = 'USA';
B1 = 0.9;
totalScore1 = calculateDivingScore(judgeScoresExample1, degreeOfDifficulty1, judgeNationalitiesExample1, diverNationality1, B1);
fprintf('Total Score for Example 1: %.2f\n', totalScore1);


judgeScoresExample2 = [9.0, 9.5, 8.5, 9.0, 9.5, 8.0, 9.0];
degreeOfDifficulty2 = 3.2;
judgeNationalitiesExample2 = {'CHN', 'CHN', 'JPN', 'KOR', 'KOR', 'CHN', 'JPN'};
diverNationality2 = 'CHN';
B2 = 0.85;
totalScore2 = calculateDivingScore(judgeScoresExample2, degreeOfDifficulty2, judgeNationalitiesExample2, diverNationality2, B2);
fprintf('Total Score for Example 2: %.2f\n', totalScore2);