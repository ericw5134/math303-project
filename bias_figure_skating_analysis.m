filename = 'fs-data.csv';
data = readtable(filename);

data.SP = str2double(strrep(data.SP, ',', '.'));
data.FS = str2double(strrep(data.FS, ',', '.'));
data.Total = str2double(strrep(data.Total, ',', '.'));
ranks = (1:height(data))';

figure;
scatter(ranks, data.Total, 70, 'filled');
hold on;

p = polyfit(ranks, data.Total, 2);
yfit = polyval(p, ranks);
plot(ranks, yfit, '--r', 'LineWidth', 1.5);

title('Ranking vs. Total Score with Polynomial Regression');
xlabel('Rank');
ylabel('Total Score');
grid on;

text(ranks, data.Total, data.Performer, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

equation = sprintf('y = %.2fx^2 + %.2fx + %.2f', p(1), p(2), p(3));
annotation('textbox', [0.2, 0.75, 0.3, 0.1], 'String', equation, ...
           'FitBoxToText', 'on', 'BackgroundColor', 'white', 'EdgeColor', 'black');

hold off;

figure;
bar(categorical(data.Performer, data.Performer), [data.SP, data.FS], 'stacked');
title('Short Program vs. Free Skating Scores');
xlabel('Performer');
ylabel('Score');
legend('Short Program', 'Free Skating');
xtickangle(45);
grid on;

figure;
boxplot([data.SP, data.FS, data.Total], {'Short Program', 'Free Skating', 'Total'});
title('Score Consistency Across Categories');
ylabel('Score');
grid on;

figure;
scatter(data.SP, data.FS, 70, 'filled');
title('Correlation Between Short Program and Free Skating Scores');
xlabel('Short Program Score');
ylabel('Free Skating Score');
grid on;
text(data.SP, data.FS, data.Performer, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right');

figure;
SP_Fraction = sum(data.SP) / sum(data.Total) * 100;
FS_Fraction = sum(data.FS) / sum(data.Total) * 100;
pie([SP_Fraction, FS_Fraction], {'Short Program', 'Free Skating'});
title('Overall Contribution to Total Score');

figure;
diffs = abs(data.Total - mean(data.Total));
bar(categorical(data.Performer, data.Performer), diffs);
title('Score Differences from the Average');
xlabel('Performer');
ylabel('Difference from Average');
xtickangle(45);
grid on;