function g = EPRmT2g(mT,freq)
% EPRMT2G Convert magnetic field values in mT into g for given frequency
% using resonance condition of magnetic resonance.
%
% Usage
%   g = EPRmT2g(mT,freq)
%
%   mT   - vector
%          magnetic field values in mT
%
%   freq - scalar
%          frequency (in Hz) used in resonance condition
%
%   g    - vector
%          corresponding g values
%
% NOTE: Depends on the common toolbox, making use of "commonConstants"
%
% See also: EPRg2mT, commonConstants

% Copyright (c) 2015, Till Biskup
% 2015-11-12

% Preassign output
g = mT;

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('mT', @(x)isnumeric(x) && isvector(x));
    p.addRequired('freq', @(x)isnumeric(x) && isvector(x));
    p.parse(mT,freq);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

mub = commonConstants('mub');
h = commonConstants('h');

g = h*freq./(mub*mT*1e-3);

