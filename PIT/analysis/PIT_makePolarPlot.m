function PIT_makePolarPlot
PITall = readtable('/lustre/scratch/wbic-beta/ccn30/ENCRYPT/scripts/PIT/slurmoutputs/PITall.csv');
PITallSize = size(PITall);

% make random angles
th = linspace(0,360,PITallSize(1));
th_radians = deg2rad(th);
th_radians_rand = th_radians(randperm(length(th_radians)));

ps = polarscatter(th_radians_rand,PITall.ADerror,'filled');
ps.SizeData = 10;
ps.MarkerFaceAlpha = .6;
ps.MarkerFaceColor = '#008080';
ax = gca;
ax.RTickLabel = {'0m','2m','4m','6m'};
ax.FontWeight = 'bold';
ax.GridAlpha = 0.5;
ax.ThetaTickLabel={};
ax.ThetaGrid = 'off';
ax.GridColor = 'white';
ax.Color = '#ADD8E6';
ax.Title.String = 'Absolute distance error distribution';


end
