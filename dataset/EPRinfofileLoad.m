function metaData = EPRinfofileLoad(filename)
% EPRINFOFILELOAD Load and parse info file and return contents as
% hierarchical struct using camelCased block and field names. 
%
% Usage
%   metaData = commonInfofileLoad(filename);
%
%   filename - string
%              Name of info file to read
%              Extension is always assumed to be .info
%
%   metaData - struct
%              Hierarchical structure containing metadata from info file
%
% For a description of the specification of the info file format, see
%   http://www.till-biskup.de/en/software/info/

% Copyright (c) 2015, Till Biskup
% 2015-03-27

metaData = commonInfofileLoad(filename);

end