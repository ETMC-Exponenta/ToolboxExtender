function add(classes)
% Add Toolbox Builder tools to current project folder
if nargin < 1
    classes = "Extender";
else
    classes = lower(string(classes));
end
if ismember(classes, "all")
    classes = ["Dev" "Storage" "Updater"];
end
classes = classes(classes ~= "extender");
fprintf('* Toolbox Extender will be initialized in current directory *\n');

TE = ToolboxExtender;
if isfile(TE.config)
    delete(TE.config);
end
v = TE.vc;
TE.root = pwd;
[nname, npath] = TE.cloneclass();
TE.echo(": " + npath + " was created");
for i = 1 : length(classes)
    cname = TE.cloneclass(classes(i));
    TE.echo(": " + cname + " was created");
    if classes(i) == "Dev"
        nfname = TE.copyscript('dev_on', cname);
        TE.echo(": " + nfname + " was created");
        fprintf("!Don't forget to exclude %s and %s.m from project\n", nfname, cname);
    end
end
TE = feval(nname);
if isempty(TE.remote)
    disp('!If you want to use full Dev features please add GitHub remote address to project folder (via Git) and reinitialize Toolbox Extender');
end
TE.extv = v;
TE.writeconfig();
TE.echo(": " + TE.config + " was created");
fprintf('* Toolbox Extender initialized successfully in current directory *\n');