function [state_tracker, transition_tracker] = load_data(B, n_sets, final_set_mode)

%file names
[state_tracker_name, transition_tracker_name] = create_file_names(B, n_sets, final_set_mode);

%directory
dir = get_directory();
dir1 = [dir, state_tracker_name];
dir2 = [dir, transition_tracker_name];

%state tracker (energyAvailable, mySets, oppSets, myGames, oppGames,
%gameState/tiebreakState, server (1 => me, 0 => opp))
load(dir1);

%transition tracker (power + win, no power + win, power + lose
%no power + lose)
load(dir2);


end

