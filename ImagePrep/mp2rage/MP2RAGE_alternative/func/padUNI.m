t1=spm_vol(MP2RAGE.filenameUNI);
if t1.dim(1)==224 % ok
elseif t1.dim(1)==223 % pad
    t1.dim = t1.dim + [1 0 0];
    vol=zeros(t1.dim);
    vol(1:223,:,:) = t1.private.dat(:,:,:);
    spm_write_vol(t1,vol);
    clear t1; clear vol
else
    disp('Something wrong with T1 dimensions');
end
