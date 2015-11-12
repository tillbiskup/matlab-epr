function mT = EPRg2mT(g,freq)
% EPRG2MT Convert g values into magnetic field values in mT for given
% frequency using resonance condition of magnetic resonance.
%
% Usage
%   mT = EPRg2mT(g,freq)
%
%   g    - vector
%          g values
%
%   freq - scalar
%          frequency (in Hz) used in resonance condition
%
%   mT   - vector
%          corresponding mT values
%
% NOTE: Depends on the common toolbox, making use of "commonConstants"
%
% See also: EPRmT2g, commonConstants

% Copyright (c) 2015, Till Biskup
% 2015-11-12

% Preassign output
mT = g;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('g', @(x)isnumeric(x) && isvector(x));
    p.addRequired('freq', @(x)isnumeric(x) && isvector(x));
    p.parse(g,freq);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

mub = commonConstants('mub');
h = commonConstants('h');

mT = h*freq./(g*mub)*1e3;

