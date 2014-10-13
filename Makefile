ALE_EXPTS=$(foreach dir, \
          resting/z \
          single_column_z sloshing/rho sloshing/z \
          adjustment2d/z adjustment2d/rho \
          seamount/z seamount/sigma \
          flow_downslope/z flow_downslope/rho flow_downslope/sigma \
          global_ALE/z \
          mixed_layer_restrat_2d \
          ,ocean_only/$(dir))
SOLO_EXPTS=$(foreach dir, \
          resting/layer \
          torus_advection_test lock_exchange external_gwave single_column \
          sloshing/layer adjustment2d/layer seamount/layer flow_downslope/layer global_ALE/layer \
          double_gyre DOME benchmark global nonBous_global Phillips_2layer \
          ,ocean_only/$(dir))
SOLO_EXPTS+=ocean_only/MESO_025_63L
SYMMETRIC_EXPTS=ocean_only/circle_obcs
SIS_EXPTS=$(foreach dir,GOLD_SIS GOLD_SIS_icebergs OM4_025,ice_ocean_SIS/$(dir))
#SIS_EXPTS+=ice_ocean_SIS/GOLD_SIS_025
SIS2_EXPTS=$(foreach dir,Baltic SIS2 SIS2_icebergs SIS2_cgrid SIS2_bergs_cgrid OM4_025,ice_ocean_SIS2/$(dir))
AM2_SIS_EXPTS=$(foreach dir,CM2G63L AM2_MOM6i_1deg,coupled_AM2_LM2_SIS/$(dir))
AM2_LM3_SIS_EXPTS=$(foreach dir,AM2_MOM6i_1deg,coupled_AM2_LM3_SIS/$(dir))
AM2_LM3_SIS2_EXPTS=$(foreach dir,AM2_SIS2B_MOM6i_1deg AM2_SIS2_MOM6i_1deg,coupled_AM2_LM3_SIS2/$(dir))
EXPTS=$(ALE_EXPTS) $(SOLO_EXPTS) $(SYMMETRIC_EXPTS) $(SIS_EXPTS) $(SIS2_EXPTS) $(AM2_SIS_EXPTS) $(AM2_LM3_SIS_EXPTS) $(AM2_LM3_SIS2_EXPTS)
EXPT_EXECS=ocean_only ocean_only_symmetric ice_ocean_SIS ice_ocean_SIS2 coupled_AM2_LM2_SIS coupled_AM2_LM3_SIS coupled_AM2_LM3_SIS2 # Executable/model configurations to build
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
EXTRAS=extras
# Name of SIS1 directory
SIS1=$(EXTRAS)/SIS
# Name of SIS2 directory
SIS2=$(MOM6_EXAMPLES)/src/SIS2
# Name of LM2 directory
LM2=$(EXTRAS)/LM2
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
BIN_DIR=bin
# Location of site templats
SITE_DIR=site

#CPPDEFS="-Duse_libMPI -Duse_netCDF -Duse_LARGEFILE -DSPMD -Duse_shared_pointers -Duse_SGI_GSM -DLAND_BND_TRACERS"
CPPDEFS="-DSPMD -DLAND_BND_TRACERS"
CPPDEFS="-Duse_libMPI -Duse_netCDF"
CPPDEFS="-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS"
CPPDEFS='-Duse_libMPI -Duse_netCDF -DSPMD -DLAND_BND_TRACERS -D_FILE_VERSION="`../../../../bin/git-version-string $$<`"'
# SITE can be ncrc, hpcs or doe
SITE=ncrc
MAKEMODE=NETCDF=4 OPENMP=1
MAKEMODE=NETCDF=4
MODES=repro prod debug
COMPILERS=intel pathscale pgi cray gnu
COMPILERS=gnu intel pgi

GOLD_tag=GOLD_ogrp
MOM6_tag=dev/master
FMS_tag=tikal_201409
ICE_tag=tikal_201409
BIN_tag=fre-commands-bronx-7

# Default compiler configuration
#COMPILER=intel
EXEC_MODE=repro
TEMPLATE=-t ../../../../$(SITE_DIR)/$(SITE)/$(COMPILER).mk
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
ALLTARGS=ale solo symmetric sis sis2 am2 am2_sis am2_sis2 status
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
repro: $(foreach exec,$(EXPT_EXECS),build/$(COMPILER)/$(exec)/repro/MOM6)
debug: build/$(COMPILER)/shared/debug/libfms.a $(foreach exec,$(EXPT_EXECS),build/$(COMPILER)/$(exec)/debug/MOM6)
prod: $(foreach exec,$(EXPT_EXECS),build/$(exec).$(COMPILER).prod/MOM6)
ale: build/$(COMPILER)/ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
solo: build/$(COMPILER)/ocean_only/$(EXEC_MODE)/MOM6 $(foreach dir,$(SOLO_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
symmetric: build/$(COMPILER)/ocean_only_symmetric/$(EXEC_MODE)/MOM6 $(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
sis: build/$(COMPILER)/ice_ocean_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
sis2: build/$(COMPILER)/ice_ocean_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
am2: build/$(COMPILER)/coupled_AM2_LM2_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
am2_sis: build/$(COMPILER)/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
am2_sis2: build/$(COMPILER)/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.$(COMPILER))
Ale:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) ale;)
Solo:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) solo;)
Sis:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) sis;)
Sis2:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) sis2;)
Coupled:
	$(foreach comp,$(COMPILERS),make COMPILER=$(comp) am2 am2_sis am2_sis2;)
All:
	make Ale Solo
	make Sis Sis2
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
	@$(foreach dir,$(wildcard build/*), (cd $(dir); make clean); )
	find build/* -type l -exec rm {} \;
	find build/* -name '*.mod' -exec rm {} \;
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

# This section defines how to checkout and layout the source code
checkout: $(MOM6_EXAMPLES) $(COUPLER) $(ICE_PARAM) $(ATMOS_NULL) $(LAND_NULL) $(SIS1) $(LM2) $(LM3) $(AM2) $(SITE_DIR) $(BIN_DIR)
$(MOM6_EXAMPLES):
	git clone --recursive git@github.com:CommerceGov/NOAA-GFDL-MOM6-examples.git $(MOM6_EXAMPLES)
$(EXTRAS):
	mkdir -p $@
$(COUPLER): | $(EXTRAS)
	cd $(@D); git clone git@gitlab.gfdl.noaa.gov:coupler_devel/coupler.git
$(ICE_PARAM) $(LAND_NULL): | $(EXTRAS)
	cd $(@D); $(CVS) co -kk -r $(FMS_tag) -P $(@F)
$(ATMOS_NULL): | $(EXTRAS)
	cd $(@D); $(CVS) co -kk -r $(FMS_tag) -P $(@F)
	cd $@; $(CVS) co -kk -r $(FMS_tag) -P atmos_param/diag_integral atmos_param/monin_obukhov
$(SIS1): | $(EXTRAS)
	cd $(@D); $(CVS) co -kk -r tikal_coupler_ogrp -P -d $(@F) ice_sis
$(LM2): | $(EXTRAS)
	mkdir -p $@
	cd $@; $(CVS) co -kk -r $(FMS_tag) -P land_lad land_param
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
builddir: # Target invoked for documenting (use with make -n checkout)
	mkdir -p $(foreach comp,$(COMPILERS),$(foreach expt,shared $(EXPT_EXECS),build/$(expt).$(comp).$(EXEC_MODE)))

# Rules for building executables ###############################################
# Choose the compiler based on the build directory
$(foreach cfg,$(EXPT_EXECS) global,build/gnu/$(cfg)/%/MOM6) build/gnu/shared/repro/libfms.a: override COMPILER:=gnu
$(foreach cfg,$(EXPT_EXECS) global,build/intel/$(cfg)/%/MOM6) build/intel/shared/repro/libfms.a: override COMPILER:=intel
$(foreach cfg,$(EXPT_EXECS) global,build/pgi/$(cfg)/%/MOM6) build/pgi/shared/repro/libfms.a: override COMPILER:=pgi
# Set REPRO and DEBUG variables based on the build directory
%/prod/MOM6: EXEC_MODE=prod
%/repro/MOM6: EXEC_MODE=repro
%/debug/MOM6: EXEC_MODE=debug
%/repro/libfms.a %/repro/MOM6: MAKEMODE+=REPRO=1
%/debug/libfms.a %/debug/MOM6: MAKEMODE+=DEBUG=1

# Create module scripts
build/pgi/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-pgi >> $@
	@echo module load netcdf/4.2.0 >> $@
build/pathscale/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-pathscale >> $@
	@echo module load netcdf/4.2.0 >> $@
build/intel/env:
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
build/cray/env:
	mkdir -p $(dir $@)
	@echo Building $@
	@echo module unload PrgEnv-pgi > $@
	@echo module unload PrgEnv-pathscale >> $@
	@echo module unload PrgEnv-intel >> $@
	@echo module unload PrgEnv-gnu >> $@
	@echo module unload PrgEnv-cray >> $@
	@echo module load PrgEnv-cray >> $@
	@echo module load netcdf/4.2.0 >> $@
build/gnu/env:
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
(cd $(dir $@); rm -f path_names; ../../../../bin/list_paths ./ $(foreach dir,$(SRCPTH),../../../../$(dir)))
(cd $(dir $@); ../../../../bin/mkmf $(TEMPLATE) -p MOM6 -c $(CPPDEFS) path_names )
(cd $(dir $@); ln -sf ../../shared/$(EXEC_MODE)/*.mod .)
(cd $(dir $@); rm -f MOM6)
(cd $(dir $@); source ../../env; make LIBS='-L../../shared/repro -lfms' $(MAKEMODE) $(PMAKEOPTS))
endef

# solo executable
SOLO_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/solo_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/
$(foreach mode,$(MODES),build/%/ocean_only/$(mode)/MOM6): SRCPTH=$(SOLO_PTH)
$(foreach mode,$(MODES),build/%/ocean_only/$(mode)/MOM6): $(foreach dir,$(SOLO_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# Symmetric executable
SOLOSYM_PTH=$(MOM6)/config_src/dynamic_symmetric $(MOM6)/config_src/solo_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/
$(foreach mode,$(MODES),build/%/ocean_only_symmetric/$(mode)/MOM6): SRCPTH=$(SOLOSYM_PTH)
$(foreach mode,$(MODES),build/%/ocean_only_symmetric/$(mode)/MOM6): $(foreach dir,$(SOLOSYM_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# SIS executable
SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(ATMOS_NULL) $(COUPLER) $(LAND_NULL) $(ICE_PARAM) $(SIS1) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),build/%/ice_ocean_SIS/$(mode)/MOM6): SRCPTH=$(SIS_PTH)
$(foreach mode,$(MODES),build/%/ice_ocean_SIS/$(mode)/MOM6): $(foreach dir,$(SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# SIS2 executable
SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(foreach dir,atmos_null coupler land_null ice_param,$(EXTRAS)/$(dir)) $(SIS2) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),build/%/ice_ocean_SIS2/$(mode)/MOM6): SRCPTH=$(SIS2_PTH)
$(foreach mode,$(MODES),build/%/ice_ocean_SIS2/$(mode)/MOM6): $(foreach dir,$(SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM2+LM2+SIS executable
AM2_LM2_SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(foreach dir,coupler ice_param,$(EXTRAS)/$(dir)) $(SIS1) $(AM2) $(LM2) $(FMS)/include
$(foreach mode,$(MODES),build/%/coupled_AM2_LM2_SIS/$(mode)/MOM6): SRCPTH=$(AM2_LM2_SIS_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM2_LM2_SIS/$(mode)/MOM6): $(foreach dir,$(AM2_LM2_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM2+LM3+SIS executable
AM2_LM3_SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(foreach dir,coupler ice_param,$(EXTRAS)/$(dir)) $(SIS1) $(LM3) $(AM2) $(FMS)/include
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): $(foreach dir,$(AM2_LM2_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM2+LM3+SIS2 executable
AM2_LM3_SIS2_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(foreach dir,coupler ice_param,$(EXTRAS)/$(dir)) $(SIS2) $(LM3) $(AM2) $(FMS)/include
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS2_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): $(foreach dir,$(AM2_LM3_SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# AM4+LM3+SIS executable
AM4_LM3_SIS_PTH=$(MOM6)/config_src/dynamic $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(foreach dir,AM4 LM3 ice_param SIS,$(EXTRAS)/$(dir)) $(FMS)/include
$(foreach mode,$(MODES),build/%/coupled_AM4_LM3_SIS/$(mode)/MOM6): SRCPTH=$(AM4_LM3_SIS_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM4_LM3_SIS/$(mode)/MOM6): $(foreach dir,$(AM4_LM3_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# Static global executable
GLOBAL_PTH=$(MOM6)/examples/ocean_only/global $(MOM6)/config_src/solo_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ shared
$(foreach mode,$(MODES),build/%/global/$(mode)/MOM6): SRCPTH=$(GLOBAL_PTH)
$(foreach mode,$(MODES),build/%/global/$(mode)/MOM6): $(foreach dir,$(GLOBAL_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	@echo; echo Building $@
	@echo SRCPTH="$(SRCPTH)"
	@echo MAKEMODE=$(MAKEMODE)
	@echo EXEC_MODE=$(EXEC_MODE)
	mkdir -p $(dir $@)
	(cd $(dir $@); rm -f path_names; ../../../../bin/list_paths ./ $(foreach dir,$(SRCPTH),../../../../$(dir)))
	(cd $(dir $@); ../../../../bin/mkmf $(TEMPLATE) -p MOM6 -c $(CPPDEFS) path_names)
	(cd $(dir $@); ln -sf ../../shared/$(EXEC_MODE)/*.{o,mod} .)
	(cd $(dir $@); rm -f MOM6)
	(cd $(dir $@); source ../../env; make $(MAKEMODE) $(PMAKEOPTS))

# Static SIS executable
STATIC_SIS_PTH=$(MOM6_EXAMPLES)/ice_ocean_SIS/GOLD_SIS $(MOM6)/config_src/coupled_driver $(MOM6)/src/*/ $(MOM6)/src/*/*/ $(foreach dir,atmos_null coupler land_null ice_param,$(EXTRAS)/$(dir)) $(SIS1) $(FMS)/coupler $(FMS)/include
$(foreach mode,$(MODES),build/%/STATIC_ice_ocean_SIS/$(mode)/MOM6): SRCPTH=$(STATIC_SIS_PTH)
$(foreach mode,$(MODES),build/%/STATIC_ice_ocean_SIS/$(mode)/MOM6): $(foreach dir,$(STATIC_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
	$(build_mom6_executable)

# libfms.a
$(foreach cmp,$(COMPILERS),$(foreach mode,$(MODES),build/$(cmp)/shared/$(mode)/libfms.a)): $(foreach dir,$(FMS)/* $(FMS)/*/*,$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/$(COMPILER)/env bin/git-version-string $(BIN_DIR) $(SITE_DIR)
	@echo; echo Building $@
	@mkdir -p $(dir $@)
	@echo MAKEMODE=$(MAKEMODE)
	@echo EXEC_MODE=$(EXEC_MODE)
	(cd $(dir $@); rm path_names; ../../../../bin/list_paths ../../../../$(FMS))
	(cd $(dir $@); mv path_names path_names.orig; egrep -v "coupler_util" path_names.orig > path_names)
	(cd $(dir $@); ../../../../bin/mkmf $(TEMPLATE) -p libfms.a -c $(CPPDEFS) path_names)
	(cd $(dir $@); rm -f libfms.a)
	(cd $(dir $@); source ../../env; make $(MAKEMODE) $(PMAKEOPTS) libfms.a)
#(cd $(dir $@); mv path_names path_names.orig; egrep -v "atmos_ocean_fluxes|coupler_types|coupler_util" path_names.orig > path_names)

# Rules to associated an executable to each experiment #########################
# (implemented by makeing the executable the FIRST pre-requisite)
$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): build/gnu/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): build/gnu/ocean_only_symmetric/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): build/gnu/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): build/gnu/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): build/gnu/coupled_AM2_LM2_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): build/gnu/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.gnu): build/gnu/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): build/intel/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): build/intel/ocean_only_symmetric/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): build/intel/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): build/intel/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): build/intel/coupled_AM2_LM2_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): build/intel/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.intel): build/intel/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): build/pgi/ocean_only/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): build/pgi/ocean_only_symmetric/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): build/pgi/ice_ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): build/pgi/ice_ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): build/pgi/coupled_AM2_LM2_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): build/pgi/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),$(MOM6_EXAMPLES)/$(dir)/timestats.pgi): build/pgi/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

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

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,$(MOM6_EXAMPLES)/ocean_only/single_column/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column_z/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/ocean_only/single_column_z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,$(MOM6_EXAMPLES)/ocean_only/single_column_z/$(fl))

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

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM2_SIS/CM2G63L/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM2_SIS/CM2G63L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM2_SIS/CM2G63L/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM2_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM2_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM2_SIS/AM2_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,$(MOM6_EXAMPLES)/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/$(fl))

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
bin/git-version-string:
	$(CVS) co -kk -r git_tools_sdu fre-commands
	mkdir -p bin; cp fre-commands/bin/git-version-string bin/
	rm -rf CVS fre-commands
