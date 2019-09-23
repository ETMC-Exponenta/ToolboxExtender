classdef ToolboxStorage < handle
    % Helps you easily store any data within installed toolbox, i.e. user settings
    % By Pavel Roslovets, ETMC Exponenta
    % https://github.com/ETMC-Exponenta/ToolboxExtender
    
    properties
        ext % Toolbox Extender
        type {mustBeMember(type,{'mat','json','pref'})} = 'mat' % Storage type
        root % data folder
        fdir % folder directory in the root
        fname % file name
        data % storage data
        local % save data file locally
        auto % automatically save and load data
        jsonopts % json files options
    end
    
    methods
        function obj = ToolboxStorage(varargin)
            %% Constructor
            p = inputParser();
            p.addParameter('ext', []);
            p.addParameter('type', 'mat');
            p.addParameter('fname', '', @(x)ischar(x)||isstring(x));
            p.addParameter('fdir', '', @(x)ischar(x)||isstring(x));
            p.addParameter('local', false);
            p.addParameter('auto', false);
            p.addParameter('jsonopts', struct, @isstruct);
            p.parse(varargin{:});
            args = p.Results;
            if ~isempty(args.ext)
                obj.ext = args.ext;
            else
                obj.ext = ToolboxExtender;
            end
            obj.type = args.type;
            obj.local = args.local;
            obj.auto = args.auto;
            obj.getroot();
            obj.fdir = args.fdir;
            fname = string(args.fname);
            if fname == ""
                fname = matlab.lang.makeValidName(obj.ext.name);
            end
            obj.fname = fname;
            obj.jsonopts = args.jsonopts;
        end
        
        function set.fname(obj, fname)
            %% Set file name
            obj.fname = fname;
            if obj.auto
                obj.load();
            end
        end
        
        function set.fdir(obj, fdir)
            %% Set file directory in the root
            if obj.type == "mat" || obj.type == "json"
                obj.fdir = fdir;
                if obj.auto
                    obj.load();
                end
            end
        end
        
        function set.jsonopts(obj, opts)
            %% Set json storage options
            p = inputParser();
            p.addParameter('useJsonlab', false);
            p.addParameter('encoding', 'UTF-8', @(x)ischar(x)||isstring(x));
            p.addParameter('readTable', true);
            p.addParameter('writeArray', true);
            opts = [fieldnames(opts) struct2cell(opts)]';
            p.parse(opts{:});
            obj.jsonopts = p.Results;
        end
        
        function [fpath, fname] = getpath(obj)
            %% Generate data file name
            switch obj.type
                case 'mat'
                    ex = ".mat";
                case 'json'
                    ex = ".json";
                otherwise
                    ex = "";
            end
            fname = obj.fname + ex;
            fpath = fullfile(obj.root, obj.fdir, fname);
        end
        
        function open(obj)
            %% Open data folder
            if ispc
                winopen(obj.root);
            else
                unix("open " + obj.root);
            end
        end
        
        function data = load(obj, fpath)
            %% Load data from file or preferences
            data = [];
            switch obj.type
                case "mat"
                    if nargin < 2
                        fpath = obj.getpath();
                    end
                    if isfile(fpath)
                        data = load(fpath);
                    end
                case "pref"
                    data = getpref(obj.fname);
                case "json"
                    data = obj.json_read(obj.getpath());
            end
            obj.data = data;
        end
        
        function save(obj, data, fpath)
            %% Save data to file
            if nargin < 2
                data = obj.data;
            else
                obj.data = data;
            end
            switch obj.type
                case "mat"
                    if nargin < 3
                        fpath = obj.getpath();
                    end
                    save(fpath, '-struct', 'data');
                case "pref"
                    fs = string(fieldnames(data));
                    for i = 1 : length(fs)
                        setpref(obj.fname, fs(i), data.(fs(i)));
                    end
                case "json"
                    obj.json_write(obj.getpath(), obj.data);
            end
        end
        
        function [value, isf] = get(obj, varname, type, def)
            %% Get variable from data
            if isstruct(obj.data) && isfield(obj.data, varname)
                value = obj.data.(varname);
                isf = true;
            else
                value = [];
                isf = false;
            end
            if nargin > 2 && ~isempty(type)
                value = cast(value, type);
            end
            if nargin > 3 && isempty(value)
                value = def;
            end
        end
        
        function data = set(obj, varname, value, type)
            %% Set variable in data
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
            %% Import data from file
            obj.load(fpath);
            if obj.auto
                obj.save();
            end
            data = obj.data;
        end
        
        function export(obj, fpath)
            %% Export data to file
            obj.save(obj.data, fpath);
        end
        
        function clear(obj)
            %% Clear data and delete data file
            obj.data = [];
            fpath = obj.getpath;
            if isfile(fpath)
                delete(fpath);
            end
        end
        
    end
    
    methods (Hidden)
        
        function root = getroot(obj)
            %% Get root folder
            if obj.local
                root = obj.ext.root;
            else
                root = obj.ext.root;
                target = "MATLAB Add-Ons";
                path = extractBefore(root, target);
                if ~isempty(path)
                    root = fullfile(path + target, 'Data');
                    if ~isfolder(root)
                        mkdir(root);
                    end
                end
            end
            obj.root = root;
        end
        
        function data = json_read(obj, fpath)
            %% Read data from .json file
            enc = obj.jsonopts.encoding;
            if obj.jsonopts.useJsonlab
                obj.check_jsonlab()
                data = loadjson(fpath, 'SimplifyCell', 1, 'ParseLogical', 1,...
                    'Encoding', enc);
            else
                fid = fopen(fpath, 'r', 'n', enc);
                txt = fread(fid, '*char')';
                fclose(fid);
                data = jsondecode(txt);
            end
            if obj.jsonopts.readTable && ~(isstruct(data) && isscalar(data))
                data = struct2table(data, 'AsArray', true);
            end
        end
        
        function json_write(obj, fpath, data)
            %% Write data to .json file
            enc = obj.jsonopts.encoding;
            if obj.jsonopts.useJsonlab
                obj.check_jsonlab()
                if istable(data)
                    data = reshape(table2struct(data), 1, []);
                end
                if obj.jsonopts.writeArray
                    data = arrayfun(@(x) {x}, data);
                end
                savejson('', data, 'FileName', fpath, 'ParseLogical', 1,...
                    'Encoding', enc);
            else
                txt = jsonencode(data);
                fid = fopen(fpath, 'wt', 'n', enc);
                fwrite(fid, txt, 'char');
                fclose(fid);
            end
        end
        
    end
    
    methods (Static)
        
        function check_jsonlab()
            %% Check jsonlab is installed
            w1 = which('loadjson');
            w2 = which('savejson');
            if isempty(w1) || isempty(w2)
                error('You need to install <a href="https://github.com/fangq/jsonlab">jsonlab</a> to use it');
            end
        end
        
    end
end