classdef Test_ImageFilters < mlfourd_xunit.Test_mlfourd
	%% TEST_IMAGEFILTERS 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_ImageFilters % in . or the matlab path
	%          >> runtests mlfourd.Test_ImageFilters:test_nameoffunc
	%          >> runtests(mlfourd.Test_ImageFilters, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 2375 $ was created $Date: 2013-03-05 07:46:05 -0600 (Tue, 05 Mar 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-03-05 07:46:05 -0600 (Tue, 05 Mar 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImageFilters.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: Test_ImageFilters.m 2375 2013-03-05 13:46:05Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        SIZE_LIMIT = 20000000; % bytes
    end
    
	properties
        printReport = false;
        imcps
        brightest    
        lowestSeriesNumber
        mostEntropy       
        leastEntropy
        smallestVoxels    
        longestDuration   
        timeDependent          
        timeIndependent   
        isPet            
        isMcf            
        isFlirted        
        isBetted  
 	end

	methods 
 		function test_brightest(this)
            this.brightest = this.getNIfTI('ep2d_010');
            this.formTester('brightest');
            this.brightest = [];
        end
        function test_lowestSeriesNumber(this)
            this.lowestSeriesNumber = this.getNIfTI('local_001');
            this.formTester('lowestSeriesNumber');
            this.lowestSeriesNumber = [];
        end
        function test_mostEntropy(this)
            this.mostEntropy = this.getNIfTIs('tof_016');
            this.formTester('mostEntropy');
            this.mostEntropy = [];
        end
        function test_leastEntropy(this)
            this.leastEntropy = this.getNIfTI('tof_016');
            this.formTester('leastEntropy');
            this.leastEntropy = [];
        end
        function test_smallestVoxels(this)
            this.smallestVoxels = this.getNIfTI('tof_016');
            this.formTester('smallestVoxels');
            this.smallestVoxels = [];
        end
        function test_longestDuration(this)
            this.longestDuration = this.getNIfTIs({'ep2d_009' 'ep2d_009_mcf'});
            this.formTester('longestDuration');
            this.longestDuration = [];
        end
        function test_timeDependent(this)
            this.timeDependent = this.getNIfTIs({'ep2d_009' 'ep2d_009_mcf'});
            this.formTester('timeDependent');
            this.timeDependent = [];
        end
        function test_isPet(this)
            this.isPet = this.getNIfTIs({'cho_f10to29' 'coo_f5to24' 'hobin' 'oobin' 'poc' 'ptr'});
            this.formTester('isPet');
            this.isPet = [];
        end
        function test_isMcf(this)
            this.isMcf = this.getNIfTI('ep2d_009_mcf');
            this.formTester('isMcf');
            this.isMcf = [];
        end
        function test_isFlirted(this)
            this.isFlirted = this.getNIfTI('t2_default_on_t1_002');
            this.formTester('isFlirted');
            this.isFlirted = [];
        end
        function test_isBetted(this)
            this.isBetted = this.getNIfTIs({'bt1_002' 'bt1_002_mask'});
            this.formTester('isBetted');
            this.isBetted = [];
        end
        
 		function this = Test_ImageFilters(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:}); 
            this.preferredSession = 1;
            cd(this.fslPath);
            if (isempty(this.imcps))                
                dt = mlsystem.DirTool(fullfile(this.fslPath, '*.nii.gz'));
                this.imcps = mlfourd.ImagingComposite.load(dt.fqfns);
            end
        end 
    end 
    
    %% PRIVATE
    
    methods (Access = 'private')
        function choice = getNIfTIs(~, fnames) 
            choice = mlfourd.ImagingComposite.load(fnames);
        end
        function choice = getNIfTI(this, fname)
            choice = mlfourd.ImagingSeries.load( ... 
                     this.fqfilenameInFsl(fname));
        end
        function          formTester(this, funname)
            choices = mlchoosers.ImageFilters.(funname)(this.imcps);
            if (this.printReport)
                this.report(funname, choices);
            else
                if (length(choices) > 1)
                    predicted = this.(funname);
                    for c = 1:length(choices)
                        assertTrue(isequal(predicted{c}, choices{c}));
                    end
                    return
                end
                %%fqfn = imcast(choices, 'fqfilename');
                %%fprintf('Test_ImageFilters.formTester:  %s -> %s\n', funname, fqfn);
                this.assertImagingArrayListsEqual(this.(funname), choices);
            end
        end
        function          report(~, funname, choices)
                fprintf('\n   %s of images -> ', funname);
            for c = 1:length(choices)            
                fprintf('%s ', choices{c}.fileprefix);
            end
                fprintf('\n');
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

