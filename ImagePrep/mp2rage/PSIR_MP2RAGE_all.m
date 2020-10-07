% Emma L Hall Jan 2012
% Updated by Olivier Mar 2012 -> Jan 2018
% Creating PSIR and MP2RAGE Images
% Modified by Ian Driver Feb 2017 for CUBRIC data
%					- Reads and writes using read_avw and save_avw (more automated & can cope with Siemens 12-bit data)
%					- Includes an if loop to rescale Siemens phase data (range 0 - 4095) to radians (range -pi - +pi)


function PSIR_MP2RAGE_all(varargin)%(m1,m2,p1,p2)%(path,file,p,m)
% Input can either be modulus (m1) and phase (p1) of both INV1 and INV2 in the same file
% or one volume per inversion per modality (m1, m2, p1, p2)

disp('You are in the PSIR function')
fsldir = getenv('FSLDIR'); fsldirmpath = sprintf('%s/etc/matlab',fsldir);
addpath(genpath(fsldirmpath));

if length(varargin)==2
    m1=varargin{1};
    p1=varargin{2};
elseif length(varargin)==4
    m1=varargin{1};
    m2=varargin{2};
    p1=varargin{3};
    p2=varargin{4};
else
    error('You need to specify modulus and phase images (2 or 4 volumes)')
end

%% Loading in data and checking format - ID
[pha pha_dim pha_res] = read_avw(p1);
[imm imm_dim imm_res] = read_avw(m1);

if length(varargin)>2
    [pha(:,:,:,2) pha_dim pha_res] = read_avw(p2);
    [imm(:,:,:,2) imm_dim imm_res] = read_avw(m2);
end

if max(pha(:))-min(pha(:)) > 4000
	pha = pha*2*pi/4095 - pi;
	disp('Phase data rescaled to radians (Assuming Siemens data range [0 4095])')
end

if sum((size(pha)-size(imm)).^2)==0
	dim = size(pha);disp([num2str(dim) 'is the image dimension'])
else
	disp([num2str(size(pha)) ' and ' num2str(size(imm))])
	error('phase and magnitude image dimensions do not match')
end
if sum((pha_res-imm_res).^2)==0
	vsize = pha_res;
else
	disp([num2str(pha_res) ' and ' num2str(imm_res)])
	error('phase and magnitude image resolutions do not match')
end

clear pha_dim imm_dim pha_res imm_res

%%MP2RAGE creation
Sx1=imm(:,:,:,1).*exp(j.*pha(:,:,:,1));
Sx2=imm(:,:,:,2).*exp(j.*pha(:,:,:,2));

%% Necessary to correct B1inh
S2=abs(imm(:,:,:,2));
S=abs(imm(:,:,:,2)+imm(:,:,:,1)); 
S=smooth3(S,'gaussian',[9 9 9],150);   

%% Sign Correct the Modulus Data
% New way to correct for sign
f=sign(real(conj(Sx1).*Sx2));
imm=repmat(f,[1 1 1 2]).*imm;

%% Create PSIR
PSIRim=(imm(:,:,:,1))./S;

%% Apply a Simple Threshold Based Mask
%mask=S>10;
mask=S>0;%ID - previous mask with S>10 cut off some inferior brain areas
PSIRim=PSIRim.*mask;
PSIRim(isnan(PSIRim))=0;

%% Create a all positive image, and threshold the PSIR to [-2 2]

mask=PSIRim<-2;
PSIRim(mask)=-2;
mask=PSIRim>2;
PSIRim(mask)=2;

S(mask)=0;
PSIRim = PSIRim+1;

MP2RAGE=real(conj(Sx1).*Sx2./(abs(Sx1).^2+abs(Sx2).^2));

%% Writing data as img/hdr Analyze pairs - ID
outfil = strcat(m1,'_PSIR.img');
save_avw(PSIRim,outfil,'f',vsize);
outfil2 = strcat(m1,'_PD_smooth.img');
save_avw(S,outfil2,'f',vsize);
outfil3 = strcat(m1,'_MP2RAGE.img');
save_avw(MP2RAGE,outfil3,'f',vsize);

disp('The PSIR reconstruction is done.')