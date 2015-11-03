function [data,warnings] = EPRbrukerSPCimport(filename)
% EPRBRUKERSPCIMPORT Read Bruker SPC file format.
%
% Usage
%   data = EPRbrukerSPCimport(filename)
%   [data,params,warning] = EPRbrukerSPCimport(filename)
%
%   filename - string
%              name of a valid filename (of a Bruker SPC file)
%   data     - struct
%              structure containing data and additional fields
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.
%
% % SEE ALSO: EPRbrukerBES3Timport

% Copyright (c) 2011-15, Till Biskup
% 2015-11-03

% Assign default output
data = [];
warnings = cell(0);
 
try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename', @(x)ischar(x));
    p.parse(filename);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Read Bruker ESP/WinEPR binary data
[fpath,fname,~] = fileparts(filename);
dscFilename = fullfile(fpath,[fname,'.par']);
dtaFilename = fullfile(fpath,[fname,'.spc']);

[params,fmt] = loadParamsFile(dscFilename);

[fid,msg] = fopen(dtaFilename);
% If fopen was successful, fid > 2, otherwise fid == -1
if fid > 2
    switch lower(fmt)
        case 'esp'
            % Data are binary, big endian, single precision (Bruker ESP) 
            data.data = fread(fid,inf,'int32=>real*8',0,'b');
        case 'emx'
            % For EMX, not ESP
            data.data = fread(fid,inf,'float');
    end
    fclose(fid);
else
    data = struct();
    warnings{end+1} = struct(...
        'identifier','brukerESPload:fileOpen',...
        'message',sprintf('Problems reading file %s: %s',filename,msg)...
        );
    return;
end

data.params = params;

end 

% For multiple spectra in one file (EMX, power sweep)
% data.data = reshape(data.data,[],numberOfSpectra);

function [params,fmt] = loadParamsFile(dscFilename)

fileContent = fileread(dscFilename);
% Determine file format: ESP (UNIX style) or EMX (DOS style)
if any(strfind(fileContent,sprintf('\r')))
    fmt = 'emx';
    fileContent = regexp(fileContent,'\r','split');
else
    fmt = 'esp';
    fileContent = regexp(fileContent,'\n','split');
end

% Remove empty lines
fileContent(cellfun(@isempty,fileContent)) = [];

[fields,values] = strtok(fileContent,' ');
for field=1:length(fields)
    params.(fields{field}) = strtrim(values{field});
end

end
