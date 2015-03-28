function [data,warnings] = EPRbrukerSPCimport(filename)
% EPRBRUKERSPCIMPORT Read Bruker SPC file format.
%
% Usage
%   data = EPRbrukerSPCimport(filename)
%   [data,warning] = EPRbrukerSPCimport(filename)
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
% 2015-03-28

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
dtaFilename = fullfile(fpath,[fname,'.spc']);
[fid,msg] = fopen(dtaFilename);
% If fopen was successful, fid > 2, otherwise fid == -1
if fid > 2
    % Data are binary, big endian, single precision (Bruker ESP, not EMX)
    %data.data = fread(fid,inf,'int32=>real*8',0,'b');
    % For EMX, not ESP
    data.data = fread(fid,inf,'float');
    fclose(fid);
else
    data = struct();
    warnings{end+1} = struct(...
        'identifier','brukerESPload:fileOpen',...
        'message',sprintf('Problems reading file %s: %s',filename,msg)...
        );
    return;
end

end 

% For multiple spectra in one file (EMX, power sweep)
% data.data = reshape(data.data,[],numberOfSpectra);