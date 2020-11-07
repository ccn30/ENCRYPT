#/bin/bash
# wrapper script to call PIT_data2table.m

which matlab
pathstem=/lustre/scratch/wbic-beta/ccn30/ENCRYPT

## separate txt file with subject and date IDs

#!mysubjs=${pathstem}/testsubjcode.txt
mysubjs=${pathstem}/ENCRYPT_MasterCBcodes.txt

xmlDir='/lustre/scratch/wbic-beta/ccn30/ENCRYPT/task_data/PIT/raw_data'

for CBcode in `cat $mysubjs`
do

echo "******** starting $CBcode ********"

#"$MATLABPATH"/bin/matlab.nowrap -nodesktop -nosplash -nodisplay -r "try, PIT_data2table('${CBcode}',${xmlDir}); end ; quit"

done
