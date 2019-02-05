function [state_tracker_name, transition_tracker_name] = create_file_names(B, n_sets, final_set_mode)

state_tracker_name = strcat('data_state_', num2str(B), '_', num2str(n_sets), '_', num2str(final_set_mode), '.mat');
transition_tracker_name = strcat('data_transition_', num2str(B), '_', num2str(n_sets), '_', num2str(final_set_mode), '.mat');

end

