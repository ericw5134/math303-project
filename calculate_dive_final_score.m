function totalScore = calculateDivingScore(judgeScores, judgeCountries, diverCountry, degreeOfDifficulty, diverScores, C)
    if length(judgeScores) < 7
        error('Not enough scores to calculate a diving score.');
    end
    
    % apply dynamic bias-adjusting constant B
    biasFactor = ones(size(judgeScores)); 
    biasFactor(strcmp(judgeCountries, diverCountry)) = 0.8; 
    adjustedScores = judgeScores .* biasFactor;

    % remove two highest and two lowest scores
    adjustedScores = sort(adjustedScores, 'ascend');
    middleScores = adjustedScores(3:end-2);

    % sum of the middle scores
    executionScore = sum(middleScores);

    % calculate round score with performance consistency factor C
    totalScore = (executionScore * degreeOfDifficulty) - C;
end

function C = calculatePerformanceConsistencyFactor(diverScores)
    if length(diverScores) > 1
        C = std(diverScores);
    else
        C = 0.1; % if not enough data
    end
end


data = readtable('data/Diving2000.csv');
uniqueDives = unique(data(:, {'Event', 'Round', 'Diver', 'Country', 'Rank', 'DiveNo', 'Difficulty'}), 'rows');
adjustedScoresTable = table(uniqueDives.Diver, uniqueDives.Country, uniqueDives.Event, uniqueDives.Round, ...
                    zeros(height(uniqueDives), 1), 'VariableNames', ...
                    {'Diver', 'Country', 'Event', 'Round', 'AdjustedScore'});

% loop through each unique dive entry
for i = 1:height(uniqueDives)
    diver = uniqueDives.Diver{i};
    diverCountry = uniqueDives.Country{i};
    event = uniqueDives.Event{i};
    round = uniqueDives.Round{i};

    % calculate C
    diverScores = data.JScore(strcmp(data.Diver, diver));
    C = calculatePerformanceConsistencyFactor(diverScores);

    diveData = data(strcmp(data.Event, event) & ...
                    strcmp(data.Diver, diver) & ...
                    uniqueDives.DiveNo(i) == data.DiveNo, :);

    if ~isempty(diveData)
        scores = diveData.JScore;
        judgeCountries = diveData.JCountry;
        DD = uniqueDives.Difficulty(i); % degree of diffculty 
        roundScore = calculateDivingScore(scores, judgeCountries, diverCountry, DD, diverScores, C);
        adjustedScoresTable.AdjustedScore(i) = roundScore;
    end
end

% sum scores by diver and event, then rank by adjusted score within each event
finalScores = varfun(@sum, adjustedScoresTable, 'InputVariables', 'AdjustedScore', ...
                     'GroupingVariables', {'Diver', 'Event', 'Round'});

% advance top 18 divers from Preliminary to Semi-final round
preliminaryRounds = finalScores(strcmp(finalScores.Round, 'Preliminary'), :);
top18Preliminary = sortrows(preliminaryRounds, 'sum_AdjustedScore', 'descend');
top18Preliminary = top18Preliminary(1:min(18, height(top18Preliminary)), :);

% combine Preliminary and Semi-final scores for Semi-final ranking
semiFinalRounds = finalScores(strcmp(finalScores.Round, 'Semi-final'), :);
combinedSemiFinalScores = [top18Preliminary(:, {'Diver', 'Event', 'sum_AdjustedScore'}); semiFinalRounds(:, {'Diver', 'Event', 'sum_AdjustedScore'})];
combinedSemiFinalScores.Properties.VariableNames{'sum_AdjustedScore'} = 'AdjustedScore';

% sum the scores from Preliminary and Semi-final rounds
combinedSemiFinalScores = varfun(@sum, combinedSemiFinalScores, 'InputVariables', 'AdjustedScore', ...
                                 'GroupingVariables', {'Diver', 'Event'});

% advance top 12 divers from Semi-final to Final round
top12SemiFinal = sortrows(combinedSemiFinalScores, 'sum_AdjustedScore', 'descend');
top12SemiFinal = top12SemiFinal(1:min(12, height(top12SemiFinal)), :);

% combine Semi-final and Final scores for Final ranking
finalRounds = finalScores(strcmp(finalScores.Round, 'Final'), :);
combinedFinalScores = [top12SemiFinal(:, {'Diver', 'Event', 'sum_AdjustedScore'}); finalRounds(:, {'Diver', 'Event', 'sum_AdjustedScore'})];

% sum the scores from both Semi-final and Final rounds
combinedFinalScores.Properties.VariableNames{'sum_AdjustedScore'} = 'AdjustedScore';
finalRanking = varfun(@sum, combinedFinalScores, 'InputVariables', 'AdjustedScore', ...
                      'GroupingVariables', {'Diver', 'Event'});
finalRanking.sum_AdjustedScore = finalRanking.sum_AdjustedScore / 3.5;

sortedFinalRanking = sortrows(finalRanking, {'Event', 'sum_AdjustedScore'}, {'ascend', 'descend'});

% display updated top10 ranking for each event
events = unique(sortedFinalRanking.Event);
for i = 1:length(events)
    event = events{i};
    disp(['Top Competitors for ', event, ':']);
    eventScores = sortedFinalRanking(strcmp(sortedFinalRanking.Event, event), :);
    disp(eventScores(1:min(10, height(eventScores)), {'Diver', 'sum_AdjustedScore'}));
end

