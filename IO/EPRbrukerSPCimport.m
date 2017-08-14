function [data,warnings] = EPRbrukerSPCimport(filename,varargin)
% EPRBRUKERSPCIMPORT Read Bruker SPC file format.
%
% Usage
%   data = EPRbrukerSPCimport(filename)
%   [data,warnings] = EPRbrukerSPCimport(filename)
%   [data,warnings] = EPRbrukerSPCimport(filename,<param>,<value>)
%
%   filename - string
%              name of a valid filename (of a Bruker SPC file)
%
%   data     - struct
%              structure containing data and additional fields
%
%   warnings - cell array of strings
%              empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.
%
% Optional parameters
%
%   RGnorm   - boolean
%              Normalise for receiver gain (RC), aka divide intensities of
%              spectrum by RC value.
%              Default: false
%
%   SCnorm   - boolean
%              Normalise for number of scans, aka divide by this number
%              Default: false
%
%
% A few notes on the Bruker SPC file format: 
%
% The Bruker SPC file format is actually two different binary file formats,
% one used for the EMX series (4 byte floating point) and one used for the
% ESP and ECS series (4 byte integer Motorola format). Fortunately, it
% looks like the par file can be used to distinguish between both, as the
% par file of the EMX series contains CR as line endings, whereas the
% ESP/ECS series par files use *NIX-style LF. 
%
% As the par files only contain those parameters that differ from their
% default values, the params structure will contain all parameters given by
% Bruker's data format specification with their default values and only
% those parameters changed that are read from the actual par file.
%
% Have in mind that there seem to be some fields present in some par files
% that are not part of the Bruker data format specification available to
% the author of this routine. These fields are contained as well in the
% params structure.
%
% Furthermore, it seems that quite in contrast to the Bruker data format
% specification, at least some versions of WinEPR/Acquisit do not change
% the default parameters accordingly, but rather add new fields,
% particularly in case of 2D experiments (e.g. power sweep).
%
% Numerical values in the params structure are converted into numerical
% values in the params struct (using str2double).
%
% An important note from the Bruker data format specification:
%
% "Definition of the x-axis can be very tricky because of instrument
% offsets, etc. To make sure that the x-axis is represented correctly, you
% should always use the parameters GST (start value) and GSI (sweep size)
% and do not use HCF (center field) and HSW (sweep width)."
%
% Note that this seems not to be true for at least some EMX files, where
% one would rather like to use the (non-standard) values XXLB and XXWI.
%
% A full specification of the Bruker SPC data format specification can be
% requested from Bruker BioSpin.
%
% SEE ALSO: EPRbrukerBES3Timport

% Copyright (c) 2011-17, Till Biskup
% Copyright (c) 2015, Deborah Meyer
% 2017-08-14

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
    p.addParamValue('RGnorm',false,@islogical);
    p.addParamValue('SCnorm',false,@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get file basename and create par and spc filenames for convenience
[fpath,fname,~] = fileparts(filename);
parFilename = fullfile(fpath,[fname,'.par']);
spcFilename = fullfile(fpath,[fname,'.spc']);

% Load params (par) file and returning format (ESP/EMX)
[data.params,fmt] = loadParamsFile(parFilename);

% Load binary (spc) file
[data.data,warnings] = loadSpcFile(spcFilename,fmt);

if isempty(data.data)
    return;
end
 
% For multiple spectra in one file (e.g.: EMX, power sweep), reshape data
if data.params.RES < length(data.data)
    data.data = reshape(data.data,data.params.RES,[]);
end

data.axes.data = createAxes(data.params);

% Normalise for receiver gain (aka divide by its value)
if p.Results.RGnorm
    data.data = data.data./data.params.RRG;
end

% Normalise for number of scans (aka divide by this number)
if p.Results.SCnorm && data.params.JSD > 0
    data.data = data.data./data.params.JSD;
end

end 

function [params,fmt] = loadParamsFile(parFilename)

% Read contents of par file
fileContent = fileread(parFilename);

% Determine file format: ESP (UNIX style) or EMX (DOS style)
if any(strfind(fileContent,sprintf('\r')))
    fmt = 'emx';
    fileContent = regexp(fileContent,'\r','split');
else
    fmt = 'esp';
    fileContent = regexp(fileContent,'\n','split');
end

% Remove empty lines of cell array
fileContent(cellfun(@isempty,fileContent)) = [];

% Split lines on first space and trim remainder
[fields,values] = strtok(fileContent,' ');
values = strtrim(values);

% Get default parameters
params = defaultParams;

% Assign field-value pairs to params struct
for field=1:length(fields)
    % Try to convert numeric values
    numValue = str2double(values{field});
    if ~isnan(numValue)
        values{field} = numValue;
    end
    params.(fields{field}) = values{field};
end

end

function params = defaultParams

% Default parameters for Bruker EMX, ESP, ECS par files
% Only parameters whose values diffeer from the default parameter values
% are included in the parameter file.
%
% The following structure contains all parameters and their default values
% as given in the Bruker specification
params = struct(...
    'JSS',0, ...
    'JON','',...
    'JRE','',...
    'JDA','',...
    'JTM','',...
    'JCO','',...
    'JUN','Gauss',...
    'JNS',1,...
    'JSD',0,...
    'JEX','EPR',...
    'JAR','ADD',...
    'GST',3.455e3,...
    'GSI',5e1,...
    'TE',-1e0,...
    'HCF',3.480006e+3,...
    'HSW',5e1,...
    'NGA',-1,...
    'NOF',0,...
    'MF',-1,...
    'MP',-1,...
    'MCA',-1,...
    'RMA',1,...
    'RRG',2e4,...
    'RPH',0,...
    'ROF',0,...
    'RCT',5.12,...
    'RTC',1.28, ...
    'RMF',1e2, ...
    'RHA',1, ...
    'RRE',1, ...
    'RES',1024, ...
    'DTM',4096, ...
    'DSD',0, ...
    'DCT',1000, ...
    'DTR',1000, ...
    'DCA','ON', ...
    'DCB','OFF', ...
    'DDM','OFF', ...
    'DRS',4096, ...
    'PPL','OFF', ...
    'PFP',2, ...
    'PSP',1, ...
    'POF',0, ...
    'PFR','ON', ...
    'EMF',3.3521e3, ...
    'ESF',2e1, ...
    'ESW',1e1, ...
    'EFD',9.977e1, ...
    'EPF',1e1, ...
    'ESP',20, ...
    'EPP',63, ...
    'EOP',0, ...
    'EPH',0, ...
    'FME','', ...
    'FWI','', ...
    'FOP',2, ...
    'FER',2 ...
    );

end

function [data,warnings] = loadSpcFile(spcFilename,fmt)

warnings = cell(0);

% Try to load binary (spc) file
[fid,msg] = fopen(spcFilename);
% If fopen was successful, fid > 2, otherwise fid == -1
if fid > 2
    switch lower(fmt)
        case 'esp'
            % Data are binary, big endian, single precision (Bruker ESP) 
            % 4 byte integer Motorola format
            data = fread(fid,inf,'int32=>real*8',0,'b');
        case 'emx'
            % For Bruker EMX
            % 4 byte floating point
            data = fread(fid,inf,'float');
    end
    fclose(fid);
else
    data = [];
    warnings{end+1} = struct(...
        'identifier','brukerESPload:fileOpen',...
        'message',sprintf('Problems reading file %s: %s',filename,msg)...
        );
end

end

function axes = createAxes(params)

% An important note from the Bruker data format specification:
%
% "Definition of the x-axis can be very tricky because of instrument
% offsets, etc. To make sure that the x-axis is represented correctly, you
% should always use the parameters GST (start value) and GSI (sweep size)
% and do not use HCF (center field) and HSW (sweep width)."
%
% Note that this seems not to be true for at least some EMX files, where
% one would rather like to use the (non-standard) values XXLB and XXWI.

axes = struct();

% Set defaults for x axis
if any(strcmpi(params.JUN,{'gauss','g'}))
    axes(1).unit = 'G';
else
    axes(1).unit = params.JUN;
end
axes(1).values = ...
    linspace(params.GST,params.GST+params.GSI,params.RES)';

if strcmpi(params.JEX,'field-sweep')
    axes(1).measure = 'magnetic field';
end

% WARNING: Bruker EMX files containing 2D data (e.g. power sweep) seem not
% to comply to Bruker file format spec
if isfield(params,'XXUN')
    axes(1).unit = params.XXUN;
end
if all(isfield(params,{'XXLB','XXWI'}))
    axes(1).values = ...
        linspace(params.XXLB,params.XXLB+params.XXWI,params.RES)';
end
if isfield(params,'XYUN')
    axes(2).unit = params.XYUN;
end

if isfield(params,'JEY')
    switch lower(params.JEY)
        case 'mw-power-sweep'
            if all(isfield(params,{'MP','MPS','XYWI'}))
                axes(2).values = ...
                    linspace(mW2dB(params.MP),...
                    mW2dB(params.MP)+params.XYWI*params.MPS,...
                    params.XYWI+1);
            end
            axes(2).measure = 'MW attenuation';
        case 'inc-sweep'
            axes(2).measure = 'time';
            if isfield(params,'XYWI')
                axes(2).values = 1:1:params.XYWI;
                axes(2).unit = 'index';
            end
    end
end

end

function pdB = mW2dB(pmW)

% NOTE: Assumes maximum MW power to be 200 mW
pdB = 10*log10(200/pmW);

end


function pmW = dB2mW(pdB)

% NOTE: Assumes maximum MW power to be 200 mW
pmW = 200*10^(-pdB/10);

end