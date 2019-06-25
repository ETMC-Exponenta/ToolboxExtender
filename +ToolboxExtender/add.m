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
[nname, npath] = cloneclass(TE);
TE.echo(": " + npath + " was created");
for i = 1 : length(classes)
    cname = cloneclass(TE, classes(i));
    TE.echo(": " + cname + " was created");
    if strcmpi(classes(i), "dev")
        nfname = copyscript(TE, 'dev_on', cname);
        TE.echo(": " + nfname + " was created");
        fprintf("!Don't forget to exclude %s and %s.m from project\n", nfname, cname);
    end
end
TE = feval(nname);
if isempty(TE.remote)
    disp('!If you want to use full Dev features please add GitHub remote address to project folder (via Git) and reinitialize Toolbox Extender');
end
TE.extv = v;
writeconfig(TE);
TE.echo(": " + TE.config + " was created");
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
function [nname, npath] = cloneclass(obj, classname)
% Clone Toolbox Extander class to current Project folder
if nargin < 2
    classname = "Extender";
else
    classname = lower(char(classname));
    classname(1) = upper(classname(1));
end
nname = obj.getvalidname + string(classname);
npath = nname + ".m";
oname = "Toolbox" + classname;
opath = fullfile(getroot(), oname + ".m");
copyfile(opath, npath);
obj.txtrep(npath, "obj = " + oname, "obj = " + nname);
obj.txtrep(npath, "classdef " + oname, "classdef " + nname);
obj.txtrep(npath, "obj.TE = ToolboxExtender", "obj.TE = " + obj.getvalidname + "Extender");
end

function nfname = copyscript(obj, sname, newclass)
% Copy script to Project folder
spath = fullfile(getroot(), 'scripts', sname + ".m");
nfname = sname + ".m";
copyfile(spath, nfname);
if nargin > 2
    obj.txtrep(nfname, 'ToolboxDev', newclass);
end
end

function root = getroot()
root = fileparts(fileparts(mfilename('fullpath')));
end