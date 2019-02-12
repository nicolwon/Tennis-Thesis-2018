clearvars -except matches points
dir_base = '/Users/nicolewongsoo/Documents/Fourth Year Uni/Full Year/Thesis/Tennis-Thesis-2018/Grand Slam Point Data/';

% points = readtable(fullfile(dir_base, 'completePoints.csv'));
% matches = readtable(fullfile(dir_base, 'completeMatches.csv'));

match_ids = matches.match_id;
pServeP1 = str2double(matches.pServeP1);
pReceiveP1 = str2double(matches.pReceiveP1);
pServeP2 = str2double(matches.pServeP2);
pReceiveP2 = str2double(matches.pReceiveP2);

% init regular point state map
keySet = {'0 0','15 0','0 15','30 0','15 15', ...
        '0 30','40 0','30 15','15 30','0 40', ...
        '40 15','30 30','15 40','40 30','30 40', ...
        'AD 40','40 AD','40 40'};
valueSet = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,15,13];
pointStateMap = containers.Map(keySet, valueSet);

% init tiebreak point state map
keySetTB = {'0 0','1 0','0 1','2 0', '1 1','0 2','3 0','2 1','1 2','0 3',...
    '4 0','3 1','2 2','1 3','0 4','5 0','4 1','3 2','2 3','1 4','0 5',...
    '6 0','5 1','4 2','3 3','2 4','1 5','0 6','6 1','5 2','4 3','3 4',...
    '2 5','1 6','6 2','5 3','4 4','3 5','2 6','6 3','5 4','4 5','3 6',...
    '6 4','5 5','4 6','6 5','5 6','6 6','7 6','6 7'};
valueSetTB = [101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,...
    116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,...
    133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151];
tieBreakStateMap = containers.Map(keySetTB, valueSetTB);

% init server map
keySetServer = {1,2};
valueSetServer = [1, 0];
serverMap = containers.Map(keySetServer, valueSetServer);

impVector = zeros(size(points,1), 1);
compPointsIndex = 1;

% for each match
for rowIndex = 1:size(pServeP1, 1)
    match_id = string(match_ids(rowIndex,1));
%   can this line be vectorized?
%   information for Player 1
    [wap, state_tracker, transition_tracker] = main(pServeP1(rowIndex,1), pReceiveP1(rowIndex,1));
%     get rows in points for a certain match id
    match_points = points(strcmp(points.match_id, match_id), :);
    for pointIndex = 1:size(match_points, 1)
        try
            %       these don't need to be stored but for legibility sake...
            setCountP1 = sum(match_points.SetWinner(1:pointIndex) == 1);
            setCountP2 = sum(match_points.SetWinner(1:pointIndex) == 2);
            gameCountP1 = str2double(match_points.P1GamesWon(pointIndex));
            gameCountP2 = str2double(match_points.P2GamesWon(pointIndex));

            scoreString = string(strjoin([match_points.P1Score(pointIndex) match_points.P2Score(pointIndex)]));
            if ~(gameCountP1 == 6 && gameCountP2 == 6)
                pointState = pointStateMap(scoreString);
            else
                try
                    pointState = tiebreakMap(scoreString);
                catch
                    if str2double(match_points.P1Score(pointIndex)) > str2double(match_points.P2Score(pointIndex))
                        pointState = 150;
                    elseif str2double(match_points.P1Score(pointIndex)) < str2double(match_points.P2Score(pointIndex))
                        pointState = 151;
                    else
                        pointState = 149;
                    end
                end
            end

            if str2double(match_points.PointServer(pointIndex)) == 0
                compPointsIndex = compPointsIndex + 1;
                continue
            else
                server = serverMap(str2double(match_points.PointServer(pointIndex)));
            end
            % state = (0, setCountP1, setCountP2, gameCountP1, gameCountP2, pointState, server)
            state = [0, setCountP1, setCountP2, gameCountP1, gameCountP2, pointState, server];

            idx = find(ismember(state_tracker, state, 'rows'));
            s_plus = transition_tracker(idx, 2);
            s_minus = transition_tracker(idx, 4);
            imp = wap(s_plus) - wap(s_minus);
            impVector(compPointsIndex) = imp;
            fprintf('Point %d: %s point %d has importance %f.\n', compPointsIndex, match_id, pointIndex, imp);
            compPointsIndex = compPointsIndex + 1;
        catch
            compPointsIndex = compPointsIndex + 1;
        end
    end
end

final = horzcat(points, array2table(impVector));
writetable(final, 'pointsWithImp.csv');
