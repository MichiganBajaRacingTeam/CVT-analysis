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
for i = 1:num_files
    plot(primaryRPM_array(1).time, primaryRPM_array(1).signal);
    [primaryRPM_array(i).peak, primaryRPM_array(i).peak_index]...
        = max(primaryRPM_array(i).signal);
    primaryRPM_array(i).peak_time = primaryRPM_array(i).peak_index * 0.0004;
    
    % for finding steady state %
    one_sec = 1 / 0.004; % 1 second in index increments%
    steady_one = primaryRPM_array(i).peak_time + one_sec * 2.5;
    steady_two = steady_one + one_sec;
    steady_three = steady_two + one_sec;
    steady_array = [primaryRPM_array(i).signal(steady_one),...
                    primaryRPM_array(i).signal(steady_one + one_sec * .5),...
                    primaryRPM_array(i).signal(steady_one + one_sec * 1.0),...
                    primaryRPM_array(i).signal(steady_one + one_sec * 1.5),...
                    primaryRPM_array(i).signal(steady_one + one_sec * 2)];
    primaryRPM_array(i).steady = mean(steady_array);
end


