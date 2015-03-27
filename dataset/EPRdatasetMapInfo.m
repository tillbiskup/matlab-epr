function dataset = EPRdatasetMapInfo(dataset,info)
% EPRDATASETMAPINFO Puts information in info into dataset
%
% Usage
%   dataset = EPRdatasetMapInfo(dataset,info)
%
%   dataset - stucture
%             Dataset complying with specification of toolbox dataset
%             structure
%
%   info    - struct
%             Info structure as returned by commonInfofileLoad
%
% SEE ALSO: EPRdatasetCreate, EPRinfofileLoad, commonDatasetCreate,
% commonInfofileLoad 

% Copyright (c) 2015, Till Biskup
% 2015-03-27

dataset = commonDatasetMapInfo(dataset,info);

end
