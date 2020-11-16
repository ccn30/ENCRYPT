%% extract information from gridcat output
% Matthias Stangl adapted by Coco Newton 11/19
% change GLM2findStr for different dir names of output

function standalone_collateGridCAToutput()

clear all
clc

% -----------------------------------------------------------------
% SETTINGS

allSubjGridcatData_dir = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/results/gridCAT';
%GLM2findStr = 'gridCAT_regress*';
%GLM2findStr = 'gridCAT_out*';
%GLM2findStr = 'gridCAT_phys*';
%GLM2findStr = 'gridCAT_thresh*';
%GLM2findStr = 'gridCAT_pmEC*';
GLM2findStr = 'gridCAT_*_nr';

get_magnitude = 1;
magnitude_showOnlyAllRunsAvg = 0;
get_sStability = 1;
get_tStability = 1;
get_meanOri = 1;

% -----------------------------------------------------------------

metricNameList = {};
subjNameList = {};
output_cArray = {};
subjDirList = dir(allSubjGridcatData_dir);

% delete all list entries that precede with . or $ (except ..), or non dir
subjDirList(~[subjDirList(:).isdir]) = [];
letters = cellfun(@(x) x(1:1),{subjDirList(:).name},'un',0);
badIds = find(strcmp(letters, '.') | strcmp(letters, '$'));
subjDirList(badIds) = [];

for subjIdx = 1:length(subjDirList)
    
    subjDir = [allSubjGridcatData_dir filesep subjDirList(subjIdx).name];
    
    fprintf('\n%s',subjDirList(subjIdx).name);

    GLM2dirList = dir([subjDir filesep GLM2findStr]);

    for GLM2dirIdx = 1:length(GLM2dirList)
        
        subjNameList{subjIdx} = subjDirList(subjIdx).name;

        GLM2dirName = GLM2dirList(GLM2dirIdx).name;
        
        if  contains(GLM2dirName, 'pmRight6')
            ROI_GLM2meanGridOriCalc = 'pmEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_pmRight_main.txt'];
        elseif contains(GLM2dirName, 'pmLeft6')
            ROI_GLM2meanGridOriCalc = 'pmEC_left';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_pmLeft_main.txt'];
        end
        
        if contains(GLM2dirName, 'alRight6')
            ROI_GLM2meanGridOriCalc = 'alEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_alRight_control.txt'];
        elseif contains(GLM2dirName, 'alLeft6')
            ROI_GLM2meanGridOriCalc = 'alEC_left';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_alLeft_control.txt'];
        end     
        
        if  contains(GLM2dirName, 'pmRight7')
            ROI_GLM2meanGridOriCalc = 'pmEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_7_pmRight_main.txt'];
        elseif contains(GLM2dirName, 'pmRight8')
            ROI_GLM2meanGridOriCalc = 'pmEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_8_pmRight_main.txt'];
        elseif contains(GLM2dirName, 'pmRight5')
            ROI_GLM2meanGridOriCalc = 'pmEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_5_pmRight_main.txt'];
        elseif contains(GLM2dirName, 'pmRight4')
            ROI_GLM2meanGridOriCalc = 'pmEC_Right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_4_pmRight_main.txt'];
        end
        
        fid = fopen(dataFile);
        
        if fid>0
            
            fprintf('.');

            tline = fgetl(fid);
            while ischar(tline)

                lineData = strsplit(tline, ';');

                if strcmp(lineData{1}, 'Magnitude of grid code response within ROI') && get_magnitude

                    cellData = strsplit(lineData{3}, 'x');
                    
                    if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        ROI_gridMetricMask = cellData{1};
                    else
                        ROI_gridMetricMask = cellData{1}; % to change with new masks
                    end
                    
                    if strncmp(ROI_gridMetricMask, ROI_GLM2meanGridOriCalc, 6)

                        cellData = strsplit(lineData{5}, {'-','_'});
                        run_str = cellData{1};

                        if ~magnitude_showOnlyAllRunsAvg || (magnitude_showOnlyAllRunsAvg && ~contains(run_str, 'allRuns'))

                            GCmagnitude = lineData{6};                    
                            metricName = ['GCmagnitude_' run_str '_' ROI_gridMetricMask(1:4) '_' ROI_gridMetricMask(6:end) '_' lineData{2}];                    
                            [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                            output_cArray{subjIdx, metricIdx} = GCmagnitude;

                        end
                    end

                elseif strcmp(lineData{1}, 'Between-voxel grid orientation coherence within ROI') && get_sStability

                    cellData = strsplit(lineData{3},'x');
                    
                    if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        ROI_gridMetricMask = cellData{1};
                        if contains(ROI_gridMetricMask,'-') % because Between-voxel somehow recodes mask name with - instead of _
                            ROI_gridMetricMask = strrep(ROI_gridMetricMask,'-','_');
                        end
                    else
                        ROI_gridMetricMask = cellData{1}; % to change with new masks
                    end

                    if strncmp(ROI_gridMetricMask,ROI_GLM2meanGridOriCalc,6)

                        cellData = strsplit(lineData{4}, '-');
                        run_str = cellData{3};

                        zRayleigh = lineData{5};
                        metricName = ['sStability_zRay_' run_str '_' ROI_gridMetricMask(1:4) '_' ROI_gridMetricMask(6:end) '_' lineData{2}];                    
                        [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                        output_cArray{subjIdx, metricIdx} = zRayleigh;

                        pRayleigh = lineData{6};
                        metricName = ['sStability_pRay_' run_str '_' ROI_gridMetricMask(1:4) '_' ROI_gridMetricMask(6:end) '_' lineData{2}];                    
                        [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                        output_cArray{subjIdx, metricIdx} = pRayleigh;
                    end


                elseif strcmp(lineData{1}, 'Within-voxel grid orientation coherence within ROI') && get_tStability
                    
                    cellData = strsplit(lineData{3}, 'x');
                    
                    if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        ROI_gridMetricMask = cellData{1};
                    else
                        ROI_gridMetricMask = cellData{1}; % to change with new masks
                    end
                    
                    if strncmp(ROI_gridMetricMask,ROI_GLM2meanGridOriCalc,6)
                        
                        cellData = strsplit(lineData{4}, '_');
                        runA_str = cellData{3};
                        
                        cellData = strsplit(lineData{5}, '_');
                        runB_str = cellData{3};
                        
                        pcntStableVox = lineData{6};
                        metricName = ['tStability_pcntStableVox_' runA_str 'VS' runB_str '_' ROI_gridMetricMask(1:4) '_' ROI_gridMetricMask(6:end) '_' lineData{2}];
                        [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                        output_cArray{subjIdx, metricIdx} = pcntStableVox;
                        
                    end
                    
                elseif strcmp(lineData{1}, 'Mean grid orientation within ROI') && strcmp(lineData{5}, 'averaged across runs') && get_meanOri
                    
                    cellData = strsplit(lineData{3}, 'x');
                    
                    if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        ROI_gridMetricMask = cellData{1};
                    else
                        ROI_gridMetricMask = cellData{1}; % to change with new masks
                    end
                    
                    if strncmp(ROI_gridMetricMask, ROI_GLM2meanGridOriCalc, 6)

                            meanOriWeighted = lineData{6};
                            metricName = ['MeanOrientation_allRuns_' ROI_gridMetricMask(1:4) '_' ROI_gridMetricMask(6:end) '_' lineData{2}];                    
                            [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                            output_cArray{subjIdx, metricIdx} = meanOriWeighted;

                    end
                    
                end
                
                tline = fgetl(fid);
                
            end
            
            fclose(fid);
            
        end

    end
end

disp(' ');
output_cArray = [['Subject' subjNameList]' [metricNameList; output_cArray]];

filename = [GLM2findStr '_results_global'];
filename(filename=='*')='X';

cell2csv([allSubjGridcatData_dir filesep filename '.csv'], output_cArray);
save(    [allSubjGridcatData_dir filesep filename '.mat'], 'output_cArray');

disp(' ');
disp(['data saved to: ' allSubjGridcatData_dir filesep filename '.mat']);

%%
function [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList)

if ~isempty(find(strcmp(metricNameList, metricName), 1))
    metricIdx = find(strcmp(metricNameList, metricName));
else
    metricIdx = length(metricNameList)+1;
    metricNameList{metricIdx} = metricName;
end


