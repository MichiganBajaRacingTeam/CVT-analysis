num_files = 8;
mat = load('data/set1.mat');
init = mat.set1;

primaryRPM_array = init(1, 1:3);

for i = 2:num_files
    filename = strcat(strcat('data/set' , int2str(i)), '.mat');
    mat = load(filename);
    init = mat.(strcat('set' , int2str(i)));
    primaryRPM_array = [primaryRPM_array init(1, :)];
end
hold on;
for i = 1:31
    [primaryRPM_array(i).max, primaryRPM_array(i).max_index]...
        = max(primaryRPM_array(i).signal);
    primaryRPM_array(i).max_time = primaryRPM_array(i).max_index * 0.0004;
    
    % for finding steady state %
    one_sec = 1 / 0.0004; % 1 second in index increments%
    steady_one = primaryRPM_array(i).max_index + one_sec * 2;
    steady_array = [primaryRPM_array(i).signal(steady_one),...
                    primaryRPM_array(i).signal(steady_one + one_sec * .5),...
                    primaryRPM_array(i).signal(steady_one + one_sec * 1.0),...
                    primaryRPM_array(i).signal(steady_one + one_sec * 1.5),...
                    primaryRPM_array(i).signal(steady_one + one_sec * 2)];
    primaryRPM_array(i).steady = mean(steady_array);
    
    % to find the duration of activity
    primaryRPM_array(i).first_deriv = diff(primaryRPM_array(i).signal)./...
        diff(primaryRPM_array(i).time);
    % finding max %
    [primaryRPM_array(i).deriv_max, primaryRPM_array(i).deriv_max_index]...
        = max(primaryRPM_array(i).first_deriv);
    % finding min %
    [primaryRPM_array(i).deriv_min, primaryRPM_array(i).deriv_min_index]...
        = min(primaryRPM_array(i).first_deriv);
    
    length = primaryRPM_array(i).deriv_min_index...
        - primaryRPM_array(i).deriv_max_index;
    
    primaryRPM_array(i).active_time = length / one_sec;
    figure;
    plot(primaryRPM_array(i).time, primaryRPM_array(i).signal);
    
    % attempting to find pre peak plateau/ hump %
    
end


