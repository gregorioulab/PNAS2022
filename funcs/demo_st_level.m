% Function that evaluates the statistical significance level of permutation
% test and creates custom labels for plotting this level

% Inputs:
%       sign_t: array that stores statistically significant time steps
%       time: whole time of analysis
%       t: current time step
%       p_val: actual p-values
%       p_cutoff: hyperparameter containing statisticall significance level

% Outputs:
        % sign_t: evaluated statistical significance

function sign_t = demo_st_level(sign_t,time,t,p_val,p_cutoff)
    
    % for t==1 look only forward
    if t == 1
        if p_val(t:t+4) < p_cutoff
            sign_t(1,t) = 3;
        end
    % for t==2 there exists 1 backward time step
    elseif t == 2
        if p_val(t-1:t+3) < p_cutoff
            sign_t(1,t) = 3;
        end
    % for t==(end-1) there exists only 1 forward time step
    elseif t == length(time)-1
        if p_val(t-3:t+1) < p_cutoff
            sign_t(1,t) = 3;
        end
    % for t==end look only backward
    elseif t == length(time)
        if p_val(t-4:t) < p_cutoff
            sign_t(1,t) = 3;
        end
    % all other ts
    else
        if p_val(t-2:t+2) < p_cutoff
            sign_t(1,t) = 3;
        end
    end

end