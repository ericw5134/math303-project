function totalScore = calculateDivingScore(judgeScores, degreeOfDifficulty)
    judgeScores = sort(judgeScores, 'ascend');
    
    % Remove two highest and two lowest scores
    middleScores = judgeScores(3:end-2);
    
    % Sum of the middle scores
    sumMiddleScores = sum(middleScores);
    
    % Total score
    totalScore = sumMiddleScores * degreeOfDifficulty * 0.6;
end

% Examples
judgeScore1 = [8.0, 8.5, 7.5, 8.0, 8.5, 7.5, 8.0];
degreeOfDifficulty1 = 2.5;
totalScore1 = calculateDivingScore(judgeScore1, degreeOfDifficulty1);
fprintf('Total Score for Example 1: %.2f\n', totalScore1);

judgeScore2 = [9.0, 9.5, 8.5, 9.0, 9.5, 8.0, 9.0];
degreeOfDifficulty2 = 3.2;
totalScore2 = calculateDivingScore(judgeScore2, degreeOfDifficulty2);
fprintf('Total Score for Example 2: %.2f\n', totalScore2);