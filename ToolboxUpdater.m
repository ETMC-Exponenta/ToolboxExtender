classdef ToolboxUpdater < handle
    % Control version of installed toolbox and update it from GitHub
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        ext % Toolbox Extender
        vr % latest remote version form internet (GitHub)
    end
    
    properties (Hidden)
        res % GitHub resources
        rel % release notes
    end
    
    methods
        function obj = ToolboxUpdater(extender)
            % Init
            if nargin < 1
                obj.ext = ToolboxExtender;
            else
                obj.ext = extender;
            end
        end
        
        function [res, err] = fetch(obj)
            % Fetch resources from GitHub
            iname = string(extractAfter(obj.ext.remote, 'https://github.com/'));
            url = "https://api.github.com/repos/" + iname + "/releases/latest";
            res = '';
            try
                res = webread(url);
                err = [];
                obj.res = res;
                obj.vr = erase(res.tag_name, 'v');
                obj.rel = res.body;
            catch err
            end
        end
        
        function vr = gvr(obj)
            % Get remote version from GitHub
            if isempty(obj.vr)
                obj.fetch();
            end
            vr = obj.vr;
        end
        
        function rel = getrel(obj)
            % Get release notes
            if isempty(obj.res)
                obj.fetch();
            end
            rel = obj.rel;
        end
        
        function webrel(obj)
            % Open GitHub releases webpage
            web(obj.ext.remote + "/releases");
        end
        
        function [vc, vr] = ver(obj)
            % Check curent installed and remote versions
            vc = obj.ext.gvc();
            if nargout == 0
                if isempty(vc)
                    fprintf('%s is not installed\n', obj.ext.name);
                else
                    fprintf('Installed version: %s\n', vc);
                end
            end
            % Check remote version
            vr = obj.gvr();
            if nargout == 0
                if ~isempty(vr)
                    fprintf('Latest version: %s\n', vr);
                    if isequal(vc, vr)
                        fprintf('You use the latest version\n');
                    else
                        fprintf('* Update is available: %s->%s *\n', vc, vr);
                        fprintf("To update call 'update' method of " + mfilename + "\n");
                    end
                else
                    fprintf('No remote version is available\n');
                end
            end
        end
        
        function yes = isonline(~)
            % Check connection to internet is available
            try
                java.net.InetAddress.getByName('google.com');
                yes = true;
            catch
                yes = false;
            end
        end
        
        function isupd = isupdate(obj, cbfun, delay)
            % Check that update is available
            if obj.isonline()
                vc = obj.ext.gvc();
                if nargin < 2
                    vr = obj.gvr();
                    isupd = ~isempty(vr) & ~isequal(vc, vr);
                else
                    if nargin < 3
                        delay = 1;
                    end
                    isupd = false;
                    t = timer('ExecutionMode', 'singleShot', 'StartDelay', delay);
                    t.TimerFcn = @(~, ~) obj.isupd_async(cbfun, vc);
                    t.Period = 1;
                    start(t);
                end
            else
                isupd = false;
            end
        end
        
        function installweb(obj)
            % Download and install latest version from remote (GitHub)
            if isempty(obj.res)
                obj.gvr();
            end
            if ~isempty(obj.vr)
                fprintf('* Installation of %s is started *\n', obj.ext.name);
                fprintf('Installing the latest version: v%s...\n', obj.vr);
                dpath = tempname;
                mkdir(dpath);
                fpath = fullfile(dpath, obj.res.assets.name);
                websave(fpath, obj.res.assets.browser_download_url);
                r = obj.ext.install(fpath);
                fprintf('%s v%s has been installed\n', r.Name{1}, r.Version{1});
                delete(fpath);
            end
        end
        
        function update(obj)
            % Update installed version to the latest from remote (GitHub)
            if obj.isupdate()
                obj.installweb();
            end
        end
        
    end
    
    methods (Hidden)
        
        function isupd_async(obj, cbfun, vc)
            % Task for async ver timer
            vr = obj.gvr();
            isupd = ~isempty(vr) & ~isequal(vc, vr);
            cbfun(isupd);
        end
        
    end
    
end

