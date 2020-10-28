%% extract grid metrics
% complements standalonee_collateGridCAToutput to get voxel number in mask
% and behavioural performance
% coco newton 10/19

function extractGridMetrics 

subjectvec = {'27734','28061','28428','29317','29321','29332','29336','29382','29383'};
runvec = {'BlockA','BlockB','BlockC'};

getVoxels = 1;
getPerformance = 0;

% prepare output files
%outfileall = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/results/group_pilot_results_leftEC6fold.txt';
%resultsall = fopen(outfileall, 'w+');
outfilematrix = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/results/gridCAT_SPMvox_results.csv';
%resultsmatrix = fopen(outfilematrix,'w+');

% header
%fprintf(resultsall, '\n');

% preallocate group_level variables for further analysis
subjects = cell(9,1);
Responseone = cell(10,1);
Responsetwo = cell(10,1);
Responsethree = cell(10,1);
MeanRTone = cell(10,1);
MeanRTtwo = cell(10,1);
MeanRTthree = cell(10,1);
Voxels_ROI = cell(9,4);
Voxels_NAN = cell(9,4);

for subj = 1:length(subjectvec)
    
    if getVoxels
        
        disp('EXTRACTING GRID CODE RESULTS: ');
        Subject = subjectvec{subj}
        subjects{subj,1} = str2double(Subject);
        
        if strcmp(Subject,'29358')
            continue
        end
        
        for side = 3:4
            clear GCresult
            
            if side == 3
                % GRID CODE RESULTS
                GCresult = fopen(['/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/results/' Subject '/gridCAT_final_pmRight6/GridCATmetrics_' Subject '_xfold_6_pmRight_affine.txt']);
                tline = fgetl(GCresult);
            elseif side == 4
                GCresult = fopen(['/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/results/' Subject '/gridCAT_final_pmLeft6/GridCATmetrics_' Subject '_xfold_6_pmLeft_affine.txt']);
                tline = fgetl(GCresult);
            end
            
            % iterate through file line by line until end reached
            while ~feof(GCresult)
                
                lineInfo = strsplit(tline, ';');
                
                % MAGNITUDE - 9 cells
                if strncmp(lineInfo{1},'Mag', 3) && strncmp(lineInfo{5},'Run1', 4)
                    % this is first line of file
                    Voxels_ROI{subj,side} = lineInfo{7};
                    Voxels_NAN{subj,side} = lineInfo{8};
                    %                             Magnitude_R1(i,1) = lineInfo{6};
                    %
                    %                         elseif strncmp(lineInfo{5},'Run2', 4)
                    %                             Magnitude_R2(i,1) = lineInfo{6};
                    %
                    %                         elseif strncmp(lineInfo{5},'Run3', 4)
                    %                             Magnitude_R3(i,1) = lineInfo{6};
                    %
                    %                         elseif strncmp(lineInfo{5},'all', 3)
                    %                             Magnitude_all(i,1) = lineInfo{6};
                    tline = fgetl(GCresult);
                    
                else
                    
                    tline = fgetl(GCresult);
                    
                    %                     end
                    %
                    %                 % BETWEEN VOXEL ORI COHERENCE - 10 cells
                    %                     if strncmp(lineInfo{1},'Bet', 3)
                    %
                    %                         if endsWith(lineInfo{4}, "allRunsAvg-deg.nii")
                    %                             RayleighZ_all(i,1) = lineInfo{5};
                    %                             RayleighP_all(i,1) = lineInfo{6};
                    %
                    %                         elseif endsWith(lineInfo{4}, "run1-deg.nii")
                    %                             RayleighZ_R1(i,1) = lineInfo{5};
                    %                             RayleighP_R1(i,1) = lineInfo{6};
                    %
                    %                         elseif endsWith(lineInfo{4}, "run2-deg.nii")
                    %                             RayleighZ_R2(i,1) = lineInfo{5};
                    %                             RayleighP_R2(i,1) = lineInfo{6};
                    %
                    %                         elseif endsWith(lineInfo{4}, "run3-deg.nii")
                    %                             RayleighZ_R3(i,1) = lineInfo{5};
                    %                             RayleighP_R3(i,1) = lineInfo{6};
                    %                         end
                    %                     end
                    %
                    %                 % WITHIN VOXEL ORI COHERENCE - 11 cells
                    %                     if strncmp(lineInfo{1},'Wit', 3)
                    %
                    %                         if endsWith(lineInfo{4}, "allRunsAvg_deg.nii") && endsWith(lineInfo{5}, "run1_deg.nii")
                    %                             WithinVoxStability_R1(i,1) = lineInfo{6};
                    %
                    %                         elseif endsWith(lineInfo{4}, "allRunsAvg_deg.nii") && endsWith(lineInfo{5}, "run2_deg.nii")
                    %                             WithinVoxStability_R2(i,1) = lineInfo{6};
                    %
                    %                         elseif endsWith(lineInfo{4}, "allRunsAvg_deg.nii") && endsWith(lineInfo{5}, "run3_deg.nii")
                    %                             WithinVoxStability_R3(i,1) = lineInfo{6} ;
                    %
                    %                         end
                    %                     end
                    %
                    %                 % MEAN GRID ORI IN ROI - 8 cells
                    %                     if strncmp(lineInfo{1},'Mea', 3)
                    %
                    %                         if strcmp(lineInfo{5},'1')
                    %                             MeanOrientation_R1(i,1) = lineInfo{6};
                    %
                    %                         elseif strcmp(lineInfo{5},'2')
                    %                             MeanOrientation_R2(i,1) = lineInfo{6};
                    %
                    %                         elseif strcmp(lineInfo{5},'3')
                    %                             MeanOrientation_R3(i,1) = lineInfo{6};
                    %
                    %                         end
                    %                     end
                    %
                    %                 % go to next line of file if line extraction is complete
                    %                 tline = fgetl(GCresult);
                    
                    % skip to next line of file if line is empty or has 'GRID METRIC'
                end
                
            end % of while loop
            
            %     % get last line
            %     lineInfo = strsplit(tline, ';');
            %     if strncmp(lineInfo{5},'av',2)
            %         MeanOrientation_all(i,1) = lineInfo{6};
            %     end
            
            fclose(GCresult);
            
        end
        
        disp('GRID CODE RESULT EXTRACTION COMPLETE');
    end %of if loop
    %% GRID TASK RESULTS
    if getPerformance
        for run = 1:length(runvec)
            
            disp(' ');
            disp('EXTRACTING GRID TASK RESULTS: ');
            Run = runvec{run}
            
            % init
            nQs = 7;
            answers = cell(length(subjectvec),3);
            answers{subj,run} = NaN(nQs,2); % answers per question in 1, RT in 2
            
            if run == 3 && strcmp(Subject,'28061') % missing data for third run
                continue
            end
            
            GTresult = fopen(['/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/raw_data/task_data/' Subject '/' Run '/testResultsData.csv']);
            tline = fgetl(GTresult);
            
            while ~feof(GTresult)
                
                lineInfo = strsplit(tline, ';');
                
                if strncmp(lineInfo{2}, 'Waitin', 6)
                    
                    prevline = str2double(lineInfo{2}(end));
                    tline = fgetl(GTresult);
                    lineInfo = strsplit(tline, ';');
                    
                    % get subject response and correct answer
                    r = strsplit(lineInfo{2},':');
                    response = str2double(r{2});
                    c = strsplit(lineInfo{3}, ':');
                    correct = str2double(c{2});
                    
                    if response == correct
                        answers{subj,run}(prevline,1) = 1;
                    else
                        answers{subj,run}(prevline,1) = 0;
                    end
                    
                    % get reaction time
                    rt = strsplit(lineInfo{4}, ':');
                    answers{subj,run}(prevline,2) = str2double(rt{2});
                    
                    % continue to next line
                    tline = fgetl(GTresult);
                    
                else
                    % skip to next line
                    tline = fgetl(GTresult);
                    
                end % of if loop
                
            end % of while loop
            
            % compute averages 1 = mean correct, 2 = mean RT
            if run == 1
                Responseone{subj,1} = mean(answers{subj,run}(:,1));
                MeanRTone{subj,1} =  mean(answers{subj,run}(:,2));
            elseif run == 2
                Responsetwo{subj,1} = mean(answers{subj,run}(:,1));
                MeanRTtwo{subj,1} =  mean(answers{subj,run}(:,2));
            elseif run == 3
                Responsethree{subj,1} = mean(answers{subj,run}(:,1));
                MeanRTthree{subj,1} =  mean(answers{subj,run}(:,2));
            end
            
        end
        
        fclose(GTresult);
        
        disp('GRID TASK RESULTS EXTRACTION COMPLETE');
        
    end % of for loop
end
%% WRITE TO FILE
%    fprintf(resultsall, '%-20s',Subject,Voxels_NAN(i,1),Voxels_ROI(i,1),Magnitude_all(i,1),MeanOrientation_all(i,1),RayleighZ_all(i,1),RayleighP_all(i,1), ...
%        WithinVoxStability_R1(i,1),WithinVoxStability_R2(i,1),WithinVoxStability_R3(i,1));
%    fprintf(resultsall, '\n');

if getVoxels && getPerformance
    metricHeader = [{'Subject'},{'Voxels_ROI_LH'},{'Voxels_NaN_LH'},{'Voxels_ROI_RH'},{'Voxels_NaN_RH'},{'PctCorr_Run1'},{'PctCorr_Run2'},{'PctCorr_Run3'},{'MeanRT_Run1'},{'MeanRT_Run2'},{'MeanRT_Run3'}];
    resultsmatrix = [subjects,str2double(Voxels_ROI(:,3)),str2double(Voxels_NAN(:,3)),str2double(Voxels_ROI(:,4)),str2double(Voxels_NAN(:,4)),Responseone,Responsetwo,Responsethree, ...
        MeanRTone,MeanRTtwo,MeanRTthree];
elseif getVoxels && getPerformance==0
     metricHeader = [{'Subject'},{'Voxels_ROI_LH'},{'Voxels_NaN_LH'},{'Voxels_ROI_RH'},{'Voxels_NaN_RH'}];
     resultsmatrix = [subjects{:},str2double(Voxels_ROI(:,3)),str2double(Voxels_NAN(:,3)),str2double(Voxels_ROI(:,4)),str2double(Voxels_NAN(:,4))];
end

outputCSV = [metricHeader;resultsmatrix];
cell2csv(outfilematrix, outputCSV);
disp(['Data saved to: ' outfilematrix]);

%fclose(resultsall);

end % of function