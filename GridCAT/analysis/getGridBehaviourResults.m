%% extract behavioural performance from grid cell task
% coco newton 10/19 modified 05/21

function getGridBehaviourResults()
addpath('/home/ccn30/Documents/MATLAB');

% list subject folders from task data dir
pathstem = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT';
allSubjGridcatData_dir = [pathstem '/task_data/gridtask'];
subjDirList = dir(allSubjGridcatData_dir);
runvec = {'BlockA','BlockB','BlockC'};
resultsfile = 'testResultsData.csv';

% delete all list entries that precede with . or $ (except ..), or non dir
subjDirList(~[subjDirList(:).isdir]) = [];
letters = cellfun(@(x) x(1:1),{subjDirList(:).name},'un',0);
badIds = find(strcmp(letters, '.') | strcmp(letters, '$'));
subjDirList(badIds) = [];

% prepare output file
outfile = [pathstem '/results/gridCAT/GCT_behaviour_global.csv'];

% preallocate answer/reaction time variables (7Q's per block) for further analysis
nSubjs = length(subjDirList);
subjects = cell(nSubjs,1);
answersB1 = cell(nSubjs,7);
answersB2 = cell(nSubjs,7);
answersB3 = cell(nSubjs,7);
RTB1 = cell(nSubjs,7);
RTB2 = cell(nSubjs,7);
RTB3 = cell(nSubjs,7);

for subj = 1:nSubjs
    disp(' ');
    disp('EXTRACTING GRID TASK RESULTS: ');
    subjects{subj} = subjDirList(subj).name;
    
    for run = 1:length(runvec)
        disp(subjDirList(subj).name);
        disp(runvec{run});
        
        % init file reading
        resultsrawpath = [allSubjGridcatData_dir '/' subjDirList(subj).name '/' runvec{run} '/' resultsfile];
        if ~isfile(resultsrawpath)
            continue
        end
        
        GTresult = fopen(resultsrawpath);
        tline = fgetl(GTresult);
        
        while ~feof(GTresult)
            
            lineInfo = strsplit(tline, ';');
            
            if strncmp(lineInfo{2}, 'Waitin', 6)
                
                Q = str2double(lineInfo{2}(end));
                tline = fgetl(GTresult);
                lineInfo = strsplit(tline, ';');
                
                % get subject response and correct answer
                r = strsplit(lineInfo{2},':');
                response = str2double(r{2});
                c = strsplit(lineInfo{3}, ':');
                correct = str2double(c{2});
                
                % check match
                if response == correct
                    if run == 1
                        answersB1{subj,Q} = 1;
                    elseif run == 2
                        answersB2{subj,Q} = 1;
                    else
                        answersB3{subj,Q} = 1;
                    end
                else
                    if run == 1
                        answersB1{subj,Q} = 0;
                    elseif run == 2
                        answersB2{subj,Q} = 0;
                    else
                        answersB3{subj,Q} = 0;
                    end
                end
                
                % get reaction time
                rt = strsplit(lineInfo{4}, ':');
                
                if run == 1
                    RTB1{subj,Q} = str2double(rt{2});
                elseif run == 2
                    RTB2{subj,Q} = str2double(rt{2});
                else
                    RTB3{subj,Q} = str2double(rt{2});
                end
                
                % continue to next line
                tline = fgetl(GTresult);
                
            else
                % skip to next line
                tline = fgetl(GTresult);
                
            end % of if loop
            
        end % of while loop
    end % of run loop
end % of subject loop

% compute averages 1 = mean correct, 2 = mean RT
% if run == 1
%     Responseone{subj,1} = mean(answers{subj,run}(:,1));
%     MeanRTone{subj,1} =  mean(answers{subj,run}(:,2));
% elseif run == 2
%     Responsetwo{subj,1} = mean(answers{subj,run}(:,1));
%     MeanRTtwo{subj,1} =  mean(answers{subj,run}(:,2));
% elseif run == 3
%     Responsethree{subj,1} = mean(answers{subj,run}(:,1));
%     MeanRTthree{subj,1} =  mean(answers{subj,run}(:,2));
% end

fclose(GTresult);

disp('GRID TASK RESULTS EXTRACTION COMPLETE');



%% WRITE TO FILE

variableHeader = [{'Subject'},{'B1Q1'},{'B1Q2'},{'B1Q3'},{'B1Q4'},{'B1Q5'},{'B1Q6'},{'B1Q7'},...
    {'B2Q1'},{'B2Q2'},{'B2Q3'},{'B2Q4'},{'B2Q5'},{'B2Q6'},{'B2Q7'},...
    {'B3Q1'},{'B3Q2'},{'B3Q3'},{'B3Q4'},{'B3Q5'},{'B3Q6'},{'B3Q7'},...
    {'B1Q1_RT'},{'B1Q2_RT'},{'B1Q3_RT'},{'B1Q4_RT'},{'B1Q5_RT'},{'B1Q6_RT'},{'B1Q7_RT'},...
    {'B2Q1_RT'},{'B2Q2_RT'},{'B2Q3_RT'},{'B2Q4_RT'},{'B2Q5_RT'},{'B2Q6_RT'},{'B2Q7_RT'},...
    {'B3Q1_RT'},{'B3Q2_RT'},{'B3Q3_RT'},{'B3Q4_RT'},{'B3Q5_RT'},{'B3Q6_RT'},{'B3Q7_RT'}];
resultsmatrix = [subjects,answersB1,answersB2,answersB3,RTB1,RTB2,RTB3];


outputCSV = [variableHeader;resultsmatrix];
cell2csv(outfile, outputCSV);
disp(['Data saved to: ' outfile]);

%fclose(resultsall);

end % of function