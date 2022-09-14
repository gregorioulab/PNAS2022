% add main folder and subfolders to the Matlab path 
% select panel to plot 'fig_3a', 'fig_3b' or 'fig_3c'
select_panel = 'fig_3b';
switch select_panel
    case 'fig_3a';
        area = 'vlPFC';
        task = 'spatial cue';
        area_acc  = load('fig_3a.mat');
    case 'fig_3b'
        area = 'vlPFC';
        task = 'color cue';
        area_acc  = load('fig_3b.mat');
    case 'fig_3c'
        area = 'FEF';
        task = 'spatial cue';
        area_acc  = load('fig_3c.mat');
end

acc      = area_acc.all_accuracies;
diag_acc = area_acc.diag_accuracies;

nTimes = size(acc,1);
pvals  = nan(nTimes,nTimes);
for tr=1:nTimes
    for ts=1:nTimes
        pvals(ts,tr) = (sum(diag_acc(tr,tr,:)<mean(acc(ts,tr,:)))+1)/(size(diag_acc,3)+1);
    end
end

% restrict data in the late delay period
acc(132:147, :, :) = [];
acc(:, 132:147, :) = [];
pvals(132:147, :)  = [];
pvals(:, 132:147)  = [];

figure('color',[1 1 1]);
clims = [25 90];
imagesc(mean(acc,3), clims);
set(gca,'YDir','normal');
% requires function customcolormap: https://www.mathworks.com/matlabcentral/fileexchange/69470-custom-colormap
mycolormap = customcolormap(linspace(0,1,9), {'#cd002b','#f66e44','#ffd97f','#def4f9','#abd9e9','#73add2','#4873b5','#363ba8','#313691'});
colormap(mycolormap);
% otherwise use Matlab's colormap
% colormap('jet');

c = colorbar;
c.Label.String = 'Decoding accuracy (% correct)';
    
ylims = get(gca,'ylim');

% contour
sign = pvals<0.01;
sign = imgaussfilt(double(sign),3);
hold on,
contour(1:size(acc,1),1:size(acc,2),sign,1,'Linewidth',2,'LineColor',[0.16 0.24 0.24],'LineStyle','--');

% plot the delay period onset
hold on;
plot([86 86], [0 size(pvals,1)], '--w', 'LineWidth', 2);
plot([0 size(pvals,1)], [86 86], '--w', 'LineWidth', 2);
rectangle('Position',[131 0 2 ylims(2)],'EdgeColor','w','FaceColor','w'), hold on,
rectangle('Position',[0 131 ylims(2) 2],'EdgeColor','w','FaceColor','w')
    
xlabel('Train time (s)')
ylabel('Test time (s)')

ax = gca;
set(ax, 'xtick', [26:30:131,132:20:156]);
set(ax, 'xticklabels', [0.3:0.3:1.3+0.1,-0.3:0.2:0+0.1]);
set(ax, 'ytick', [26:30:131,132:20:156]);
set(ax, 'yticklabels', [0.3:0.3:1.3+0.1,-0.3:0.2:0+0.1]);
    
title([area,', ' task, ', n=', num2str(area_acc.num_neur)], 'interpreter', 'none');