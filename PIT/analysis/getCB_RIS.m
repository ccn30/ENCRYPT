function getCB_RIS()

participantCSV_dir = '/lustre/scratch/wbic-beta/ccn30/ENCRYPT/task_data/gridtask';
subjDirList = dir(participantCSV_dir);
outputArray = {};

% delete all list entries that precede with . or $ (except ..), or non dir
subjDirList(~[subjDirList(:).isdir]) = [];
letters = cellfun(@(x) x(1:1),{subjDirList(:).name},'un',0);
badIds = find(strcmp(letters, '.') | strcmp(letters, '$'));
subjDirList(badIds) = [];

for subjIdx = 1:length(subjDirList)
    
    subjDir = [participantCSV_dir filesep subjDirList(subjIdx).name];
    opts = detectImportOptions([subjDir '/BlockA/participantData.csv']);
    % read matrix is skipping top line??
    subjCSVA = readmatrix([subjDir '/BlockA/participantData.csv'],'OutputType','string');
    subjCSVB = readmatrix([subjDir '/BlockB/participantData.csv'],'OutputType','string');
    
    RIS_A = subjCSVA{1,2}
    RIS_B = subjCSVB{1,2}
    CODE_A = subjCSVA{2,2}
    CODE_B = subjCSVB{2,2}

    if strcmp(RIS_A,RIS_B) && strcmp(CODE_A,CODE_B)
        outputArray{subjIdx,1} = RIS_A;
        outputArray{subjIdx,2} = CODE_A;
    else
        warning(['Mismatch of block codes for ' RIS_A ' ' RIS_B ' ' CODE_A ' ' CODE_B]);
    end
    
end

cell2csv([participantCSV_dir filesep 'CB_RIS_codes.csv'], outputArray);
save(    [participantCSV_dir filesep 'CB_RIS_codes.mat'], 'outputArray');

disp(' ');
disp(['data saved to: ' participantCSV_dir filesep filename 'CB_RIS_codes.mat']);
    
end