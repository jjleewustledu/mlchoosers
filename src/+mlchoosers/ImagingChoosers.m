classdef ImagingChoosers < mlchoosers.ImagingChoosersInterface
	%% IMAGINGCHOOSERS 
    
	%  $Revision: 2466 $
 	%  was created $Date: 2013-08-10 21:27:30 -0500 (Sat, 10 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-10 21:27:30 -0500 (Sat, 10 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingChoosers.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: ImagingChoosers.m 2466 2013-08-11 02:27:30Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    
	properties (Dependent)
        fslPath
        inputParserDefaults
    end
      
    methods (Static)
        function obj   = createReturnType(p)
            %% CREATERETURNTYPE dispatches to createFileprefix/name/Fq/ImagingComponent/NIfTI
            
            import mlchoosers.*;
            switch (lower(p.Results.returnType))
                case {'fileprefix' 'fp'}
                    obj = ImagingChooser.createFileprefix(p);
                case {'filename' 'fn'}
                    obj = ImagingChooser.createFilename(p);
                case {'fqfileprefix' 'fqfp'}   
                    obj = this.fileprefixOnFslPath( ...
                          ImagingChooser.createFqFileprefix(p));
                case {'fqfilename' 'fqfn'} 
                    obj = this.filenameOnFslPath( ...                    
                          ImagingChooser.createFqFilename(p));
                case  'nifti'  
                    obj = ImagingChooser.createNIfTI(p);
                case {'imagingseries' 'imagingcomposite' 'imagingcomponent'} 
                    obj = ImagingChooser.createImagingComponent(p);
                otherwise
                    error('mlchoosers:UnsupportedType', 'ImagingChoosers.createReturnType; p.Results.returnType->%s', ...
                           p.Results.returnType);    
            end 
            if (iscell(obj) && 1 == length(obj))
                obj = obj{1}; 
            end  
        end
        function fps   = createFileprefix(p)
            fps = fileprefixes( ...
                  mlchoosers.ImagingChoosers.createFilename(p));
        end        
        function fns   = createFilename(p)       
            fns = ensureCell(mlchoosers.ImagingChoosers.createFqFilename(p));
            if (~p.Results.fullyQualified)
                for f = 1:length(fns)
                    [~,fp,e] = filepartsx(fns{f}, mlfourd.NIfTId.FILETYPE_EXT);
                    fns{f} = [fp e];
                end
            end
        end
        function fqfps = createFqFileprefix(p)
            fqfps = fileprefixes( ...
                    mlchoosers.ImagingChoosers.createFqFilename(p), mlfourd.NIfTId.FILETYPE_EXT, true);
        end
        function fqfns = createFqFilename(p)
            import mlchoosers.*;
            [pth,fp,e] = ImagingChoosers.decoratedFileparts(p);
            fqfns      = ImagingChoosers.selectModality(fullfilenames(pth, [fp e]), p);
            fqfns      = ImagingChoosers.applyFiltersByType(fqfns, p);
        end
        function imcmp = createImagingComponent(p)
            imcmp = mlfourd.ImagingComponent.load( ...
                    mlchoosers.ImagingChoosers.createFqFilename(p));
        end   
        function nii   = createNIfTI(p)
            imser = mlchoosers.ImagingChoosers.createImagingComponent(p);
            assert(1 == imser.length);
            nii = imser.cached;
        end
          
        function prts  = splitFilename(name, varargin)
            %% SPLITFILENAME retuns an array of the parts of a filename separated by sep
            %  Usage:   prts = obj.splitFilename(name[, sep]);
            %                                           ^ default '_on_'; try '_to_'
            %           ^ cell-array of strings
            
            p = inputParser;
            addRequired(p, 'name', @ischar);
            addOptional(p, 'sep', mlfsl.FslRegistry.INTERIMAGE_TOKEN, @ischar);
            parse(p, name, varargin{:});
            
            [~,fp] = filepartsx(p.Results.name, mlfourd.NIfTId.FILETYPE_EXT);
            if (isempty(fp))
                prts = {};  return; end
            sepsFound = strfind(fp, p.Results.sep);
            if (isempty(sepsFound))
                prts = {fp}; return; end
            prts = cell(1, length(sepsFound) + 1);
            prts = splitBySep(prts, p.Results.sep);
            
            function prts = splitBySep(prts, sep)
                lastIndex = 1;
                for d = 1:length(sepsFound)
                    prts{d} = fp(lastIndex:sepsFound(d)-1); 
                    lastIndex = sepsFound(d) + length(sep);
                end
                prts{end} = fp(lastIndex:end);
            end
            
        end % static splitFilename      
        function fn    = ensureFilenameSuffix(fn0)
            if (lstrfind(fn0, mlfourd.NIfTId.FILETYPE_EXT))
                fn = fn0;
            else
                fn = '';
            end
        end
        function fns   = ensureFilenameSuffixes(fns0)
            fns  = {}; g = 1;
            fns0 = ensureCell(fns0);
            for f = 1:length(fns0)
                if (lstrfind(fns0{f}, mlfourd.NIfTId.FILETYPE_EXT))
                    fns{g} = fns0{f}; %#ok<AGROW>
                    g = g + 1;
                end
            end
        end
        function obj   = imageObject(varargin)
            %% IMAGEOBJECT returns an object with the typeclass of the last varargin;
            %  char filenames will be returned as fileprefixes

            if (1 == length(varargin))
                obj = imcast(varargin{1}, 'fileprefix');
                return
            end
            try
                import mlchoosers.*;
                namstr  = ImagingChoosers.coregNameStruct(varargin{:});
                obj     = fullfilename(namstr.path, [namstr.pre mlfsl.FslRegistry.INTERIMAGE_TOKEN namstr.post]);
                lastArg = varargin{length(varargin)};
                obj     = imcast(obj, class(lastArg));
            catch ME
                handexcept(ME);
            end
        end
        function nameStruct = coregNameStruct(varargin)
            %% COREGNAME accepts char, cell, CellArrayList, struct, INIfTI and
            %  returns a struct-array with string fields path, pre, post;
            %  dispatches to *2coregNameStruct methods that update path, pre, post so that 
            %  varargin{1} updates path, pre and varargin{N}, N = length(varargin), updates post.
            %  the coregistered name will have the form:   [char(varargin{1}) '_on_' char(varargin{N})]
            
            nameStruct = struct('path', '', 'pre', '', 'post', '');
            import mlchoosers.*;
            for v = 1:length(varargin)
                assert(~isempty(varargin{v}));
                switch (class(varargin{v}))
                    case 'char'
                        nameStruct = ImagingChoosers.char2coregNameStruct(nameStruct, varargin{v});
                    case 'cell'
                        nameStruct = ImagingChoosers.cell2coregNameStruct(nameStruct, varargin{v});
                    case mlfourd.ImagingArrayList
                        nameStruct = ImagingChoosers.cal2coregNameStruct(nameStruct, varargin{v});
                    case 'struct'
                        nameStruct = ImagingChoosers.struct2coregNameStruct(nameStruct, varargin{v});
                    otherwise
                        if (isa(varargin{v}, 'mlfourd.INIfTI'))
                            nameStruct = ImagingChoosers.abstractImage2coregNameStruct(nameStruct, varargin{v});
                        else
                            error('mlchoosers:unsupportedTypeclass', ...
                                  'class(ImagingChoosers.coregNameStruct.varargin{%i})->%s', v, class(varargin{v}));
                        end
                end
            end
            nameStruct = ImagingChoosers.finalizeNameStruct(nameStruct);
        end
        
        %% calls to FilenameFilters, ImageFilters
        
        function obj   = brightest(obj)
            obj = mlfourd.FilenameFilters.brightest(obj);
        end
        function obj   = highestSeriesNumber(obj)
            obj = mlfourd.FilenameFilters.highestSeriesNumber(obj);
        end
        function obj   = isMcf(obj)
            obj = mlfourd.FilenameFilters.isMcf(obj);
        end
        function obj   = isMr(obj)
            obj = mlfourd.FilenameFilters.isMr(obj);
        end
        function obj   = isPet(obj)
            obj = mlfourd.FilenameFilters.isPet(obj);
        end
        function obj   = leastEntropy(obj)
            obj = mlfourd.FilenameFilters.leastEntropy(obj);
        end
        function obj   = longestDuration(obj)
            obj = mlfourd.FilenameFilters.longestDuration(obj);
        end
        function obj   = lowestSeriesNumber(obj)
            obj = mlfourd.FilenameFilters.lowestSeriesNumber(obj);
        end
        function obj   = maximum(obj)
            obj = mlfourd.FilenameFilters.maximum(obj);
        end
        function obj   = meanvol(obj)
            obj = mlfourd.FilenameFilters.meanvol(obj);
        end
        function obj   = minimum(obj)
            obj = mlfourd.FilenameFilters.minimum(obj);
        end
        function obj   = mostEntropy(obj)
            obj = mlfourd.FilenameFilters.mostEntropy(obj);
        end
        function obj   = mostPixels(obj)
            obj = mlfourd.ImageFilters.mostPixels(obj);
        end
        function obj   = notIsMcf(obj)
            obj = mlfourd.FilenameFilters.notIsMcf(obj);
        end
        function obj   = notIsMr(obj)
            obj = mlfourd.FilenameFilters.notIsMr(obj);
        end
        function obj   = notIsPet(obj)
            obj = mlfourd.FilenameFilters.notIsPet(obj);
        end
        function obj   = smallestVoxels(obj)
            obj = mlfourd.FilenameFilters.smallestVoxels(obj);
        end
        function obj   = timeDependent(obj)
            obj = mlfourd.ImageFilters.timeDependent(obj);
        end

        function obj   = not(fhandle, obj)
            assert(iscell(obj));
            objfns = imcast(obj, 'fqfilename');
            hits   = fhandle(objfns);
            nots   = cellfun(@(x) ~lstrcmp(hits, x), objfns);
            obj    = {};
            for f = 1:length(objfns)
                if (nots{f})
                    obj = [obj objfns{f}]; end %#ok<AGROW>
            end
        end
    end
    
    methods %% setters/getters
        function this = set.fslPath(this, pth)
            assert(lexist(pth, 'dir'));
            this.fslPath_ = pth;
        end
        function pth  = get.fslPath(this)
            assert(lexist(this.fslPath_, 'dir'));
            pth = this.fslPath_;
        end 
        function defaults = get.inputParserDefaults(this)
            defaults = struct( ...
                'returnType', 'fqfilename', ...
                'fileprefixPattern', '', ...
                'path', this.fslPath, ...
                'ensureExists', false, ...
                'fullyQualified', false, ...
                'meanvol', false, ...
                'averaged', '', ...
                'blocked', 1, ....
                'blurred', 0, ....
                'modality', 'mr', ...
                'brightest', false, ....
                'lowestSeriesNumber', false, ....
                'highestSeriesNumber', false, ...
                'mostEntropy', false, ...
                'leastEntropy', false, ...
                'mostPixels', false, ...
                'smallestVoxels', false, ...
                'longestDuration', false, ...
                'timeDependent', false, ...
                'isMcf', false, ...
                'isFlirted', '', ...
                'isBetted', false );
        end
    end
    
	methods 
        function adc   = choose_adc(this, varargin)
            adc = this.choose_img('adc', varargin{:});
            if (isempty(adc))
                adc = this.choose_img('dwi', 'highestSeriesNumber', true, varargin{:}); end
            if (ischar(adc))
                this.chooseAsDefault(filename(adc), 'adc'); end
        end
        function asl   = choose_asl(this, varargin)
            asl = this.choose_img('asl', 'lowestSeriesNumber', true, varargin{:});
            if (ischar(asl))
                this.chooseAsDefault(filename(asl), 'asl'); end
        end
        function ase   = choose_ase(this, varargin)
            ase = this.choose_img('ase', 'lowestSeriesNumber', true, varargin{:});
            if (ischar(ase))
                this.chooseAsDefault(filename(ase), 'ase'); end
        end
        function dwi   = choose_dwi(this, varargin)
            dwi = this.choose_img('dwi', 'lowestSeriesNumber', true, varargin{:});
            if (ischar(dwi))
                this.chooseAsDefault(filename(dwi), 'dwi'); end
        end
        function t1    = choose_t1(this, varargin)
            t1 = this.choose_img('t1', 'mostPixels', true, varargin{:});
            if (ischar(t1))
                this.chooseAsDefault(filename(t1), 't1'); end
        end        
        function t2    = choose_t2(this, varargin)
            t2 = this.choose_img('t2', 'mostPixels',  true, varargin{:});
            if (ischar(t2))
                this.chooseAsDefault(filename(t2), 't2'); end
        end
        function ir    = choose_ir(this, varargin)
            ir = this.choose_img('ir', 'mostPixels', true, varargin{:});
            if (ischar(ir))
                this.chooseAsDefault(filename(ir), 'ir'); end
        end        
        function ir_abs = choose_ir_abs(this, varargin)
            ir_abs = this.choose_img('ir_abs', 'mostPixels', true, varargin{:});
            if (ischar(ir_abs))
                this.chooseAsDefault(filename(ir_abs), 'ir'); end
        end
        function gre   = choose_gre(this, varargin)
            gre = this.choose_img('gre', 'leastEntropy', true, 'timeDependent', true, varargin{:});
            if (ischar(gre))
                this.chooseAsDefault(filename(gre), 'gre'); end
        end        
        function tof   = choose_tof(this, varargin)
            tof = this.choose_img('tof', 'mostPixels', true, varargin{:});
            if (ischar(tof))
                this.chooseAsDefault(filename(tof), 'tof'); end
        end 
        function ep2d  = choose_ep2d(this, varargin)
            ep2d = this.choose_img('ep2d', 'mostPixels', true, 'timeDependent', true, 'longestDuration', true, varargin{:});
            if (ischar(ep2d))
                this.chooseAsDefault(filename(ep2d), 'ep2d'); end
        end        
        function ep2d  = choose_ep2dMeanvol(this, varargin)
            ep2d = this.choose_meanvol_img('ep2d_mcf_meanvol', 'mostPixels', true, 'timeDependent', false, 'meanvol', true, varargin{:});
            if (ischar(ep2d))
                this.chooseAsDefault(filename(ep2d), 'ep2d'); end
        end        
        function h15o  = choose_h15o(this, varargin)
            h15o = this.choose_img('*ho', 'modality', 'pet', 'timeDependent', true, 'longestDuration', true, varargin{:});
            if (ischar(h15o))
                this.chooseAsDefault(filename(h15o), 'ho'); end
        end       
        function h15o  = choose_h15oMeanvol(this, varargin)
            h15o = this.choose_meanvol_img('*ho', 'modality', 'pet', 'timeIndependent', true, 'brightest', true, varargin{:});
            if (ischar(h15o))
                this.chooseAsDefault(filename(h15o), 'ho_meanvol'); end
        end 
        function o15o  = choose_o15o(this, varargin)
            o15o = this.choose_img('*oo', 'modality', 'pet', 'timeDependent', true, 'longestDuration', true, varargin{:});
            if (ischar(o15o))
                this.chooseAsDefault(filename(o15o), 'oo'); end
        end  
        function o15o  = choose_o15oMeanvol(this, varargin)
            o15o = this.choose_meanvol_img('*oo', 'modality', 'pet', 'timeIndependent', true, varargin{:});
            if (ischar(o15o))
                this.chooseAsDefault(filename(o15o), 'oo_meanvol'); end
        end
        function c15o  = choose_c15o(this, varargin)
            c15o = this.choose_img('*oc', 'modality', 'pet', 'brightest', true, varargin{:});
            if (ischar(c15o))
                this.chooseAsDefault(filename(c15o), 'oc'); end
        end 
        function tr    = choose_tr(this, varargin)
            tr = this.choose_img('*tr*', 'modality', 'pet', 'brightest', true, varargin{:});
            if (ischar(tr))
                this.chooseAsDefault(filename(tr), 'tr'); end
        end        
        function         chooseAsDefault(this, fname, prefix)
            assert(ischar(fname));
            assert(ischar(prefix));
            prefix = this.dropUnderscore(prefix);
            try
                fname        = this.filenameOnFslPath(fname);
                defaultFname = this.filenameOnFslPath([prefix mlchoosers.ImagingChoosers.DEFAULT_SUFF mlfourd.NIfTId.FILETYPE_EXT]);
                if (~strcmp(fname, defaultFname))
                    movefile(fname, defaultFname, 'f'); end
                logger = mlpipeline.Logger(defaultFname);
                logger.add(sprintf('mlchoosers.ImagingChoosers.chooseAsDefault:  renamed %s to %s\n', fname, defaultFname));
                logger.save;
            catch ME
                handwarning(ME);
            end
        end
        
        function p     = theInputParser(this, varargin)
            p = inputParser;
            addParameter(p, 'returnType',         this.inputParserDefaults.returnType, @this.validReturnType);
            addParameter(p, 'fileprefixPattern',  this.inputParserDefaults.fileprefixPattern, @ischar);
            addParameter(p, 'path',               this.inputParserDefaults.path, @this.validPath); % defers to any path in fileprefixPattern
            addParameter(p, 'ensureExists',       this.inputParserDefaults.ensureExists);
            addParameter(p, 'fullyQualified',     this.inputParserDefaults.fullyQualified);
            addParameter(p, 'meanvol',            this.inputParserDefaults.meanvol);
            addParameter(p, 'averaged',           this.inputParserDefaults.averaged, @this.validAveraging);            
            addParameter(p, 'blocked',            this.inputParserDefaults.blocked, @isnumeric);
            addParameter(p, 'blurred',            this.inputParserDefaults.blurred, @isnumeric);            
            addParameter(p, 'modality',           this.inputParserDefaults.modality, @this.validModality);
            addParameter(p, 'brightest',          this.inputParserDefaults.brightest);
            addParameter(p, 'lowestSeriesNumber', this.inputParserDefaults.lowestSeriesNumber);
            addParameter(p, 'highestSeriesNumber',this.inputParserDefaults.highestSeriesNumber);
            addParameter(p, 'mostEntropy',        this.inputParserDefaults.mostEntropy);
            addParameter(p, 'leastEntropy',       this.inputParserDefaults.leastEntropy);
            addParameter(p, 'mostPixels',         this.inputParserDefaults.mostPixels);
            addParameter(p, 'smallestVoxels',     this.inputParserDefaults.smallestVoxels);
            addParameter(p, 'longestDuration',    this.inputParserDefaults.longestDuration); 
            addParameter(p, 'timeDependent',      this.inputParserDefaults.timeDependent); 
            addParameter(p, 'isMcf',              this.inputParserDefaults.isMcf);
            addParameter(p, 'isFlirted',          this.inputParserDefaults.isFlirted, @ischar);
            addParameter(p, 'isBetted',           this.inputParserDefaults.isBetted);
            parse(p, varargin{:});
        end  
        
 		function this  = ImagingChoosers(fslpth) 
 			%% ImagingChoosers 
 			%  Usage:  obj = ImagingChoosers(fsl_path) 
            
            assert(lexist(fslpth, 'dir'));
            this.fslPath_ = fslpth;
 		end %  ctor 
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        fslPath_
    end
    
    methods (Static, Access = 'private') 
        function obj = applyFiltersByType(obj, p)
            import mlchoosers.*;          
            if (isempty(obj) || 1 == length(obj)); return; end
            filtList = ImagingChoosers.globParsed(p);
            if (~isempty(filtList))
                if     (ischar(obj))
                    obj = ImagingChoosers.applyFilenameFilters(obj, filtList{:});
                elseif (iscell(obj) && ischar(obj{1}))
                    obj = ImagingChoosers.applyFilenameFilters(obj, filtList{:});
                elseif (isa(obj, 'mlfourd.ImagingComponent'))
                    obj = ImagingChoosers.applyImageFilters(obj, filtList{:});
                else
                    error('mlchoosers:unsupportedClass', 'ImagingChoosers.applyFiltersByType.obj has unsupported type->%s', ...
                           class(obj));
                end
            end
        end
        function fns = selectModality(fns, p)
            import mlfourd.*;
            if (~isempty(fns))
                switch (lower(p.Results.modality))
                    case {'mr' 'trio' 'avanto' 'allegra' 'sonata'}
                        fns = FilenameFilters.notIsPet(fns);
                    case {'pet' 'ecat_exact'}
                        fns = FilenameFilters.isPet(fns);
                    otherwise
                        error('mlchoosers:UnsupportedParam', 'ImagingChoosers.selectModality.p.Results.modality->%s', ...
                               p.Results.modality);
                end
            end
        end
        function [pth,fp,e] = decoratedFileparts(p)
            import mlfsl.*;
            [pth,fp,e] = filepartsx(p.Results.fileprefixPattern, mlfourd.NIfTId.FILETYPE_EXT);
            if (isempty(pth))
                pth = p.Results.path;
            end
            if (p.Results.ensureExists)
                ensureFilenameExists(fullfilename(pth, fp));
            end
            if (p.Results.meanvol)
                fp = FlirtBuilder.ensureMeanvolFilename(fp);
            end
            if (~isempty(p.Results.averaged))
                fp = [fp '_' p.Results.averaged];
            end
            if (prod(p.Results.blocked) > 1)
                fp = FlirtBuilder.blockedFilename(fp, p.Results.blocked);
            end
            if (sum(p.Results.blurred) > 0)
                fp = FlirtBuilder.blurredFilename(fp, p.Results.blurred);
            end
            if (p.Results.isMcf)
                fp = FlirtBuilder.ensureMcfFilename(fp);
            end
            if (~isempty(p.Results.isFlirted))
                fp = FlirtBuilder.flirtedFilename(fp, p.Results.isFlirted);
            end
            if (p.Results.isBetted)
                fp = BetBuilder.bettedFilename(fp);
            end    
            if (isempty(e))
                e = mlfourd.NIfTId.FILETYPE_EXT;
            end
        end   
        function rt = validReturnType(val)
            VALID = {'fileprefix' 'fp' 'filename' 'fn' 'fqfileprefix' 'fqfp' 'fqfilename' 'fqfn' ...
                     'imagingcomponent' 'imagingseries' 'imagingcomposite' 'nifti'};
            rt = lstrfind(lower(val), VALID);
        end
        function rt = validAveraging(val)
            assert(ischar(val));
            if (isempty(val))
                rt = true; 
                return
            end
            rt = lstrfind(lower(val), mlpet.PETBuilder.PREPROCESS_LIST);
        end
        function rt = validModality(val)
            VALID = {'mr' 'trio' 'avanto' 'allegra' 'sonata' 'pet' 'ecat_exact'};
            rt = lstrfind(lower(val), VALID);
        end     
        function rt = validPath(val)
            ensuredir(val);
            rt = true;
        end   
        function filtList = globParsed(p)
            filtList = {};
            if (p.Results.isBetted)
                filtList = [filtList 'isBetted']; end
            if (~isempty(p.Results.isFlirted))
                filtList = [filtList 'isFlirted']; end
            if (p.Results.isMcf)
                filtList = [filtList 'isMcf']; end
            if (p.Results.timeDependent)
                filtList = [filtList 'timeDependent']; end
            if (p.Results.longestDuration)
                filtList = [filtList 'longestDuration']; end
            if (p.Results.brightest)
                filtList = [filtList 'brightest']; end
            if (p.Results.smallestVoxels)
                filtList = [filtList 'smallestVoxels']; end
            if (p.Results.meanvol)
                filtList = [filtList 'meanvol']; end
            if (p.Results.mostPixels)
                filtList = [filtList 'mostPixels']; end
            if (p.Results.mostEntropy)
                filtList = [filtList 'mostEntropy']; end
            if (p.Results.leastEntropy)
                filtList = [filtList 'leastEntropy']; end
            if (p.Results.lowestSeriesNumber)
                filtList = [filtList 'lowestSeriesNumber']; end
            if (p.Results.highestSeriesNumber)
                filtList = [filtList 'highestSeriesNumber']; end
        end    
        
        function obj        = applyImageFilters(obj, varargin)
            %% APPLYIMAGEFILTERS
            %  Usage:  obj = ImagingChoosers.applyImageFilters(obj, constraint[, constraint2, ...])
            %          ^                                     ^ ImagingComponent object
            %                                                     ^ string, name of method from ImageFilters
                       
            if (isempty(obj) || 1 == length(obj)); return; end
            if (isa(obj, 'mlfourd.INIfTI')) % KLUDGE
                obj = mlchoosers.ImagingChoosers.applyNiftiFilters(obj, varargin{:});
                return
            end
            for v = 1:length(varargin)
                try
                    obj = mlfourd.ImageFilters.(varargin{v})(obj);
                catch ME
                    handexcept(ME);
                end
            end
        end
        function obj        = applyNiftiFilters(obj, varargin)
            if (isempty(obj) || 1 == length(obj)); return; end
            imser = mlfourd.ImagingSeries.load(obj);
            imser = mlchoosers.ImagingChoosers.applyImageFilters(imser, varargin{:});
            obj   = imser.cached;
        end
        function nameStruct = coregFirstLastNameStructs(nameStruct, obj0, objf)
            import mlchoosers.*;
            first = ImagingChoosers.coregNameStruct(obj0);
            last  = ImagingChoosers.coregNameStruct(objf);
            if (isempty(nameStruct.path))
                nameStruct.path = first.path; end
            if (isempty(nameStruct.pre))
                nameStruct.pre  = first.pre; end
                nameStruct.post = last.post;
        end
        function nameStruct = char2coregNameStruct(nameStruct, strng)
            import mlchoosers.*;
            [pth,strng] = filepartsx( ...
                          imcast(strng, 'fqfilename'), mlfourd.NIfTId.FILETYPE_EXT);
            if (isempty(nameStruct.path))
                nameStruct.path = pth; end
            if (isempty(nameStruct.pre))
                nameStruct.pre  = ImagingChoosers.beforeToken(strng); end
                nameStruct.post = ImagingChoosers.afterToken( strng);
        end
        function str        = beforeToken(str, tok)
            %% BEFORETOKEN returns the substring in front of the first token, 
            %  excluding filename suffixes .mat/.nii.gz; default is TOKEN
            
            str = fileprefix(fileprefix(str, mlfsl.FlirtVisitor.XFM_SUFFIX));
            if (~exist('tok', 'var')); tok = mlfsl.FslRegistry.INTERIMAGE_TOKEN; end
            locs = strfind(str, tok);
            if (~isempty(locs))
                str = str(1:locs(1)-1);
            end
        end % static beforeToken
        function str        = afterToken(str, tok)
            %% AFTERTOKEN returns the substring after the last token, 
            %  excluding filename suffixes .mat/.nii.gz; default is TOKEN
            
            str = fileprefix(fileprefix(str, mlfsl.FlirtVisitor.XFM_SUFFIX));
            if (~exist('tok', 'var')); tok = mlfsl.FslRegistry.INTERIMAGE_TOKEN; end
            locs = strfind(str, tok);
            if (~isempty(locs))
                str = str(locs(end)+length(tok):end);
            end
        end % static afterToken

        function nameStruct = cell2coregNameStruct(nameStruct, cll)
            nameStruct = mlchoosers.ImagingChoosers.coregFirstLastNameStructs( ...
                nameStruct, cll{1}, cll{length(cll)});
        end
        function nameStruct = cal2coregNameStruct(nameStruct, cal)
            nameStruct = mlchoosers.ImagingChoosers.coregFirstLastNameStructs( ...
                nameStruct, cal.get(1), cal.get(length(cal)));
        end
        function nameStruct = struct2coregNameStruct(nameStruct, strct)
            import mlchoosers.*;
            if (1 == length(strct))
                fields = fieldnames(mlfsl.FslProduct);
                for f = 1:length(fields)
                    if (isfield(strct, fields{f}))
                        nameStruct = ImagingChoosers.char2coregNameStruct( ...
                            nameStruct, imcast(strct.(fields{f}), 'fqfilename'));
                    end
                end
                return
            end
            nameStruct = ImagingChoosers.coregFirstLastNameStructs( ...
                nameStruct, strcts(1), strcts(length(strcts)));
        end
        function nameStruct = abstractImage2coregNameStruct(nameStruct, imobj)
            import mlchoosers.*;
            if (isempty(nameStruct))
                return; 
            end
            if (length(imobj) > 1)
                nameStruct = ImagingChoosers.cal2coregNameStruct(nameStruct, imobj);
                return
            end
            nameStruct = ImagingChoosers.char2coregNameStruct(nameStruct, imobj.fqfileprefix);
            
        end
        function nameStruct = finalizeNameStruct(nameStruct)
            if (~isempty(nameStruct.path))
                assert(lexist(nameStruct.path, 'dir')); end
            nameStruct.pre  = fileprefix(nameStruct.pre);
            nameStruct.post = fileprefix(nameStruct.post);
        end
    end
    
    methods (Access = 'private')
        function fqfn  = filenameOnFslPath(this, fn) 
            try
                if (~lstrfind(fn, this.fslPath))
                    fqfn = fullfile(this.fslPath, fn); end
            catch ME
                handexcept(ME);
            end
        end    
        function fqfp  = fileprefixOnFslPath(this, obj)
            fqfp = fileprefix(this.filenameOnFslPath(obj));
        end
        function img   = choose_img(this, fpstem, varargin)
            %% CHOOSE_IMG
            %  Usage:   NIfTI_image = this.choose_img(fileprefix_stem, varargin)
            %                                         ^ e.g., 't1', 'ep2d_meanvol', 'cho_f10to20'
            %                                                          ^ args to this.inputParser beyond 'path' & 'fileprefixPattern'
            
            try
                img = this.loadDefault(this.dropUnderscore(fpstem));
                if (isempty(img))
                    img = this.loadFileprefixPattern(fpstem, varargin{:});
                end
            catch ME
                handwarning(ME);
            end
        end
        function img   = choose_meanvol_img(this, fpstem, varargin)
            try
                img = this.loadDefault([this.dropUnderscore(fpstem) '_meanvol']);
                if (isempty(img))
                    img = this.loadFileprefixPattern(fpstem, varargin{:});
                end
            catch ME
                handwarning(ME);
            end
        end
        function fqfn  = loadFileprefixPattern(this, fp, varargin)
            fp   = [fp '*'];
            fqfn = this.createReturnType( ...
                   this.theInputParser('path', this.fslPath, 'fileprefixPattern', fp, varargin{:}));
        end
        function fqfn  = loadDefault(this, fpstem)
            %% LOADDEFAULT
            %  Usage:   NIfTI_image = this.loadDefault(fileprefix_stem)
            %                                          ^ e.g., 't1', 'ep2d', 'cho_f10to20'
            
            try
                fqfn = filename(mlfourd.NIfTI.load( ...
                      this.filenameOnFslPath( ...
                      [fpstem this.DEFAULT_SUFF mlfourd.NIfTId.FILETYPE_EXT])));
            catch %#ok<CTCH>
                fqfn = [];
            end
        end
        function str   = dropUnderscore(~, str)
            if (strcmp('_', str(length(str))))
                str = str(1:length(str)-1); end
        end
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

