function DemoFindMatches()
close all
count=1;        % to save the variances
variances=struct();


%%%% set params here
Runs=[70 80 90];    % wich files to investigate
%Runs=[20 30];

for Run=Runs
    accuracy=0.90;  % abort condition5
    fidsKernelLength=10;  % the kernel indices will be from fidsValue-fidsKernelLength  until fidsValue+fidsKernelLength
    kernel_shift=0;       % a "kernel shift", to shift the kernel by kernel_shift
    % reminder: it is kernel_idx=fid_start-fidsKernelLength+kernel_shift:fid_start+fidsKernelLength+kernel_shift

    window_width=20;   % dont search complete beat,
    % ws=bs+loc_fidsValues(fidNumber)-window_width;  
    % we=bs+loc_fidsValues(fidNumber)+window_width;

    leadsToWorkWith=20:50:900;  %which lead to find fiducials for and plot

    fiducialsToBeFound=[1 2 3 4 5];       %the indices in allFidsTypes=[2 4 5 6 7] of fids to be searched for;


    data=fullfile('C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\Testing\17-6-30 latestExp\Data\Preprocessed',sprintf('Run%04d.mat',Run));
    fidData=fullfile('C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\Testing\17-6-30 latestExp\Data\Processed',sprintf('Run%04d-ns.mat',Run));


    %%%% get all the kernels (beat and fids)

    load(fidData)

    % beat
    bsk=ts.selframes(1); 
    bek=ts.selframes(2);

    %%%% fids to be found
    %local fids
    loc_qrs_start=round(ts.fids([ts.fids.type]==2).value);
    loc_qrs_end=round(ts.fids([ts.fids.type]==4).value);
    loc_t_start=round(ts.fids([ts.fids.type]==5).value);
    loc_t_end=round(ts.fids([ts.fids.type]==7).value);
    loc_t_peak=round(ts.fids([ts.fids.type]==6).value);


    startframe=ts.selframes(1);
    glob_qrs_start=startframe-1+loc_qrs_start;        % it looks for kernel_idx=fid_start-fidsKernelLength:fid_start+fidsKernelLength
    glob_qrs_end=startframe-1+loc_qrs_end;    % values taken from OldExp_R15-ns_WithRealFids.mat

    glob_t_start=startframe-1+loc_t_start;        % it looks for kernel_idx=fid_start-fidsKernelLength+kernel_shift:fid_start+fidsKernelLength+kernel_shift
    glob_t_end=startframe-1+loc_t_end;    % values taken from OldExp_R15-ns_WithRealFids.mat
    glob_t_peak=startframe-1+loc_t_peak; 



    clear global allFids
    global allFids   % optional, just to have a look at it


    %%%% get potvals and signal (RMS) from testrun 
    load(data)
    potvals=ts.potvals(leadsToWorkWith,:);
    signal = preprocessPotvals(potvals);
    % temporal filter
    A = 1;
    B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
    D = potvals';
    D = filter(B,A,D);
    D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
    potvals = D';

    % normalise & rescale all potval leads
    for p=1:size(potvals,1)
        potvals(p,:)=potvals(p,:)-min(potvals(p,:));
        potvals(p,:)=potvals(p,:)./max(potvals(p,:));
    end


    %%%% set up everything so that "findAllFids" works
    nFids=length(fiducialsToBeFound); 

    % this is only "internal use" to find the fids to be seached for, not used in actuall stuff
    allGlobFidsValues=[glob_qrs_start; glob_qrs_end; glob_t_start; glob_t_peak; glob_t_end];  %this is only to get right indeces
    allLocFidsValues=[loc_qrs_start; loc_qrs_end; loc_t_start; loc_t_peak; loc_t_end];
    allFidsTypes=[2 4 5 6 7];

    % the actuall fids to be searched for
    fidsTypes=allFidsTypes(fiducialsToBeFound);
    glob_fidsValues = allGlobFidsValues(fiducialsToBeFound);
    loc_fidsValues = allLocFidsValues(fiducialsToBeFound);


    %%%% set up the fsk and fek
    fsk=glob_fidsValues-fidsKernelLength+kernel_shift;
    fek=glob_fidsValues+fidsKernelLength+kernel_shift;


    %%%%% find the beats
    beats=findMatches(signal, signal(bsk:bek), accuracy);
    nBeats=length(beats);
    %%%% initialice/preallocate allFids
    defaultFid(nFids).type=[];
    [allFids{1:nBeats}]=deal(defaultFid);
    
    
    info=sprintf('window_width = %d, fidsKernel_width = %d, kernel_shift = %d,',window_width,fidsKernelLength,kernel_shift);
    variances(1).info=info;
    %%%%%%%%%%%%% fill AllFids with values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tic  
    for beatNumber=1:length(beats) %for each beat

        bs=beats{beatNumber}(1);  % start of beat

        for fidNumber=1:nFids

            %windows=potvals(:,bs:be);

            ws=bs+loc_fidsValues(fidNumber)-window_width;  % dont search complete beat, only around fid
            we=bs+loc_fidsValues(fidNumber)+window_width;
            windows=potvals(:,ws:we);



            
            kernels=potvals(:,fsk(fidNumber):fek(fidNumber));

            [globFid, indivFids, variance] = findFid(windows,kernels,'normal');


            indivFids=indivFids+fidsKernelLength-kernel_shift+bs-1+loc_fidsValues(fidNumber)-window_width;  % now  newIndivFids is in "complete potvals" frame.
            globFid=globFid+fidsKernelLength-kernel_shift+bs-1+loc_fidsValues(fidNumber)-window_width;      % put it into "complete potvals" frame
         
            %%%% put the found newIndivFids in allFids
            allFids{beatNumber}(fidNumber).type=fidsTypes(fidNumber);
            allFids{beatNumber}(fidNumber).value=indivFids;
            allFids{beatNumber}(fidNumber).variance=variance;


            %%%% add the global fid to allFids
            allFids{beatNumber}(nFids+fidNumber).type=fidsTypes(fidNumber);
            allFids{beatNumber}(nFids+fidNumber).value=globFid; 
        end
    end

    toc
    
    
    %%%%%%% plot stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%% plot the beats to see which beat was found %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % figure
    % time=1:length(signal);
    % close all
    % plot(time,signal)
    % set(gcf,'Units', 'Inches','Position',[1 1 13 7])
    % 
    % length(signal)
    % % plot matches
    % yshift=0.3;
    % for p=1:length(beats)
    %     idx=time(beats{p}(1):beats{p}(2));
    %     hold on
    %     plot(time(idx),signal(idx)+1+yshift, 'r')
    %     yshift=-yshift;
    % end
    % % plot kernel
    % hold on
    % plot(time(bsk:bek),signal(bsk:bek),'k')


    %%%%% plot all leads to see which fiducials where found %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure
    
    time=1:size(potvals,2);
    yOffShift=0;  % offshift to "stack plots on top of each other"

    for lead=1:length(leadsToWorkWith) % for each lead
        % plot single leadToPlot
        plot(time,potvals(lead,:)+yOffShift)
        hold on

        % plot the found fiducials
        minY=yOffShift;
        maxY=+yOffShift+1;
        xlim([1,3000]);
        for beatNumber=1:length(beats)

            % get the values to plot
            qrs_start=[]; qrs_end=[]; t_start=[]; t_end=[]; t_peak=[];
            for fidNumber=1:nFids            
                switch  allFids{beatNumber}(fidNumber).type
                    case 2
                        qrs_start=allFids{beatNumber}(fidNumber).value(lead);
                    case 4
                        qrs_end=allFids{beatNumber}(fidNumber).value(lead);
                    case 5
                        t_start=allFids{beatNumber}(fidNumber).value(lead);
                    case 6
                        t_peak=allFids{beatNumber}(fidNumber).value(lead);
                    case 7
                        t_end=allFids{beatNumber}(fidNumber).value(lead);
                end
            end       
            % now plot the values (the patches/line)
            if ~isempty(qrs_start)
                patch('Xdata',[qrs_start qrs_start qrs_end qrs_end],'Ydata',[minY maxY maxY minY],'FaceColor','r','hittest','off','FaceAlpha', 0.2);
            end
            if ~isempty(t_start)
                patch('Xdata',[t_start t_start t_end t_end],'Ydata',[minY maxY maxY minY],'FaceColor','b','hittest','off','FaceAlpha', 0.2);
            end
            if ~isempty(t_peak)
                line('Xdata',[t_peak t_peak],'Ydata',[minY maxY],'LineStyle','--','hittest','off','Color','b');
            end
        end

        % plot the fiducal kernel  fid_start:fid_end

        patch('Xdata',[glob_fidsValues(1) glob_fidsValues(1) glob_fidsValues(2) glob_fidsValues(2)],'Ydata',[minY maxY maxY minY],'FaceColor','k','hittest','off','FaceAlpha', 0.4);


        yOffShift=yOffShift+1;
    end
    
    title_string=[sprintf('Run%04d, leads: ',Run) num2str(leadsToWorkWith)];
    title(title_string);
    set(gcf,'Units', 'Inches','Position',[1 1 13 7])

    
    
    %%%% comparison coef_xcor  and matlab xcor  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % 
    % figure
    % time=1:size(potvals,2);
    % 
    % % plot single leadToPlot
    % plot(time,potvals(lead,:))
end

%%%% save the variances
save('variances','variances')




function signal = preprocessPotvals(potvals)
% do temporal filter and RMS, to get a signal to work with

%%%% temporal filter
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
D = potvals';
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
potvals = D';

%%%% do RMS
signal=rms(potvals,1);
signal=signal-min(signal);



function [xc, lags] = coef_xcorr(window, kernel)
%like original xcorr, but with 'coef'.  No Zeros are appended! Instead, window is shortended. No "overlapp"
% can be used exactly like normal xcorr
% only returns the lags from 0 to length(windows)-length(kernel)-2 ! so no overlap

length_kernel=length(kernel);
lagshift=0;
lags=1:length(window)-length_kernel+1;   %only the lags with "no overlapping"

xc=zeros(1,length(lags));
for lag=lags
    xc(lag)=xcorr(window(lag:lag+length_kernel-1), kernel,lagshift,'coef');
end
lags=lags-1;   % to make it behave like original xcorr

