function [fitInfo, drift]=DME_drift_estimate(handles)

%% if too many localizations
N=length(handles.fitInfo(:,1));
if N>10000000
%     ID=handles.fitInfo(:,6)<0.06 & handles.fitInfo(:,7)<0.06;
    ID=handles.fitInfo(:,1)>10000/110 & handles.fitInfo(:,1)<35000/110 & handles.fitInfo(:,2)>8000/110 & handles.fitInfo(:,2)<33000/110 & handles.fitInfo(:,6)<0.08 & handles.fitInfo(:,7)<0.08;
    
    coords=[];
    coords(:,1)=handles.fitInfo(ID,1);
    coords(:,2)=handles.fitInfo(ID,2);
    imagesz=handles.totsz;
    im=cHistRecon(imagesz*3,imagesz*3,single(coords(:,2))*3,single(coords(:,1))*3,0);
    gaussim=gaussf(im,[1 1]);
    dipshow(gaussim); 
    pause(eps)
    
else
    ID=ones(N,1)>0;
end

%% Prepare data
localizations=handles.fitInfo(ID,1:2);
crlb=handles.fitInfo(ID,6:7);
framenum=handles.fitInfo(ID,3);    
if handles.parameter.drift_z 
    flag_3D=1;
    localizations(:,3)=handles.fitInfo(ID,10);
    if handles.parameter.cspline
        crlb(:,3)=handles.Z_err(ID)/1000;   % nm to um
    else
        crlb(:,3)=0.02;
    end
else
    flag_3D=0;
end

%% User inputs RCC drift computation
zoom = 5;
sigma = 1;
maxpairs = 1000;
framebin = handles.parameter.tWindow*handles.fps;
timebins = ceil((max(framenum)/framebin));
usecuda = true; 

%% RCC computation
str=[handles.folder_result,handles.filebase,'_drift_xyz.mat'];
if exist(str,'file')
    load(str);
else
    tic
    if flag_3D
        [drift_xyz] = rcc3D(localizations, framenum, timebins, zoom, sigma, maxpairs, usecuda);
    else
        [drift_xyz] = rcc(localizations, framenum, timebins, zoom, sigma, maxpairs, usecuda);
    end
    toc
    save(str,'drift_xyz');
end

%% User inputs for drift estimation - !keep data types alive!
coarse_est = false;                     % Coarse drift estimation (bool)
precision_est = false;                  % Precision estimation (bool)
coarse_frames_per_bin = int32(100);     % Number of bins for coarse est. (int32)
framesperbin = int32(10);               % Number of frames per bin (int32)
maxneighbors_coarse = int32(1000);      % Max neighbors for coarse and precision est. (int32)
maxneighbors_regular = int32(1000);     % Max neighbors for regular est. (int32)
coarseSigma= single(mean(crlb));        % Localization precision for coarse estimation (single/float)                     
max_iter_coarse = int32(1000);          % Max iterations coarse est. (int32)
max_iter = int32(10000);                % Max iterations (int32)
gradientstep = single(1e-6);            % Gradient (single/float)

%% Drift estimation
drift = dme_estimate(localizations, framenum, crlb, drift_xyz, usecuda, coarse_frames_per_bin, ...
    framesperbin, maxneighbors_coarse,maxneighbors_regular, coarseSigma, max_iter_coarse, max_iter, gradientstep, precision_est);

%% plot
figure;
for i = 1:size(drift,2)
    subplot(size(drift,2),1,i);
    plot(1:1:max(framenum), drift(:,i), 'LineWidth', 2);
    hold on
    plot(1:1:max(framenum), drift_xyz(:,i), 'LineWidth', 2);
    legend('Estimated drift (DME)', 'Estimated drift (RCC)') ;
end

%% Output
drift_per_frame = drift(handles.fitInfo(:,3),:);
fitInfo = single(zeros(N,3));
fitInfo(:,1:2) = handles.fitInfo(:,1:2)-drift_per_frame(:,1:2);
fitInfo(:,3) = handles.fitInfo(:,3);
if flag_3D
    fitInfo(:,4) = handles.fitInfo(:,10)-drift_per_frame(:,3);
end
