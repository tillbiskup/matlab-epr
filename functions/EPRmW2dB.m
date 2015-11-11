function pdB = EPRmW2dB(pmW, varargin)
% EPRMW2DB Convert microwave power from mW in dB
%
% Usage
%   pdB = EPRmW2dB(pmW)
%   pdB = EPRmW2dB(pmW,<param>,<value>)
%
%   pmW - vector
%         Power in mW
%
%   pdB - vector
%         Power in dB
%
% Optional parameters
%
%   pmax - scalar
%          maximum power of the MW source (in mW)
%          default: 200 mW (standard X-band bridge)
%
% NOTE: The standard maximum output power of 200 mW is only valid for (old)
% standard X-band bridges. Bridges with other frequencies and new Bruker
% X-band bridges have different (normally lower) power.
%
% SEE ALSO EPRdB2mW

% Copyright (c) 2015, Till Biskup
% 2015-11-11

% Assing default output
pdB = pmW;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('pmW', @(x)isnumeric(x) && isvector(x));
    p.addParamValue('pmax',200,@isscalar);
    p.parse(pmW,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

pdB = 10*log10(p.Results.pmax./pmW);

end