% Function that computes p-values for observed data vs the null distribution
% 
% Inputs:
%       observed_acc: observed accuracies
%       null_acc: null accuracies from data shuffling
% 
% Outputs:
%       p_values: one-sided p-values for observed data

function [p_values] = demo_chance(observed_acc, null_acc)

nShuffles = size(null_acc, 1);
nTimes    = size(null_acc, 2);

p_values = nan(1, nTimes);
for iTime=1:nTimes
    myAcc = mean(observed_acc(:,iTime),1);
    % compare the observed with the null distribution 
    p_values(iTime) = (sum(null_acc(:, iTime)>=myAcc))/(nShuffles);
end

end