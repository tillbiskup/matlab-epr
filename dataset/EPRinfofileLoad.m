function [metaData,format] = EPRinfofileLoad(filename)
% CWEPRINFOFILELOAD Load and parse info file and return contents as
% hierarchical struct using camelCased block and field names. 
%
% Usage
%   metaData = EPRinfofileLoad(filename);
%   [metaData,identifierString] = EPRinfofileLoad(filename);
%
%   filename - string
%              Name of info file to read
%              Extension is always assumed to be .info
%
%   metaData - struct
%              Hierarchical structure containing metadata from info file
%
%   format   - struct
%              Information from first line of info file used to identify
%              type and version (with date).
%              Fields are: type, version, date
%              See specification (link below) for details.
%
% For a description of the specification of the info file format, see
%   http://www.till-biskup.de/en/software/info/

% Copyright (c) 2015, Till Biskup
% Copyright (c) 2015, Deborah Meyer
% 2015-04-09

[metaData,format] = commonInfofileLoad(filename);

end