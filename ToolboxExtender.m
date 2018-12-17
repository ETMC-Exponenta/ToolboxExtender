classdef ToolboxExtender < handle
    %A lot of powerful features for custom toolbox
    
    properties
        name % project name
        pname % name of project file
        type % type of project
        remote % GitHub link
        pv % project version
        cv % current installed version
        rv % latest remote version form internet
        root % root dir
        extv % Toolbox Extender version
    end
    
    properties (Hidden)
        config = 'ToolboxConfig.xml' % configuration file name
    end
    
    methods
        function obj = ToolboxExtender(root)
            % Init
            if nargin < 1
                obj.root = fileparts(mfilename('fullpath'));
            else
                obj.root = root;
            end
        end
        
        function set.root(obj, root)
            % Set root path
            obj.root = root;
            if ~obj.readconfig()
                obj.getpname();
                obj.gettype();
                obj.getname();
                obj.getremote();
            end
            obj.gpv();
            obj.gcv();
        end
        
        function init(obj, classes)
            % Init Toolbox Extender in current project folder
            if nargin < 2
                classes = "Extender";
            else
                classes = lower(string(classes));
            end
            if ismember(classes, "all")
                classes = ["Dev" "Storage" "Updater"];
            end
            classes = classes(classes ~= "extender");
            fprintf('* Toolbox Extender will be initialized in current directory *\n');
            if isfile(obj.config)
                delete(obj.config);
            end
            v = obj.cv;
            obj.root = pwd;
            [nname, npath] = obj.cloneclass();
            obj.echo(": " + npath + " was created");
            for i = 1 : length(classes)
                cname = obj.cloneclass(classes(i));
                obj.echo(": " + cname + " was created");
                if classes(i) == "Dev"
                    nfname = obj.copyscript('dev_on', cname);
                    obj.echo(": " + nfname + " was created");
                    fprintf("!Don't forget to exclude %s and %s.m from project\n", nfname, cname);
                end
            end
            TE = feval(nname);
            if isempty(TE.remote)
                disp('!If you want to use full Dev features please add GitHub remote address to project folder (via Git) and reinitialize Toolbox Extender');
            end
            TE.extv = v;
            TE.writeconfig();
            obj.echo(": " + obj.config + " was created");
            fprintf('* Toolbox Extender initialized successfully in current directory *\n');
        end
        
        function pv = gpv(obj)
            % Get project version
            ppath = fullfile(obj.root, obj.pname);
            if isfile(ppath)
                if obj.type == "toolbox"
                    pv = matlab.addons.toolbox.toolboxVersion(ppath);
                else
                    txt = obj.readtxt(ppath);
                    pv = char(regexp(txt, '(?<=(<param.version>))(.*?)(?=(</param.version>))', 'match'));
                end
            else
                pv = '';
            end
            obj.pv = pv;
        end
        
        function [cv, guid] = gcv(obj)
            % Get current installed version
            if obj.type == "toolbox"
                tbx = matlab.addons.toolbox.installedToolboxes;
                tbx = struct2table(tbx, 'AsArray', true);
                idx = strcmp(tbx.Name, obj.name);
                cv = tbx.Version(idx);
                guid = tbx.Guid(idx);
                if isscalar(cv)
                    cv = char(cv);
                elseif isempty(cv)
                    cv = '';
                end
            else
                tbx = matlab.apputil.getInstalledAppInfo;
                cv = '';
                guid = '';
            end
            obj.cv = cv;
        end
        
        function [rv, r] = grv(obj)
            % Get remote version from GitHub
            iname = string(extractAfter(obj.remote, 'https://github.com/'));
            url = "https://api.github.com/repos/" + iname + "/releases/latest";
            try
                r = webread(url);
                rv = r.tag_name;
                rv = erase(rv, 'v');
            catch
                rv = '';
                r = '';
            end
            obj.rv = rv;
        end
        
        function res = install(obj, fpath)
            % Install toolbox or app
            if nargin < 2
                fpath = obj.getbinpath();
            end
            if obj.type == "toolbox"
                res = matlab.addons.install(fpath);
            else
                res = matlab.apputil.install(fpath);
            end
            obj.gcv();
            obj.echo('has been installed');
        end
        
        function installweb(obj, r)
            % Download and install latest version from remote (GitHub)
            if nargin < 2
                [~, r] = obj.grv();
            end
            fprintf('* Installation of %s is started *\n', obj.E.name);
            fprintf('Installing the latest version: v%s...\n', obj.E.rv);
            dpath = tempname;
            mkdir(dpath);
            fpath = fullfile(dpath, r.assets.name);
            websave(fpath, r.assets.browser_download_url);
            res = obj.install(fpath);
            fprintf('%s v%s has been installed\n', res.Name{1}, res.Version{1});
            delete(fpath);
        end
        
        function uninstall(obj)
            % Uninstall toolbox or app
            [~, guid] = obj.gcv();
            if isempty(guid)
                disp('Nothing to uninstall');
            else
                if obj.type == "toolbox"
                    matlab.addons.uninstall(guid);
                else
                    matlab.apputil.uninstall(guid);
                end
                disp('Uninstalled successfully');
                obj.gcv();
            end
        end
        
        function doc(obj, name)
            % Open page from documentation
            if nargin < 2
                name = 'GettingStarted';
            end
            if ~any(endsWith(name, {'.mlx' '.html'}))
                name = name + ".html";
            end
            docpath = fullfile(obj.root, 'doc', name);
            if endsWith(name, '.html')
                web(docpath);
            else
                open(docpath);
            end
        end
        
        function examples(obj)
            % cd to Examples dir
            expath = fullfile(obj.root, 'examples');
            cd(expath);
        end
        
    end
    
    
    
    methods (Hidden)
        
        function echo(obj, msg)
            % Display service message
            fprintf('%s v%s %s\n', obj.name, obj.pv, msg);
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
            root = fileparts(mfilename('fullpath'));
            opath = fullfile(root, oname + ".m");
            copyfile(opath, npath);
            obj.txtrep(npath, oname, nname);
            obj.txtrep(npath, "obj.E = ToolboxExtender", "obj.E = " + obj.getvalidname + "Extender");
        end
        
        function name = getname(obj)
            % Get project name from project file
            name = '';
            ppath = fullfile(obj.root, obj.pname);
            if isfile(ppath)
                txt = obj.readtxt(ppath);
                name = char(extractBetween(txt, '<param.appname>', '</param.appname>'));
            end
            obj.name = name;
        end
        
        function pname = getpname(obj)
            % Get project file name
            fs = dir(fullfile(obj.root, '*.prj'));
            if ~isempty(fs)
                pname = fs(1).name;
                obj.pname = pname;
            else
                error('Project file was not found in a current folder');
            end
        end
        
        function type = gettype(obj)
            % Get project type (Toolbox/App)
            ppath = fullfile(obj.root, obj.pname);
            txt = obj.readtxt(ppath);
            if contains(txt, 'plugin.toolbox')
                type = 'toolbox';
            elseif contains(txt, 'plugin.apptool')
                type = 'app';
            else
                type = '';
            end
            obj.type = type;
        end
        
        function remote = getremote(obj)
            % Get remote (GitHub) address via Git
            [~, cmdout] = system('git remote -v');
            remote = extractBetween(cmdout, 'https://', '.git', 'Boundaries', 'inclusive');
            if ~isempty(remote)
                remote = remote(end);
            end
            remote = char(remote);
            obj.remote = remote;
        end
        
        function name = getvalidname(obj)
            % Get valid variable name
            name = char(obj.name);
            name = name(isstrprop(name, 'alpha'));
        end  
        
        function nfname = copyscript(obj, sname, newclass)
            % Copy script to Project folder
            root = fileparts(mfilename('fullpath'));
            spath = fullfile(root, 'scripts', sname + ".m");
            nfname = sname + ".m";
            copyfile(spath, nfname);
            if nargin > 2
                obj.txtrep(nfname, 'ToolboxDev', newclass);
            end
        end
        
        function txt = readtxt(~, fpath)
            % Read text from file
            f = fopen(fpath, 'r', 'n', 'windows-1251');
            txt = fread(f, '*char')';
            fclose(f);
        end
        
        function writetxt(~, txt, fpath)
            % Wtite text to file
            fid = fopen(fpath, 'w', 'n', 'windows-1251');
            fwrite(fid, unicode2native(txt, 'windows-1251'));
            fclose(fid);
        end
        
        function txt = txtrep(obj, fpath, old, new)
            % Replace in txt file
            txt = obj.readtxt(fpath);
            txt = replace(txt, old, new);
            obj.writetxt(txt, fpath);
        end
        
        function bpath = getbinpath(obj)
            % Get generated binary file path
            [~, name] = fileparts(obj.pname);
            if obj.type == "toolbox"
                ext = ".mltbx";
            else
                ext = ".mlappinstall";
            end
            bpath = fullfile(obj.root, name + ext);
        end
        
        function ok = readconfig(obj)
            % Read config from xml file
            confpath = fullfile(obj.root, obj.config);
            ok = isfile(confpath);
            if ok
                xml = xmlread(confpath);
                conf = obj.getxmlitem(xml, 'config', 0);
                obj.name = obj.getxmlitem(conf, 'name');
                obj.pname = obj.getxmlitem(conf, 'pname');
                obj.type = obj.getxmlitem(conf, 'type');
                obj.remote = erase(obj.getxmlitem(conf, 'remote'), '.git');
                obj.extv = obj.getxmlitem(conf, 'extv');
            end
        end
        
        function [confname, confpath] = writeconfig(obj)
            % Write config to xml file
            docNode = com.mathworks.xml.XMLUtils.createDocument('config');
            docNode.appendChild(docNode.createComment('ToolboxUpdater configuration file'));
            obj.addxmlitem(docNode, 'name', obj.name);
            obj.addxmlitem(docNode, 'pname', obj.pname);
            obj.addxmlitem(docNode, 'type', obj.type);
            obj.addxmlitem(docNode, 'remote', obj.remote);
            obj.addxmlitem(docNode, 'extv', obj.extv);
            confpath = fullfile(obj.root, obj.config);
            confname = obj.config;
            xmlwrite(confpath, docNode);
        end
        
        function i = getxmlitem(~, xml, name, getData)
            % Get item from XML
            if nargin < 4
                getData = true;
            end
            i = xml.getElementsByTagName(name);
            i = i.item(0);
            if getData
                i = i.getFirstChild;
                if ~isempty(i)
                    i = i.getData;
                end
                i = char(i);
            end
        end
        
        function addxmlitem(~, node, name, value)
            % Add item to XML
            doc = node.getDocumentElement;
            el = node.createElement(name);
            el.appendChild(node.createTextNode(value));
            doc.appendChild(el);
        end
        
    end
end