%% extract information from gridcat output
% Matthias Stangl adapted by Coco Newton 11/19
% change GLM2findStr for different dir names of output

function standalone_collateGridCAToutput()

clear all
clc
addpath('/home/ccn30/rds/hpc-work/WBIC_home/Documents/MATLAB');

% -----------------------------------------------------------------
% SETTINGS

allSubjGridcatData_dir = '/home/ccn30/rds/hpc-work/WBIC_lustre/ENCRYPT/results/gridCAT';
%GLM2findStr = 'gridCAT_regress*';
%GLM2findStr = 'gridCAT_out*';
%GLM2findStr = 'gridCAT_phys*';
%GLM2findStr = 'gridCAT_thresh*';
%GLM2findStr = 'gridCAT_pmEC*';
%GLM2findStr = 'gridCAT_*_nr';
GLM2findStr = 'gridCAT_*';
%GLM2findStr = 'gridCAT_*_thresh*';


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

        %% get current folder
        GLM2dirName = GLM2dirList(GLM2dirIdx).name;
        % main
        if  contains(GLM2dirName, 'pmRight6_hybridMaass')
            ROI_GLM2meanGridOriCalc = 'pmEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_pmRightMaass_main.txt'];
        elseif contains(GLM2dirName, 'pmLeft6_hybridMaass')
            ROI_GLM2meanGridOriCalc = 'pmEC_left';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_pmLeftMaass_main.txt'];
        elseif contains(GLM2dirName, 'EC')
            ROI_GLM2meanGridOriCalc = 'EC';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_EC_main.txt'];    
        elseif contains(GLM2dirName, 'pmLeft6_DTImasked')
            ROI_GLM2meanGridOriCalc = 'pmECDTI_left';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_pmLeftDTI_main.txt'];
        elseif contains(GLM2dirName, 'pmRight6_DTImasked')
            ROI_GLM2meanGridOriCalc = 'pmECDTI_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_pmRightDTI_main.txt'];
        end
        % control al region
        if contains(GLM2dirName, 'alRight6_hybridMaass')
            ROI_GLM2meanGridOriCalc = 'alEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_alRightMaass_control.txt'];
        elseif contains(GLM2dirName, 'alLeft6_hybridMaass')
            ROI_GLM2meanGridOriCalc = 'alEC_left';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_alLeftMaass_control.txt'];
        elseif contains(GLM2dirName, 'alLeft6_DTImasked')
            ROI_GLM2meanGridOriCalc = 'alECDTI_left';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_alLeftDTI_control.txt'];
        elseif contains(GLM2dirName, 'alRight6_DTImasked')
            ROI_GLM2meanGridOriCalc = 'alECDTI_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_alRightDTI_control.txt'];    
        end
        % control HC tail region
        if contains(GLM2dirName, 'HCtail_left')
            ROI_GLM2meanGridOriCalc = 'HCtail_left';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_HCtailL_control.txt'];
        elseif contains(GLM2dirName, 'HCtail_right')
            ROI_GLM2meanGridOriCalc = 'HCtail_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_6_HCtailR_control.txt'];
        end     
        % control xFold
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
            ROI_GLM2meanGridOriCalc = 'pmEC_right';
            dataFile = [subjDir filesep GLM2dirName filesep 'GridCATmetrics_' subjNameList{subjIdx} '_xfold_4_pmRight_main.txt'];
        end
 
        %% open file
        fid = fopen(dataFile);
        
        if fid>0
            
            fprintf('.');

            tline = fgetl(fid);
            while ischar(tline)
                
                % get current line info
                lineData = strsplit(tline, ';');
                
                % interlude - get side
                if length(ROI_GLM2meanGridOriCalc) < 3
                    side='';
                elseif strncmp(ROI_GLM2meanGridOriCalc(6:9),'left',4)
                    side = 'left';
                elseif strncmp(ROI_GLM2meanGridOriCalc(6:10),'right',5)
                    side = 'right';
                elseif strncmp(ROI_GLM2meanGridOriCalc(8:11),'left',4) % for HCtail
                    side = 'left';
                elseif strncmp(ROI_GLM2meanGridOriCalc(8:12),'right',5)
                    side = 'right';
                elseif strncmp(ROI_GLM2meanGridOriCalc(9:12),'left',5) % for DTI masks
                    side = 'left';
                elseif strncmp(ROI_GLM2meanGridOriCalc(9:13),'right',5)
                    side = 'right'; 
                end
                
                % interlude - get threshold value if thresh models 
                if contains(GLM2dirName,'thresh')
                    if strncmp(GLM2dirName(end),'2',1)
                        thresh='0.2';
                    elseif strncmp(GLM2dirName(end),'3',1)
                        thresh='0.3';
                    elseif strncmp(GLM2dirName(end),'4',1)
                        thresh='0.4';
                    elseif strncmp(GLM2dirName(end),'5',1)
                        thresh='0.5';
                    end
                end

                %% get metrics
               
                %%% magnitude %%%
                
                %lineData % for debugging
                if strcmp(lineData{1}, 'Magnitude of grid code response within ROI') && get_magnitude

                    cellData = strsplit(lineData{3}, '_');
              
                    if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        if contains(GLM2dirName, 'DTI')
                            ROI_gridMetricMask = [cellData{1} 'DTI'];
                            strN = 7;
                        else    
                            ROI_gridMetricMask = cellData{1};
                            strN = 4;
                        end
                    elseif contains(GLM2dirName, 'EC') 
                            ROI_gridMetricMask = cellData{2};
                            strN = 2;
                    else
                        ROI_gridMetricMask = cellData{3}; % to change with new masks
                        strN = 6;
                    end
                                        
                    if strncmp(ROI_gridMetricMask, ROI_GLM2meanGridOriCalc, strN)

                        cellData = strsplit(lineData{5}, {'-','_'});
                        run_str = cellData{1};                                              

                        if ~magnitude_showOnlyAllRunsAvg || (magnitude_showOnlyAllRunsAvg && ~contains(run_str, 'allRuns'))

                            GCmagnitude = lineData{6};                    
                            metricName = ['GCmagnitude_' run_str '_' ROI_gridMetricMask(1:strN) '_' side '_' lineData{2}];                    
                            %metricName = ['GCmagnitude_' run_str '_' ROI_gridMetricMask(1:4) '_' side '_' thresh];
                            [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                            output_cArray{subjIdx, metricIdx} = GCmagnitude;
                                                                                
                        end
                    end
                    
                %%% between voxel coherence %%%
                elseif strcmp(lineData{1}, 'Between-voxel grid orientation coherence within ROI') && get_sStability

                    cellData = strsplit(lineData{3},'-');
                    
                     if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        if contains(GLM2dirName, 'DTI')
                            ROI_gridMetricMask = [cellData{1} 'DTI'];
                            strN = 7;
                        else    
                            ROI_gridMetricMask = cellData{1};
                            strN = 4;
                        end
                    elseif contains(GLM2dirName, 'EC') 
                            ROI_gridMetricMask = cellData{2};
                            strN = 2;    
                    else
                        ROI_gridMetricMask = cellData{3}; % to change with new masks
                        strN = 6;
                    end

                    if strncmp(ROI_gridMetricMask,ROI_GLM2meanGridOriCalc,strN)

                        cellData = strsplit(lineData{4}, '-');
                        run_str = cellData{3};

                        zRayleigh = lineData{5};
                        metricName = ['sStability_zRay_' run_str '_' ROI_gridMetricMask(1:strN) '_' side '_' lineData{2}];                    
                        %metricName = ['sStability_zRay_' run_str '_' ROI_gridMetricMask(1:4) '_' side '_' thresh];
                        [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                        output_cArray{subjIdx, metricIdx} = zRayleigh;

                        pRayleigh = lineData{6};
                        metricName = ['sStability_pRay_' run_str '_' ROI_gridMetricMask(1:strN) '_' side '_' lineData{2}];                    
                        %metricName = ['sStability_pRay_' run_str '_' ROI_gridMetricMask(1:4) '_' side '_' thresh];
                        [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                        output_cArray{subjIdx, metricIdx} = pRayleigh;
                    end

                %%% within voxel coherence %%%
                elseif strcmp(lineData{1}, 'Within-voxel grid orientation coherence within ROI') && get_tStability
                    
                    cellData = strsplit(lineData{3}, '_');
                    
                     if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        if contains(GLM2dirName, 'DTI')
                            ROI_gridMetricMask = [cellData{1} 'DTI'];
                            strN = 7;
                        else    
                            ROI_gridMetricMask = cellData{1};
                            strN = 4;
                        end
                     elseif contains(GLM2dirName, 'EC') 
                            ROI_gridMetricMask = cellData{2};
                            strN = 2;   
                     else
                        ROI_gridMetricMask = cellData{3}; % to change with new masks
                        strN = 6;
                    end
                    
                    if strncmp(ROI_gridMetricMask,ROI_GLM2meanGridOriCalc,strN)
                        
                        cellData = strsplit(lineData{4}, '_');
                        runA_str = cellData{3};
                        
                        cellData = strsplit(lineData{5}, '_');
                        runB_str = cellData{3};
                        
                        pcntStableVox = lineData{6};
                        metricName = ['tStability_pcntStableVox_' runA_str 'VS' runB_str '_' ROI_gridMetricMask(1:strN) '_' side '_' lineData{2}];
                        %metricName = ['tStability_pcntStableVox_' run_str '_' ROI_gridMetricMask(1:4) '_' side '_' thresh];
                        [metricIdx, metricNameList] = getMetricIdx(metricName, metricNameList);
                        output_cArray{subjIdx, metricIdx} = pcntStableVox;
                        
                    end
                    
                %%% mean orientation %%%
                elseif strcmp(lineData{1}, 'Mean grid orientation within ROI') && strcmp(lineData{5}, 'averaged across runs') && get_meanOri
                    
                    cellData = strsplit(lineData{3}, '_');
                    
                     if contains(GLM2dirName,'pm') || contains(GLM2dirName, 'al')
                        if contains(GLM2dirName, 'DTI')
                            ROI_gridMetricMask = [cellData{1} 'DTI'];
                            strN = 7;
                        else    
                            ROI_gridMetricMask = cellData{1};
                            strN = 4;
                        end
                     elseif contains(GLM2dirName, 'EC') 
                            ROI_gridMetricMask = cellData{2};
                            strN = 2;   
                     else
                        ROI_gridMetricMask = cellData{3}; % to change with new masks
                        strN = 6;
                    end
                    
                    if strncmp(ROI_gridMetricMask, ROI_GLM2meanGridOriCalc, strN)

                            meanOriWeighted = lineData{6};
                            metricName = ['MeanOrientation_allRuns_' ROI_gridMetricMask(1:strN) '_' side '_' lineData{2}];                    
                            %metricName = ['MeanOrientation_allRuns_' run_str '_' ROI_gridMetricMask(1:4) '_' side '_' thresh];
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

%% write to file
disp(' ');
output_cArray = [['Subject' subjNameList]' [metricNameList; output_cArray]];

filename = [GLM2findStr '_results_global'];
filename(filename=='*')='3';

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


