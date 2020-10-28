function GCAP_logfile2eventTable
%(logfile, setAllDurationsToZero_flag, includeRotation_flag, minActiveTranslDur_sec)
includeRotation_flag = 1;
setAllDurationsToZero_flag = 0;
minActiveTranslDur_sec = 0.01;
subjectvec = {'29780','27734','28061','28428','29317','29321','29332','29336','29358','29382','29383'};
blocks = {'BlockA','BlockB','BlockC'};
pathstem = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/gridcellpilot/raw_data/task_data';

for i = 2:length(subjectvec)
    
    for b = 1:3
        logfile = [pathstem '/' subjectvec{i} '/' blocks{b} '/movemenEventData.csv'];
        % clear all
        % load temp_nabvngnhbnuaper99949949
        
        % rotStr = '';
        % if ~includeRotation_flag
        %     rotStr = 'noRotation_';
        % end
        %
        % allDurationsZeroStr = '';
        % if setAllDurationsToZero_flag
        %     allDurationsZeroStr = 'allDur0_';
        % end
        %
        % minActiveTranslDurStr = '';
        % if minActiveTranslDur_sec > 0
        %     minActiveTranslDurStr = 'noShortRuns_';
        % end
        
        
        
        % open new event table file
        [fpath, fname, ~] = fileparts(logfile);
        newFilename = [fpath filesep 'eventTable_2_' fname '.txt'];
        disp(' ');
        disp(['New event-table: ' newFilename]);
        fp_eventTable = fopen(newFilename, 'w+');
        
        disp(' ');
        disp(['Logfile: ' logfile]);
        
        fid = fopen(logfile);
        tline = fgetl(fid);
        
        
        % ---
        % default init
        currentPhase = 'dummy';
        currentTimestamp = -1;
        currentHeadingDirection = -1000;
        % ---
        
        while ischar(tline)
            
            lineInfo = strsplit(tline, {';', ',', ':'});
            
            if ~isempty(lineInfo{1})
                
                prevLinePhase = currentPhase;
                prevLineTimestamp = currentTimestamp;
                prevLineHeadingDirection = currentHeadingDirection;
                
                % get current timestamp
                currentTimestamp = str2double(lineInfo{2});
                
                % get current facing direction
                rotationInfo = strsplit(lineInfo{end}, {'(', ')', '|', ' '});
                currentHeadingDirection = str2double(rotationInfo{3});
                
                
                %         currentTrialPhaseFlag = str2double(lineInfo{5});
                %         currentTranslFlag = str2double(lineInfo{9});
                %         currentRotationFlag = str2double(lineInfo{10});
                %         currentTimestamp = str2double(lineInfo{2});
                %         currentHeadingDirection = str2double(lineInfo{14});
                
                %         if currentTranslFlag~=0 && currentRotationFlag~=0
                %             error('ERROR');
                
                if strcmp(lineInfo{3}, 'Moving')
                    currentPhase = 'translation';
                    
                    %         elseif currentTranslFlag==1
                    %             currentPhase = 'translation';
                    
                elseif strcmp(lineInfo{3}, 'Rotate to')
                    currentPhase = 'rotation';
                    if ~includeRotation_flag
                        currentPhase = 'other'; % this is actually the rotation phase, but I do not want to include this in my models, so I add this to the "other" phase (which is excluded)
                    end
                    
                    %         elseif currentTrialPhaseFlag==1 && currentHeadingDirection==prevLineHeadingDirection
                    %             currentPhase = 'passiveTranslation';
                    %             if ~includePassiveTransl_flag
                    %                 currentPhase = 'other'; % this is actually the passive translation phase, but I do not want to include this in my models, so I add this to the "other" phase (which is excluded)
                    %             elseif combineActiveAndPassiveTransl_flag
                    %                 currentPhase = 'translation';
                    %             end
                    
                    %         elseif currentTrialPhaseFlag==5
                    %             currentPhase = 'feedback';
                    %
                    %         elseif currentTrialPhaseFlag==0
                    % %             currentPhase = 'instruct';
                    %             currentPhase = 'other'; % this is actually the instruction screen phase, but I do not want to include this in my models, so I add this to the "other" phase (which is excluded)
                    
                else
                    currentPhase = 'other';
                end
                
                
                
                
                % --------------------------
                
                if ~strcmp(prevLinePhase, currentPhase) && ~strcmp(prevLinePhase, 'dummy')
                    % a new phase just started with this line
                    
                    % save the previous phase details
                    if strcmp(prevLinePhase, 'translation')
                        headingOriStr = [';' num2str(prevLineHeadingDirection)];
                    else
                        headingOriStr = '';
                    end
                    if ~strcmp(prevLinePhase, 'other') % do not save 'other' events
                        
                        phaseDuration = currentTimestamp-phaseStartTime;
                        
                        if ~(strcmp(prevLinePhase, 'translation') && phaseDuration < minActiveTranslDur_sec)
                            
                            if setAllDurationsToZero_flag
                                phaseDuration = 0;
                            end
                            
                            fprintf(fp_eventTable, '%s;%.3f;%.3f%s\n', prevLinePhase, phaseStartTime, phaseDuration, headingOriStr);
                            %                     fprintf('%s;%.3f;%.3f%s\n', prevLinePhase, phaseStartTime, phaseDuration, headingOriStr);
                            
                        end
                    end
                    
                    % new phase starts
                    phaseStartTime = currentTimestamp;
                    
                elseif strcmp(prevLinePhase, 'dummy')
                    
                    % new phase starts
                    phaseStartTime = currentTimestamp;
                    
                end
            end
            
            tline = fgetl(fid);
        end
        
    end
end

fclose(fid);

fclose(fp_eventTable);
    

