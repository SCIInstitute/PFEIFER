function success = baseLineCorrectSignal(TSidx)
% a wrapper function for the actual baselineCorrection

global ScriptData TS


%%%% prepare the inputs
baselineWidth = ScriptData.BASELINEWIDTH;

% start and endframe for baseline correction
startframe =[];
endframe = [];
if isfield(TS{TSidx},'fids')  % first check if there are any 
    blpts = round(fidsFindFids(TSidx,'baseline'));  % get blpts from fids
    if size(blpts,2) > 1
        startframe = blpts(:,1);
        endframe = blpts(:,2);
    end
end
if isempty(startframe)
    startframe = 1;
    endframe = TS{TSidx}.ts.numframes;
end

%%%% check if there is actually a function there to do Baseline Correction
if isempty(ScriptData.BASELINE_OPTIONS)
    errordlg('Cannot do baseline correction, since no baseline correction function is provided. Aborting...')
    success = 0;
    return
end


%%%% now baselineFunction (the function selected to do baseline correction) and check if it is valid
baselineFunctionString = ScriptData.BASELINE_OPTIONS{ScriptData.BASELINE_SELECTION};
if nargin(baselineFunctionString)~=4 || nargout(baselineFunctionString)~=1
    msg=sprintf('the provided baseline correction function ''%s'' does not have the right number of input and output arguments. Cannot filter data. Aborting..',baselineFunctionString);
    errordlg(msg)
    success = 0;
    return
end
baselineFunction = str2func(baselineFunctionString);

%%%% try catch to baseline the data
try
    TS{TSidx}.potvals = baselineFunction(TS{TSidx}.potvals,startframe,endframe,baselineWidth);
catch
    msg = sprintf('Something wrong with the provided baseline correction function ''%s''. Using it to baseline correct the data failed. Aborting..',baselineFunctionString);
    errordlg(msg)
    success = 0;
    return
end

%%%%  check if potvals still have the right format and the filterFunction worked correctly
if TS{TSidx}.numframes ~= size(TS{TSidx}.potvals,2) || TS{TSidx}.numleads ~= size(TS{TSidx}.potvals,1)
    msg = sprintf('The provided baseline correction function ''%s'' does not work as supposed. It changes the dimensions of the potvals. Using it to baseline correct the data failed. Aborting..',baselineFunctionString);
    errordlg(msg)
    success = 0;
    return
end

%%%% add an audit string to ts.audit
tsAddAudit(TSidx,sprintf('| baseline correction using the function ''%s'': startframe %d endframe %d over a window of %d frames',startframe,endframe,baselineWidth));

success = 1;