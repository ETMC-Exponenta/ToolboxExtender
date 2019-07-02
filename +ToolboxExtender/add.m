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
v = TE.vc;
TE.root = targetpath;
if ~isscalar(classes) || ~strcmpi(classes, 'install')
    useext = true;
else
    useext = false;
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
            nfname = copy_dev_on(TE, cname);
            fprintf("! Don't forget to exclude %s and %s.m from project\n", nfname, cname);
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

function nname = copy_dev_on(obj, newclass)
% Copy dev_on script
nname = copyscript(obj, 'dev_on');
if nargin > 1
    obj.txtrep(nname, 'ToolboxDev', newclass);
end
end

function sname = copy_install(obj)
% Copy dev_on script
[~, bname] = obj.getbinpath();
url = obj.getlatesturl();
sname = copyscript(obj, 'install');
obj.txtrep(sname, '%%BINNAME%%', bname);
obj.txtrep(sname, '%%NAME%%', obj.name);
sname = copyscript(obj, 'installweb');
obj.txtrep(sname, '%%REMOTE%%', url);
end

function root = getroot()
root = fileparts(fileparts(mfilename('fullpath')));
end