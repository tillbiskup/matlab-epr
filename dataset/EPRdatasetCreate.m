function dataset = EPRdatasetCreate(varargin)
% EPRDATASETCREATE Create and return data structure of EPR dataset.
%
% Usage
%   dataset = EPRdatasetCreate
%   dataset = EPRdatasetCreate(<parameters>)
%
%   dataset    - struct
%                Structure complying with the data structure of the dataset
%                of the common toolbox
%
%   parameters - key-value pairs (OPTIONAL)
%
%                Optional parameters may include:
%
%                numberOfAxes      - scalar
%                                    Number of axes the dataset should have
%                                    Default: 2
%
%                hasOptionalFields - logical
%                                    Should  the dataset have optional
%                                    fields?
%                                    Default: false
%    
% Hint: Parameters can be provided as a structure with the fieldnames
% corresponding to the parameter names specified above.
%
% SEE ALSO: commonDatasetCreate, commonHistoryCreate, EPRhistoryCreate

% Copyright (c) 2015-16, Till Biskup
% 2016-01-18

% Assign output parameter
dataset = struct();

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParameter('numberOfAxes',2,@isscalar);
    p.addParameter('hasOptionalFields',false,@islogical);
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Define version of dataset structure
structureVersion = '0.1';

% Call function from common toolbox
commonDataset = commonDatasetCreate(...
    'numberOfAxes',p.Results.numberOfAxes,...
    'hasOptionalFields',p.Results.hasOptionalFields...
    );

dataset.parameters = struct(...
    'experiment',struct(...
        'runs',[]...
        ), ...
    'spectrometer',struct(...
        'model','',...
        'software','' ...
        ), ...
    'field',struct(...
        'probe',struct(...
            'type','',...
            'model','' ...
            ),...
        'start',struct(...
            'value',[],...
            'unit','' ...
            ), ...
        'stop',struct(...
            'value',[],...
            'unit','' ...
            ), ...
        'step',struct(...
            'value',[],...
            'unit','' ...
            ), ...
        'sequence','',...
        'controller','',...
        'powerSupply','',...
        'calibration',struct(...
            'filename','',...
            'probe',struct(...
                'type','',...
                'model','' ...
                ),...
            'standard','',...
            'signalField',struct(...
                'value',[],...
                'unit','' ...
                ),...
            'MWfrequency',struct(...
                'value',[],...
                'unit','' ...
                )...
            )...
        ),...
    'bridge',struct(...
        'MWfrequency',struct(...
            'value',[],...
            'unit','' ...
            ),...
        'attenuation',struct(...
            'value',[],...
            'unit','' ...
            ),...
        'power',struct(...
            'value',[],...
            'unit','' ...
            ),...
        'Qvalue',[],...
        'model','',...
        'controller','',...
        'MWfrequencyCounter','',...
        'detection','' ...
        ), ...
    'probehead',struct(...
        'type','',...
        'model','',...
        'coupling','' ...
        ), ...
    'temperature',struct(...
        'controller','',...
        'cryostat','',...
        'cryogen','' ...
        ) ...
    );

% Join common and EPR dataset structure
dataset = commonStructCopy(dataset,commonDataset);

dataset.format(end+1) = struct(...
    'type','EPR dataset',...
    'version',structureVersion ...
    );

end
