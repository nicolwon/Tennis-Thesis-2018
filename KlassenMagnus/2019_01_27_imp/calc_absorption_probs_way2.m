function win_absorption_probs = calc_absorption_probs_way2(T, n_states)

Q = T(1:n_states-2,1:n_states-2);
R = T(1:n_states-2, n_states-1:n_states);
I_t = speye(n_states-2);
%N = inv( I_t - Q);
B = (I_t - Q)\R;
win_absorption_probs = B(:, 1);
win_absorption_probs(n_states - 1) = 1;
win_absorption_probs(n_states) = 0;

% sparse to full
win_absorption_probs = full(win_absorption_probs);

end

