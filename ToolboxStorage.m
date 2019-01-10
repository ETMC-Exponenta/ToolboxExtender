classdef ToolboxStorage < handle
    % Helps you easily store any data within installed toolbox, i.e. user settings
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        TE % Toolbox Extender
        root % data folder
        fname % File name
        data % storage data
        auto = true % Automatically save and load data
    end
    
    methods
        function obj = ToolboxStorage(fname, varargin)
            % Constructor
            p = inputParser();
            p.addParameter('TE', ToolboxExtender);
            p.addParameter('local', false);
            p.parse();
            obj.TE = p.Results.TE;
            obj.getroot(p.Results.local);
            if nargin < 1
                fname = matlab.lang.makeValidName(obj.TE.name) + "_data";
            end
            obj.fname = fname;
        end
        
        function set.fname(obj, fname)
            % Set file name
            obj.fname = fname;
            if obj.auto
                obj.load();
            end
        end
        
        function [fpath, fname] = getpath(obj)
            % Generate data file name
            fname = obj.fname + ".mat";
            fpath = fullfile(obj.root, fname);
        end
        
        function open(obj)
            % Open data folder
            if ispc
                winopen(obj.root);
            else
                unix("open " + obj.root);
            end
        end
        
        function data = load(obj, fpath)
            % Load data from file
            if nargin < 2
                fpath = obj.getpath();
            end
            if isfile(fpath)
                data = load(fpath);
                data = data.data;
            else
                data = [];
            end
            obj.data = data;
        end
        
        function save(obj, data, fpath)
            % Save data to file
            if nargin < 2
                data = obj.data;
            else
                obj.data = data;
            end
            if nargin < 3
                fpath = obj.getpath();
            end
            save(fpath, 'data');
        end
        
        function [value, isf] = get(obj, varname, type)
            % Get variable from data
            if isstruct(obj.data) && isfield(obj.data, varname)
                value = obj.data.(varname);
                isf = true;
            else
                value = [];
                isf = false;
            end
            if nargin > 2
                value = cast(value, type);
            end
        end
        
        function data = set(obj, varname, value, type)
            % Set variable in data
            if nargin > 3
                value = cast(value, type);
            end
            obj.data.(varname) = value;
            if obj.auto
                obj.save();
            end
            data = obj.data;
        end
        
        function data = import(obj, fpath)
            % Import data from file
            obj.load(fpath);
            if obj.auto
                obj.save();
            end
            data = obj.data;
        end
        
        function export(obj, fpath)
            % Export data to file
            obj.save(obj.data, fpath);
        end
        
        function clear(obj)
            % Clear data and delete data file
            obj.data = [];
            fpath = obj.getpath;
            if isfile(fpath)
                delete(fpath);
            end
        end
        
    end
    
    methods (Hidden)
        
        function root = getroot(obj, local)
            % Get root folder
            root = obj.TE.root;
            if ~local
                target = "MATLAB Add-Ons";
                path = extractBefore(root, target);
                if ~isempty(path)
                    root = fullfile(path + target, 'Data');
                    if ~isfolder(root)
                        mkdir(root);
                    end
                end
                obj.root = root;
            end
        end
        
    end
end