function add(classes, targetpath)
% Add Toolbox Builder tools to current project folder
if nargin < 2
    targetpath = pwd;
end
if nargin < 1
    classes = "Extender";
else
    classes = lower(string(classes));
end
useext = false;
if ismember(classes, "all")
    classes = ["Dev" "Storage" "Updater" "install"];
    useext = true;
end
classes = classes(classes ~= "extender");
fprintf('* Toolbox Extender will be initialized in current directory *\n');

TE = ToolboxExtender;
v = TE.vc;
TE.root = targetpath;
ToolboxDev.exclude(TE.getppath(), {'.git' '.gitignore' '**/*.asv'});
if ~isscalar(classes) || ~strcmpi(classes, 'install')
    useext = true;
end
if useext
    confpath = fullfile(targetpath, TE.config);
    if isfile(confpath)
        delete(confpath);
    end
    [nname, npath] = TE.cloneclass('Extender', getroot());
    TE.echo(": " + npath + " was created");
end
isdev = false;
for i = 1 : length(classes)
    if strcmpi(classes(i), 'install')
        copy_install(TE);
    else
        [cname, cpath] = TE.cloneclass(classes(i), getroot());
        TE.echo(": " + cpath + " was created");
        if strcmpi(classes(i), "dev")
            isdev = true;
            nfname = copy_dev_on(TE);
            ToolboxDev.exclude(TE.getppath(), cname);
        end
    end
end
if useext
    p1 = cd(TE.root);
    TE = feval(nname);
    TE.extv = v;
    writeconfig(TE);
    TE.echo(": " + TE.config + " was created");
    cd(p1);
end
if isdev && isempty(TE.remote)
    disp('! If you want to use full Dev features please add GitHub remote address to project folder (via Git) and add Toolbox Extender again');
end
fprintf('* Toolbox Extender initialized successfully in current directory *\n');
end

function addxmlitem(node, name, value)
% Add item to XML
doc = node.getDocumentElement;
el = node.createElement(name);
el.appendChild(node.createTextNode(value));
doc.appendChild(el);
end

function [confname, confpath] = writeconfig(obj)
% Write config to xml file
docNode = com.mathworks.xml.XMLUtils.createDocument('config');
docNode.appendChild(docNode.createComment('Toolbox Extender configuration file. DO NOT DELETE'));
addxmlitem(docNode, 'name', obj.name);
addxmlitem(docNode, 'pname', obj.pname);
addxmlitem(docNode, 'type', obj.type);
addxmlitem(docNode, 'remote', obj.remote);
addxmlitem(docNode, 'extv', obj.extv);
confpath = fullfile(obj.root, obj.config);
confname = obj.config;
xmlwrite(confpath, docNode);
end

function [nname, npath] = copyscript(obj, sname)
% Copy script to Project folder
spath = fullfile(getroot(), 'scripts', sname + ".m");
nname = sname + ".m";
npath = fullfile(obj.root, nname);
copyfile(spath, npath);
obj.echo(": " + nname + " was created");
end

function nname = copy_dev_on(obj)
% Copy dev_on script
nname = copyscript(obj, 'dev_on');
devc = obj.getvalidname('Dev');
obj.txtrep(nname, '%%DEVCLASS%%', devc);
ToolboxDev.exclude(obj.getppath(), 'dev_on.m');
end

function sname = copy_install(obj)
% Copy dev_on script
url = obj.getlatesturl();
extc = obj.getvalidname('Extender');
devc = obj.getvalidname('Dev');
sname = copyscript(obj, 'install');
obj.txtrep(sname, '%%EXTCLASS%%', extc);
obj.txtrep(sname, '%%DEVCLASS%%', devc);
sname = copyscript(obj, 'installweb');
obj.txtrep(sname, '%%REMOTE%%', url);
obj.txtrep(sname, '%%EXTCLASS%%', extc);
ToolboxDev.exclude(obj.getppath(), {'install.m' 'installweb.m'});
dev = ToolboxDev(obj);
i = dev.webinstaller();
fprintf('  -> Web installer command:\n     %s\n', i);
end

function root = getroot()
root = fileparts(fileparts(mfilename('fullpath')));
end