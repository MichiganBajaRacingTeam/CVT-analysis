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

for i = 25
    
    one_sec = 1 / 0.0004; % 1 second in index increments
    time = primaryRPM_array(i).time; % to make life easier
    sig = primaryRPM_array(i).signal; % to make life easier
    
    % to check if the data fits
    time_meas = size(time);
    time_check = time_meas(1);
    if time_check > one_sec * 15
        continue
    end
    
    smooth_sig = smooth(sig, 200, 'moving');
    smooth_deriv = smooth(diff(smooth_sig)./diff(time), 200, 'moving');
    
    %to find the duration of activity
    [primaryRPM_array(i).deriv_max, primaryRPM_array(i).deriv_max_index]...
        = max(smooth_deriv(1:one_sec * 5));
    [primaryRPM_array(i).deriv_min, primaryRPM_array(i).deriv_min_index]...
        = min(smooth_deriv);
    
    active_length = primaryRPM_array(i).deriv_min_index...
        - primaryRPM_array(i).deriv_max_index;
 
    primaryRPM_array(i).active_time = active_length / one_sec;
    
    %code to find peak %
    [start_val, start_index] = max(smooth_deriv(1:one_sec * 4));
    temp = primaryRPM_array(i).deriv_max_index;
    [end_val, end_index] = min(smooth_deriv(temp:one_sec * 4));
    end_index = start_index + end_index;
    
    [primaryRPM_array(i).peak, temp_ind]...
        = max(sig(start_index:end_index));
    primaryRPM_array(i).peak_index = temp_ind + start_index;
    
    primaryRPM_array(i).peak_time = primaryRPM_array(i).peak_index / one_sec;
    
    %for finding steady state
    peak_temp = primaryRPM_array(i).peak_index;
    steady_array = smooth_sig(peak_temp + 1.5 * one_sec: peak_temp + 3.5 * one_sec);
    primaryRPM_array(i).steady = mean(steady_array);
    
    %attempting to find pre peak plateau/hump 
    last = primaryRPM_array(i).peak_index - one_sec * 0.25;
    first = last - one_sec;
    [plateau_grad, plateau_temp] = min(smooth_deriv(first:last));
    plateau_index = plateau_temp + first;
    primaryRPM_array(i).plateau_bool = 0;
    primaryRPM_array(i).plateau = 0;
    if plateau_grad < 100
        primaryRPM_array(i).plateau_bool = 1;
        primaryRPM_array(i).plateau = smooth_sig(plateau_index);
    end
end

% for testing
x = primaryRPM_array(i);
hold on;
plot(x.time, smooth_sig);
plot(x.time, sig);

len = size(x.time);
plot(x.time, ones(len(1), 1) * x.steady);
plot(x.time, ones(len(1), 1) * x.peak);

if x.plateau_bool == 1
    plot(x.time, ones(len(1), 1) * x.plateau);
end

plot(x.time(2:end), smooth_deriv);

