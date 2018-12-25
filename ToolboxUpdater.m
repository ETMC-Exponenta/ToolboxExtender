classdef ToolboxUpdater < handle
    %Control version of installed toolbox and update it from GitHub
    
    properties
        E % Toolbox Extender
    end
    
    methods
        function obj = ToolboxUpdater(extender)
            % Init
            if nargin < 1
                obj.E = ToolboxExtender;
            else
                obj.E = extender;
            end
        end
        
        function [cv, rv] = ver(obj)
            % Check curent installed and remote versions
            cv = obj.E.gcv();
            if isempty(cv)
                fprintf('%s is not installed\n', obj.E.name);
            else
                fprintf('Installed version: %s\n', cv);
            end
            % Get latest version
            rv = obj.E.grv();
            if ~isempty(rv)
                fprintf('Latest version: %s\n', rv);
                if isequal(cv, rv)
                    fprintf('You use the latest version\n');
                else
                    fprintf('* Update is available: %s->%s *\n', cv, rv);
                    fprintf("To update call 'update' method\n");
                end
            else
                fprintf('No remote version is available\n');
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
        
        function [isupd, r] = isupdate(obj)
            % Check that update is available
            if obj.isonline()
                cv = obj.E.gcv();
                [rv, r] = obj.E.grv();
                isupd = ~isempty(rv) & ~isequal(cv, rv);
            else
                r = [];
                isupd = false;
            end
        end
        
        function update(obj)
            % Update installed version to the latest from remote (GitHub)
            [isupd, r] = obj.isupdate();
            if isupd
                obj.E.installweb(r);
            end
        end
        
    end
end

