function table = EPRdatasetMappingTableV0_1_0
% EPRDATASETMAPPINGTABLEV0_1_0 Mapping table for mapping EPR info file (v.
% 0.1.0) contents to dataset.
%
% Usage
%   table = EPRdatasetMappingTableV0_1_0
%
%   table - cell (nx3)
%           1st column: field of info structure returned by
%           EPRinfofileLoad
%
%           2nd column: corresponding field in dataset structure as
%           returned by EPRdatasetCreate
%
%           3rd column: modifier telling datasetMapInfo how to modify the
%           field from the info file to fit into the dataset
%
%           Currently allowed (case insensitive) modifiers contain:
%           join, joinWithSpace, splitValueUnit, str2double
%
%           See the source code of EPRdatasetMapInfo for more info
%
% NOTE FOR TOOLBOX DEVELOPERS:
% Use EPRinfofileMappingTableHelper to create the basic structure of the
% cell array "table" and create your own PREFIXdatasetMappingTable function
% as a copy of this function.
%
% SEE ALSO: EPRdatasetMapInfo, EPRdatasetCreate, EPRinfofileLoad,

% Copyright (c) 2014-15, Till Biskup
% Copyright (c) 2015, Deborah Meyer
% 2015-11-17

commonTable = commonDatasetMappingTableV0_1_0;

table = {...
    'sample.tube','sample.tube',''; ...
    'experiment.runs','parameters.experiment.runs','str2double'; ...
    'spectrometer.model','parameters.spectrometer.model',''; ...
    'spectrometer.software','parameters.spectrometer.software',''; ...
    'magneticField.fieldProbeType','parameters.field.probe.type',''; ...
    'magneticField.fieldProbeModel','parameters.field.probe.model',''; ...
    'magneticField.start','parameters.field.start','splitValueUnit'; ...
    'magneticField.stop','parameters.field.stop','splitValueUnit'; ...
    'magneticField.step','parameters.field.step','splitValueUnit'; ...
    'magneticField.sequence','parameters.field.sequence',''; ...
    'magneticField.controller','parameters.field.controller',''; ...
    'magneticField.powerSupply','parameters.field.powerSupply',''; ...
    'bridge.model','parameters.bridge.model',''; ...
    'bridge.controller','parameters.bridge.controller',''; ...
    'bridge.attenuation','parameters.bridge.attenuation','splitValueUnit'; ...
    'bridge.power','parameters.bridge.power','splitValueUnit'; ...
    'bridge.detection','parameters.bridge.detection',''; ...
    'bridge.frequencyCounter','parameters.bridge.MWfrequencyCounter',''; ...
    'bridge.mwFrequency','parameters.bridge.MWfrequency','splitValueUnit'; ...
    'bridge.Qvalue','parameters.bridge.Qvalue','str2double'; ...
    'probehead.type','parameters.probehead.type',''; ...
    'probehead.model','parameters.probehead.model',''; ...
    'probehead.coupling','parameters.probehead.coupling',''; ...
    'temperature.temperature','parameters.temperature','splitValueUnit'; ...
    'temperature.controller','parameters.temperature.controller',''; ...
    'temperature.cryostat','parameters.temperature.cryostat',''; ...
    'temperature.cryogen','parameters.temperature.cryogen',''; ...
    'fieldCalibration.filename','parameters.field.calibration.filename',''; ...
    'fieldCalibration.fieldProbeType','parameters.field.calibration.probe.type',''; ...
    'fieldCalibration.fieldProbeModel','parameters.field.calibration.probe.model',''; ...
    'fieldCalibration.standard','parameters.field.calibration.standard',''; ...
    'fieldCalibration.signalField','parameters.field.calibration.signalField','splitValueUnit'; ...
    'fieldCalibration.MWfrequency','parameters.field.calibration.MWfrequency','splitValueUnit'; ...
    };

% Join mapping tables from common and EPR datasets
table = [commonTable; table];

end