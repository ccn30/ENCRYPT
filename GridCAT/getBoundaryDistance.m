function getBoundaryDistance()
% iterate through movementEventData and get each subject position/facing
% direction, estimate boundary positions, could get trajectories and
% positions of objects

taskDir='/lustre/scratch/wbic-beta/ccn30/ENCRYPT/task_data/gridtask';
blocks = {'BlockA','BlockB','BlockC'};
subject='25739';

for b = 1:3
    logfile = [taskDir '/' subject '/' blocks{b} '/movemenEventData.csv'];
    
    % open new event table file
    [fpath, ~] = fileparts(logfile);
    newFilename = [fpath filesep 'pathCoordinates_' subject '_' blocks{b} '.csv'];
    disp(' ');
    disp(['New event-table: ' newFilename]);
    fp_pathTable = fopen(newFilename, 'w+');
    
    disp(' ');
    disp(['Logfile: ' logfile]);
    
    fid = fopen(logfile);
    tline = fgetl(fid);
    
    % ---
    % default init first line in path file
    headings = 'Phase,Time,HeadingDir,X,Y,Target,Direction';
    fprintf(fp_pathTable,headings);
    fprintf(fp_pathTable,'\n');
    %---
    
    while ischar(tline)
        
        lineInfo = strsplit(tline, {';', ',', ':'});
        
        if ~isempty(lineInfo{1})
            
            if strcmp(lineInfo{3}, 'Start to move')
                currentPhase = 'Moving';
                
                % get current timestamp
                currentTimestamp = str2double(lineInfo{2});
                
                % get current facing direction
                rotationInfo = strsplit(lineInfo{end}, {'(', ')', '|', ' '});
                currentHeadingDirection = str2double(rotationInfo{3});
                
                % get current position
                positionInfo = strsplit(lineInfo{end-1}, {'(', ')', '|', ' '});
                currentX = str2double(positionInfo{2});
                currentY = str2double(positionInfo{4});
                
                % get planned distance
                Target = strsplit(lineInfo{4},'\s*m','DelimiterType','RegularExpression');
                currentTarget = str2double(Target{1});
                % get planned direction
                currentDirection = 'na';
                
                fprintf(fp_pathTable, '%s,%.2f,%d,%.2f,%.2f,%.2f,%s\n', currentPhase, currentTimestamp, currentHeadingDirection, currentX, currentY, currentTarget, currentDirection);

                
            elseif strcmp(lineInfo{3}, 'Start to rotate to')
                
                currentPhase = 'Rotating';
                
                % get current timestamp
                currentTimestamp = str2double(lineInfo{2});
                
                % get current facing direction
                rotationInfo = strsplit(lineInfo{end}, {'(', ')', '|', ' '});
                currentHeadingDirection = str2double(rotationInfo{3});
                
                % get current position
                positionInfo = strsplit(lineInfo{end-1}, {'(', ')', '|', ' '});
                currentX = str2double(positionInfo{2});
                currentY = str2double(positionInfo{4});
                
                % get target rotation
                currentTarget = str2double(lineInfo{4});
                
                % get planned direction
                currentDirection = strtrim(lineInfo{8});
                
                fprintf(fp_pathTable, '%s,%.2f,%d,%.2f,%.2f,%.2f,%s\n', currentPhase, currentTimestamp, currentHeadingDirection, currentX, currentY, currentTarget, currentDirection);

                
            end % if is moving or rotating
                        
        end % if is empty
        
        tline = fgetl(fid);
        
    end % while isChar
    
end % for blocks

fclose(fid);

fclose(fp_pathTable);

end %of function