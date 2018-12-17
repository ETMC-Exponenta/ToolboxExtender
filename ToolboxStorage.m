classdef ToolboxStorage < handle
    %Store data locally in installed toolbox folder
    
    properties
        E % Toolbox Extender
        root % data folder
        fname % File name
        data % storage data
        auto = true % Automatically save and load data
    end
    
    methods
        function obj = ToolboxStorage(fname, varargin)
            % Constructor
            p = inputParser();
            p.addParameter('local', false);
            p.parse();
            obj.E = ToolboxExtender;
            obj.getroot(p.Results.local);
            if nargin < 1
                fname = matlab.lang.makeValidName(obj.E.name) + "_data";
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
        
        function root = getroot(obj, local)
            % Get root folder
            root = obj.E.root;
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
        
        function [val, isf] = get(obj, varname, type)
            % Get variable from data
            if isstruct(obj.data) && isfield(obj.data, varname)
                val = obj.data.(varname);
                isf = true;
            else
                val = [];
                isf = false;
            end
            if nargin > 2
                val = cast(val, type);
            end
        end
        
        function set(obj, varname, val, type)
            % Set variable in data
            if nargin > 3
                val = cast(val, type);
            end
            obj.data.(varname) = val;
            if obj.auto
                obj.save();
            end
        end
        
        function import(obj, fpath)
            % Import data from file
            obj.load(fpath);
            if obj.auto
                obj.save();
            end
        end
        
        function export(obj, fpath)
            % Export data to file
            obj.save(obj.data, fpath);
        end
        
    end
end