# ALE_EXPTS and SOLO_EXPTS are ocean-only experiments using the ocean_only executable.
# SIS_EXPTS use the ice_ocean_SIS executable.
# SIS2_EXPTS use the ice_ocean_SIS2 executable.
# AM2_LM3_SIS_EXPTS use the coupled_AM2_LM3_SIS executable.
# AM2_LM3_SIS2_EXPTS use the coupled_AM2_LM3_SIS2 executable.
ALE_EXPTS=$(foreach dir, \
          resting/z \
          single_column/KPP single_column/EPBL \
          sloshing/rho sloshing/z \
          SCM_idealized_hurricane \
          CVmix_SCM_tests/mech_only/KPP CVmix_SCM_tests/wind_only/KPP \
          CVmix_SCM_tests/skin_warming_wind/KPP CVmix_SCM_tests/cooling_only/KPP \
          CVmix_SCM_tests/mech_only/EPBL CVmix_SCM_tests/wind_only/EPBL \
          CVmix_SCM_tests/skin_warming_wind/EPBL CVmix_SCM_tests/cooling_only/EPBL \
          adjustment2d/z adjustment2d/rho \
          seamount/z seamount/sigma \
          flow_downslope/z flow_downslope/rho flow_downslope/sigma \
          global_ALE/z global_ALE/hycom \
          mixed_layer_restrat_2d \
          ,ocean_only/$(dir))

SOLO_EXPTS=$(foreach dir, \
          resting/layer \
          CVmix_SCM_tests/mech_only/BML CVmix_SCM_tests/wind_only/BML \
          CVmix_SCM_tests/skin_warming_wind/BML CVmix_SCM_tests/cooling_only/BML \
          torus_advection_test lock_exchange external_gwave single_column/BML \
          sloshing/layer adjustment2d/layer seamount/layer flow_downslope/layer global_ALE/layer \
          double_gyre DOME benchmark global nonBous_global Phillips_2layer \
          ,ocean_only/$(dir))

SOLO_EXPTS+=ocean_only/MESO_025_63L
SYMMETRIC_EXPTS=ocean_only/circle_obcs
SIS_EXPTS=$(foreach dir,GOLD_SIS GOLD_SIS_icebergs,ice_ocean_SIS/$(dir))
#SIS_EXPTS+=ice_ocean_SIS/GOLD_SIS_025
SIS2_EXPTS=$(foreach dir,Baltic SIS2 SIS2_icebergs SIS2_cgrid SIS2_bergs_cgrid OM4_025,ice_ocean_SIS2/$(dir))
#SIS2_EXPTS+=$(foreach dir,SIS2 SIS2_icebergs_1 SIS2_icebergs_2 SIS2_icebergs_layout,ice_ocean_SIS2/$(dir))
AM2_LM3_SIS_EXPTS=$(foreach dir,CM2G63L AM2_MOM6i_1deg,coupled_AM2_LM3_SIS/$(dir))
AM2_LM3_SIS2_EXPTS=$(foreach dir,AM2_SIS2B_MOM6i_1deg AM2_SIS2_MOM6i_1deg,coupled_AM2_LM3_SIS2/$(dir))
EXPTS=$(ALE_EXPTS) $(SOLO_EXPTS) $(SYMMETRIC_EXPTS) $(SIS_EXPTS) $(SIS2_EXPTS) $(AM2_LM3_SIS_EXPTS) $(AM2_LM3_SIS2_EXPTS)
EXPT_EXECS=ocean_only symmetric_ocean_only ice_ocean_SIS ice_ocean_SIS2 coupled_AM2_LM3_SIS coupled_AM2_LM3_SIS2 # Executable/model configurations to build

# Name of MOM6-examples directory
MOM6_EXAMPLES=MOM6-examples
# Name of FMS/shared directory
FMS=$(MOM6_EXAMPLES)/src/FMS
# Name of MOM6 directory
MOM6=$(MOM6_EXAMPLES)/src/MOM6
# Location for extras components
EXTRAS=$(MOM6_EXAMPLES)/src
# Name of SIS1 directory
SIS1=$(EXTRAS)/SIS
# Name of SIS2 directory
SIS2=$(MOM6_EXAMPLES)/src/SIS2
# Name of icebergs directory
ICEBERGS=$(MOM6_EXAMPLES)/src/icebergs
# Name of LM3 directory
LM3=$(EXTRAS)/LM3
# Name of AM2 directory
AM2=$(EXTRAS)/AM2
AM2_REPOS=$(AM2)/atmos_drivers $(AM2)/atmos_fv_dynamics $(AM2)/atmos_shared
AM2_MODULES=$(AM2)/atmos_drivers/coupled $(AM2)/atmos_fv_dynamics/driver/coupled $(AM2)/atmos_fv_dynamics/model $(AM2)/atmos_fv_dynamics/tools $(AM2)/atmos_shared $(ATMOS_PARAM)
# Name of coupler directory
COUPLER=$(EXTRAS)/coupler
# Name of coupler directory
ICE_PARAM=$(EXTRAS)/ice_param
# Name of atmos_null directory
ATMOS_NULL=$(EXTRAS)/atmos_null
# Name of atmos_param directory
ATMOS_PARAM=$(EXTRAS)/atmos_param
# Name of land_null directory
LAND_NULL=$(EXTRAS)/land_null
# Name of ice_ocean_extras directory (which is in MOM6-examples and is not a module)
ICE_OCEAN_EXTRAS=$(MOM6_EXAMPLES)/src/ice_ocean_extras
# Location to build
BUILD_DIR=$(MOM6_EXAMPLES)/build
#BUILD_DIR=$(MOM6_EXAMPLES)/build-openmp
#BUILD_DIR=$(MOM6_EXAMPLES)/build-intel15
# MKMF package
MKMF_DIR=$(BUILD_DIR)/mkmf
# Location of bin scripts
BIN_DIR=$(MKMF_DIR)/bin
# Location of site templats
TEMPLATE_DIR=$(MKMF_DIR)/templates
# Relative path from compile directory to top
REL_PATH=../../../../..

#CPPDEFS="-Duse_libMPI -Duse_netCDF -Duse_LARGEFILE -DSPMD -Duse_shared_pointers -Duse_SGI_GSM -DLAND_BND_TRACERS"
CPPDEFS="-DSPMD -DLAND_BND_TRACERS"
CPPDEFS="-Duse_libMPI -Duse_netCDF"
CPPDEFS="-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS"
CPPDEFS='-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS -D_FILE_VERSION="`$(REL_PATH)/$(BIN_DIR)/git-version-string $$<`"'
CPPDEFS='-Duse_libMPI -Duse_netCDF -DSPMD -DUSE_LOG_DIAG_FIELD_INFO -D_FILE_VERSION="`$(REL_PATH)/$(BIN_DIR)/git-version-string $$<`"'
# SITE can be ncrc, hpcs, doe, linux
SITE=ncrc
# MPIRUN can be aprun or mpirun
MPIRUN=aprun
# MAKEMODE can have either NETCDF=3, NETCDF=4 or OPENMP=1
MAKEMODE=NETCDF=4 OPENMP=1
MAKEMODE=NETCDF=3 OPENMP=1
MAKEMODE=NETCDF=4
MAKEMODE=NETCDF=3
MODES=repro prod debug
COMPILERS=intel pathscale pgi cray gnu
COMPILERS=gnu intel pgi

# Version of code
MOM6_tag=dev/master
SIS2_tag=dev/master
FMS_tag=ulm_201510
LM3_tag=ulm

# Default compiler configuration
EXEC_MODE=repro
TEMPLATE=$(TEMPLATE_DIR)/$(SITE)-$(COMPILER).mk
NPES=2
PMAKEOPTS=-l 12.0 -j 12
PMAKEOPTS=-j

TIMESTATS=timestats
STATS_FILES=$(foreach dir,$(EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
STDERR_LABEL=out
# .SECONDARY stops deletiong of targets that were built implicitly
.SECONDARY:

MV=\mv
RM=\rm
SHELL=tcsh

# The "all" target depends on which set of nodes we are on...
ifeq ($(findstring $(HOST),$(foreach n,1 2 3 4 5 6 7 8 9,c1-batch$(n))),$(HOST))
ALLMESG=On batch nodes: building executables, running experiments
ALLTARGS=ale solo symmetric sis sis2 am2_sis am2_sis2
else
ALLMESG=On login nodes: building executables, reporting status
ALLTARGS=$(EXEC_MODE) status
endif
all:
	@echo HOST = $(HOST)
	@echo $(ALLMESG)
	@echo targets = $(ALLTARGS)
	@time make $(ALLTARGS)
ALL:
	make gnu
	make intel
	make pgi

buildall: $(MODES)
repro: $(foreach exec,$(EXPT_EXECS),$(BUILD_DIR)/$(COMPILER)/$(exec)/repro/MOM6)
debug: $(BUILD_DIR)/$(COMPILER)/shared/debug/libfms.a $(foreach exec,$(EXPT_EXECS),$(BUILD_DIR)/$(COMPILER)/$(exec)/debug/MOM6)
prod: $(foreach exec,$(EXPT_EXECS),$(BUILD_DIR)/$(exec).$(COMPILER).prod/MOM6)
ale: $(BUILD_DIR)/$(COMPILER)/ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
solo: $(BUILD_DIR)/$(COMPILER)/ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(SOLO_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
symmetric: $(BUILD_DIR)/$(COMPILER)/symmetric_ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
sis: $(BUILD_DIR)/$(COMPILER)/ice_ocean_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
sis2: $(BUILD_DIR)/$(COMPILER)/ice_ocean_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
am2_sis: $(BUILD_DIR)/$(COMPILER)/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
am2_sis2: $(BUILD_DIR)/$(COMPILER)/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).$(COMPILER))
Ale:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) ale;)
Solo:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) solo;)
Sis:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) sis;)
Sis2:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) sis2;)
Coupled:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) am2_sis am2_sis2;)
All:
	make Ale Solo
	make Sis Sis2
	$(foreach comp,$(COMPILERS),make $(comp);)
intel: $(BUILD_DIR)/intel/env
	make COMPILER=intel
pathscale: $(BUILD_DIR)/pathscale/env
	make COMPILER=pathscale
pgi: $(BUILD_DIR)/pgi/env
	make COMPILER=pgi
cray: $(BUILD_DIR)/cray/env
	make COMPILER=cray
gnu: $(BUILD_DIR)/gnu/env
	make COMPILER=gnu
help:
	@echo 'Typical targets:'
	@echo ' make help     - this message'
	@echo ' make checkout - checkout source code                     ** LOGIN nodes only **'
	@echo ' make buildall - compile executables for each of the configurations'
	@echo '                 listed in the MODES variable'
	@echo
	@echo 'Other complex targest:'
	@echo ' make gnu       - same as "all" with COMPILER=gnu'
	@echo ' make intel     - same as "all" with COMPILER=intel'
	@echo ' make pgi       - same as "all" with COMPILER=pgi'
	@echo ' make pathscale - same as "all" with COMPILER=pathscale'
	@echo ' make repro     - build the repro executables for all compilers'
	@echo ' make debug     - build the debug executables for all compilers'
	@echo ' make prod      - build the prod executables for all compilers'
	@echo ' make solo      - build/run the solo experiments'
	@echo ' make ale       - build/run the ALE experiments'
	@echo ' make sis       - build/run the GOLD_SIS experiments'
	@echo ' make sis2      - build/run the GOLD_SIS experiments'
	@echo ' make coupled   - build/run the coupled CM2G3L experiments'
	@echo ' make status    - check git status of expts list in EXPTS variable'
	@echo ' make cleancore - cleans up core dumps and truncation files'
	@echo ' make doxMOM6   - generates doxygen html files in src/MOM6/html'
	@echo ' make all'
	@echo ' make force'
	@echo ' make clean'
	@echo ' make buildall - do "build" for all compilers'
	@echo ' make COMPILER=pathscale   (or gnu, pgi, or intel)'
	@echo ' make EXEC_MODE=debug      (or prod, or repro)'
	@echo ' make all      - Used in conjunction with COMPILER macro.'
	@echo '               - On login nodes, install data, build the repro executables'
	@echo '                 and check git status of stats files'
	@echo '               - On batch nodes, build the repro executables and run'
	@echo '                 executables for any out-of-date stats files'
	@echo 'Specific targets:                                         ** BATCH nodes only **\n' $(foreach dir,$(EXPTS),'make $(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS)\n')
status: # Check git status of $(STATS_FILES)
	@cd $(MOM6_EXAMPLES); git status -- $(subst $(MOM6_EXAMPLES)/,,$(STATS_FILES))
	@echo ==================================================================
	@cd $(MOM6_EXAMPLES); git status -s -- $(subst $(MOM6_EXAMPLES)/,,$(STATS_FILES))
	@find $(MOM6_EXAMPLES)/ -name stderr.out -exec grep -H 'WARNING' {} \;
	@find $(MOM6_EXAMPLES)/ -name stderr.out -exec grep -H 'diag_util_mod::opening_file' {} \;
force: cleanstats
	@make all
cleanstats:
	$(RM) -f $(STATS_FILES)
clean:
	@$(foreach dir,$(wildcard $(BUILD_DIR)/*), (cd $(dir); make clean); )
	find $(BUILD_DIR)/* -type l -exec $(RM) {} \;
	find $(BUILD_DIR)/* -name '*.mod' -exec $(RM) {} \;
Clean: clean cleancore
	-$(RM) -f $(MOM6_EXAMPLES)/{*,*/*,*/*/*}/*.nc.*
	-$(RM) -f $(MOM6_EXAMPLES)/{*,*/*,*/*/*}/*.{nc,out}
	-$(RM) -rf $(MOM6_EXAMPLES)/{*,*/*}/RESTART
	-$(RM) -f $(MOM6_EXAMPLES)/{*,*/*}/{fort.*,*.nml,$(TIMESTATS),CPU_stats,exitcode,available_diags.*}
cleancore:
	-find $(MOM6_EXAMPLES)/ -name core -type f -exec $(RM) {} \;
	-find $(MOM6_EXAMPLES)/ -name "*truncations" -type f -exec $(RM) {} \;
backup: Clean
	tar zcvf ~/MOM6_backup.tgz MOM6
sync:
	rsync -rtvim --exclude RESTART/ --exclude tools/ --exclude build/ --include '*/' --include \*.nc --exclude \* $(EXPT)/ gfdl:/local2/home/workspace/$(EXPT)/
doxMOM6: MOM6-examples/src/MOM6/html/index.html
MOM6-examples/src/MOM6/html/index.html: MOM6-examples/src/MOM6/doxygen $(MOM6)/config_src/*/* $(MOM6)/src/*/* $(MOM6)/src/*/*/*
	(cd $(<D); ./doxygen/bin/doxygen .doxygen)
MOM6-examples/src/MOM6/doxygen:
	(cd $(@D); git clone https://github.com/doxygen/doxygen)
	(cd $(@); ./configure)
	(cd $(@); make)

# This section defines how to checkout and layout the source code
checkout: $(MOM6_EXAMPLES) $(ICE_PARAM) $(ATMOS_PARAM) $(SIS1) $(LM3) $(AM2_REPOS) $(MKMF_DIR) $(TEMPLATE_DIR) $(BIN_DIR) $(MOM6_EXAMPLES)/.datasets
status_extras: $(ICE_PARAM) $(ATMOS_PARAM) $(SIS1) $(AM2_REPOS)
	echo $^ | tr ' ' '\n' | xargs -I dir sh -c 'cd dir; git fetch'
	echo $^ | tr ' ' '\n' | xargs -I dir sh -c 'cd dir; echo Status in dir; git status'
remote_extras: $(ICE_PARAM) $(ATMOS_PARAM) $(SIS1) $(AM2_REPOS)
	echo $^ | tr ' ' '\n' | xargs -I dir sh -c 'cd dir; echo Remote for dir:; git remote -v'
update_extras: $(ICE_PARAM) $(ATMOS_PARAM) $(SIS1) $(AM2_REPOS)
	echo $^ | tr ' ' '\n' | xargs -I dir sh -c 'cd dir; git fetch'
	echo $^ | tr ' ' '\n' | xargs -I dir sh -c 'cd dir; echo Updating dir; git checkout $(FMS_tag)'
checkout_minimal:
	git clone git@github.com:adcroft/MOM6-examples.git
	(cd $(MOM6_EXAMPLES); git submodule init)
	(cd $(MOM6_EXAMPLES); git submodule update src/FMS)
	(cd $(MOM6_EXAMPLES); git submodule update src/MOM6)
	(cd $(MOM6_EXAMPLES)/src/MOM6; git submodule init)
	(cd $(MOM6_EXAMPLES)/src/MOM6; git submodule update)
	make $(MKMF_DIR)
$(MOM6_EXAMPLES) $(FMS) (SIS2) $(COUPLER) $(ATMOS_NULL) $(LAND_NULL):
	git clone --recursive git@github.com:NOAA-GFDL/MOM6-examples.git $(MOM6_EXAMPLES)
	(cd $(MOM6_EXAMPLES); git submodule init)
	(cd $(MOM6_EXAMPLES); git submodule update)
	(cd $(MOM6_EXAMPLES)/src/MOM6; git checkout $(MOM6_tag))
	(cd $(MOM6_EXAMPLES)/src/SIS2; git checkout $(SIS2_tag))
$(EXTRAS) $(AM2):
	mkdir -p $@
$(ICE_PARAM) $(ATMOS_PARAM) $(AM2_REPOS): | $(EXTRAS)
	(cd $(@D); git clone http://gitlab.gfdl.noaa.gov/fms/$(@F).git)
	(cd $@; git checkout $(FMS_tag))
$(SIS1): | $(EXTRAS)
	(cd $(@D); git clone http://gitlab.gfdl.noaa.gov/fms/ice_sis.git $(@F))
	(cd $@; git checkout $(FMS_tag))
$(LM3): | $(EXTRAS)
	mkdir -p $@
	(cd $@; git clone http://gitlab.gfdl.noaa.gov/fms/land_param.git)
	(cd $@/land_param; git checkout $(LM3_tag))
	(cd $@; git clone http://gitlab.gfdl.noaa.gov/fms/land_lad2.git)
	(cd $@/land_lad2; git checkout $(LM3_tag))
	make cppLM3
cppLM3: $(LM3)
	find $(LM3)/land_lad2 -type f -name \*.F90 -exec cpp -Dintel14_bug -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE -C -v -I $(FMS)/include -o '{}'.cpp {} \;
	find $(LM3)/land_lad2 -type f -name \*.F90.cpp -exec rename .F90.cpp .f90 {} \;
	mkdir -p $(LM3)/land_lad2_cpp
	find $(LM3)/land_lad2 -type f -name \*.f90 -exec mv {} $(LM3)/land_lad2_cpp/ \;
$(AM2_REPOS): | $(AM2)
$(MKMF_DIR):
	mkdir -p $(@D)
	(cd $(@D); git clone git@github.com:NOAA-GFDL/mkmf.git)
$(BIN_DIR) $(TEMPLATE_DIR): $(MKMF_DIR)
$(MOM6_EXAMPLES)/.datasets: /lustre/f1/pdata/gfdl_O/datasets
	(cd $(@D); ln -s $< $(@F))
wiki: wiki.MOM6-examples wiki.MOM6
wiki.MOM6-examples:
	git clone git@github.com:NOAA-GFDL/MOM6-examples.wiki.git wiki.MOM6-examples
wiki.MOM6:
	git clone git@github.com:NOAA-GFDL/MOM6.wiki.git wiki.MOM6

# Rules for building executables ###############################################
# Choose the compiler based on the build directory
$(BUILD_DIR)/gnu/%/MOM6 $(BUILD_DIR)/gnu/%/libfms.a: COMPILER=gnu
$(BUILD_DIR)/intel/%/MOM6 $(BUILD_DIR)/intel/%/libfms.a: COMPILER=intel
$(BUILD_DIR)/pgi/%/MOM6 $(BUILD_DIR)/pgi/%/libfms.a: COMPILER=pgi
# Set REPRO and DEBUG variables based on the build directory
%/prod/MOM6 %/prod/libfms.a: EXEC_MODE=prod
%/repro/MOM6 %/repro/libfms.a: EXEC_MODE=repro
%/debug/MOM6 %/debug/libfms.a: EXEC_MODE=debug
%/repro/libfms.a %/repro/MOM6: MAKEMODE+=REPRO=1
%/debug/libfms.a %/debug/MOM6: MAKEMODE+=DEBUG=1
# env
$(foreach mode,$(MODES),$(BUILD_DIR)/gnu/shared/$(mode)/libfms.a): $(BUILD_DIR)/gnu/env
$(foreach mode,$(MODES),$(BUILD_DIR)/intel/shared/$(mode)/libfms.a): $(BUILD_DIR)/intel/env
$(foreach mode,$(MODES),$(BUILD_DIR)/pgi/shared/$(mode)/libfms.a): $(BUILD_DIR)/pgi/env

# Create module scripts
envs: $(foreach cmp,$(COMPILERS),$(BUILD_DIR)/$(cmp)/env)
$(BUILD_DIR)/pgi/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-pgi >> $@
	@echo module load netcdf/4.2.0 >> $@
$(BUILD_DIR)/pathscale/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-pathscale >> $@
	@echo module load netcdf/4.2.0 >> $@
$(BUILD_DIR)/intel/env:
	mkdir -p $(dir $@)
	@echo Building $@
ifeq ($(SITE),linux)
	@echo module load ifort/11.1.073 > $@
	@echo module load intel_compilers >>$@
	@echo module use /home/sdu/publicmodules >>$@
	@echo module load netcdf/4.2 >>$@
	@echo module load mpich2/1.5b1 >>$@
else
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-intel/4.0.46 >> $@
	@echo module switch intel intel/12.0.5.220 >> $@
	@echo module load netcdf/4.2.0 >> $@
endif
$(BUILD_DIR)-intel15/intel/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-intel/4.0.46 >> $@
	@echo module switch intel intel/15.0.2.164 >> $@
	@echo module load netcdf/4.2.0 >> $@
# use with make BUILD_DIR=MOM6-examples/build-intel14 intel
$(BUILD_DIR)-intel14/intel/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-intel/5.2.40 >> $@
	@echo module switch intel intel/14.0.2.144 >> $@
	@echo module load netcdf/4.3.0 >> $@
$(BUILD_DIR)/cray/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-cray >> $@
	@echo module load netcdf/4.2.0 >> $@
$(BUILD_DIR)/gnu/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-gnu >> $@
	@echo module load netcdf/4.2.0 >> $@

# Canned rule to run all executables
define build_mom6_executable
@echo; echo Building $@
@echo SRCPTH="$(SRCPTH)"
@echo MAKEMODE=$(MAKEMODE)
@echo EXEC_MODE=$(EXEC_MODE)
mkdir -p $(dir $@)
(cd $(dir $@); $(RM) -f path_names; $(REL_PATH)/$(BIN_DIR)/list_paths ./ $(foreach dir,$(SRCPTH),$(REL_PATH)/$(dir)))
(cd $(dir $@); $(REL_PATH)/$(BIN_DIR)/mkmf -t $(REL_PATH)/$(TEMPLATE) -o '-I../../shared/$(EXEC_MODE)' -p 'MOM6 -L../../shared/$(EXEC_MODE) -lfms' -c $(CPPDEFS) path_names )
(cd $(dir $@); $(RM) -f MOM6)
(cd $(dir $@); source ../../env; make $(MAKEMODE) $(PMAKEOPTS) MOM6)
endef

# solo executable
SOLO_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/solo_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ocean_only/$(mode)/MOM6): SRCPTH=$(SOLO_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ocean_only/$(mode)/MOM6): $(foreach dir,$(SOLO_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# Symmetric executable
SOLOSYM_PTH=$(MOM6)/config_src/dynamic_symmetric $(MOM6)/config_src/solo_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/
$(foreach mode,$(MODES),$(BUILD_DIR)/%/symmetric_ocean_only/$(mode)/MOM6): SRCPTH=$(SOLOSYM_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/symmetric_ocean_only/$(mode)/MOM6): $(foreach dir,$(SOLOSYM_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# SIS executable
SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(ICE_OCEAN_EXTRAS) $(COUPLER) $(LAND_NULL) $(SIS1) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS/$(mode)/MOM6): SRCPTH=$(SIS_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS/$(mode)/MOM6): $(foreach dir,$(SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# SIS2 executable
SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(ICE_OCEAN_EXTRAS) $(COUPLER) $(LAND_NULL) $(SIS2) $(ICEBERGS) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS2/$(mode)/MOM6): SRCPTH=$(SIS2_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS2/$(mode)/MOM6): $(foreach dir,$(SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM2+LM3+SIS executable
AM2_LM3_SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(COUPLER) $(ICE_PARAM) $(SIS1) $(LM3)/{land_param,land_lad2_cpp}/ $(AM2_MODULES) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): $(foreach dir,$(AM2_LM3_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM2+LM3+SIS2 executable
AM2_LM3_SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(COUPLER) $(ICE_PARAM) $(SIS2) $(ICEBERGS) $(LM3)/{land_param,land_lad2_cpp}/ $(AM2_MODULES) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS2_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): $(foreach dir,$(AM2_LM3_SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# LM3+SIS2 executable
LM3_SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(COUPLER) $(ICE_OCEAN_EXTRAS) $(SIS2) $(ICEBERGS) $(LM3)/{land_param,land_lad2_cpp}/ $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_LM3_SIS2/$(mode)/MOM6): SRCPTH=$(LM3_SIS2_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_LM3_SIS2/$(mode)/MOM6): $(foreach dir,$(LM3_SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM4+LM3+SIS executable
AM4_LM3_SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(COUPLER) $(ICE_PARAM) $(EXTRAS)/AM4 $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM4_LM3_SIS/$(mode)/MOM6): SRCPTH=$(AM4_LM3_SIS_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM4_LM3_SIS/$(mode)/MOM6): $(foreach dir,$(AM4_LM3_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# Static global executable
STATIC_GLOBAL_PTH=$(MOM6)/examples/ocean_only/global $(MOM6)/config_src/solo_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/
$(foreach mode,$(MODES),$(BUILD_DIR)/%/STATIC_global/$(mode)/MOM6): SRCPTH=$(STATIC_GLOBAL_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/STATIC_global/$(mode)/MOM6): $(foreach dir,$(STATIC_GLOBAL_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# Static SIS executable
STATIC_SIS_PTH=$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(COUPLER) $(LAND_NULL) $(ICE_PARAM) $(SIS1) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/STATIC_GOLD_SIS/$(mode)/MOM6): SRCPTH=$(STATIC_SIS_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/STATIC_GOLD_SIS/$(mode)/MOM6): $(foreach dir,$(STATIC_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# libfms.a
$(foreach cmp,$(COMPILERS),$(foreach mode,$(MODES),$(BUILD_DIR)/$(cmp)/shared/$(mode)/libfms.a)): $(foreach dir,$(FMS)/* $(FMS)/*/*,$(wildcard $(dir)/*.F90 $(dir)/*.h))
	@echo; echo Building $@
	@mkdir -p $(dir $@)
	@echo MAKEMODE=$(MAKEMODE)
	@echo EXEC_MODE=$(EXEC_MODE)
	(cd $(dir $@); $(RM) path_names; $(REL_PATH)/$(BIN_DIR)/list_paths $(REL_PATH)/$(FMS))
	(cd $(dir $@); $(REL_PATH)/$(BIN_DIR)/mkmf -t $(REL_PATH)/$(TEMPLATE) -p libfms.a -c $(CPPDEFS) path_names)
	(cd $(dir $@); $(RM) -f libfms.a)
	(cd $(dir $@); source ../../env; make $(MAKEMODE) $(PMAKEOPTS) libfms.a)
#(cd $(dir $@); $(MV) path_names path_names.orig; egrep -v "atmos_ocean_fluxes|coupler_types|coupler_util" path_names.orig > path_names)

# Rules to associated an executable to each experiment #########################
# (implemented by makeing the executable the FIRST pre-requisite)
$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).gnu): $(BUILD_DIR)/gnu/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).gnu): $(BUILD_DIR)/gnu/symmetric_ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).gnu): $(BUILD_DIR)/gnu/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).gnu): $(BUILD_DIR)/gnu/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).gnu): $(BUILD_DIR)/gnu/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).gnu): $(BUILD_DIR)/gnu/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).intel): $(BUILD_DIR)/intel/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).intel): $(BUILD_DIR)/intel/symmetric_ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).intel): $(BUILD_DIR)/intel/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).intel): $(BUILD_DIR)/intel/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).intel): $(BUILD_DIR)/intel/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).intel): $(BUILD_DIR)/intel/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).pgi): $(BUILD_DIR)/pgi/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).pgi): $(BUILD_DIR)/pgi/symmetric_ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).pgi): $(BUILD_DIR)/pgi/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).pgi): $(BUILD_DIR)/pgi/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).pgi): $(BUILD_DIR)/pgi/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/$(TIMESTATS).pgi): $(BUILD_DIR)/pgi/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

# Rules for configuring and running experiments ################################
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/unit_tests/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/unit_tests/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/unit_tests/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/torus_advection_test/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/torus_advection_test/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/torus_advection_test/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/double_gyre/$(TIMESTATS).$(cmp)): NPES=8
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/double_gyre/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/double_gyre/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/DOME/$(TIMESTATS).$(cmp)): NPES=6
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/DOME/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/DOME/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/benchmark/$(TIMESTATS).$(cmp)): NPES=72
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/benchmark/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/benchmark/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/BML/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/BML/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,$(MOM6_EXAMPLES)/ocean_only/single_column/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/KPP/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/KPP/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,$(MOM6_EXAMPLES)/ocean_only/single_column/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/EPBL/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/EPBL/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,$(MOM6_EXAMPLES)/ocean_only/single_column/EPBL/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/SCM_idealized_hurricane/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/SCM_idealized_hurricane/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/SCM_idealized_hurricane/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/KPP/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/KPP/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/BML/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/BML/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/EPBL/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/EPBL/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/EPBL/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/KPP/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/KPP/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/BML/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/BML/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/EPBL/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/EPBL/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/EPBL/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/KPP/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/KPP/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/BML/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/BML/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/EPBL/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/EPBL/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/EPBL/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/KPP/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/KPP/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/BML/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/BML/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/EPBL/$(TIMESTATS).$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/EPBL/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/EPBL/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/circle_obcs/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/circle_obcs/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/circle_obcs/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/lock_exchange/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/lock_exchange/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/lock_exchange/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/%/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/layer/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/adjustment2d/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/z/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/adjustment2d/z/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/rho/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/adjustment2d/rho/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/resting/%/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/resting/layer/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/resting/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/resting/z/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/resting/z/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/%/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/layer/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/sloshing/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/rho/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/sloshing/rho/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/z/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/sloshing/z/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/%/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/layer/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/z/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/z/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/rho/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/rho/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/sigma/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/sigma/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/%/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/layer/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/seamount/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/z/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/seamount/z/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/sigma/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/seamount/sigma/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/mixed_layer_restrat_2d/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/mixed_layer_restrat_2d/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/mixed_layer_restrat_2d/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/external_gwave/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/external_gwave/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/external_gwave/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global/$(TIMESTATS).$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/global/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/layer/$(TIMESTATS).$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/layer/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/global_ALE/layer/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/z/$(TIMESTATS).$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/z/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/global_ALE/z/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/hycom/$(TIMESTATS).$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/hycom/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/global_ALE/hycom/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/nonBous_global/$(TIMESTATS).$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/nonBous_global/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/nonBous_global/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/Phillips_2layer/$(TIMESTATS).$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/Phillips_2layer/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/Phillips_2layer/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_23L/$(TIMESTATS).$(cmp)): NPES=288
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_23L/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/MESO_025_23L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_63L/$(TIMESTATS).$(cmp)): NPES=288
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_63L/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/MESO_025_63L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS/$(TIMESTATS).$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_icebergs/$(TIMESTATS).$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_icebergs/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_icebergs/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_025/$(TIMESTATS).$(cmp)): NPES=1024
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_025/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/$(TIMESTATS).$(cmp)): NPES=512
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/$(TIMESTATS).$(cmp)): NPES=254
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/OM4_025/$(TIMESTATS).$(cmp)): NPES=480
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/OM4_025/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/OM4_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/Baltic/$(TIMESTATS).$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/Baltic/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/Baltic/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2/$(TIMESTATS).$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs/$(TIMESTATS).$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_1/$(TIMESTATS).$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_1/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_1/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_2/$(TIMESTATS).$(cmp)): NPES=60
$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_2/$(TIMESTATS).gnu: $(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_1/$(TIMESTATS).gnu
$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_2/$(TIMESTATS).intel: $(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_1/$(TIMESTATS).intel
$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_2/$(TIMESTATS).pgi: $(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_1/$(TIMESTATS).pgi
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_2/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_2/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_layout/$(TIMESTATS).$(cmp)): NPES=96
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_layout/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs_layout/$(fl))


$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_cgrid/$(TIMESTATS).$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_cgrid/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_cgrid/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_bergs_cgrid/$(TIMESTATS).$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_bergs_cgrid/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_bergs_cgrid/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/MOM6z_SIS2_025/$(TIMESTATS).$(cmp)): NPES=512
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/MOM6z_SIS2_025/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/MOM6z_SIS2_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/OM4_025/$(TIMESTATS).$(cmp)): NPES=480
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/OM4_025/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/OM4_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(TIMESTATS).$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/$(TIMESTATS).$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(TIMESTATS).$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/$(TIMESTATS).$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/$(TIMESTATS).$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/$(TIMESTATS).$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/$(fl))

# Canned rule to run all experiments
define run-model-to-make-$(TIMESTATS)
echo $@: Using executable $< ' '; echo -n $@: Starting at ' '; date
@cd $(dir $@); $(RM) -rf RESTART; mkdir -p RESTART
@$(RM) -f $(dir $@){Depth_list.nc,RESTART/coupler.res,CPU_stats,$(TIMESTATS),seaice.stats,time_stamp.out} $@
set rdir=$$cwd; (cd $(dir $@); setenv OMP_NUM_THREADS 1; (time $(MPIRUN) -n $(NPES) $$rdir/$< > std.out) |& tee stderr.$(STDERR_LABEL)) | sed 's,^,$@: ,'
@echo -n $@: Done at ' '; date
@$(MV) $(dir $@)std.out $(dir $@)std$(suffix $@).out
@$(MV) $(dir $@)$(TIMESTATS) $@
@find $(dir $@) -maxdepth 1 -name seaice.stats -exec $(MV) {} $(dir $@)seaice.stats$(suffix $@) \;
@cd $(dir $@); (echo -n 'git status: '; git status -s $(TIMESTATS)$(suffix $@)) | sed 's,^,$@: ,'
@cd $(dir $@); (echo; git status .) | sed 's,^,$@: ,'
endef
%/$(TIMESTATS).gnu: ; $(run-model-to-make-$(TIMESTATS))
%/$(TIMESTATS).intel: ; $(run-model-to-make-$(TIMESTATS))
%/$(TIMESTATS).pgi: ; $(run-model-to-make-$(TIMESTATS))
