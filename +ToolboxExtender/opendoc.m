function opendoc(name)
% Open documentation
if nargin < 1
    name = 'GettingStarted';
end
TE = ToolboxExtender;
TE.doc(name);