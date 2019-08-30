function [data, warnings] = EPRMagnettechImport(filename)
%EPRMagnettechImport Read Magnettech (xml) file format
%
% Usage
%   data = EPRMagnettechImport(filename)
%   [data,warning] = EPRMagnettechImport(filename)
%
%   filename - string
%              name of a valid filename (of a Bruker BES3T file)
%   data     - struct
%              structure containing data and additional fields
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.
%
% NOTE:
% This function currently makes use of the EasySpin eprload function.
% Furthermore, it is only designed to read 1D spectra I(B0)
%
% SEE ALSO: EPRimport, EPRbrukerBES3Timport, EPRbrukerSPCimport

% Copyright (c) 2019, Till Biskup
% 2019-08-29

% Assign default output
data = [];
warnings = cell(0);

% Preassign values to the data struct
data = EPRdatasetCreate();

[b0,int,param] = eprload(filename);

data.data = int';
data.axes.data(1).values = b0;

data.file.name = filename;
data.file.format = "Magnettech XML";

data.header = param;

data = assign_parameters(data,param);

end

function data = assign_parameters(data,parameters)

% Cell array correlating struct fieldnames read from the DSC file and
% from the toolbox data structure.
parameterMatching = {
    'XDatasource','axes.data(1).measure'; ...
    'YDatasource','axes.data(2).measure'; ...
    'XUnit','axes.data(1).unit'; ...
    'YUnit','axes.data(2).unit'; ...
    'XUnit','parameters.field.start.unit'; ...
    'Name','label'; ...
    'Bfrom','parameters.field.start.value'; ...
    'Bto','parameters.field.stop.value'; ...
    'XUnit','parameters.field.start.unit'; ...
    'MicrowavePower','parameters.bridge.power'; ...
    'MwFreq','parameters.bridge.MWfrequency'; ...
    'Accumulations','parameters.recorder.averages'; ...
    };
% Assign values according to cell array above. Therefore, make use of
% the two internal functions setCascadedField and getCascadedField.
for k=1:length(parameterMatching)
    if isfield(parameters,parameterMatching{k,1})
        data = commonSetCascadedField(...
            data,...
            parameterMatching{k,2},...
            commonGetCascadedField(parameters,parameterMatching{k,1}));
    end
end

% Assign manually a few parameters that cannot easily assigned above
data.parameters.runs = 1;
data.parameters.date = ...
    datestr(datenum(parameters.Timestamp,'yyyy-mm-ddTHH:MM:SS'),31);

if data.axes.data(1).measure == "BField"
    data.axes.data(1).measure = 'magnetic field';
end

if data.axes.data(2).measure == "MW_Absorption"
    data.axes.data(2).measure = 'intensity';
end

end