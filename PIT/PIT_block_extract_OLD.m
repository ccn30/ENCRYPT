%% PIT Script: generate table of trial information and plots of trial trajectories for one xml file
% Coco Newton 26.11.18
% Acknowledgement to David Howett

% CONTENTS:
% 1. Extract participant data into structure from xml file using xml2struct
% 2. Extract all trial information as variables
% 3. Calculate distance, angular and proportional errors 
% 4. Create table with all trial variables and errors
% 5. Extract all trajectory coordinate information for each trial
% 6. Plot trajectories from all trials with flag, triggered position and out of bounds locations 

% USER GUIDE:
% 1. Set number of trials (nTrials)
% 2. Load in xml file to filename
% 3. Run script

%    * * * * * * * * * * * * * * * * KEY INFO * * * * * * * * * * * * * * * * 
%    * z coordinates == 'y' coordinates in data (y=height)                  *
%    * Triggered position = <Tester_Acquired_Position>                      *
%    * 9 Trials repeated three times, with different return con/env type    *
%    * <Trial><Info> = 3 levels: NoChange // NoOpticFlow // NoDistalCue     *
%    * <EnvironmentNumber> = 3 levels: 0 // 1 // 2                          *
%    * <ReachedOutOfBounds> = logical TRUE/FALSE                            *
%    * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 

%-------------------- ENTER DIR PATH -------------------------
% 
% subjDirList = dir('/Users/ccnewton/Documents/Projects/ENCRYPT/VR_Results');
% 
% 
% % delete all list entries that precede with . or $ (except ..)
% letters = cellfun(@(x) x(1:1),{subjDirList(:).name},'un',0);
% badIds = find(strcmp(letters, '.') | strcmp(letters, '$'));
% subjDirList(badIds) = [];

%for subjIdx = 1:length(subjDirList)
    
 %   subjDir = [allSubjGridcatData_dir filesep subjDirList(subjIdx).name];
    
  %  fprintf('\n%s',subjDirList(subjIdx).name);

%% 1.Extract data from xml file into a structure and numerise
filename = '/Users/ccnewton/Documents/Projects/ENCRYPT/VR_Results/test1_sm_Trial1_Block_1.xml';
[full_data] = xml2struct(filename);

% Replace strings with numbers for trial type and out of bounds info
% "NoChange""NoOpticFlow""NoDistalClues" = 1 2 3
% "True""False" = 1 0

coded_full_data1 = struct_string_replace(full_data, 'NoChange', '1');
coded_full_data2 = struct_string_replace(coded_full_data1, 'NoOpticFlow', '2');
coded_full_data3 = struct_string_replace(coded_full_data2, 'NoDistalClues', '3');

coded_full_data4 = struct_string_replace(coded_full_data3, 'true', '1');
coded_full_data = struct_string_replace(coded_full_data4, 'false', '0');

clear('full_data', 'coded_full_data1','coded_full_data2','coded_full_data3','coded_full_data4');

%% 2. Extract trial information from all trials 

% Create variables (Data entry number, Trial number, Trial type, Environment type, Out of Bounds info, Flag positions, Trigger position)
% Set number of trials in file

nTrials = 12;

% Initialise variable vectors
Entry = [1:nTrials]';
Type = zeros(nTrials,1);
TrialNo = zeros(nTrials,1);
Env = zeros(nTrials,1);
OoB = zeros(nTrials,1);
OoBX = zeros(nTrials,1);
OoBY = zeros(nTrials,1);
Flag1X = zeros(nTrials,1);
Flag1Y = zeros(nTrials,1);
Flag2X = zeros(nTrials,1);
Flag2Y = zeros(nTrials,1);
Flag3X = zeros(nTrials,1);
Flag3Y = zeros(nTrials,1);
TrigX = zeros(nTrials,1);
TrigY = zeros(nTrials,1);

% Loop through all trials in nested structure to extract relevant information for varibale
% (convert to numbers from strings)
for triali = 1:nTrials
    Type(triali, 1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Info.InwardType.Text);
    TrialNo(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Number.Text);
    Env(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Info.EnvironmentNumber.Text);
    OoB(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Reached_Out_Of_Bound.Text);
   
    OoBX(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Out_Of_Bound_Position.x.Text);
    OoBY(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Out_Of_Bound_Position.z.Text);
    
    Flag1X(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Flag_1.x.Text); 
    Flag1Y(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Flag_1.z.Text);
    
    Flag2X(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Flag_2.x.Text); 
    Flag2Y(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Flag_2.z.Text); 
    
    Flag3X(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Flag_3.x.Text); 
    Flag3Y(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Flag_3.z.Text); 
    
    TrigX(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Tester_Acquired_Position.x.Text);
    TrigY(triali,1) = str2double(coded_full_data.Block.Trials.Trial{1, triali}.Path.Tester_Acquired_Position.z.Text);
end

Flag1 = [Flag1X Flag1Y]; % concatenate x and y coordinates into single matrix
Flag2 = [Flag2X Flag2Y];
Flag3 = [Flag3X Flag3Y];
Trig = [TrigX TrigY];
OoBPos = [OoBX OoBY];

disp('Trial Information Extracted...')
%% 3. Calculate absolute distance (AD), absolute angular (AA) and proportional distance/angular errors (PD/PA)

ADerror = zeros(nTrials,1); % Calculate distance (aka vector magnitude) between triggered position->flag 1 using pdist function
PDerror = zeros(nTrials,1); % Calculate ratio of linear distances between triggered position->flag1 and flag3->flag1 (participant and actual distances respectively)
AAerror = zeros(nTrials,1); % Calculate angle (degrees) between participant and actual trajctories (aka vectors) from flag3 using atan2d and abs to make negative angles positive (see below)
PAerror = zeros(nTrials,1); % Calculate ratio of angles between participant and actual trajectories from an artifical 'north pole' vector (originating Flag3, ending due north consistently at y=2)

anglebetween = @(va,vb) atan2d(va(:,1) .* vb(:,2) - va(:,2) .*vb (:,1), va(:,1) .*vb (:,1) + va(:,2) .* vb(:,2)); % anonymous function to calculate angles (atan2d calculates counterclockwise 0-180 degree angle between vectors (if over 180, will be negative and below 180 - use abs to make positive))

for triali = 1:nTrials  
      ADerror(triali, 1) = pdist([Flag1(triali,1), Flag1(triali,2); Trig(triali,1), Trig(triali,2)], 'euclidean');
      
        Partic_dist = pdist([Trig(triali,1), Trig(triali,2); Flag3(triali,1), Flag3(triali,2)], 'euclidean');
        Actual_dist = pdist([Flag1(triali,1), Flag1(triali,2); Flag3(triali,1), Flag3(triali,2)], 'euclidean');
      PDerror(triali,1) = Partic_dist/Actual_dist;
      
        Return_vec = [(Trig(triali,1)-Flag3(triali,1)),(Trig(triali,2)-Flag3(triali,2))];      % [(x2-x1),(y2-y1)] = x y components of vector from flag3 to triggered pos
        TrueReturn_vec = [(Flag1(triali,1)-Flag3(triali,1)), (Flag1(triali,2)-Flag3(triali,2))];   % same as above but from flag3 to flag1
      AAerror(triali,1) = abs(anglebetween(Return_vec,TrueReturn_vec)); 
      
        F2toF3_vec = [(Flag3(triali,1)-Flag2(triali,1)), (Flag3(triali,2)-Flag2(triali,2))];
        Partic_angle = anglebetween(F2toF3_vec,Return_vec); 
        Actual_angle = anglebetween(F2toF3_vec,TrueReturn_vec);
         
            if (((Partic_angle > 0) && (Actual_angle < 0)) || ((Partic_angle < 0) && (Actual_angle > 0)))  % normalise angles due to nature of atan2d calculation
                if (Partic_angle > 0)
                    Partic_angle = Partic_angle - 360; 
                elseif (Partic_angle < 0)
                   Partic_angle = Partic_angle + 360;
                end
            end
        
      PAerror(triali,1) = Partic_angle/Actual_angle; 
      
end

%North_vec = [0, (2-Flag3(triali,1))]; % Generate artificial north vector from flag3
%Partic_angle = atan2d((North_vec(1)*Return_vec(2)-North_vec(2)*Return_vec(1)), dot(North_vec, Return_vec)); % Calculate angle between north vector and the vectors generated above
%Actual_angle = atan2d((North_vec(1)*TrueReturn_vec(2)-North_vec(2)*TrueReturn_vec(1)), dot(North_vec, TrueReturn_vec));
%PAerror(triali,1) = abs(Partic_angle/Actual_angle); % abs ensures no negative angles are present
% (atan2d((Return_vec(1)*TrueReturn_vec(2)-Return_vec(2)*TrueReturn_vec(1)), dot(Return_vec, TrueReturn_vec))); - original angle calulation (same as anglebetween)
        
disp('Errors Calculated...')
%% 4. Put all above trial variables into table TInfo

TInfo = table(Entry, TrialNo, Type, Env, OoB, OoBPos, Flag1, Flag2, Flag3, Trig, ADerror, PDerror, AAerror, PAerror);

%% 5. Extract trajectories in XY coordinates from all trials into cell array TrackedPositionX/Y, using nested for loops
% Inner loop iterates through timepoints of each trial
% Outer loop iterates through each trial
% Generate vector variable trial_lengths (number of timepoints for each trial to initialise lengths of arrays for coordinates)

trial_lengths = zeros(1,nTrials); 
for triali = 1:nTrials
        trial_lengths(1,triali) = length(coded_full_data.Block.Trials.Trial{1, triali}.Path.TrackedPosition.TrackedPosition);
end

% Generate TrackedPositionX/Y with coordinates from each trial
TrackedPositionX = cell(nTrials, 1); 
TrackedPositionY= cell(nTrials, 1); % extract y(z) coordinates
for triali = 1:nTrials
    xarray = zeros(1,trial_lengths(1, triali)); % initialise intermediate variables xarray zarray to carry coord data into TrackedPositionX cells (uses number of timepoints from loop above)
    yarray = zeros(1,trial_lengths(1, triali));
    
    for timei = 1:trial_lengths(1,triali) % each trial has different number sampling timepoints
        tempTrackedPosition = coded_full_data.Block.Trials.Trial{1, triali}.Path.TrackedPosition.TrackedPosition{1,timei}; % extract structure path to timepoints into temporary variable tempTrackedPosition
        xarray(1,timei) = str2double(tempTrackedPosition.Position.x.Text); % put tempTrackedPosition with coord info into xarray/zarray vectors to keep permanent - tempTrackedPosition will be overwritten next iteration (str2double converts structure strings to numbers)
        yarray(1,timei) = str2double(tempTrackedPosition.Position.z.Text); 
    end
    
    TrackedPositionX{triali} = xarray; % Each cell in TrackedPositionX stores xarray from each iteration of loops (xarray gets overwritten)
    TrackedPositionY{triali} = yarray;
end

disp('Trajectories Extracted...')
%% 6. Plot all trials and examine out of border info

set(0,'DefaultFigureWindowStyle','docked');

for triali = 1:nTrials
    thisfig = figure('Name', ['Trajectory ' ,num2str(TInfo.Entry(triali))]);                                
    fig = plot(TrackedPositionX{triali}, TrackedPositionY{triali}, 'k-*', 'linewidth',1); 
    hold on;
    title(['Trial Number ' ,num2str(TInfo.TrialNo(triali)), ' Trial Type ' ,num2str(TInfo.Type(triali)), ' Environment Type ' ,num2str(TInfo.Env(triali))]);
    
    scatter(TInfo.Flag1(triali,1), TInfo.Flag1(triali,2),100, 'go', 'filled');
    scatter(TInfo.Flag2(triali,1), TInfo.Flag2(triali,2),100, 'bo','filled');  
    scatter(TInfo.Flag3(triali,1), TInfo.Flag3(triali,2),100, 'mo','filled');
    scatter(TInfo.Trig(triali,1), TInfo.Trig(triali,2),200, 'r*');
    plot([TInfo.Trig(triali,1), TInfo.Flag1(triali,1)], [TInfo.Trig(triali,2), TInfo.Flag1(triali,2)], 'r-');
    legend({'Trajectory','Flag 1','Flag 2','Flag3','Triggered Position','Distance Error'},'Location','northeastoutside','NumColumns',2);    
    grid on
    
        if TInfo.OoB(triali) == 1
            fig = gcf;
            scatter(TInfo.OoBPos(triali,1), TInfo.OoBPos(triali,2),100, 'kd','filled');
            legend({'Trajectory','Flag 1','Flag 2','Flag3','Triggered Position','Distance Error','Out Of Bounds'},'Location','northeastoutside','NumColumns',2);
        end
        
    hold off;
end

disp('Finished')
