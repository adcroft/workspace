#EXPTS=$(wildcard MOM6/examples/[a-zA-Z][a-zA-UW-Z]*)
ALE_EXPTS=resting/z \
          single_column_z sloshing/rho \
          adjustment2d/z adjustment2d/rho \
          seamount/z seamount/sigma \
          flow_downslope/z flow_downslope/sigma \
          global_ALE/z
SOLO_EXPTS=torus_advection_test lock_exchange external_gwave single_column \
           sloshing/layer adjustment2d/layer seamount/layer flow_downslope/layer global_ALE/layer \
           double_gyre DOME benchmark global nonBous_global MESO_025_63L Phillips_2layer
SYMMETRIC_EXPTS=circle_obcs
SIS_EXPTS=GOLD_SIS GOLD_SIS_icebergs
SIS2_EXPTS=SIS2 SIS2_icebergs
CPLD_EXPTS=CM2G63L AM2_MOM6i_1deg
EXPTS=$(ALE_EXPTS) $(SOLO_EXPTS) $(SYMMETRIC_EXPTS) $(SIS_EXPTS) $(SIS2_EXPTS) $(CPLD_EXPTS)
EXPT_EXECS=solo solo_symmetric MOM6_SIS SIS2 CM2G # Executable/model configurations to build
#For non-GFDL users: CVS=cvs -d /ncrc/home2/fms/cvs
#For GFDL users: CVS=cvs -d :ext:cvs.princeton.rdhpcs.noaa.gov:/home/fms/cvs
#For when certificates are down: CVS=cvs -d :ext:gfdl:/home/fms/cvs
#CVS=cvs -d :ext:gfdl:/home/fms/cvs
CVS=cvs -d :ext:cvs.princeton.rdhpcs.noaa.gov:/home/fms/cvs
#DATASETS_ROOT=/lustre/fs/scratch/Alistair.Adcroft/datasets
#DATASETS_ROOT=/lustre/fs/scratch/gold/datasets
DATASETS_ROOT=/lustre/fs/pdata/gfdl_O/datasets

#CPPDEFS="-Duse_libMPI -Duse_netCDF -Duse_LARGEFILE -DSPMD -Duse_shared_pointers -Duse_SGI_GSM -DLAND_BND_TRACERS"
CPPDEFS="-DSPMD -DLAND_BND_TRACERS"
CPPDEFS="-Duse_libMPI -Duse_netCDF"
CPPDEFS="-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS"
CPPDEFS='-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS -D_FILE_VERSION="`../../bin/git-get-fms-version $$<`"'
CPPDEFS='-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS -D_FILE_VERSION="`../../bin/git-version-string $$<`"'
# SITE can be ncrc, hpcs or doe
SITE=ncrc
MAKEMODE=NETCDF=4 OPENMP=1
MAKEMODE=NETCDF=4
MODES=repro prod debug
COMPILERS=intel pathscale pgi cray gnu
COMPILERS=gnu intel pgi

GOLD_tag=GOLD_ogrp
MOM6_tag=dev/master
FMS_tag=siena_201308
ICE_tag=siena_201308
BIN_tag=fre-commands-bronx-5

# Default compiler configuration
COMPILER=intel
EXEC_MODE=repro
TEMPLATE=-t ../../site/$(SITE)/$(COMPILER).mk
NPES=2
PMAKEOPTS=-l 12.0 -j 12
PMAKEOPTS=-j

TIMESTATS=$(foreach dir,$(EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
# .SECONDARY stops deletiong of targets that were built implicitly
.SECONDARY:

CP=ln -sf
UCP=cp -u
LN=ln -sf
LN=ln -s
SHELL=tcsh

# The "all" target depends on which set of nodes we are on...
ifeq ($(findstring $(HOST),$(foreach n,1 2 3 4 5 6 7 8 9,c1-batch$(n))),$(HOST))
ALLMESG=On batch nodes: building executables, running experiments
ALLTARGS=ale solo symmetric sis sis2 coupled status
else
ALLMESG=On login nodes: building executables, reporting status
ALLTARGS=$(EXEC_MODE) status
endif
all:
	@echo HOST = $(HOST)
	@echo $(ALLMESG)
	@echo targets = $(ALLTARGS)
	@time make $(ALLTARGS)

buildall: $(MODES)
#repro: $(foreach exec,$(EXPT_EXECS),$(foreach comp,$(COMPILERS),build/$(exec).$(comp).repro/MOM6))
#debug: $(foreach exec,$(EXPT_EXECS),$(foreach comp,$(COMPILERS),build/$(exec).$(comp).debug/MOM6))
#prod: $(foreach exec,$(EXPT_EXECS),$(foreach comp,$(COMPILERS),build/$(exec).$(comp).prod/MOM6))
repro: $(foreach exec,$(EXPT_EXECS),build/$(exec).$(COMPILER).repro/MOM6)
debug: build/shared.$(COMPILER).debug/libfms.a $(foreach exec,$(EXPT_EXECS),build/$(exec).$(COMPILER).debug/MOM6)
prod: $(foreach exec,$(EXPT_EXECS),build/$(exec).$(COMPILER).prod/MOM6)
ale: build/solo.$(COMPILER).$(EXEC_MODE)/MOM6 $(foreach dir,$(ALE_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
solo: build/solo.$(COMPILER).$(EXEC_MODE)/MOM6 $(foreach dir,$(SOLO_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
symmetric: build/solo_symmetric.$(COMPILER).$(EXEC_MODE)/MOM6 $(foreach dir,$(SYMMETRIC_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
sis: build/MOM6_SIS.$(COMPILER).$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
sis2: build/SIS2.$(COMPILER).$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS2_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
coupled: build/CM2G.$(COMPILER).$(EXEC_MODE)/MOM6 $(foreach dir,$(CPLD_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
Ale:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) ale;)
Solo:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) solo;)
Sis:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) sis sis2;)
Coupled:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) cooupled;)
All:
	make Ale Solo
	make Sis
	$(foreach comp,$(COMPILERS),make $(comp);)
intel:
	make COMPILER=intel
pathscale:
	make COMPILER=pathscale
pgi:
	make COMPILER=pgi
cray:
	make COMPILER=cray
gnu:
	make COMPILER=gnu
help:
	@echo 'Typical targets:'
	@echo ' make help     - this message'
	@echo ' make checkout - checkout source code                     ** LOGIN nodes only **'
	@echo ' make buildall - compile executables for each of the configurations'
	@echo '                 listed in the MODES variable'
	@echo ' make all      - On login nodes, install data, build the repro executables'
	@echo '                 and check CVS status of timestats files'
	@echo '               - On batch nodes, build the repro executables and run'
	@echo '                 executables for any out-of-date timestats files'
	@echo
	@echo 'Other complex targest:'
	@echo ' make repro    - build the repro executables for all compilers'
	@echo ' make debug    - build the debug executables for all compilers'
	@echo ' make prod     - build the prod executables for all compilers'
	@echo ' make intel    - same as "all" with COMPILER=intel'
	@echo ' make pgi      - same as "all" with COMPILER=pgi'
	@echo ' make pathscale- same as "all" with COMPILER=pathscale'
	@echo ' make solo     - build/run the solo experiments'
	@echo ' make sis      - build/run the GOLD_SIS experiments'
	@echo ' make sis2     - build/run the GOLD_SIS experiments'
	@echo ' make coupled  - build/run the coupled CM2G3L experiments'
	@echo ' make status   - check CVS status of expts list in EXPTS variable'
	@echo ' make all'
	@echo ' make force'
	@echo ' make clean'
	@echo ' make buildall - do "build" for all compilers'
	@echo ' make COMPILER=pathscale   (or pgi, or intel)'
	@echo ' make EXEC_MODE=debug      (or prod, or repro)'
	@echo 'Specific targets:                                         ** BATCH nodes only **\n' $(foreach dir,$(EXPTS),'make MOM6/examples/$(dir)/timestats\n')
status: # Check CVS status of $(TIMESTATS)
	@cd MOM6; git status -- $(subst MOM6/,,$(TIMESTATS))
	@echo ==================================================================
	@cd MOM6; git status -s -- $(subst MOM6/,,$(TIMESTATS))
force: cleantimestats
	@make all
cleantimestats:
	rm -f $(TIMESTATS)
clean:
	@$(foreach dir,$(wildcard build/*), (cd $(dir); make clean); )
	find build/* -type l -exec rm {} \;
	find build/* -name '*.mod' -exec rm {} \;
Clean: clean cleancore
	-rm -f MOM6/examples/{*,*/*,*/*/*}/*.nc.*
	-rm -f MOM6/examples/{*,*/*,*/*/*}/*.{nc,out}
	-rm -rf MOM6/examples/{*,*/*}/RESTART
	-rm -f MOM6/examples/{*,*/*}/{fort.*,*.nml,timestats,CPU_stats,exitcode,available_diags.*}
cleancore:
	-find MOM6/examples/ -name core -type f -exec rm {} \;
	-find MOM6/examples/ -name "*truncations" -type f -exec rm {} \;
backup: Clean
	tar zcvf ~/MOM6_backup.tgz MOM6

# This section defines how to checkout and layout the source code
checkout: MOM6 shared extras/MOM6_SIS extras/SIS2 extras/CM2G site bin builddir
GOLD:
	$(CVS) co -kk -r $(GOLD_tag) -P GOLD
	(cd MOM6/src/ice_shelf; $(CVS) up -r null_ice_shelf_ogrp)
MOM6:
	git clone -n ssh://cvs.princeton.rdhpcs.noaa.gov/home/fms/git/ocean/MOM6.git
	(cd MOM6; git checkout $(MOM6_tag))
shared:
	$(CVS) co -kk -r $(FMS_tag) -P shared
	rm -rf shared/oda_tools
extras/MOM6_SIS:
	mkdir -p $@
	(cd $@; \
$(CVS) co -kk -r $(FMS_tag) -P atmos_null atmos_param/diag_integral atmos_param/monin_obukhov coupler ice_sis ice_param land_null; \
$(CVS) up -r $(ICE_tag) -P -d ice_sis)
extras/SIS2: extras/MOM6_SIS
	mkdir -p $@
	(cd $@; \
git clone -n ssh://cvs.princeton.rdhpcs.noaa.gov/home/sdu/git/ice/sis2 ice_sis2; \
ln -s ../MOM6_SIS/{coupler,*_param,*_null} .; \
cd ice_sis2; git checkout dev/master)
extras/CM2G: extras/MOM6_SIS
	mkdir -p $@
	(cd $@; $(CVS) co -kk -r $(FMS_tag) -P atmos_coupled atmos_fv_dynamics atmos_param_am3 atmos_shared coupler ice_param land_lad land_param)
	(cd $@; rm -rf ice_sis; ln -s ../MOM6_SIS/ice_sis .)
	rm -rf $@/atmos_fv_dynamics/driver/solo
site:
	$(CVS) co -kk -r $(BIN_tag) -P -d site fre/fre-commands/site
bin:
	$(CVS) co -kk -r $(BIN_tag) -P -d bin bin-pub
builddir: # Target invoked for documenting (use with make -n checkout
	mkdir -p $(foreach expt,shared $(EXPT_EXECS),build/$(expt).$(COMPILER).$(EXEC_MODE))
MOM6/pkg/CVmix:
	cd MOM6; git submodule init; git submodule update
#cd MOM6; git submodule add ssh://cvs.princeton.rdhpcs.noaa.gov/home/aja/Repos/CVmix.git pkg/CVmix

# Rules for building executables ###############################################
# Choose the compiler based on the build directory
$(foreach cfg,$(MODES),build/%.pathscale.$(cfg)/MOM6): override COMPILER:=pathscale
$(foreach cfg,$(MODES),build/%.intel.$(cfg)/MOM6): override COMPILER:=intel
$(foreach cfg,$(MODES),build/%.pgi.$(cfg)/MOM6): override COMPILER:=pgi
$(foreach cfg,$(MODES),build/%.cray.$(cfg)/MOM6): override COMPILER:=cray
$(foreach cfg,$(MODES),build/%.gnu.$(cfg)/MOM6): override COMPILER:=gnu
build/shared.pathscale.%/libfms.a: override COMPILER:=pathscale
build/shared.intel.%/libfms.a: override COMPILER:=intel
build/shared.pgi.%/libfms.a: override COMPILER:=pgi
build/shared.cray.%/libfms.a: override COMPILER:=cray
build/shared.gnu.%/libfms.a: override COMPILER:=gnu
# Set REPRO and DEBUG variables based on the build directory
build/%.prod/MOM6: EXEC_MODE=prod
build/%.repro/MOM6: EXEC_MODE=repro
build/%.debug/MOM6: EXEC_MODE=debug
build/%.repro/libfms.a build/%.repro/MOM6: MAKEMODE+=REPRO=1
build/%.debug/libfms.a build/%.debug/MOM6: MAKEMODE+=DEBUG=1

# Create module scripts
build/env: Makefile
	@mkdir -p build/env
#	@make build/env/pgi build/env/pathscale build/env/intel
build/env/pgi: build/env
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-pgi >> $@
	@echo module load netcdf/4.2.0 >> $@
build/env/pathscale: build/env
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-pathscale >> $@
	@echo module load netcdf/4.2.0 >> $@
build/env/intel: build/env
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-intel/4.0.46 >> $@
	@echo module switch intel intel/12.0.5.220 >> $@
	@echo module load netcdf/4.2.0 >> $@
build/env/cray: build/env
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-cray >> $@
	@echo module load netcdf/4.2.0 >> $@
build/env/gnu: build/env
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-gnu >> $@
	@echo module load netcdf/4.2.0 >> $@
runscript.sh: Makefile
	@echo Building $@
	@echo '#/bin/csh -ve' > $@
	@echo 'cd $$PWD' >> $@
	@echo 'if ($$?RUNARGS == "0") set RUNARGS=" "' >> $@
	@echo 'make $$RUNARGS' >> $@

# solo executable
#build/solo.%/MOM6: $(foreach dir,config_src/dynamic config_src/solo_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/shared.$(COMPILER).$(EXEC_MODE)/libfms.a build/shared.%/libfms.a
#build/solo_symmetric.pgi.%/MOM6: build/shared.pgi.%/libfms.a
#build/solo_symmetric.gnu.%/MOM6: build/shared.gnu.%/libfms.a
#build/solo_symmetric.intel.%/MOM6: build/shared.intel.%/libfms.a
#build/solo_symmetric.cray.%/MOM6: build/shared.cray.%/libfms.a
#build/solo.pgi.%/MOM6: build/shared.pgi.%/libfms.a
#build/solo.gnu.%/MOM6: build/shared.gnu.%/libfms.a
#build/solo.intel.%/MOM6: build/shared.intel.%/libfms.a
#build/solo.cray.%/MOM6: build/shared.cray.%/libfms.a
build/solo.%/MOM6: build/shared.%/libfms.a
build/solo.%/MOM6: SRCPTH="./ ../../MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/ ../../shared/"
build/solo.%/MOM6: $(foreach dir,config_src/dynamic config_src/solo_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/shared.%/libfms.a
	@echo; echo Building $@
	@echo SRCPTH=$(SRCPTH)
	@echo MAKEMODE=$(MAKEMODE)
	@echo COMPILER=$(COMPILER)
	@echo EXEC_MODE=$(EXEC_MODE)
	mkdir -p $(dir $@)
	(cd $(dir $@); rm -f path_names; ../../bin/list_paths $(SRCPTH))
	(cd $(dir $@); ../../bin/mkmf $(TEMPLATE) -p MOM6 -c $(CPPDEFS) path_names)
	(cd $(dir $@); ln -sf ../shared.$(COMPILER).$(EXEC_MODE)/*.{o,mod} .)
	(cd $(dir $@); rm -f MOM6)
	(cd $(dir $@); source ../../build/env/$(COMPILER); make $(MAKEMODE) $(PMAKEOPTS))

# Create a local MOM_memory.h for symmetric mode
build/%/MOM_memory.h: MOM6/config_src/dynamic/MOM_memory.h
	mkdir -p $(dir $@)
	(cd $(dir $@); sed 's/#undef  SYMMETRIC_MEMORY/#define SYMMETRIC_MEMORY/' ../../MOM6/config_src/dynamic/MOM_memory.h > MOM_memory.h)

# Symmetric executable
build/solo_symmetric.pathscale.debug/MOM6: build/solo_symmetric.pathscale.debug/MOM_memory.h
build/solo_symmetric.pgi.debug/MOM6: build/solo_symmetric.pgi.debug/MOM_memory.h
build/solo_symmetric.intel.debug/MOM6: build/solo_symmetric.intel.debug/MOM_memory.h
build/solo_symmetric.gnu.debug/MOM6: build/solo_symmetric.gnu.debug/MOM_memory.h
build/solo_symmetric.cray.debug/MOM6: build/solo_symmetric.cray.debug/MOM_memory.h
build/solo_symmetric.pathscale.repro/MOM6: build/solo_symmetric.pathscale.repro/MOM_memory.h
build/solo_symmetric.pgi.repro/MOM6: build/solo_symmetric.pgi.repro/MOM_memory.h
build/solo_symmetric.intel.repro/MOM6: build/solo_symmetric.intel.repro/MOM_memory.h
build/solo_symmetric.cray.repro/MOM6: build/solo_symmetric.cray.repro/MOM_memory.h
build/solo_symmetric.gnu.repro/MOM6: build/solo_symmetric.gnu.repro/MOM_memory.h
build/solo_symmetric.%/MOM6: build/shared.%/libfms.a
build/solo_symmetric.%/MOM6: SRCPTH="./ ../../MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/ ../../shared/"
build/solo_symmetric.%/MOM6: $(foreach dir,config_src/dynamic config_src/solo_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/shared.%/libfms.a
	@echo; echo Building $@
	@echo SRCPTH=$(SRCPTH)
	@echo MAKEMODE=$(MAKEMODE)
	@echo COMPILER=$(COMPILER)
	@echo EXEC_MODE=$(EXEC_MODE)
	mkdir -p $(dir $@)
	(cd $(dir $@); rm -f path_names; ../../bin/list_paths $(SRCPTH))
	(cd $(dir $@); ../../bin/mkmf $(TEMPLATE) -p MOM6 -c $(CPPDEFS) path_names)
	(cd $(dir $@); ln -sf ../shared.$(COMPILER).$(EXEC_MODE)/*.{o,mod} .)
	(cd $(dir $@); rm -f MOM6)
	(cd $(dir $@); source ../../build/env/$(COMPILER); make $(MAKEMODE) $(PMAKEOPTS))

# MOM6_SIS executable
#build/MOM6_SIS.%/MOM6: $(foreach dir,config_src/dynamic config_src/coupled_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/shared.$(COMPILER).$(EXEC_MODE)/libfms.a $(foreach dir,$(wildcard extras/MOM6_SIS/*),$(wildcard $(dir)/*.F90 $(dir)/*.h))
build/MOM6_SIS.%/MOM6: build/shared.%/libfms.a
build/MOM6_SIS.%/MOM6: SRCPTH="./ ../../MOM6/{config_src/dynamic,config_src/coupled_driver,src/{*,*/*}}/ ../../extras/MOM6_SIS/{*,*/*}/ ../../shared/"
build/MOM6_SIS.%/MOM6: $(foreach dir,config_src/dynamic config_src/coupled_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/shared.%/libfms.a $(foreach dir,$(wildcard extras/MOM6_SIS/*),$(wildcard $(dir)/*.F90 $(dir)/*.h))
	@echo; echo Building $@
	@echo SRCPTH=$(SRCPTH)
	@echo MAKEMODE=$(MAKEMODE)
	@echo COMPILER=$(COMPILER)
	@echo EXEC_MODE=$(EXEC_MODE)
	mkdir -p $(dir $@)
	(cd $(dir $@); rm -f path_names; ../../bin/list_paths $(SRCPTH))
	(cd $(dir $@); ../../bin/mkmf $(TEMPLATE) -p MOM6 -c $(CPPDEFS) path_names)
	(cd $(dir $@); ln -sf ../shared.$(COMPILER).$(EXEC_MODE)/*.{o,mod} .)
	(cd $(dir $@); rm -f MOM6)
	(cd $(dir $@); source ../../build/env/$(COMPILER); make $(MAKEMODE) $(PMAKEOPTS))

# SIS2 executable
build/SIS2.%/MOM6: build/shared.%/libfms.a
build/SIS2.%/MOM6: SRCPTH="./ ../../MOM6/{config_src/dynamic,config_src/coupled_driver,src/{*,*/*}}/ ../../extras/SIS2/*/ ../../shared/"
build/SIS2.%/MOM6: $(foreach dir,config_src/dynamic config_src/coupled_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/shared.$(COMPILER).$(EXEC_MODE)/libfms.a $(foreach dir,$(wildcard extras/SIS2/*),$(wildcard $(dir)/*.F90 $(dir)/*.h))
	@echo; echo Building $@
	@echo SRCPTH=$(SRCPTH)
	@echo MAKEMODE=$(MAKEMODE)
	@echo COMPILER=$(COMPILER)
	@echo EXEC_MODE=$(EXEC_MODE)
	mkdir -p $(dir $@)
	(cd $(dir $@); rm -f path_names; ../../bin/list_paths $(SRCPTH))
	(cd $(dir $@); ../../bin/mkmf $(TEMPLATE) -p MOM6 -c $(CPPDEFS) path_names)
	(cd $(dir $@); ln -sf ../shared.$(COMPILER).$(EXEC_MODE)/*.{o,mod} .)
	(cd $(dir $@); rm -f MOM6)
	(cd $(dir $@); source ../../build/env/$(COMPILER); make $(MAKEMODE) $(PMAKEOPTS))

#build/CM2G.%/MOM6: MOM6/config_src/dynamic/* MOM6/config_src/coupled_driver/* MOM6/src/* MOM6/src/*/* MOM6/src/*/*/* extras/CM2G/*/*
build/CM2G.%/MOM6: build/shared.%/libfms.a
build/CM2G.%/MOM6: SRCPTH="./ ../../MOM6/{config_src/dynamic,config_src/coupled_driver,src/{*,*/*}}/ ../../extras/CM2G/{*,*/*}/ ../../shared/"
build/CM2G.%/MOM6: $(foreach dir,config_src/dynamic config_src/coupled_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/shared.$(COMPILER).$(EXEC_MODE)/libfms.a $(foreach dir,$(wildcard extras/CM2G/*),$(wildcard $(dir)/*.F90 $(dir)/*.h))
	@echo; echo Building $@
	@echo SRCPTH=$(SRCPTH)
	@echo MAKEMODE=$(MAKEMODE)
	@echo COMPILER=$(COMPILER)
	@echo EXEC_MODE=$(EXEC_MODE)
	mkdir -p $(dir $@)
	(cd $(dir $@); rm -f path_names; ../../bin/list_paths $(SRCPTH))
	(cd $(dir $@); ../../bin/mkmf $(TEMPLATE) -p MOM6 -c $(CPPDEFS) path_names)
	(cd $(dir $@); ln -sf ../shared.$(COMPILER).$(EXEC_MODE)/*.{o,mod} .)
	(cd $(dir $@); rm -f MOM6)
	(cd $(dir $@); source ../../build/env/$(COMPILER); make $(MAKEMODE) $(PMAKEOPTS))

# Choose the compiler based on the build directory (repeated from above rules
# due to different libfms.a target)
build/shared.%/libfms.a: build/shared.%/Makefile
	@echo; echo Building $@
	@mkdir -p $(dir $@)
	@echo MAKEMODE=$(MAKEMODE)
	@echo COMPILER=$(COMPILER)
	(cd $(dir $@); rm -f libfms.a)
	(cd $(dir $@); source ../../build/env/$(COMPILER); make $(MAKEMODE) $(PMAKEOPTS) libfms.a)
build/shared.%/Makefile: shared/* shared/*/* shared/*/*/* build/env/$(COMPILER)
	@echo; echo Building $@
	@mkdir -p $(dir $@)
	@echo MAKEMODE=$(MAKEMODE)
	@echo COMPILER=$(COMPILER)
	(cd $(dir $@); rm path_names; ../../bin/list_paths ../../shared)
	(cd $(dir $@); mv path_names path_names.orig; egrep -v "atmos_ocean_fluxes|coupler_types|coupler_util" path_names.orig > path_names)
	(cd $(dir $@); ../../bin/mkmf $(TEMPLATE) -p libfms.a -c $(CPPDEFS) path_names)

# Rules for configuring and running experiments ################################

MOM6/examples/unit_tests/timestats.$(COMPILER): NPES=2
MOM6/examples/unit_tests/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/unit_tests/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/unit_tests/$(fl))

MOM6/examples/torus_advection_test/timestats.$(COMPILER): NPES=2
MOM6/examples/torus_advection_test/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/torus_advection_test/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/torus_advection_test/$(fl))

MOM6/examples/double_gyre/timestats.$(COMPILER): NPES=8
MOM6/examples/double_gyre/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/double_gyre/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/double_gyre/$(fl))

MOM6/examples/DOME/timestats.$(COMPILER): NPES=6
MOM6/examples/DOME/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/DOME/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/DOME/$(fl))

MOM6/examples/benchmark/timestats.$(COMPILER): NPES=72
MOM6/examples/benchmark/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/benchmark/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/benchmark/$(fl))

MOM6/examples/single_column/timestats.$(COMPILER): NPES=1
MOM6/examples/single_column/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/single_column/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/single_column/$(fl))

MOM6/examples/single_column_z/timestats.$(COMPILER): NPES=1
MOM6/examples/single_column_z/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/single_column_z/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/single_column_z/$(fl))

MOM6/examples/circle_obcs/timestats.$(COMPILER): NPES=2
MOM6/examples/circle_obcs/timestats.$(COMPILER): build/solo_symmetric.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/circle_obcs/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/circle_obcs/$(fl))

MOM6/examples/lock_exchange/timestats.$(COMPILER): NPES=2
MOM6/examples/lock_exchange/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/lock_exchange/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/lock_exchange/$(fl))

MOM6/examples/adjustment2d/%/timestats.$(COMPILER): NPES=2
MOM6/examples/adjustment2d/layer/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/adjustment2d/layer/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/adjustment2d/layer/$(fl))
MOM6/examples/adjustment2d/z/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/adjustment2d/z/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/adjustment2d/z/$(fl))
MOM6/examples/adjustment2d/rho/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/adjustment2d/rho/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/adjustment2d/rho/$(fl))

MOM6/examples/resting/%/timestats.$(COMPILER): NPES=2
MOM6/examples/resting/layer/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/resting/layer/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/resting/layer/$(fl))
MOM6/examples/resting/z/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/resting/z/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/resting/z/$(fl))

MOM6/examples/sloshing/%/timestats.$(COMPILER): NPES=2
MOM6/examples/sloshing/layer/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/sloshing/layer/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/sloshing/layer/$(fl))
MOM6/examples/sloshing/rho/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/sloshing/rho/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/sloshing/rho/$(fl))

MOM6/examples/flow_downslope/%/timestats.$(COMPILER): NPES=2
MOM6/examples/flow_downslope/layer/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/flow_downslope/layer/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/flow_downslope/layer/$(fl))
MOM6/examples/flow_downslope/z/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/flow_downslope/z/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/flow_downslope/z/$(fl))
MOM6/examples/flow_downslope/rho/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/flow_downslope/rho/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/flow_downslope/rho/$(fl))
MOM6/examples/flow_downslope/sigma/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/flow_downslope/sigma/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/flow_downslope/sigma/$(fl))
MOM6/examples/flow_downslope/rho/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6

MOM6/examples/seamount/%/timestats.$(COMPILER): NPES=2
MOM6/examples/seamount/layer/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/seamount/layer/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/seamount/layer/$(fl))
MOM6/examples/seamount/z/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/seamount/z/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/seamount/z/$(fl))
MOM6/examples/seamount/sigma/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/seamount/sigma/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/seamount/sigma/$(fl))

MOM6/examples/external_gwave/timestats.$(COMPILER): NPES=2
MOM6/examples/external_gwave/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/external_gwave/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/external_gwave/$(fl))

MOM6/examples/global/timestats.$(COMPILER): NPES=64
MOM6/examples/global/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/global/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/global/$(fl))

MOM6/examples/global_ALE/layer/timestats.$(COMPILER): NPES=64
MOM6/examples/global_ALE/layer/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/global_ALE/layer/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/global_ALE/layer/$(fl))

MOM6/examples/global_ALE/z/timestats.$(COMPILER): NPES=64
MOM6/examples/global_ALE/z/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/global_ALE/z/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/global_ALE/z/$(fl))

MOM6/examples/nonBous_global/timestats.$(COMPILER): NPES=64
MOM6/examples/nonBous_global/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/nonBous_global/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/nonBous_global/$(fl))

MOM6/examples/Phillips_2layer/timestats.$(COMPILER): NPES=64
MOM6/examples/Phillips_2layer/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/Phillips_2layer/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/Phillips_2layer/$(fl))

MOM6/examples/MESO_025_23L/timestats.$(COMPILER): NPES=288
MOM6/examples/MESO_025_23L/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/MESO_025_23L/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/MESO_025_23L/$(fl))

#MOM6/examples/MESO_025_63L/timestats.$(COMPILER): NPES=96
MOM6/examples/MESO_025_63L/timestats.$(COMPILER): NPES=288
MOM6/examples/MESO_025_63L/timestats.$(COMPILER): build/solo.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/MESO_025_63L/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/MESO_025_63L/$(fl))

MOM6/examples/GOLD_SIS/timestats.$(COMPILER): NPES=60
MOM6/examples/GOLD_SIS/timestats.$(COMPILER): build/MOM6_SIS.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/GOLD_SIS/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/GOLD_SIS/$(fl))

MOM6/examples/GOLD_SIS_icebergs/timestats.$(COMPILER): NPES=60
MOM6/examples/GOLD_SIS_icebergs/timestats.$(COMPILER): build/MOM6_SIS.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/GOLD_SIS_icebergs/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/GOLD_SIS_icebergs/$(fl))

MOM6/examples/GOLD_SIS_025/timestats.$(COMPILER): NPES=1024
MOM6/examples/GOLD_SIS_025/timestats.$(COMPILER): build/MOM6_SIS.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/GOLD_SIS_025/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/GOLD_SIS_025/$(fl))

MOM6/examples/SIS2/timestats.$(COMPILER): NPES=60
MOM6/examples/SIS2/timestats.$(COMPILER): build/SIS2.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/SIS2/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/SIS2/$(fl))

MOM6/examples/SIS2_icebergs/timestats.$(COMPILER): NPES=60
MOM6/examples/SIS2_icebergs/timestats.$(COMPILER): build/SIS2.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/SIS2_icebergs/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/SIS2_icebergs/$(fl))

MOM6/examples/CM2.2/timestats.$(COMPILER): NPES=90
MOM6/examples/CM2.2/timestats.$(COMPILER): build/CM2G.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/CM2.2/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/CM2.2/$(fl))

MOM6/examples/CM2G63L/timestats.$(COMPILER): NPES=90
MOM6/examples/CM2G63L/timestats.$(COMPILER): build/CM2G.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/CM2G63L/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/CM2G63L/$(fl))

MOM6/examples/AM2_MOM6i_1deg/timestats.$(COMPILER): NPES=90
MOM6/examples/AM2_MOM6i_1deg/timestats.$(COMPILER): build/CM2G.$(COMPILER).$(EXEC_MODE)/MOM6
MOM6/examples/AM2_MOM6i_1deg/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/AM2_MOM6i_1deg/$(fl))

MOM6/examples/CM2Gfixed/timestats.$(COMPILER): NPES=120
MOM6/examples/CM2Gfixed/timestats.$(COMPILER): build/CM2G/MOM6 MOM6/examples/AM2_MOM6i_1deg/MOM_input MOM6/examples/CM2Gfixed/input.nml
MOM6/examples/CM2Gfixed/timestats.$(COMPILER): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/CM2Gfixed/$(fl))
	@echo; echo Running $(dir $@)
	dmget /archive/gold/datasets/CM2G/perth/INPUT/*
	(cd $(dir $@); mkdir -p INPUT; cd INPUT; $(CP) /archive/gold/datasets/CM2G/perth/INPUT/* .)
	dmget /archive/gold/datasets/CM2G/perth/mosaic.mica2.unpacked/*
	(cd $(dir $@); cd INPUT; $(CP) /archive/gold/datasets/CM2G/perth/mosaic.mica2.unpacked/* .)
	dmget /archive/gold/datasets/CM2G/perth/RESTART/CM2G.initCond_2008.06.04.unpacked/*
	(cd $(dir $@); cd INPUT ; $(CP) /archive/gold/datasets/CM2G/perth/RESTART/CM2G.initCond_2008.06.04.unpacked/* .)
	-cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
	(cd $(dir $@); rm -f timestats; (aprun -np $(NPES) ../../../$< > std.out) |& tee stderr.out)

# Rule to run all executables
%/timestats.$(COMPILER):
	@echo; echo Running in $(dir $@) with $<
	@cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
	@rm -f $(dir $@)Depth_list.nc
	set rdir=$$cwd; (cd $(dir $@); rm -f timestats.$(COMPILER); setenv OMP_NUM_THREADS 1; (aprun -n $(NPES) $$rdir/$< > std.out) |& tee stderr.out)
	@mv $(dir $@)std.out $(dir $@)std.$(COMPILER).out
	@mv $(dir $@)timestats $@
	@cd $(dir $@); git status -s timestats.$(COMPILER)
#	set rdir=$$cwd; (cd $(dir $@); rm -f timestats.$(COMPILER); setenv F_UFMTENDIAN big; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_UNEX_BUFFER_SIZE 122914560; (aprun -n $(NPES) $$rdir/$< > std.out) |& tee stderr.out)
##(cd $(dir $@); rm -f timestats.$(COMPILER); setenv F_UFMTENDIAN big; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_UNEX_BUFFER_SIZE 122914560; (aprun -n $(NPES) ../../../$< > std.out) |& tee stderr.out)
## cd $(dir $@); rm -f timestats.$(COMPILER); setenv F_UFMTENDIAN big; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; (aprun -n $(NPES) ../../../$< > std.out) |& tee stderr.out
## cd $(dir $@); rm -f timestats; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; (aprun -n $(NPES) ../../../$< > std.out) |& tee stderr.out

# Rules to do some performance tests using benchmark
benchmark: $(foreach n,48 96 144 192 216 240 288 384 480 576,MOM6/examples/benchmark/c1ms.$(COMPILER).360x180x22-n$(n).rank)
benchmark: $(foreach n,24 48 72 96 144 192 216 240 288 384 480 576,MOM6/examples/benchmark/c1ms.$(COMPILER).360x180x22-n$(n).norank)
MOM6/examples/benchmark/%.norank MOM6/examples/benchmark/%.rank: SHRTHOST=$(word 1,$(subst -batch, ,$(HOST)))
MOM6/examples/benchmark/%.norank MOM6/examples/benchmark/%.rank: PARTS=$(shell echo $(*F) | sed 's/\([a-zA-Z0-9]*\)\.\([a-zA-Z0-9]*\)\.\([0-9]*x[0-9]*x[0-9]*\)\(.*\)/\1 \2 \3 \4/')
MOM6/examples/benchmark/%.norank MOM6/examples/benchmark/%.rank: COMPILER=$(word 2,$(PARTS))
MOM6/examples/benchmark/%.norank MOM6/examples/benchmark/%.rank: APARGS=$(shell echo $(word 4,$(PARTS)) | sed 's/-/ -/g' | sed 's/\(-[a-zA-Z]\)\([0-9][0-9]*\)/\1 \2/g')
MOM6/examples/benchmark/%.norank: build/solo.$(COMPILER).prod/MOM6
	make build/solo.$(COMPILER).prod/MOM6
	-cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
	(cd $(@D); setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; aprun $(APARGS) ../../../build/solo.$(COMPILER).prod/MOM6 >& std.out)
	mv MOM6/examples/benchmark/std.out $@
MOM6/examples/benchmark/%.rank: NORANK=$(subst .rank,.norank,$@)
MOM6/examples/benchmark/%.rank: PES=$(shell echo $(word 4,$(PARTS))| sed 's/.*-n\([0-9][0-9]*\).*/\1/')
MOM6/examples/benchmark/%.rank: MOM6/examples/benchmark/%.norank
	make $(NORANK)
	@echo cp *3*=`awk /X-AX/,/Y-AX/ $(NORANK) | grep -v "Y-AX" | sed 's/.*=//' | wc -w`x`fgrep "Y-AX" $(NORANK) | sed 's/.*=//' | wc -w`=$(PES) $(@D)/MPICH_RANK_ORDER
	@cp *3*=`awk /X-AX/,/Y-AX/ $(NORANK) | grep -v "Y-AX" | sed 's/.*=//' | wc -w`x`fgrep "Y-AX" $(NORANK) | sed 's/.*=//' | wc -w`=$(PES) $(@D)/MPICH_RANK_ORDER
	-cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
	(cd $(@D); setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; setenv MPICH_RANK_REORDER_METHOD 3; aprun $(APARGS) ../../../build/solo.$(COMPILER).prod/MOM6 >& std.out)
	rm $(@D)/MPICH_RANK_ORDER
	mv MOM6/examples/benchmark/std.out $@

#@cp *3*=`fgrep "X-AX" $(NORANK) | sed 's/.*=//' | wc -w`x`fgrep "Y-AX" $(NORANK) | sed 's/.*=//' | wc -w`=$(PES) $(@D)/MPICH_RANK_ORDER
