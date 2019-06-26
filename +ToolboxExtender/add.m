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
if ismember(classes, "all")
    classes = ["Dev" "Storage" "Updater"];
end
classes = classes(classes ~= "extender");
fprintf('* Toolbox Extender will be initialized in current directory *\n');

TE = ToolboxExtender;
confpath = fullfile(targetpath, TE.config);
if isfile(confpath)
    delete(confpath);
end
v = TE.vc;
TE.root = targetpath;
[nname, npath] = TE.cloneclass('Extender', getroot());
TE.echo(": " + npath + " was created");
isdev = false;
for i = 1 : length(classes)
    [cname, cpath] = TE.cloneclass(classes(i), getroot());
    TE.echo(": " + cpath + " was created");
    if strcmpi(classes(i), "dev")
        isdev = true;
        nfname = copyscript(TE, 'dev_on', cname);
        TE.echo(": " + nfname + " was created");
        fprintf("! Don't forget to exclude %s and %s.m from project\n", nfname, cname);
    end
end
p1 = cd(TE.root);
TE = feval(nname);
TE.extv = v;
writeconfig(TE);
TE.echo(": " + TE.config + " was created");
cd(p1);
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

function nname = copyscript(obj, sname, newclass)
% Copy script to Project folder
spath = fullfile(getroot(), 'scripts', sname + ".m");
nname = sname + ".m";
npath = fullfile(obj.root, nname);
copyfile(spath, npath);
if nargin > 2
    obj.txtrep(nname, 'ToolboxDev', newclass);
end
end

function root = getroot()
root = fileparts(fileparts(mfilename('fullpath')));
end