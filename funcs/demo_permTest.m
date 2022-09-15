%% compute significance between group means using a permutation test
% Example:
% condA = ones(10, 1); condB = 2*ones(12,1);
% [p, c, distDiff] = examplePermTest(condA, condB, 1000)

function [p, distDiff, obsDiff] = ...
    demo_permTest(condA, condB, nPermutations, onewaytest, sign)

if ~exist('onewaytest', 'var')
    onewaytest = false;
end

if ~exist('sign', 'var')
    sign = [];
end
%% convert to column vector
if size(condA,1) == 1
    condA = condA';
end
if size(condB,1) == 1
    condB = condB';
end
%% remove nans and compute mean accross neurons
meanCondA = nanmean(condA);
meanCondB = nanmean(condB);

% compute observed difference
obsDiff = meanCondA - meanCondB;

% remove nans
condA(isnan(condA)) = [];
condB(isnan(condB)) = [];
%% merge matrices from the two conditions into a single matrix
condBoth = vertcat(condA,condB);

% start permutations 
distDiff = nan(nPermutations,1);
for permN = 1:nPermutations
    
    % create random indices for matrix rows
    rand = randperm(size(condBoth,1))';
    
    % assign responses to each condition randomly
    bothCondRand = condBoth(rand,:);
   
    randCondA = bothCondRand(1:size(condA,1),:);
    randCondB = bothCondRand((size(condA,1)+1):end,:);
       
    meanRandCondA = nanmean(randCondA);
    meanRandCondB = nanmean(randCondB);
    
    distDiff(permN) = meanRandCondA-meanRandCondB;
end

% remove NaNs (if any) and sort
distDiff = distDiff(~isnan(distDiff));
distDiff = sort(distDiff);

if onewaytest
        switch sign
            case 'positive'
                p = (sum(obsDiff>distDiff)+1)/(length(distDiff)+1);
            case 'negative'
                p = (sum(obsDiff<distDiff)+1)/(length(distDiff)+1);
        end
end
