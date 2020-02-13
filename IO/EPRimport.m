function dataset = EPRimport(filename,varargin)
% EPRIMPORT Read EPR data from different file types and return dataset
% complying to EPR toolbox dataset structure.
%
% Usage
%   dataset = EPRimport(filename)
%
%   filename - string
%              name of a valid filename 
%
%   dataset  - struct
%              structure containing data and additional fields
%              Complying to EPR toolbox dataset structure
%
% Optional parameters
%
%   RCnorm       - boolean
%                  Normalise for receiver gain (RC), aka divide intensities
%                  of spectrum by RC value.
%                  Default: false
%
%   SCnorm       - boolean
%                  Normalise for number of scans, aka divide by this number
%                  Default: false
%
%   vendorFields - boolean
%                  Add vendor-specific parameters and format information to
%                  dataset in structure "vendor"
%                  Default: false
%
% NOTE: Currently (2015-11-17), this function has not been checked properly
%       with other than Bruker PAR/SPC data (from EMX/ESP respectively). 
%       Once this has been done, remove this note.
%
% See also: EPRbrukerSPCimport, EPRbrukerBES3Timport, EPRdatasetCreate

% Copyright (c) 2015-2020, Till Biskup
% Copyright (c) 2015, Deborah Meyer
% 2020-02-13

% Create dataset
dataset = struct();

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x));
    p.addParameter('RGnorm',false,@islogical);
    p.addParameter('SCnorm',false,@islogical);
    p.addParameter('vendorFields',false,@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Remove extension from filename if any
[path,name,ext] = fileparts(filename);
filename = fullfile(path,name);

fileFormat = '';
% If there was an extension, try to guess file format, otherwise try to
% find respective files and guess this way.
if ~isempty(ext(2:end))
    switch lower(ext(2:end))
        case {'par','spc'}
            fileFormat = 'BrukerSPC';
        case {'dsc','dta'}
            fileFormat = 'BrukerBES3T';
        case {'xml'}
            fileFormat = 'MagnettechXML';
    end
else
    if exist(fullfile(path,[name '.par']),'file')
        fileFormat = 'BrukerSPC';
    elseif exist(fullfile(path,[name '.DSC']),'file')
        fileFormat = 'BrukerBES3T';
    elseif exist(fullfile(path,[name '.xml']),'file')
        fileFormat = 'MagnettechXML';
    end
end

% Try to load file
switch fileFormat
    case 'BrukerSPC'
        [rawData, warnings] = EPRbrukerSPCimport(filename,'RGnorm',p.Results.RGnorm);
    case 'BrukerBES3T'
        [rawData, warnings] = EPRbrukerBES3Timport(filename);
    case 'MagnettechXML'
        [rawData, warnings] = EPRMagnettechImport([filename '.xml']);
    otherwise
        % Try to load file assuming bare ASCII data with two columns,
        % axis in first column and intensity values in second column
        try
            extensions = {'.txt','.dat'};
            for extension = 1:length(extensions)
                fullfilename = [filename extensions{extension}];
                if exist(fullfilename,'file')
                    tmpData = load(fullfilename);
                    rawData.axes(1).values = tmpData(:,1)';
                    rawData.data = tmpData(:,2);
                    break;
                end
            end
        catch
            warning('Unknown file format. Nothing loaded!');
            return;
        end
end

if ~exist('rawData', 'var')
    warning('Problem loading file. Nothing loaded!');
    return;
end

% Try to convert field axis: G -> mT
if isfield(rawData.axes.data(1),'unit') && strcmpi(rawData.axes.data(1).unit,'g')
    rawData.axes.data(1).values = rawData.axes.data(1).values / 10;
    rawData.axes.data(1).unit = 'mT';
end

% Create dataset with correct number of axes
dataset = EPRdatasetCreate('numberOfAxes',length(rawData.axes.data)+1);

% Assign a minimum of fields in the dataset
dataset.data = rawData.data';
for axis = 1:length(rawData.axes.data)
    dataset.axes.data(axis) = ...
        commonStructCopy(dataset.axes.data(axis),rawData.axes.data(axis));
end
dataset.axes.data(end).measure = 'intensity';

% Fill origdata fields
dataset.origdata = dataset.data;
dataset.axes.origdata = dataset.axes.data;

% Add file info
dataset.file.name = filename;
dataset.file.format = fileFormat;

% Add parameters in case of MagnettechXML
if strcmp(fileFormat,'MagnettechXML')
    dataset.parameters = rawData.parameters;
end

% Add vendor fields if asked
if p.Results.vendorFields
    dataset.vendor.fileFormat = fileFormat;
    if strcmp(fileFormat,'BrukerSPC')
        dataset.vendor.parameters = rawData.params;
    end
end

end