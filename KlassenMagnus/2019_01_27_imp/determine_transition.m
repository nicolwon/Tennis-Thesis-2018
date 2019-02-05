function [state_win, state_lose, prob_win] = determine_transition(action, transition_tracker, state, server, p)

if action > 0.9 %use_power
    state_win =  transition_tracker(state, 1);
    state_lose = transition_tracker(state, 3);
    
    if server > 0.9 %me serving
        prob_win = p(1,1);
    else %opp serving
        prob_win = p(1,2);
    end
    
else %do not use power
    state_win =  transition_tracker(state, 2);
    state_lose = transition_tracker(state, 4);
    
    if server > 0.9 %me serving
        prob_win = p(2,1);
    else %opp serving
        prob_win = p(2,2);
    end
end

end

