classdef Test_FilenameFilters < mlfourd_xunit.Test_mlfourd
	%% TEST_FILENAMEFILTERS 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlchoosers.Test_FilenameFilters % in . or the matlab path
	%          >> runtests mlchoosers.Test_FilenameFilters:test_nameoffunc
	%          >> runtests(mlchoosers.Test_FilenameFilters, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 2298 $ was created $Date: 2012-12-09 19:53:37 -0600 (Sun, 09 Dec 2012) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2012-12-09 19:53:37 -0600 (Sun, 09 Dec 2012) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_FilenameFilters.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: Test_FilenameFilters.m 2298 2012-12-10 01:53:37Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties        
        fqfns
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
            this.assertStringsEqual(this.brightest, ...
                mlchoosers.FilenameFilters.brightest(this.fqfns));
        end
        function test_lowestSeriesNumber(this)
            this.assertStringsEqual(this.lowestSeriesNumber, ...
                mlchoosers.FilenameFilters.lowestSeriesNumber(this.fqfns));
        end
        function test_mostEntropy(this)
            this.assertStringsEqual(this.mostEntropy, ...
                mlchoosers.FilenameFilters.mostEntropy(this.fqfns));
        end
        function test_leastEntropy(this)
            this.assertStringsEqual(this.leastEntropy, ...
                mlchoosers.FilenameFilters.leastEntropy(this.fqfns));
        end
        function test_smallestVoxels(this)
            this.assertStringsEqual(this.smallestVoxels, ...
                mlchoosers.FilenameFilters.smallestVoxels(this.fqfns));
        end
        function test_longestDuration(this)
            this.assertStringsEqual(this.longestDuration, ...
                mlchoosers.FilenameFilters.longestDuration(this.fqfns));
        end
        function test_timeDependent(this)
            this.assertStringsEqual(this.timeDependent, ...
                mlchoosers.FilenameFilters.timeDependent(this.fqfns));
        end
        function test_isPet(this)
            this.assertStringsEqual(this.isPet, ...
                mlchoosers.FilenameFilters.isPet(this.fqfns));
        end
        function test_isMcf(this)
            this.assertStringsEqual(this.isMcf, ...
                mlchoosers.FilenameFilters.isMcf(this.fqfns));
        end
        function test_isFlirted(this)
            this.assertStringsEqual(this.isFlirted, ...
                mlchoosers.FilenameFilters.isFlirted(this.fqfns));
        end
        function test_isBetted(this)
            this.assertStringsEqual( ...
                this.isBetted, ...
                mlchoosers.FilenameFilters.isBetted(this.fqfns));
        end
        
 		function this = Test_FilenameFilters(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:});
            this.preferredSession = 1;
            cd(this.fslPath);
            dt = mlsystem.DirTool(fullfile(this.fslPath, '*.nii.gz'));
            this.fqfns = dt.fqfns;

            this.brightest          = this.ensureFqfns('ep2d_010.nii.gz');
            this.lowestSeriesNumber = this.ensureFqfns('local_001.nii.gz');
            this.mostEntropy        = this.ensureFqfns('tof_016.nii.gz');
            this.leastEntropy       = this.ensureFqfns('tof_016.nii.gz');
            this.smallestVoxels     = this.ensureFqfns('tof_016.nii.gz');
            this.longestDuration    = this.ensureFqfns( ...
                {'ep2d_009' 'ep2d_009_mcf'});
            this.timeDependent      = this.ensureFqfns( ...
                { 'ep2d_009' 'ep2d_009_mcf' });
            this.isPet              = this.ensureFqfns( ...
                { 'cho_f10to29' 'coo_f5to24' 'hobin' 'oobin' 'poc' 'ptr' });
            this.isMcf              = this.ensureFqfns('ep2d_009_mcf.nii.gz');
            this.isFlirted          = this.ensureFqfns('t2_default_on_t1_002.nii.gz');
            this.isBetted           = this.ensureFqfns({'bt1_002.nii.gz' 'bt1_002_mask.nii.gz'});
        end % ctor 
        
        function fns  = ensureFqfns(this, fprefix)
            switch (class(fprefix))
                case 'cell'
                    fns = cellfun(@(x) fullfile(this.fslPath, filename(x)), fprefix, 'UniformOutput', false);
                case 'char'
                    fns = fullfile(this.fslPath, filename(fprefix));
                otherwise
                    error('mlfourd_xunit:NotImplemented', 'Test_FilenameFilters.ensureFqfns');
            end
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

