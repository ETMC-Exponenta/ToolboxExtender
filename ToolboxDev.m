classdef ToolboxDev < handle
    %Easily build toolbox and push to GitHub
    
    properties
        E % Toolbox Extender
    end
    
    methods
        function obj = ToolboxDev(extender)
            % Init
            if nargin < 1
                obj.E = ToolboxExtender;
            else
                obj.E = extender;
            end
        end
        
        function build(obj, pv)
            % Build toolbox for specified version
            ppath = fullfile(obj.E.root, obj.E.pname);
            obj.gendoc();
            if nargin > 1
                if obj.E.type == "toolbox"
                    matlab.addons.toolbox.toolboxVersion(ppath, pv);
                else
                    txt = obj.E.readtxt(ppath);
                    txt = regexprep(txt, '(?<=(<param.version>))(.*?)(?=(</param.version>))', pv);
                    txt = strrep(txt, '<param.version />', '');
                    obj.E.writetxt(txt, ppath);
                end
                obj.E.pv = pv;
            end
            [~, bname] = fileparts(obj.E.pname);
            bpath = fullfile(obj.E.root, bname);
            if obj.E.type == "toolbox"
                obj.seticons();
                matlab.addons.toolbox.packageToolbox(ppath, bname);
            else
                matlab.apputil.package(ppath);
                movefile(fullfile(obj.E.root, obj.E.name + ".mlappinstall"), bpath + ".mlappinstall",'f');
            end
            obj.E.echo('has been built');
        end
        
        function test(obj)
            % Build and install
            obj.build();
            obj.E.install();
        end
        
        function untag(obj, v)
            % Delete tag from local and remote
            untagcmd1 = sprintf('git push --delete origin v%s', v);
            untagcmd2 = sprintf('git tag -d v%s', v);
            system(untagcmd1);
            system(untagcmd2);
            system('git push --tags');
            obj.E.echo('has been untagged');
        end
        
        function release(obj, pv)
            % Build toolbox, push and tag version
            if nargin > 1
                obj.build(pv);
            else
                obj.build();
            end
            obj.push();
            obj.tag();
            obj.E.echo('has been deployed');
            clipboard('copy', ['"' char(obj.E.getbinpath) '"'])
            disp("Binary path was copied to clipboard")
            disp("* Now create release on GitHub page with binary attached *")
            pause(1)
            web(obj.E.remote + "/releases/edit/v" + obj.E.pv, '-browser')
        end
        
    end
    
    
    methods (Hidden)
        
        function gendoc(obj)
            % Generate html from mlx doc
            docdir = fullfile(obj.E.root, 'doc');
            fs = struct2table(dir(fullfile(docdir, '*.mlx')), 'AsArray', true);
            fs = convertvars(fs, 1:3, 'string');
            for i = 1 : height(fs)
                [~, fname] = fileparts(fs.name(i));
                fprintf('Converting %s...\n', fname);
                fpath = fullfile(fs.folder(i), fs.name{i});
                htmlpath = fullfile(fs.folder(i), fname + ".html");
                matlab.internal.liveeditor.openAndConvert(char(fpath), char(htmlpath));
                disp('Doc has been generated');
            end
        end
        
        function seticons(obj)
            % Set icons of app in toolbox
            xmlfile = 'DesktopToolset.xml';
            oldtxt = '<icon filename="matlab_app_generic_icon_' + string([16; 24]) + '"/>';
            newtxt = '<icon path="./" filename="icon_' + string([16; 24]) + '.png"/>';
            if isfile(xmlfile) && isfolder('resources')
                if all(isfile("resources/icon_" + [16 24] + ".png"))
                    txt = obj.E.readtxt(xmlfile);
                    if contains(txt, oldtxt)
                        txt = replace(txt, oldtxt, newtxt);
                        obj.E.writetxt(txt, xmlfile);
                    end
                end
            end
        end
        
        function push(obj)
            % Commit and push project to GitHub
            commitcmd = sprintf('git commit -m v%s', obj.E.pv);
            system('git add .');
            system(commitcmd);
            system('git push');
            obj.E.echo('has been pushed');
        end
        
        function tag(obj)
            % Tag git project and push tag
            tagcmd = sprintf('git tag -a v%s -m v%s', obj.E.pv, obj.E.pv);
            system(tagcmd);
            system('git push --tags');
            obj.E.echo('has been tagged');
        end
        
    end
    
end

