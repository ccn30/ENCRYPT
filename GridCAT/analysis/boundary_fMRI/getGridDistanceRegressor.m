function getGridDistanceRegressor(subject,taskDir)
% function to get xy/angle position per TR from grid cell task movemenEventData.csv logfile to make
% parametric distance regressor for boundary analysis
% output = csv file 'distanceRegressor_subject_block.csv' in each taskdata block dir
% CN 18.03.21

% preamble
blocks = {'BlockA','BlockB','BlockC'};
TR = 2.531;
nVols = 238;
% room wall extreme coordinates
WestWallX = -80;
EastWallX = 80;
NorthWallY = 80;
SouthWallY = -80;


for b = 1:3
    %% open results file for w+ and set logfile
    
    try
        % define grid cell task logfile
        logfile = [taskDir '/' subject '/' blocks{b} '/movemenEventData.csv'];
        
        % open new regressor file for writing
        [fpath, ~] = fileparts(logfile);
        newFilename = [fpath filesep 'distanceRegressor_' subject '_' blocks{b} '.csv'];
        disp(' ');
        disp(['New event-table: ' newFilename]);
        fp_Table = fopen(newFilename, 'w+');
        
        disp(' ');
        disp(['Logfile: ' logfile]);
        
        % ---
        % default init first line in regressor file - don't need this if add to
        % other data2eventtable function
        headings = 'TR,TaskTimepoint,Phase,X,Y,HeadingDir,DistNrstWall,NrstWall,Visible';
        fprintf(fp_Table,headings);
        fprintf(fp_Table,'\n');
        %---
        
        %% import logfile into table + filter TR relevant timepoints
        opts = detectImportOptions(logfile); %create import option object
        l = length(opts.VariableTypes); % change all variable types to characters because distances have 'm' at end apart from time
        for i = 1:l
            if contains(opts.VariableTypes{i},'double')
                opts.VariableTypes{i} = 'char';
            end
        end
        opts.VariableTypes{2} = 'double'; % time points
        opts.Delimiter = {';',':',')','('}; % split cells by these characters
        opts.DataLines = 1; % start from 1st row
        movementEventData = readtable(logfile,opts);
        
        % make vector of TRs
        TRvec = zeros(nVols,1);
        for n = 2:nVols
            TRvec(n) = TR + TRvec(n-1);
        end
        
        % get rows from movementEventData where timepoint (Var2) best matches TR in vec
        [~,idx]=min(abs( movementEventData.Var2 - TRvec.' )); %relies on implicit expansion, subtracts cumulative TRs from each timepoint and finds row with smallest difference
        TRmovementEventData = movementEventData(idx,:);
        TRmovementEventDataArray = table2cell(convertvars(TRmovementEventData,2,'string')); % make into cell array
        
        %% Get distance to nearest wall per TR
        
        for row = 1:nVols
            
            % get position per TR from (x|180|y) in file
            PositionIdx = find(cellfun(@(c) strcmp(c, 'Position'), TRmovementEventDataArray(row,:)));
            Position = strsplit(TRmovementEventDataArray{row,PositionIdx+2},'|');
            PositionX = str2double(Position{1});
            PositionY = str2double(Position{3});
            
            % get distance to nearest wall and establish which wall is nearest
            if abs(PositionX) > abs(PositionY) % if closer to EW than NS walls
                if sign(PositionX) == 1 % if closer to east than west wall
                    distance = EastWallX - PositionX;
                    NrstWall = 2; % east
                elseif sign(PositionX) == -1
                    distance = abs(WestWallX) - abs(PositionX);
                    NrstWall = 4; % west
                end
            elseif abs(PositionX) < abs(PositionY) % if closer to NS than EW walls
                if sign(PositionY) == 1 % if closer to north than south wall
                    distance = NorthWallY - PositionY;
                    NrstWall = 1; % north
                elseif sign(PositionY) == -1
                    distance = abs(SouthWallY) - abs(PositionY);
                    NrstWall = 3; % south
                end
            elseif PositionX == PositionY && PositionX == 0
                distance = 80; % position is at origin, equidistant to all walls
                NrstWall = 9;
            else
                disp(['X = ' PositionX]);
                disp(['Y = ' PositionY]);
                error('Something weird with coorindates');
            end % of if loop
            
            % get other variables
            time = str2double(TRmovementEventDataArray{row,2});
            phase = TRmovementEventDataArray{row,3}(1:3);
            
            % heading info is (0|x|0)
            orientationIdx = find(cellfun(@(c) strcmp(c, 'Rotation'), TRmovementEventDataArray(row,:)));
            getOrientation = strsplit(TRmovementEventDataArray{row,orientationIdx+2},'|');
            orientation = str2double(getOrientation{2});
            
            % work out if participant is facing nearest wall or not (present in 180 degree view in front, assuming 0/360 is north)
            if NrstWall == 1 && ((270 <= orientation) && (orientation <= 90))
                facingNrst = 1;
            elseif NrstWall == 2 && ((0 <= orientation) && (orientation <= 180))
                facingNrst = 1;
            elseif NrstWall == 3 && ((90 <= orientation) && (orientation <= 270))
                facingNrst = 1;
            elseif NrstWall == 4 && ((180 <= orientation) && (orientation <= 360))
            else
                facingNrst = 0;
            end
            
            % print current row data to results file
            fprintf(fp_Table, '%.3f,%.3f,%s,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n',TRvec(row),time,phase,PositionX,PositionY,orientation,distance,NrstWall,facingNrst);
            
        end % for row
    catch
        warning(['Estimating distance failed for subject ' subject ' block ' blocks{b} ' , continuing to next block']);
    end % for block
    
end
