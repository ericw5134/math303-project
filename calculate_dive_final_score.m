function totalScore = calculateDivingScore(judgeScores, judgeCountries, diverCountry, degreeOfDifficulty, diverScores, C)
    % Check if there are enough scores to calculate a valid total score
    if length(judgeScores) < 7
        error('Not enough scores to calculate a diving score.');
    end
    
    % Apply dynamic bias adjustment factor B
    biasFactor = ones(size(judgeScores)); % Default biasFactor is 1.0
    biasFactor(strcmp(judgeCountries, diverCountry)) = 0.8; % Adjust for shared nationality

    adjustedScores = judgeScores .* biasFactor;

    % Remove two highest and two lowest scores
    adjustedScores = sort(adjustedScores, 'ascend');
    middleScores = adjustedScores(3:end-2);

    % Sum of the middle scores
    executionScore = sum(middleScores);

    % Calculate the standard deviation (SD) of the diver's scores
    if ~isempty(diverScores)
        SD = std(diverScores);
    else
        SD = 0; % Default to 0 if no historical data is available
    end

    % Calculate total score with performance consistency adjustment
    totalScore = (executionScore * degreeOfDifficulty) - C;
end

function C = calculatePerformanceConsistencyFactor(diverScores)
    if length(diverScores) > 1
        C = std(diverScores);
    else
        C = 0.1; % Default value if not enough data
    end
end

% Main program to read data and calculate scores
data = readtable('data/Diving2000.csv');

% Get unique dives based on Event, Round, Diver, Country, and Rank
uniqueDives = unique(data(:, {'Event', 'Round', 'Diver', 'Country', 'Rank', 'DiveNo', 'Difficulty'}), 'rows');

% Initialize scores
scoresTable = table(uniqueDives.Diver, uniqueDives.Country, uniqueDives.Event, uniqueDives.Round, ...
                    zeros(height(uniqueDives), 1), 'VariableNames', ...
                    {'Diver', 'Country', 'Event', 'Round', 'AdjustedScore'});

% Loop through each unique dive entry
for i = 1:height(uniqueDives)
    % Extract data for each round
    diver = uniqueDives.Diver{i};
    diverCountry = uniqueDives.Country{i};
    event = uniqueDives.Event{i};
    round = uniqueDives.Round{i};

    % Historical scores for consistency factor
    diverScores = data.JScore(strcmp(data.Diver, diver));

    % Calculate performance consistency factor C
    C = calculatePerformanceConsistencyFactor(diverScores);

    diveData = data(strcmp(data.Event, event) & ...
                    strcmp(data.Diver, diver) & ...
                    uniqueDives.DiveNo(i) == data.DiveNo, :);

    if ~isempty(diveData)
        scores = diveData.JScore;
        judgeCountries = diveData.JCountry;
        DD = uniqueDives.Difficulty(i); % Difficulty level
        roundScore = calculateDivingScore(scores, judgeCountries, diverCountry, DD, diverScores, C);
        scoresTable.AdjustedScore(i) = roundScore;
    end
end

% Sum scores by diver and event, then rank by adjusted score within each event
finalScores = varfun(@sum, scoresTable, 'InputVariables', 'AdjustedScore', ...
                     'GroupingVariables', {'Diver', 'Event', 'Round'});

% Advance top 18 divers from Preliminary to Semi-final round
preliminaryRounds = finalScores(strcmp(finalScores.Round, 'Preliminary'), :);
top18Preliminary = sortrows(preliminaryRounds, 'sum_AdjustedScore', 'descend');
top18Preliminary = top18Preliminary(1:min(18, height(top18Preliminary)), :);

% Combine Preliminary and Semi-final scores for Semi-final ranking
semiFinalRounds = finalScores(strcmp(finalScores.Round, 'Semi-final'), :);
combinedSemiFinalScores = [top18Preliminary(:, {'Diver', 'Event', 'sum_AdjustedScore'}); semiFinalRounds(:, {'Diver', 'Event', 'sum_AdjustedScore'})];
combinedSemiFinalScores.Properties.VariableNames{'sum_AdjustedScore'} = 'AdjustedScore';
combinedSemiFinalScores = varfun(@sum, combinedSemiFinalScores, 'InputVariables', 'AdjustedScore', ...
                                 'GroupingVariables', {'Diver', 'Event'});

% Advance top 12 divers from Semi-final to Final round
top12SemiFinal = sortrows(combinedSemiFinalScores, 'sum_AdjustedScore', 'descend');
top12SemiFinal = top12SemiFinal(1:min(12, height(top12SemiFinal)), :);

% Combine Semi-final and Final scores for Final ranking
finalRounds = finalScores(strcmp(finalScores.Round, 'Final'), :);
combinedFinalScores = [top12SemiFinal(:, {'Diver', 'Event', 'sum_AdjustedScore'}); finalRounds(:, {'Diver', 'Event', 'sum_AdjustedScore'})];
combinedFinalScores.Properties.VariableNames{'sum_AdjustedScore'} = 'AdjustedScore';
finalRanking = varfun(@sum, combinedFinalScores, 'InputVariables', 'AdjustedScore', ...
                      'GroupingVariables', {'Diver', 'Event'});

% Sort scores in descending order within each event and display top competitors for each event
sortedFinalRanking = sortrows(finalRanking, {'Event', 'sum_AdjustedScore'}, {'ascend', 'descend'});

% Display updated ranking for each individual event (Top 10 competitors)
events = unique(sortedFinalRanking.Event);
for i = 1:length(events)
    event = events{i};
    disp(['Top Competitors for ', event, ':']);
    eventScores = sortedFinalRanking(strcmp(sortedFinalRanking.Event, event), :);
    disp(eventScores(1:min(10, height(eventScores)), {'Diver'}));
end