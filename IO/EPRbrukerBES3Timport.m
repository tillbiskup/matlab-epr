function [data,warnings] = EPRbrukerBES3Timport(filename)
% EPRBRUKERBES3TIMPORT Read Bruker BES3T file format.
%
% Usage
%   data = EPRbrukerBES3Timport(filename)
%   [data,warning] = EPRbrukerBES3Timport(filename)
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
% SEE ALSO: EPRbrukerSPCimport

% Copyright (c) 2011-20, Till Biskup
% 2020-02-13

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

try
    % If there is no filename specified, return
    if isempty(filename)
        data = struct();
        warnings{end+1} = struct(...
            'identifier','EPRbrukerBES3Tload:nofile',...
            'message','No filename or file does not exist'...
            );
        return;
    end
    % If filename does not exist, try to add extension
    if  ~exist(filename,'file')
        [fpath,fname,fext] = fileparts(filename); %#ok<NASGU>
        if exist(fullfile(fpath,[fname '.DTA']),'file')
            filename = fullfile(fpath,[fname '.DTA']);
        else
            data = struct();
            warnings{end+1} = struct(...
                'identifier','trEPRbrukerBES3Tload:nofile',...
                'message','No filename or file does not exist'...
                );
            return;
        end
    end
    
    % Read Bruker DSC file and get minimum set of parameters
    % First, create filename for DSC file
    [fpath,fname,~] = fileparts(filename);
    dscFilename = fullfile(fpath,[fname,'.DSC']);
    
    % Open DSC file and read line by line
    [fid,msg] = fopen(dscFilename);
    % If fopen was successful, fid > 2, otherwise fid == -1
    if fid > 2
        % Read first line of file
        tline = fgetl(fid);
        % Do some very basic input checking, compare to what is the first
        % line of a Bruker BES3T description file and if that does not fit,
        % complain and exit
        if ~strfind(tline,'#DESC	1.2 * DESCRIPTOR INFORMATION')
            fclose(fid);
            data = struct();
            warnings{end+1} = struct(...
                'identifier','trEPRbrukerBES3Tload:wrongFormat',...
                'message',[sprintf('Problems reading file %s. ',filename)...
                'Seems not to be a proper Bruker BES3T file. '...
                'Could not understand DSC file.'...
                ]...
                );
            return;        
        end
        % List fields to parse the DSC file for.
        % The first entry contains the string to be searched for in the DSC
        % file. The second parameter tells the program how to parse the
        % corresponding entry. 
        % Here, "numeric" means that the numbers of the field should be
        % treated as numbers, "string" means to treat the whole field as
        % string, and "valueunit" splits the field in a numeric value and a
        % string containing the unit.
        matching = {...
            'XPTS','numeric'; ...
            'YPTS','numeric'; ...
            'XMIN','numeric'; ...
            'XWID','numeric'; ...
            'XNAM','qstring'; ...
            'XUNI','qstring'; ...
            'XTYP','string'; ...
            'YTYP','string'; ...
            'ZTYP','string'; ...
            'YMIN','numeric'; ...
            'YWID','numeric'; ...
            'YNAM','qstring'; ...
            'YUNI','qstring'; ...
            'IKKF','string';...
            'TITL','qstring';...
            'OPER','string';...
            'DATE','string';...
            'TIME','string';...
            'FrequencyMon','valueunit';...
            'Power','valueunit';...
            'PowerAtten','valueunit';...
            'HighFieldVal','valueunit';...
            'LowFieldVal','valueunit';...
            'AveragesPerScan','numeric'; ...
            'RampCenter','valueunit'; ...
            'RampWidth','valueunit'; ...
            'TransPerScan','numeric'; ...
            'NbScansAcc','numeric'; ...
            };
        % Read whole DSC file in one pass into cell array
        k=1;
        while ischar(tline)
            DSC{k,1} = tline; %#ok<AGROW>
            % Do some very basic assignment of necessary parameters already
            % while reading file (saves doing another looping through the
            % cell array later on
            lineStart = regexp(tline,'\s','split','once');
            [value,ind] = max(strcmp(lineStart{1},matching(:,1)));
            if value
                switch matching{ind,2}
                    case 'numeric'
                        parameters.(matching{ind,1}) = str2double(...
                            regexp(...
                            tline,...
                            sprintf('%s[^\\d\\c](.+)',matching{ind,1}),...
                            'tokens','once'));
                    case 'qstring'
                        parameters.(matching{ind,1}) = char(regexp(...
                            tline,...
                            sprintf('%s[^\\d\\c]''(.*)''',matching{ind,1}),...
                            'tokens','once'));
                    case 'string'
                        parameters.(matching{ind,1}) = strtrim(char(regexp(...
                            tline,...
                            sprintf('%s[^\\d\\c](.*)',matching{ind,1}),...
                            'tokens','once')));
                    case 'valueunit'
                        [tokens, ~] = regexp(...
                            tline,...
                            '(?<value>[0-9.]+)\s*(?<unit>\w*)',...
                            'tokens','names');
                        parameters.(matching{ind,1}).value = ...
                            str2double(tokens{1}{1});
                        parameters.(matching{ind,1}).unit = tokens{1}{2};
                end
            end
            tline = fgetl(fid);
            k=k+1;
        end
        % Close file
        fclose(fid);
    else % meaning: file could not be opened
        data = struct();
        warnings{end+1} = struct(...
            'identifier','EPRbrukerBES3Tload:fileOpen',...
            'message',sprintf('Problems reading file %s: %s',filename,msg)...
            );
        return;
    end
    
    % Preassign values to the data struct
    data = EPRdatasetCreate;
        
    % Create axes vectors
    data.axes.data(1).values = linspace(...
        parameters.XMIN,...
        parameters.XMIN+parameters.XWID,...
        parameters.XPTS)';
    if isfield(parameters,'YTYP') && strcmp(parameters.YTYP, 'IGD')
        [fpath,fname,~] = fileparts(filename);
        binaryFilename = fullfile(fpath,[fname,'.YGF']);
        fid = fopen(binaryFilename);
        data.axes.data(2).values = fread(fid,inf,'double=>double',0,'b');
        fclose(fid);
    elseif isfield(parameters,'YMIN')
        data.axes.data(2).values = linspace(...
            parameters.YMIN,...
            parameters.YMIN+parameters.YWID,...
            parameters.YPTS);
    else
        data.axes.data(2).values = 1;
    end
    
    % In case we don't have YPTS in structure 
    % (happens with cwEPR data in new BES3T v.2 format)
    if ~isfield(parameters,'YPTS')
        parameters.YPTS = 1;
    end
    
    % Read Bruker BES3T binary data
    [fpath,fname,~] = fileparts(filename);
    dtaFilename = fullfile(fpath,[fname,'.DTA']);
    [fid,msg] = fopen(dtaFilename);
    try
        % If fopen was successful, fid > 2, otherwise fid == -1
        if fid > 2
            % Data are binary, big endian, double precision
            data.data = fread(fid,inf,'double=>double',0,'b');
            fclose(fid);
        else
            data = struct();
            warnings{end+1} = struct(...
                'identifier','EPRbrukerBES3Tload:fileOpen',...
                'message',sprintf('Problems reading file %s: %s',filename,msg)...
                );
            return;
        end
    catch
        fclose(fid);
    end
    
    % Reshape data according to what we read from DSC file
    if strcmp(parameters.IKKF,'CPLX') % If we have quadrature detection
        % Deal with aborted measurements where we have less data points
        % than expected from DSC file
        if length(data.data) < parameters.XPTS*parameters.YPTS*2
            tmp = data.data;
            data.data = zeros(parameters.XPTS*parameters.YPTS*2,1);
            data.data(1:length(tmp)) = tmp;
            clear tmp;
        end
        data.data = reshape(data.data(2:2:end),parameters.XPTS,[])';
    else
        % Deal with aborted measurements where we have less data points
        % than expected from DSC file
        if length(data.data) < parameters.XPTS*parameters.YPTS
            tmp = data.data;
            data.data = zeros(parameters.XPTS*parameters.YPTS,1);
            data.data(1:length(tmp)) = tmp;
            clear tmp;
        end
        data.data = reshape(data.data,parameters.XPTS,[])';
    end

    % Do a very rough checking of dimensions, using XPTS and YPTS from the
    % DSC file
    [y,x] = size(data.data);
    if ~(y==parameters.YPTS && x==parameters.XPTS)
        disp('WARNING: data seem to have wrong dimensions!');
        warnings{end+1} = struct(...
            'identifier','EPRbrukerBES3Tload:dataDimensions',...
            'message','WARNING: data seem to have wrong dimensions!'...
            );
    end
    
    % Set other fields of data structure
    data.file.name = filename;
    data.file.format = 'BrukerBES3T';

    % Append complete DSC file to data structure
    data.header = DSC;
        
    % Handle situation if field 'LowFieldVal' doesn't exist
    if ~isfield(parameters,'LowFieldVal') && ...
            isfield(parameters,'RampCenter') && ...
            isfield(parameters,'RampWidth')
        parameters.LowFieldVal.value = ...
            parameters.RampCenter.value - parameters.RampWidth.value/2;
        parameters.LowFieldVal.unit = parameters.RampWidth.unit;
        parameters.HighFieldVal.value = ...
            parameters.RampCenter.value + parameters.RampWidth.value/2;
        parameters.HighFieldVal.unit = parameters.RampWidth.unit;
    end
    
    if ~isfield(parameters,'AveragesPerScan')
        if isfield(parameters,'TransPerScan')
            parameters.AveragesPerScan = parameters.TransPerScan;
        else
            parameters.AveragesPerScan = parameters.NbScansAcc;
        end
    end
    
    % Cell array correlating struct fieldnames read from the DSC file and
    % from the toolbox data structure.
    parameterMatching = {
        'XPTS','parameters.transient.points'; ...
        'XWID','parameters.transient.length.value'; ...
        'XNAM','axes.data(1).measure'; ...
        'YNAM','axes.data(2).measure'; ...
        'XUNI','axes.data(1).unit'; ...
        'YUNI','axes.data(2).unit'; ...
        'XUNI','parameters.transient.length.unit'; ...
        'YUNI','parameters.field.start.unit'; ...
        'TITL','label'; ...
        'LowFieldVal.value','parameters.field.start.value'; ...
        'HighFieldVal.value','parameters.field.stop.value'; ...
        'LowFieldVal.unit','parameters.field.start.unit'; ...
        'OPER','parameters.operator'; ...
        'Power','parameters.bridge.power'; ...
        'PowerAtten','parameters.bridge.attenuation'; ...
        'FrequencyMon','parameters.bridge.MWfrequency'; ...
        'AveragesPerScan','parameters.recorder.averages'; ...
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
%     data.parameters.field.step.value = ...
%         data.axes.y.values(2)-data.axes.y.values(1);
%     data.parameters.field.stop.unit = data.parameters.field.start.unit;
%     data.parameters.field.step.unit = data.parameters.field.start.unit;
    data.parameters.date = ...
        datestr(...
        datenum([parameters.DATE ' ' parameters.TIME],...
        'dd/mm/yy HH:MM:SS'),...
        31);
catch exception
    throw(exception);
end

end


% --- Get field of cascaded struct
function value = getCascadedField (struct, fieldName)
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    switch length(nDots)
        case 0
            value = struct.(fieldName);
        case 1
            value = struct.(fieldName(1:nDots(1)-1)).(...
                fieldName(nDots(1)+1:length(fieldName)));
        otherwise
            value = '';
    end
end

% --- Set field of cascaded struct
function struct = setCascadedField (struct, fieldName, value)
    % Get number of "." in fieldName
    nDots = strfind(fieldName,'.');
    if isempty(nDots)
        struct.(fieldName) = value;
    else
        if ~isfield(struct,fieldName(1:nDots(1)-1))
            struct.(fieldName(1:nDots(1)-1)) = [];
        end
        innerstruct = struct.(fieldName(1:nDots(1)-1));
        innerstruct = setCascadedField(...
            innerstruct,...
            fieldName(nDots(1)+1:end),...
            value);
        struct.(fieldName(1:nDots(1)-1)) = innerstruct;
    end
end
