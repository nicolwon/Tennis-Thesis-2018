function T = transition_matrix(state_tracker, transition_tracker, p, policy)

%number of states
n_state = size(transition_tracker, 1);

%using sparse(i,j,s,m,n,nzmax) for computational efficiency
i = (1 : n_state)';
j_1 = zeros(n_state, 1);
j_2 = zeros(n_state, 1);
s_1 = zeros(n_state, 1);
s_2 = zeros(n_state, 1);
m = n_state;
n = n_state;
nzmax = 2*n_state;

%iterate over states (excluding win and lose states)
for state = 1 : n_state - 2
    
    %who is serving in this state (1 => me, 0 => opp)
    server = state_tracker(state, 7);
    
    %extract action (0 => do not use energy, 1 => use energy)
    action = policy(state);
    
    %determine transition
    [state_win, state_lose, prob_win] = determine_transition(action, transition_tracker, state, server, p);
    
    %fill
    j_1(state) = state_win;
    j_2(state) = state_lose;
    
    s_1(state) = prob_win;
    s_2(state) = 1 - prob_win;   
        
end

%win state (absorption)
j_1(n_state - 1) = n_state - 1;
j_2(n_state - 1) = n_state - 1;
s_1(n_state - 1) = 1;
s_2(n_state - 1) = 0;

%lose state (absorption)
j_1(n_state) = n_state;
j_2(n_state) = n_state;
s_1(n_state) = 1;
s_2(n_state) = 0;

%win transitions
T1 = sparse(i,j_1,s_1,m,n,nzmax);

%lose transitions
T2 = sparse(i,j_2,s_2,m,n,nzmax);

%win + lose transitions
T = T1 + T2;

end

