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

% x = primaryRPM_array(4).time;
% y = primaryRPM_array(4).signal;
% yy = smooth(y, 200, 'moving');
% dyy = smooth(diff(yy)./diff(x), 200, 'moving');
% 
% figure;
% plot(x, yy);
% hold on;
% plot(x(2:end), dyy);


for i = 1:31
    one_sec = 1 / 0.0004; % 1 second in index increments%
    time = primaryRPM_array(i).time; % to make life easier
    sig = primaryRPM_array(i).signal; % to make life easier
    
    % code to find peak %
    [primaryRPM_array(i).max, primaryRPM_array(i).max_index]...
        = max(sig);
    primaryRPM_array(i).max_time = primaryRPM_array(i).max_index / one_sec;
    
    % for finding steady state %
    
    steady_one = primaryRPM_array(i).max_index + one_sec * 2;
    steady_array = [sig(steady_one), sig(steady_one + one_sec * .5),...
                    sig(steady_one + one_sec * 1.0),...
                    sig(steady_one + one_sec * 1.5),...
                    sig(steady_one + one_sec * 2)];
    primaryRPM_array(i).steady = mean(steady_array);
    
    % to find the duration of activity
    smooth_sig = smooth(sig, 200, 'moving');
    smooth_deriv = smooth(diff(smooth_sig)./diff(time), 200, 'moving');
    % finding max %
    [primaryRPM_array(i).deriv_max, primaryRPM_array(i).deriv_max_index]...
        = max(smooth_deriv);
    % finding min %
    [primaryRPM_array(i).deriv_min, primaryRPM_array(i).deriv_min_index]...
        = min(smooth_deriv);
    
    length = primaryRPM_array(i).deriv_min_index...
        - primaryRPM_array(i).deriv_max_index;
    
    primaryRPM_array(i).active_time = length / one_sec;
    
    % attempting to find pre peak plateau/ hump %
    first = primaryRPM_array(i).deriv_max_index;
    last = primaryRPM_array(i).max_index;
    [plateau_grad, plateau_index] = min(smooth_deriv(first:last));
    if plateau_grad < 100
        primaryRPM_array.plat_bool = 1;
        primaryRPM_array.plateau = smooth_sig(plateau_index);
    end
end




