function demo_makeSignBar(condA, condB, xAxis, nPermutations, RGB1, RGB2, cmpToBaseline, offset)

if ~exist('cmpToBaseline', 'var')
    cmpToBaseline = 0;
end
if ~exist('offset', 'var')
    offset = 0;
end
p       = nan(size(condB,2),1);
obsDiff = nan(size(condB,2),1);

if ~cmpToBaseline
    for iFreq = 1: size(condB,2)
        [p(iFreq),~,~,obsDiff(iFreq)] = permTest(condA(:,iFreq), condB(:,iFreq), nPermutations,0);
    end
else
    for iFreq = 1: size(condB,2)
        [p(iFreq),~,~,obsDiff(iFreq)] = permTest(nanmean(condA,2), condB(:,iFreq), nPermutations,0, true, 'positive');
    end
end

demo_plotSignBar(p, xAxis, RGB1, RGB2, obsDiff, offset)