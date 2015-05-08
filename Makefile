ALE_EXPTS=$(foreach dir, \
          resting/z \
          single_column/KPP sloshing/rho sloshing/z \
          SCM_idealized_hurricane \
          CVmix_SCM_tests/mech_only/KPP CVmix_SCM_tests/wind_only/KPP \
          CVmix_SCM_tests/skin_warming_wind/KPP CVmix_SCM_tests/cooling_only/KPP \
          CVmix_SCM_tests/mech_only/EPBL CVmix_SCM_tests/wind_only/EPBL \
          CVmix_SCM_tests/skin_warming_wind/EPBL CVmix_SCM_tests/cooling_only/EPBL \
          adjustment2d/z adjustment2d/rho \
          seamount/z seamount/sigma \
          flow_downslope/z flow_downslope/rho flow_downslope/sigma \
          global_ALE/z \
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
SIS_EXPTS=$(foreach dir,GOLD_SIS GOLD_SIS_icebergs OM4_025,ice_ocean_SIS/$(dir))
#SIS_EXPTS+=ice_ocean_SIS/GOLD_SIS_025
SIS2_EXPTS=$(foreach dir,Baltic SIS2 SIS2_icebergs SIS2_cgrid SIS2_bergs_cgrid OM4_025,ice_ocean_SIS2/$(dir))
AM2_LM3_SIS_EXPTS=$(foreach dir,CM2G63L AM2_MOM6i_1deg,coupled_AM2_LM3_SIS/$(dir))
AM2_LM3_SIS2_EXPTS=$(foreach dir,AM2_SIS2B_MOM6i_1deg AM2_SIS2_MOM6i_1deg,coupled_AM2_LM3_SIS2/$(dir))
EXPTS=$(ALE_EXPTS) $(SOLO_EXPTS) $(SYMMETRIC_EXPTS) $(SIS_EXPTS) $(SIS2_EXPTS) $(AM2_LM3_SIS_EXPTS) $(AM2_LM3_SIS2_EXPTS)
EXPT_EXECS=ocean_only symmetric_ocean_only ice_ocean_SIS ice_ocean_SIS2 coupled_AM2_LM3_SIS coupled_AM2_LM3_SIS2 # Executable/model configurations to build
#For non-GFDL users: CVS=cvs -d /ncrc/home2/fms/cvs
#For GFDL users: CVS=cvs -d :ext:cvs.princeton.rdhpcs.noaa.gov:/home/fms/cvs
#For when certificates are down: CVS=cvs -d :ext:gfdl:/home/fms/cvs
#CVS=cvs -d :ext:gfdl:/home/fms/cvs
CVS=cvs -d :ext:cvs.princeton.rdhpcs.noaa.gov:/home/fms/cvs

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
# Name of coupler directory
COUPLER=$(EXTRAS)/coupler
# Name of coupler directory
ICE_PARAM=$(EXTRAS)/ice_param
# Name of atmos_null directory
ATMOS_NULL=$(EXTRAS)/atmos_null
# Name of land_null directory
LAND_NULL=$(EXTRAS)/land_null
# Location of bin scripts
BIN_DIR=$(MOM6_EXAMPLES)/build/bin
# Location of site templats
SITE_DIR=$(MOM6_EXAMPLES)/build/site
# Location to build
BUILD_DIR=$(MOM6_EXAMPLES)/build
# Relative path from compile directory to top
REL_PATH=../../../../..

#CPPDEFS="-Duse_libMPI -Duse_netCDF -Duse_LARGEFILE -DSPMD -Duse_shared_pointers -Duse_SGI_GSM -DLAND_BND_TRACERS"
CPPDEFS="-DSPMD -DLAND_BND_TRACERS"
CPPDEFS="-Duse_libMPI -Duse_netCDF"
CPPDEFS="-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS"
CPPDEFS='-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS -D_FILE_VERSION="`$(REL_PATH)/$(BIN_DIR)/git-version-string $$<`"'
CPPDEFS='-Duse_libMPI -Duse_netCDF -DSPMD -DUSE_LOG_DIAG_FIELD_INFO -D_FILE_VERSION="`$(REL_PATH)/$(BIN_DIR)/git-version-string $$<`"'
# SITE can be ncrc, hpcs or doe
SITE=ncrc
MAKEMODE=NETCDF=4 OPENMP=1
MAKEMODE=NETCDF=4
MAKEMODE=
MODES=repro prod debug
COMPILERS=intel pathscale pgi cray gnu
COMPILERS=gnu intel pgi

GOLD_tag=GOLD_ogrp
MOM6_tag=dev/master
FMS_tag=ulm
SIS1_tag=ulm
BIN_tag=fre-commands-bronx-7

# Default compiler configuration
#COMPILER=intel
EXEC_MODE=repro
TEMPLATE=-t $(REL_PATH)/$(SITE_DIR)/$(SITE)/$(COMPILER).mk
NPES=2
PMAKEOPTS=-l 12.0 -j 12
PMAKEOPTS=-j

TIMESTATS=$(foreach dir,$(EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
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
ale: $(BUILD_DIR)/$(COMPILER)/ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
solo: $(BUILD_DIR)/$(COMPILER)/ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(SOLO_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
symmetric: $(BUILD_DIR)/$(COMPILER)/symmetric_ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
sis: $(BUILD_DIR)/$(COMPILER)/ice_ocean_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
sis2: $(BUILD_DIR)/$(COMPILER)/ice_ocean_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
am2_sis: $(BUILD_DIR)/$(COMPILER)/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
am2_sis2: $(BUILD_DIR)/$(COMPILER)/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
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
intel: $(BUILD_DIR)/intel/env $(BUILD_DIR)/site
	make COMPILER=intel
pathscale: $(BUILD_DIR)/pathscale/env $(BUILD_DIR)/site
	make COMPILER=pathscale
pgi: $(BUILD_DIR)/pgi/env $(BUILD_DIR)/site
	make COMPILER=pgi
cray: $(BUILD_DIR)/cray/env $(BUILD_DIR)/site
	make COMPILER=cray
gnu: $(BUILD_DIR)/gnu/env $(BUILD_DIR)/site
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
	@echo ' make status    - check CVS status of expts list in EXPTS variable'
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
	@echo '                 and check CVS status of timestats files'
	@echo '               - On batch nodes, build the repro executables and run'
	@echo '                 executables for any out-of-date timestats files'
	@echo 'Specific targets:                                         ** BATCH nodes only **\n' $(foreach dir,$(EXPTS),'make $(MOM6_EXAMPLES)/$(dir)/timestats\n')
status: # Check git status of $(TIMESTATS)
	@cd $(MOM6_EXAMPLES); git status -- $(subst $(MOM6_EXAMPLES)/,,$(TIMESTATS))
	@echo ==================================================================
	@cd $(MOM6_EXAMPLES); git status -s -- $(subst $(MOM6_EXAMPLES)/,,$(TIMESTATS))
	@find $(MOM6_EXAMPLES)/ -name stderr.out -exec grep -H 'WARNING' {} \;
	@find $(MOM6_EXAMPLES)/ -name stderr.out -exec grep -H 'diag_util_mod::opening_file' {} \;
force: cleantimestats
	@make all
cleantimestats:
	rm -f $(TIMESTATS)
clean:
	@$(foreach dir,$(wildcard $(BUILD_DIR)/*), (cd $(dir); make clean); )
	find $(BUILD_DIR)/* -type l -exec rm {} \;
	find $(BUILD_DIR)/* -name '*.mod' -exec rm {} \;
Clean: clean cleancore
	-rm -f $(MOM6_EXAMPLES)/{*,*/*,*/*/*}/*.nc.*
	-rm -f $(MOM6_EXAMPLES)/{*,*/*,*/*/*}/*.{nc,out}
	-rm -rf $(MOM6_EXAMPLES)/{*,*/*}/RESTART
	-rm -f $(MOM6_EXAMPLES)/{*,*/*}/{fort.*,*.nml,timestats,CPU_stats,exitcode,available_diags.*}
cleancore:
	-find $(MOM6_EXAMPLES)/ -name core -type f -exec rm {} \;
	-find $(MOM6_EXAMPLES)/ -name "*truncations" -type f -exec rm {} \;
backup: Clean
	tar zcvf ~/MOM6_backup.tgz MOM6
package:
	tar zcvf $(BIN_tag).tgz $(SITE_DIR) $(BIN_DIR)
	tar zcvf SIS_$(FMS_tag).tgz extras/{SIS,*null,coupler/*,ice_param}
#	tar zcvf $(FMS_tag).tgz shared extras/{SIS,*null,coupler/*,ice_param} site bin
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
checkout: $(MOM6_EXAMPLES) $(COUPLER) $(ICE_PARAM) $(ATMOS_NULL) $(LAND_NULL) $(SIS1) $(LM3) $(AM2) $(SITE_DIR) $(BIN_DIR)
$(MOM6_EXAMPLES) $(FMS) (SIS2):
	git clone --recursive git@github.com:CommerceGov/NOAA-GFDL-MOM6-examples.git $(MOM6_EXAMPLES)
$(EXTRAS):
	mkdir -p $@
$(COUPLER): | $(EXTRAS)
	cd $(@D); git clone git@gitlab.gfdl.noaa.gov:fms/coupler.git
$(ICE_PARAM) $(LAND_NULL): | $(EXTRAS)
	cd $(@D); $(CVS) co -kk -r $(FMS_tag) -P $(@F)
$(ATMOS_NULL): | $(EXTRAS)
	cd $(@D); $(CVS) co -kk -r $(FMS_tag) -P $(@F)
	cd $@; $(CVS) co -kk -r $(FMS_tag) -P atmos_param/diag_integral atmos_param/monin_obukhov
$(SIS1): | $(EXTRAS)
	cd $(@D); $(CVS) co -kk -r $(SIS1_tag) -P -d $(@F) ice_sis
$(LM3): | $(EXTRAS)
	mkdir -p $@
	cd $@; $(CVS) co -kk -r $(FMS_tag) -P land_lad2 land_param
	find $@/land_lad2 -type f -name \*.F90 -exec cpp -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE -C -v -I $(FMS)/include -o '{}'.cpp {} \;
	find $@/land_lad2 -type f -name \*.F90.cpp -exec rename .F90.cpp .f90 {} \;
	find $@/land_lad2 -type f -name \*.F90 -exec rename .F90 .F90_preCPP {} \;
$(AM2): | $(EXTRAS)
	mkdir -p $@
	(cd $@; $(CVS) co -kk -r $(FMS_tag) -P atmos_coupled atmos_fv_dynamics atmos_param_am3 atmos_shared)
	rm -rf $@/atmos_fv_dynamics/driver/solo
extras/AM4: | extras
	mkdir -p $@
	(cd $@; $(CVS) co -kk -r $(FMS_tag) -P atmos_coupled cubed_sphere_coupled atmos_param_am3 atmos_shared)
	(cd $@; cvs update -r tikal_ncar1p5_micro_rsh atmos_param/strat_cloud/aerosol_cloud.F90 atmos_param/strat_cloud/cldwat2m_micro.F90 atmos_param/strat_cloud/microphysics.F90 atmos_param/strat_cloud/morrison_gettelman_microp.F90 atmos_param/strat_cloud/rotstayn_klein_mp.F90 atmos_param/strat_cloud/strat_cloud.F90 atmos_param/strat_cloud/strat_cloud_utilities.F90 atmos_param/strat_cloud/strat_nml.h atmos_param/strat_cloud/micro_mg.F90)
	(cd $@; cvs update -r tikal_precip_paths_rsh atmos_param/moist_processes/moist_processes.F90)
	(cd $@; cvs update -r tikal_ncar1p5_micro_rsh_wfc atmos_param/strat_cloud/rotstayn_klein_mp.F90)
	(cd $@; cvs update -r tikal_rad_diag_xlh_cjg atmos_param/sea_esf_rad/longwave_driver.F90 atmos_param/sea_esf_rad/rad_output_file.F90 atmos_param/sea_esf_rad/sealw99.F90)
	(cd $@; cvs update -r tikal_pbl_depth_cjg atmos_param/physics_driver/physics_driver.F90 atmos_param/vert_turb_driver/vert_turb_driver.F90)
	(cd $@; cvs update -r dpconv20140318_miz atmos_param/shallow_cu/conv_plumes_k.F90 atmos_param/shallow_cu/conv_plumes_k.F90)
	(cd $@; cvs update -r tikal_pbl_depth_cjg atmos_coupled/atmos_model.F90)
	(cd $@; cvs update -r tikal_pbl_depth_cjg atmos_cubed_sphere/driver/coupled/atmosphere.F90 atmos_cubed_sphere/driver/coupled/fv_physics.F90)
	(cd $@; git clone git@gitlab.gfdl.noaa.gov:coupler_devel/coupler.git)
	(cd $@/coupler; git checkout user/nnz/merge_tikal_pbl_depth_cjg)
$(SITE_DIR):
	mkdir -p $(@D)
	cd $(@D); $(CVS) co -r $(BIN_tag) -P -d site fre/fre-commands/site
$(BIN_DIR):
	mkdir -p $(@D)
	cd $(@D); $(CVS) co -r $(BIN_tag) -P -d bin bin-pub

# Rules for building executables ###############################################
# Choose the compiler based on the build directory
$(BUILD_DIR)/gnu/%/MOM6 $(BUILD_DIR)/gnu/%/libfms.a: COMPILER=gnu
$(BUILD_DIR)/intel/%/MOM6 $(BUILD_DIR)/intel/%/libfms.a: COMPILER=intel
$(BUILD_DIR)/pgi/%/MOM6 $(BUILD_DIR)/pgi/%/libfms.a: COMPILER=pgi
#$(foreach cfg,$(EXPT_EXECS),$(BUILD_DIR)/gnu/$(cfg)/%/MOM6) $(BUILD_DIR)/gnu/shared/repro/libfms.a: COMPILER=gnu
#$(foreach cfg,$(EXPT_EXECS),$(BUILD_DIR)/intel/$(cfg)/%/MOM6) $(BUILD_DIR)/intel/shared/repro/libfms.a: COMPILER=intel
#$(foreach cfg,$(EXPT_EXECS),$(BUILD_DIR)/pgi/$(cfg)/%/MOM6) $(BUILD_DIR)/pgi/shared/repro/libfms.a: COMPILER=pgi
# Set REPRO and DEBUG variables based on the build directory
%/prod/MOM6 %/prod/libfms.a: EXEC_MODE=prod
%/repro/MOM6 %/repro/libfms.a: EXEC_MODE=repro
%/debug/MOM6 %/debug/libfms.a: EXEC_MODE=debug
%/repro/libfms.a %/repro/MOM6: MAKEMODE+=REPRO=1
%/debug/libfms.a %/debug/MOM6: MAKEMODE+=DEBUG=1

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
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-intel/4.0.46 >> $@
	@echo module switch intel intel/12.0.5.220 >> $@
	@echo module load netcdf/4.2.0 >> $@
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

# Canned rule to run all experiments
define build_mom6_executable
@echo; echo Building $@
@echo SRCPTH="$(SRCPTH)"
@echo MAKEMODE=$(MAKEMODE)
@echo EXEC_MODE=$(EXEC_MODE)
mkdir -p $(dir $@)
(cd $(dir $@); rm -f path_names; $(REL_PATH)/$(BIN_DIR)/list_paths ./ $(foreach dir,$(SRCPTH),$(REL_PATH)/$(dir)))
(cd $(dir $@); $(REL_PATH)/$(BIN_DIR)/mkmf $(TEMPLATE) -o '-I../../shared/$(EXEC_MODE)' -p 'MOM6 -L../../shared/$(EXEC_MODE) -lfms' -c $(CPPDEFS) path_names )
(cd $(dir $@); rm -f MOM6)
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
SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(COUPLER) $(LAND_NULL) $(ICE_PARAM) $(SIS1) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS/$(mode)/MOM6): SRCPTH=$(SIS_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS/$(mode)/MOM6): $(foreach dir,$(SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# SIS2 executable
SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(COUPLER) $(LAND_NULL) $(ICE_PARAM) $(ICEBERGS) $(SIS2) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS2/$(mode)/MOM6): SRCPTH=$(SIS2_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/ice_ocean_SIS2/$(mode)/MOM6): $(foreach dir,$(SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM2+LM3+SIS executable
AM2_LM3_SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(COUPLER) $(ICE_PARAM) $(SIS1) $(LM3) $(AM2) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): $(foreach dir,$(AM2_LM3_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM2+LM3+SIS2 executable
AM2_LM3_SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(COUPLER) $(ICE_PARAM) $(ICEBERGS) $(SIS2) $(LM3) $(AM2) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS2_PTH)
$(foreach mode,$(MODES),$(BUILD_DIR)/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): $(foreach dir,$(AM2_LM3_SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BUILD_DIR)/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# LM3+SIS2 executable
LM3_SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(COUPLER) $(ICE_PARAM) $(ICEBERGS) $(SIS2) $(LM3) $(FMS)/coupler $(FMS)/include
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
$(foreach cmp,$(COMPILERS),$(foreach mode,$(MODES),$(BUILD_DIR)/$(cmp)/shared/$(mode)/libfms.a)): $(FMS) $(foreach dir,$(FMS)/* $(FMS)/*/*,$(wildcard $(dir)/*.F90 $(dir)/*.h)) $(BIN_DIR)/git-version-string $(BIN_DIR) $(SITE_DIR)
	@echo; echo Building $@
	@mkdir -p $(dir $@)
	@echo MAKEMODE=$(MAKEMODE)
	@echo EXEC_MODE=$(EXEC_MODE)
	(cd $(dir $@); rm path_names; $(REL_PATH)/$(BIN_DIR)/list_paths $(REL_PATH)/$(FMS))
	(cd $(dir $@); mv path_names path_names.orig; egrep -v "coupler" path_names.orig > path_names)
	(cd $(dir $@); $(REL_PATH)/$(BIN_DIR)/mkmf $(TEMPLATE) -p libfms.a -c $(CPPDEFS) path_names)
	(cd $(dir $@); rm -f libfms.a)
	(cd $(dir $@); source ../../env; make $(MAKEMODE) $(PMAKEOPTS) libfms.a)
#(cd $(dir $@); mv path_names path_names.orig; egrep -v "atmos_ocean_fluxes|coupler_types|coupler_util" path_names.orig > path_names)

# Rules to associated an executable to each experiment #########################
# (implemented by makeing the executable the FIRST pre-requisite)
$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): $(BUILD_DIR)/gnu/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): $(BUILD_DIR)/gnu/symmetric_ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): $(BUILD_DIR)/gnu/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): $(BUILD_DIR)/gnu/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): $(BUILD_DIR)/gnu/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): $(BUILD_DIR)/gnu/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): $(BUILD_DIR)/intel/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): $(BUILD_DIR)/intel/symmetric_ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): $(BUILD_DIR)/intel/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): $(BUILD_DIR)/intel/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): $(BUILD_DIR)/intel/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): $(BUILD_DIR)/intel/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): $(BUILD_DIR)/pgi/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): $(BUILD_DIR)/pgi/symmetric_ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): $(BUILD_DIR)/pgi/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): $(BUILD_DIR)/pgi/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): $(BUILD_DIR)/pgi/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): $(BUILD_DIR)/pgi/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

# Rules for configuring and running experiments ################################
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/unit_tests/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/unit_tests/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/unit_tests/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/torus_advection_test/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/torus_advection_test/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/torus_advection_test/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/double_gyre/timestats.$(cmp)): NPES=8
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/double_gyre/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/double_gyre/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/DOME/timestats.$(cmp)): NPES=6
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/DOME/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/DOME/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/benchmark/timestats.$(cmp)): NPES=72
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/benchmark/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/benchmark/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/BML/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/BML/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,$(MOM6_EXAMPLES)/ocean_only/single_column/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/KPP/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/KPP/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,$(MOM6_EXAMPLES)/ocean_only/single_column/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/SCM_idealized_hurricane/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/SCM_idealized_hurricane/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/SCM_idealized_hurricane/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/KPP/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/KPP/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/BML/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/BML/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/EPBL/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/EPBL/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/mech_only/EPBL/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/KPP/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/KPP/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/BML/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/BML/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/wind_only/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/KPP/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/KPP/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/BML/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/BML/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/skin_warming_wind/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/KPP/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/KPP/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/KPP/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/BML/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/BML/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/CVmix_SCM_tests/cooling_only/BML/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/circle_obcs/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/circle_obcs/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/circle_obcs/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/lock_exchange/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/lock_exchange/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/lock_exchange/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/adjustment2d/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/adjustment2d/z/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/adjustment2d/rho/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/adjustment2d/rho/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/resting/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/resting/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/resting/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/resting/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/resting/z/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/sloshing/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/rho/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/sloshing/rho/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/sloshing/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/sloshing/z/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/z/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/rho/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/rho/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/flow_downslope/sigma/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/flow_downslope/sigma/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/seamount/layer/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/seamount/z/$(fl))
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/seamount/sigma/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/seamount/sigma/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/mixed_layer_restrat_2d/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/mixed_layer_restrat_2d/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/mixed_layer_restrat_2d/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/external_gwave/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/external_gwave/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/external_gwave/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/global/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/layer/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/global_ALE/layer/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/z/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/global_ALE/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/global_ALE/z/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/nonBous_global/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/nonBous_global/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/nonBous_global/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/Phillips_2layer/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/Phillips_2layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/Phillips_2layer/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_23L/timestats.$(cmp)): NPES=288
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_23L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/MESO_025_23L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_63L/timestats.$(cmp)): NPES=288
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/MESO_025_63L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ocean_only/MESO_025_63L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_icebergs/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_icebergs/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_icebergs/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_025/timestats.$(cmp)): NPES=1024
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/timestats.$(cmp)): NPES=512
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/timestats.$(cmp)): NPES=254
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/OM4_025/timestats.$(cmp)): NPES=480
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS/OM4_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS/OM4_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/Baltic/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/Baltic/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/Baltic/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_icebergs/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_cgrid/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_cgrid/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_cgrid/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_bergs_cgrid/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_bergs_cgrid/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/SIS2_bergs_cgrid/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/MOM6z_SIS2_025/timestats.$(cmp)): NPES=512
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/MOM6z_SIS2_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/MOM6z_SIS2_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/OM4_025/timestats.$(cmp)): NPES=480
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ice_ocean_SIS2/OM4_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/ice_ocean_SIS2/OM4_025/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/CM2G63L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/$(fl))

# Canned rule to run all experiments
define run-model-to-make-timestats
echo $@: Using executable $< ' '; echo -n $@: Starting at ' '; date
@cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
@rm -f $(dir $@){Depth_list.nc,RESTART/coupler.res,CPU_stats,timestats,seaice.stats,time_stamp.out} $@
set rdir=$$cwd; (cd $(dir $@); setenv OMP_NUM_THREADS 1; (time aprun -n $(NPES) $$rdir/$< > std.out) |& tee stderr.out) | sed 's,^,$@: ,'
@echo -n $@: Done at ' '; date
@mv $(dir $@)std.out $(dir $@)std$(suffix $@).out
@mv $(dir $@)timestats $@
@find $(dir $@) -maxdepth 1 -name seaice.stats -exec mv {} $(dir $@)seaice.stats$(suffix $@) \;
@cd $(dir $@); (echo -n 'git status: '; git status -s timestats$(suffix $@)) | sed 's,^,$@: ,'
@cd $(dir $@); (echo; git status .) | sed 's,^,$@: ,'
endef
%/timestats.gnu: ; $(run-model-to-make-timestats)
%/timestats.intel: ; $(run-model-to-make-timestats)
%/timestats.pgi: ; $(run-model-to-make-timestats)

# Special rule to get misc files
$(BIN_DIR)/git-version-string:
	mkdir -p $(@D)
	cd $(@D); $(CVS) co -kk -r git_tools_sdu fre-commands
	cd $(@D); cp fre-commands/bin/git-version-string .
	cd $(@D); rm -rf CVS fre-commands
