function pmW = EPRdB2mW(pdB, varargin)
% EPRdB2mW Convert microwave power from mW in dB
%
% Usage
%   pmW = EPRdB2mW(pdB)
%   pmW = EPRdB2mW(pdB,<param>,<value>)
%
%   pdB - vector
%         Power in dB
%
%   pmW - vector
%         Power in mW
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
% SEE ALSO EPRmW2dB

% Copyright (c) 2015, Till Biskup
% 2015-11-11

% Assing default output
pmW = pdB;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('pdB', @(x)isnumeric(x) && isvector(x));
    p.addParamValue('pmax',200,@isscalar);
    p.parse(pdB,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

pmW = p.Results.pmax*10.^(-pdB/10);

end