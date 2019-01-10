function [vc, vr] = ver()
% Check Toolbox Updater version
TU = ToolboxUpdater;
if nargout > 0
    [vc, vr] = TU.ver;
else
    TU.ver;
end