function leadsToAutofiducialize = getleadsToAutofiducialize(numLeadsToBeFiducialised,leadsOfAllGroups,demandedLeads,badLeads)
% get leadsToAutofiducialize, the leads to find fiducials for and show in autofiducializer window.  Only these leads will be autofiducialized and used to compute the global fids


% %%%% find the blankedLeads, the leads that contain only zeros, we don't want those!!
% potvals = TS{SCRIPTDATA.CURRENTTS}.potvals;
% blankedLeads = [];
% for leadIdx = 1:size(potvals,1)
%     if nnz(potvals(leadIdx,1:20:end)) == 0
%         blankedLeads(end+1) = leadIdx;
%     end
% end
blankedLeads = [];

%%%% filter out the bad leads and blankedLeads from leadsOfAllGroups and demandedLeads


unwantedLeads = [blankedLeads, badLeads];



demandedLeads = setdiff(demandedLeads, unwantedLeads);
leadsOfAllGroups = setdiff(leadsOfAllGroups, unwantedLeads);


%%%% now get nToBeFiducialised beats, if there are not enoug demandedLeads
numDemandedLeads = length(demandedLeads);
numStillNeededLeads = numLeadsToBeFiducialised - numDemandedLeads;

leadsOfAllGroups = setdiff(leadsOfAllGroups, demandedLeads);
idxs = round(linspace(1,length(leadsOfAllGroups),numStillNeededLeads));

leadsToAutofiducialize = [leadsOfAllGroups(idxs), demandedLeads];