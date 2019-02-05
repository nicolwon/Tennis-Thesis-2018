function [win_absorption_probs, state_tracker, transition_tracker] = main(p_serve, p_receive)

% INPUTS-------------------------------------------------------------------
%   (1) p_serve = point-win prob for player A when A serves (scalar)
%   (2) p_recieve = point-win prob for player A when B serves (scalar)

% OUTPUT
%   (1) win_absorption_probs = P(player A wins match from each state) (vector)
%   (2) state_tracker = information of each state (each row of
%   state_tracker corresponds to each row of win_absorption_probs)
%   (3) transition_tracker = transition information (columnns 2 and 4 are
%   important; correspond to win and lose)
% -------------------------------------------------------------------------

% USER PARAMETERS----------------------------------------------------------
% initial energy budget
B = 0; % comment for Nicole: do not change this

% best of n_sets (could be 1, 3, or 5)
n_sets = 3;

% final set mode (0 => no tie-break, 1 => tie-break)
final_set_mode = 1;
% -------------------------------------------------------------------------

% ALGORITHM----------------------------------------------------------------
% load data 
% comment for Nicole:
%   (1) change dir_base in the function get_directory
%   (2) understand state_tracker (I should explain it perhaps) 
[state_tracker, transition_tracker] = load_data(B, n_sets, final_set_mode);

% transition probability matrix (do not change)
% row 1 => use the power
% row 2 => do not use the power
% col 1 => my serve
% col 2 => opponent's serve
p = [1            1;
    p_serve p_receive];

% number of states
n_states = size(state_tracker, 1);

% initialize "dummy" policy (0 => do not use energy, 1 => use energy)
policy = zeros(n_states, 1);

% transition matrix corresponding to policy
T = transition_matrix(state_tracker, transition_tracker, p, policy);

% compute win_absorption_probs
win_absorption_probs = calc_absorption_probs_way2(T, n_states);
% -------------------------------------------------------------------------

end

