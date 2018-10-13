function init()
% Add Toolbox Builder tools to current projetc folder
fprintf('* ToolboxUpdater will be initialized in current directory *\n');
TU0 = ToolboxUpdater;
[uname, upath] = TU0.clone;
echo(upath);
TU = feval(uname);
if isempty(TU.remote)
    remote = input("Enter remote GitHub URL:\n", 's');
    TU.remote = char(remote);
end
TU.updaterv = TU0.cv;
confname = TU.writeconfig();
echo(confname);
nfname = TU0.copyscript('dev_on', uname);
echo(nfname);
fprintf("!Don't forget to exclude %s from project\n", nfname);
fprintf('* ToolboxUpdater initialized successfully in current directory *\n');
end

function echo(fname)
fprintf('File was created: %s\n', fname);
end
