#EXPTS=$(wildcard MOM6/examples/*/[a-zA-Z][a-zA-UW-Z]*)
ALE_EXPTS=$(foreach dir, \
          resting/z \
          single_column_z sloshing/rho sloshing/z \
          adjustment2d/z adjustment2d/rho \
          seamount/z seamount/sigma \
          flow_downslope/z flow_downslope/rho flow_downslope/sigma \
          global_ALE/z \
          ,solo_ocean/$(dir))
SOLO_EXPTS=$(foreach dir, \
          resting/layer \
          torus_advection_test lock_exchange external_gwave single_column \
          sloshing/layer adjustment2d/layer seamount/layer flow_downslope/layer global_ALE/layer \
          double_gyre DOME benchmark global nonBous_global Phillips_2layer \
          ,solo_ocean/$(dir))
SOLO_EXPTS+=solo_ocean/MESO_025_63L
#         double_gyre DOME benchmark global nonBous_global MESO_025_63L Phillips_2layer \
#
SYMMETRIC_EXPTS=solo_ocean/circle_obcs
SIS_EXPTS=$(foreach dir,GOLD_SIS GOLD_SIS_icebergs OM4_025 MOM6z_SIS_025 MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18,ocean_SIS/$(dir))
#SIS_EXPTS=$(foreach dir,GOLD_SIS GOLD_SIS_icebergs MOM6z_SIS_025 GOLD_SIS_025 ,ocean_SIS/$(dir))
#SIS_EXPTS=$(foreach dir,GOLD_SIS GOLD_SIS_icebergs MOM6z_SIS_025,ocean_SIS/$(dir))
#SIS_EXPTS=$(foreach dir,GOLD_SIS GOLD_SIS_icebergs,ocean_SIS/$(dir))
SIS2_EXPTS=$(foreach dir,Baltic SIS2 SIS2_icebergs SIS2_cgrid SIS2_bergs_cgrid MOM6z_SIS2_025,ocean_SIS2/$(dir))
#SIS2_EXPTS=$(foreach dir,Baltic SIS2 SIS2_icebergs SIS2_cgrid SIS2_bergs_cgrid,ocean_SIS2/$(dir))
AM2_SIS_EXPTS=$(foreach dir,CM2G63L AM2_MOM6i_1deg,coupled_AM2_SIS/$(dir))
AM2_LM3_SIS_EXPTS=$(foreach dir,AM2_MOM6i_1deg,coupled_AM2_LM3_SIS/$(dir))
AM2_LM3_SIS2_EXPTS=$(foreach dir,AM2_SIS2B_MOM6i_1deg AM2_SIS2_MOM6i_1deg,coupled_AM2_LM3_SIS2/$(dir))
EXPTS=$(ALE_EXPTS) $(SOLO_EXPTS) $(SYMMETRIC_EXPTS) $(SIS_EXPTS) $(SIS2_EXPTS) $(AM2_SIS_EXPTS) $(AM2_LM3_SIS_EXPTS) $(AM2_LM3_SIS2_EXPTS)
EXPT_EXECS=solo_ocean solo_ocean_symmetric ocean_SIS ocean_SIS2 coupled_AM2_SIS coupled_AM2_LM3_SIS coupled_AM2_LM3_SIS2 coupled_AM4_LM3_SIS # Executable/model configurations to build
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
FMS_tag=tikal
ICE_tag=tikal
BIN_tag=fre-commands-bronx-7

# Default compiler configuration
#COMPILER=intel
EXEC_MODE=repro
TEMPLATE=-t ../../../../site/$(SITE)/$(COMPILER).mk
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
debug: build/shared.$(COMPILER).debug/libfms.a $(foreach exec,$(EXPT_EXECS),build/$(exec).$(COMPILER).debug/MOM6)
prod: $(foreach exec,$(EXPT_EXECS),build/$(exec).$(COMPILER).prod/MOM6)
ale: build/$(COMPILER)/solo_ocean/$(EXEC_MODE)/MOM6 $(foreach dir,$(ALE_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
solo: build/$(COMPILER)/solo_ocean/$(EXEC_MODE)/MOM6 $(foreach dir,$(SOLO_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
symmetric: build/$(COMPILER)/solo_ocean_symmetric/$(EXEC_MODE)/MOM6 $(foreach dir,$(SYMMETRIC_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
sis: build/$(COMPILER)/ocean_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
sis2: build/$(COMPILER)/ocean_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(SIS2_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
am2: build/$(COMPILER)/coupled_AM2_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_SIS_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
am2_sis: build/$(COMPILER)/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
am2_sis2: build/$(COMPILER)/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6 $(foreach dir,$(AM2_LM3_SIS2_EXPTS),MOM6/examples/$(dir)/timestats.$(COMPILER))
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
	@echo 'Specific targets:                                         ** BATCH nodes only **\n' $(foreach dir,$(EXPTS),'make MOM6/examples/$(dir)/timestats\n')
status: # Check CVS status of $(TIMESTATS)
	@cd MOM6; git status -- $(subst MOM6/,,$(TIMESTATS))
	@echo ==================================================================
	@cd MOM6; git status -s -- $(subst MOM6/,,$(TIMESTATS))
	@find MOM6/examples/ -name stderr.out -exec grep -H 'diag_util_mod::opening_file' {} \;
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
checkout: MOM6 shared extras/coupler extras/ice_param extras/SIS extras/SIS2 extras/LM2 extras/LM3 extras/AM2 site bin
MOM6:
	git clone --recursive git@github.com:CommerceGov/NOAA-GFDL-MOM6.git MOM6
shared:
	$(CVS) co -kk -r tikal_201406 -P shared
	cvs up -r tikal_group_update_fix_z1l shared/mpp/include/{mpp_domains_misc.inc,mpp_domains_util.inc,mpp_group_update.h}
	cvs up -r tikal_group_update_fix_z1l shared/mpp/{mpp_domains.F90,test_mpp_domains.F90}
	cd shared/; cvs up -r rms_sdu diag_manager
#$(CVS) co -kk -r $(FMS_tag) -P shared
#cvs up -r tikal_missing_z1l shared/horiz_interp/horiz_interp.F90
#cvs up -r tikal_missing_z1l shared/horiz_interp/horiz_interp_bilinear.F90
#cvs co -r siena_groupupdate_z1l shared/mpp/include/mpp_group_update.h
#cvs up -r tikal_groupupdate_z1l shared/mpp/mpp_domains.F90 shared/mpp/test_mpp_domains.F90 shared/mpp/include/mpp_domains_misc.inc shared/mpp/include/mpp_domains_util.inc
extras:
	mkdir -p $@
extras/coupler: | extras
	cd extras; git clone git@gitlab.gfdl.noaa.gov:coupler_devel/coupler.git
extras/atmos_null extras/ice_param extras/land_null: | extras
	cd extras; $(CVS) co -kk -r tikal -P atmos_null ice_param land_null; \
cd atmos_null; $(CVS) co -kk -r tikal -P atmos_param/diag_integral atmos_param/monin_obukhov
extras/SIS: | extras
	cd extras; $(CVS) co -kk -r tikal_coupler_ogrp -P -d SIS ice_sis
extras/SIS2: | extras
	cd extras; git clone git@github.com:CommerceGov/NOAA-GFDL-SIS2.git SIS2
extras/LM2: | extras
	mkdir -p $@
	cd $@; $(CVS) co -kk -r tikal -P land_lad land_param
extras/LM3: | extras
	mkdir -p $@
	cd $@; $(CVS) co -kk -r tikal -P land_lad2 land_param
	cd $@; $(CVS) up -r tikal_gfort_slm land_lad2/{canopy_air/cana_tile,glacier/glac_tile,lake/lake_tile,river/river,soil/soil_tile,soil/uptake,vegetation/vegn_cohort,vegetation/vegn_dynamics,vegetation/vegn_photosynthesis,vegetation/vegn_radiation,vegetation/vegn_tile,land_model,canopy_air/canopy_air,glacier/glacier,lake/lake,soil/soil,vegetation/vegetation}.F90
	find $@/land_lad2 -type f -name \*.F90 -exec cpp -Duse_libMPI -Duse_netCDF -DSPMD -Duse_LARGEFILE -C -v -I ./shared/include -o '{}'.cpp {} \;
	find $@/land_lad2 -type f -name \*.F90.cpp -exec rename .F90.cpp .f90 {} \;
	find $@/land_lad2 -type f -name \*.F90 -exec rename .F90 .F90_preCPP {} \;
extras/AM2: | extras
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

site:
	$(CVS) co -kk -r $(BIN_tag) -P -d site fre/fre-commands/site
bin:
	$(CVS) co -kk -r $(BIN_tag) -P -d bin bin-pub
builddir: # Target invoked for documenting (use with make -n checkout
	mkdir -p $(foreach comp,$(COMPILERS),$(foreach expt,shared $(EXPT_EXECS),build/$(expt).$(comp).$(EXEC_MODE)))
MOM6/pkg/CVmix:
	cd MOM6; git submodule init; git submodule update
#cd MOM6; git submodule add ssh://cvs.princeton.rdhpcs.noaa.gov/home/aja/Repos/CVmix.git pkg/CVmix

# Rules for building executables ###############################################
# Choose the compiler based on the build directory
$(foreach cfg,$(EXPT_EXECS),build/gnu/$(cfg)/%/MOM6) build/gnu/shared/repro/libfms.a: override COMPILER:=gnu
$(foreach cfg,$(EXPT_EXECS),build/intel/$(cfg)/%/MOM6) build/intel/shared/repro/libfms.a: override COMPILER:=intel
$(foreach cfg,$(EXPT_EXECS),build/pgi/$(cfg)/%/MOM6) build/pgi/shared/repro/libfms.a: override COMPILER:=pgi
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

# solo executable
SOLO_PTH=MOM6/config_src/dynamic MOM6/config_src/solo_driver MOM6/src/*/ MOM6/src/*/*/ shared
$(foreach mode,$(MODES),build/%/solo_ocean/$(mode)/MOM6): SRCPTH=$(SOLO_PTH)
$(foreach mode,$(MODES),build/%/solo_ocean/$(mode)/MOM6): $(foreach dir,$(SOLO_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# Symmetric executable
SOLOSYM_PTH=MOM6/config_src/dynamic_symmetric MOM6/config_src/solo_driver MOM6/src/*/ MOM6/src/*/*/ shared
$(foreach mode,$(MODES),build/%/solo_ocean_symmetric/$(mode)/MOM6): SRCPTH=$(SOLOSYM_PTH)
$(foreach mode,$(MODES),build/%/solo_ocean_symmetric/$(mode)/MOM6): $(foreach dir,$(SOLOSYM_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# SIS executable
SIS_PTH=MOM6/config_src/dynamic MOM6/config_src/coupled_driver MOM6/src/*/ MOM6/src/*/*/ $(foreach dir,atmos_null coupler land_null ice_param SIS,extras/$(dir)) shared
$(foreach mode,$(MODES),build/%/ocean_SIS/$(mode)/MOM6): SRCPTH=$(SIS_PTH)
$(foreach mode,$(MODES),build/%/ocean_SIS/$(mode)/MOM6): $(foreach dir,$(SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# SIS2 executable
SIS2_PTH=MOM6/config_src/dynamic MOM6/config_src/coupled_driver MOM6/src/*/ MOM6/src/*/*/ $(foreach dir,atmos_null coupler land_null ice_param SIS2,extras/$(dir)) shared
$(foreach mode,$(MODES),build/%/ocean_SIS2/$(mode)/MOM6): SRCPTH=$(SIS2_PTH)
$(foreach mode,$(MODES),build/%/ocean_SIS2/$(mode)/MOM6): $(foreach dir,$(SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# AM2+LM2+SIS executable
AM2_LM2_SIS_PTH=MOM6/config_src/dynamic MOM6/config_src/coupled_driver MOM6/src/*/ MOM6/src/*/*/ $(foreach dir,AM2 coupler LM2 ice_param SIS,extras/$(dir)) shared
$(foreach mode,$(MODES),build/%/coupled_AM2_SIS/$(mode)/MOM6): SRCPTH=$(AM2_LM2_SIS_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM2_SIS/$(mode)/MOM6): $(foreach dir,$(AM2_LM2_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# AM2+LM3+SIS executable
AM2_LM3_SIS_PTH=MOM6/config_src/dynamic MOM6/config_src/coupled_driver MOM6/src/*/ MOM6/src/*/*/ $(foreach dir,AM2 coupler LM3 ice_param SIS,extras/$(dir)) shared
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS/$(mode)/MOM6): $(foreach dir,$(AM2_LM2_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# AM2+LM3+SIS2 executable
AM2_LM3_SIS2_PTH=MOM6/config_src/dynamic MOM6/config_src/coupled_driver MOM6/src/*/ MOM6/src/*/*/ $(foreach dir,AM2 coupler LM3 ice_param SIS2,extras/$(dir)) shared
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): SRCPTH=$(AM2_LM3_SIS2_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM2_LM3_SIS2/$(mode)/MOM6): $(foreach dir,$(AM2_LM3_SIS2_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# AM4+LM3+SIS executable
AM4_LM3_SIS_PTH=MOM6/config_src/dynamic MOM6/config_src/coupled_driver MOM6/src/*/ MOM6/src/*/*/ $(foreach dir,AM4 LM3 ice_param SIS,extras/$(dir)) shared
$(foreach mode,$(MODES),build/%/coupled_AM4_LM3_SIS/$(mode)/MOM6): SRCPTH=$(AM4_LM3_SIS_PTH)
$(foreach mode,$(MODES),build/%/coupled_AM4_LM3_SIS/$(mode)/MOM6): $(foreach dir,$(AM4_LM3_SIS_PTH),$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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

# Static global executable
build/global.%/MOM6: build/shared.%/libfms.a
build/global.%/MOM6: SRCPTH="./ ../../MOM6/examples/global/ ../../MOM6/{config_src/dynamic,config_src/solo_driver,src/{*,*/*}}/ ../../shared/"
build/global.%/MOM6: $(foreach dir,examples/global config_src/dynamic config_src/solo_driver src/* src/*/*,$(wildcard MOM6/$(dir)/*.F90 MOM6/$(dir)/*.h)) build/%/shared/$(EXEC_MODE)/libfms.a
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
$(foreach cmp,$(COMPILERS),$(foreach mode,$(MODES),build/$(cmp)/shared/$(mode)/libfms.a)): $(foreach dir,shared/* shared/*/*,$(wildcard $(dir)/*.F90 $(dir)/*.h)) build/$(COMPILER)/env bin/git-version-string
	@echo; echo Building $@
	@mkdir -p $(dir $@)
	@echo MAKEMODE=$(MAKEMODE)
	@echo EXEC_MODE=$(EXEC_MODE)
	(cd $(dir $@); rm path_names; ../../../../bin/list_paths ../../../../shared)
	(cd $(dir $@); mv path_names path_names.orig; egrep -v "atmos_ocean_fluxes|coupler_types|coupler_util" path_names.orig > path_names)
	(cd $(dir $@); ../../../../bin/mkmf $(TEMPLATE) -p libfms.a -c $(CPPDEFS) path_names)
	(cd $(dir $@); rm -f libfms.a)
	(cd $(dir $@); source ../../env; make $(MAKEMODE) $(PMAKEOPTS) libfms.a)

# Rules to associated an executable to each experiment #########################
$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),MOM6/examples/$(dir)/timestats.gnu): build/gnu/solo_ocean/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),MOM6/examples/$(dir)/timestats.gnu): build/gnu/solo_ocean_symmetric/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),MOM6/examples/$(dir)/timestats.gnu): build/gnu/ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),MOM6/examples/$(dir)/timestats.gnu): build/gnu/ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_SIS_EXPTS),MOM6/examples/$(dir)/timestats.gnu): build/gnu/coupled_AM2_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),MOM6/examples/$(dir)/timestats.gnu): build/gnu/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),MOM6/examples/$(dir)/timestats.gnu): build/gnu/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),MOM6/examples/$(dir)/timestats.intel): build/intel/solo_ocean/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),MOM6/examples/$(dir)/timestats.intel): build/intel/solo_ocean_symmetric/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),MOM6/examples/$(dir)/timestats.intel): build/intel/ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),MOM6/examples/$(dir)/timestats.intel): build/intel/ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_SIS_EXPTS),MOM6/examples/$(dir)/timestats.intel): build/intel/coupled_AM2_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),MOM6/examples/$(dir)/timestats.intel): build/intel/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),MOM6/examples/$(dir)/timestats.intel): build/intel/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

$(foreach dir,$(SOLO_EXPTS) $(ALE_EXPTS),MOM6/examples/$(dir)/timestats.pgi): build/pgi/solo_ocean/$(EXEC_MODE)/MOM6
$(foreach dir,$(SYMMETRIC_EXPTS),MOM6/examples/$(dir)/timestats.pgi): build/pgi/solo_ocean_symmetric/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS_EXPTS),MOM6/examples/$(dir)/timestats.pgi): build/pgi/ocean_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(SIS2_EXPTS),MOM6/examples/$(dir)/timestats.pgi): build/pgi/ocean_SIS2/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_SIS_EXPTS),MOM6/examples/$(dir)/timestats.pgi): build/pgi/coupled_AM2_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS_EXPTS),MOM6/examples/$(dir)/timestats.pgi): build/pgi/coupled_AM2_LM3_SIS/$(EXEC_MODE)/MOM6
$(foreach dir,$(AM2_LM3_SIS2_EXPTS),MOM6/examples/$(dir)/timestats.pgi): build/pgi/coupled_AM2_LM3_SIS2/$(EXEC_MODE)/MOM6

# Rules for configuring and running experiments ################################
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/unit_tests/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/unit_tests/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/unit_tests/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/torus_advection_test/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/torus_advection_test/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/torus_advection_test/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/double_gyre/timestats.$(cmp)): NPES=8
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/double_gyre/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/double_gyre/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/DOME/timestats.$(cmp)): NPES=6
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/DOME/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/DOME/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/benchmark/timestats.$(cmp)): NPES=72
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/benchmark/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/benchmark/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/single_column/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/single_column/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,MOM6/examples/solo_ocean/single_column/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/single_column_z/timestats.$(cmp)): NPES=1
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/single_column_z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override MOM_override2,MOM6/examples/solo_ocean/single_column_z/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/circle_obcs/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/circle_obcs/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/circle_obcs/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/lock_exchange/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/lock_exchange/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/lock_exchange/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/adjustment2d/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/adjustment2d/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/adjustment2d/layer/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/adjustment2d/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/adjustment2d/z/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/adjustment2d/rho/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/adjustment2d/rho/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/resting/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/resting/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/resting/layer/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/resting/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/resting/z/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/sloshing/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/sloshing/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/sloshing/layer/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/sloshing/rho/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/sloshing/rho/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/sloshing/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/sloshing/z/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/flow_downslope/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/flow_downslope/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/flow_downslope/layer/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/flow_downslope/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/flow_downslope/z/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/flow_downslope/rho/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/flow_downslope/rho/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/flow_downslope/sigma/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/flow_downslope/sigma/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/seamount/%/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/seamount/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/seamount/layer/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/seamount/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/seamount/z/$(fl))
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/seamount/sigma/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/seamount/sigma/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/external_gwave/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/external_gwave/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/external_gwave/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/global/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/global/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/global/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/global_ALE/layer/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/global_ALE/layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/global_ALE/layer/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/global_ALE/z/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/global_ALE/z/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/global_ALE/z/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/nonBous_global/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/nonBous_global/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/nonBous_global/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/Phillips_2layer/timestats.$(cmp)): NPES=64
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/Phillips_2layer/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/Phillips_2layer/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/MESO_025_23L/timestats.$(cmp)): NPES=288
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/MESO_025_23L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/MESO_025_23L/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/MESO_025_63L/timestats.$(cmp)): NPES=288
$(foreach cmp,$(COMPILERS),MOM6/examples/solo_ocean/MESO_025_63L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/solo_ocean/MESO_025_63L/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/GOLD_SIS/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/GOLD_SIS/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/ocean_SIS/GOLD_SIS/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/GOLD_SIS_icebergs/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/GOLD_SIS_icebergs/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/ocean_SIS/GOLD_SIS_icebergs/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/GOLD_SIS_025/timestats.$(cmp)): NPES=1024
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/GOLD_SIS_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/ocean_SIS/GOLD_SIS_025/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/MOM6z_SIS_025/timestats.$(cmp)): NPES=512
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/MOM6z_SIS_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/ocean_SIS/MOM6z_SIS_025/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/timestats.$(cmp)): NPES=254
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/ocean_SIS/MOM6z_SIS_025/MOM6z_SIS_025_mask_table.34.16x18/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/OM4_025/timestats.$(cmp)): NPES=512
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS/OM4_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/ocean_SIS/OM4_025/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/Baltic/timestats.$(cmp)): NPES=2
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/Baltic/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/ocean_SIS2/Baltic/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/ocean_SIS2/SIS2/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2_icebergs/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2_icebergs/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/ocean_SIS2/SIS2_icebergs/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2_cgrid/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2_cgrid/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/ocean_SIS2/SIS2_cgrid/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2_bergs_cgrid/timestats.$(cmp)): NPES=60
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/SIS2_bergs_cgrid/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/ocean_SIS2/SIS2_bergs_cgrid/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/MOM6z_SIS2_025/timestats.$(cmp)): NPES=512
$(foreach cmp,$(COMPILERS),MOM6/examples/ocean_SIS2/MOM6z_SIS2_025/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/ocean_SIS2/MOM6z_SIS2_025/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_SIS/CM2G63L/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_SIS/CM2G63L/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/coupled_AM2_SIS/CM2G63L/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/coupled_AM2_SIS/AM2_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/coupled_AM2_LM3_SIS/AM2_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/coupled_AM2_LM3_SIS2/AM2_SIS2B_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/timestats.$(cmp)): NPES=90
$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override SIS_input SIS_override,MOM6/examples/coupled_AM2_LM3_SIS2/AM2_SIS2_MOM6i_1deg/$(fl))

$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_SIS/CM2Gfixed/timestats.$(cmp)): NPES=120
$(foreach cmp,$(COMPILERS),MOM6/examples/coupled_AM2_SIS/CM2Gfixed/timestats.$(cmp)): $(foreach fl,input.nml MOM_input MOM_override,MOM6/examples/coupled_AM2_SIS/CM2Gfixed/$(fl))
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
#%/timestats.gnu: override COMPILER:=gnu
#%/timestats.intel: override COMPILER:=intel
#%/timestats.pgi: override COMPILER:=pgi
$(foreach cmp,$(COMPILERS),%/timestats.$(cmp)):
	@echo $@: Using executable $< ' '; echo -n $@: Starting at ' '; date
	@cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
	@rm -f $(dir $@){Depth_list.nc,RESTART/coupler.res,CPU_stats,timestats,seaice.stats} $@
	set rdir=$$cwd; (cd $(dir $@); setenv OMP_NUM_THREADS 1; (time aprun -n $(NPES) $$rdir/$< > std.out) |& tee stderr.out) | sed 's,^,$@: ,'
	@echo -n $@: Done at ' '; date
	@mv $(dir $@)std.out $(dir $@)std$(suffix $@).out
	@mv $(dir $@)timestats $@
	find $(dir $@) -maxdepth 1 -name seaice.stats -exec mv {} $(dir $@)seaice.stats$(suffix $@) \;
	@cd $(dir $@); (echo -n 'git status: '; git status -s timestats$(suffix $@)) | sed 's,^,$@: ,'
	@cd $(dir $@); (echo; git status .) | sed 's,^,$@: ,'
#	set rdir=$$cwd; (cd $(dir $@); rm -f timestats.$(COMPILER); setenv F_UFMTENDIAN big; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_UNEX_BUFFER_SIZE 122914560; (aprun -n $(NPES) $$rdir/$< > std.out) |& tee stderr.out)
##(cd $(dir $@); rm -f timestats.$(COMPILER); setenv F_UFMTENDIAN big; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_UNEX_BUFFER_SIZE 122914560; (aprun -n $(NPES) ../../../$< > std.out) |& tee stderr.out)
## cd $(dir $@); rm -f timestats.$(COMPILER); setenv F_UFMTENDIAN big; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; (aprun -n $(NPES) ../../../$< > std.out) |& tee stderr.out
## cd $(dir $@); rm -f timestats; setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; (aprun -n $(NPES) ../../../$< > std.out) |& tee stderr.out

# Special rule to get misc files
bin/git-version-string:
	$(CVS) co -kk -r git_tools_sdu fre-commands
	mkdir -p bin; cp fre-commands/bin/git-version-string bin/
	rm -rf CVS fre-commands
# Rules to do some performance tests using benchmark
benchmark: $(foreach n,48 96 144 192 216 240 288 384 480 576,MOM6/examples/solo_ocean/benchmark/c1ms.$(COMPILER).360x180x22-n$(n).rank)
benchmark: $(foreach n,24 48 72 96 144 192 216 240 288 384 480 576,MOM6/examples/solo_ocean/benchmark/c1ms.$(COMPILER).360x180x22-n$(n).norank)
MOM6/examples/solo_ocean/benchmark/%.norank MOM6/examples/solo_ocean/benchmark/%.rank: SHRTHOST=$(word 1,$(subst -batch, ,$(HOST)))
MOM6/examples/solo_ocean/benchmark/%.norank MOM6/examples/solo_ocean/benchmark/%.rank: PARTS=$(shell echo $(*F) | sed 's/\([a-zA-Z0-9]*\)\.\([a-zA-Z0-9]*\)\.\([0-9]*x[0-9]*x[0-9]*\)\(.*\)/\1 \2 \3 \4/')
MOM6/examples/solo_ocean/benchmark/%.norank MOM6/examples/solo_ocean/benchmark/%.rank: COMPILER=$(word 2,$(PARTS))
MOM6/examples/solo_ocean/benchmark/%.norank MOM6/examples/solo_ocean/benchmark/%.rank: APARGS=$(shell echo $(word 4,$(PARTS)) | sed 's/-/ -/g' | sed 's/\(-[a-zA-Z]\)\([0-9][0-9]*\)/\1 \2/g')
MOM6/examples/solo_ocean/benchmark/%.norank: build/$(COMPILER)/solo_ocean/$(EXEC_MODE)/MOM6
	make build/$(COMPILER)/solo_ocean/$(EXEC_MODE)/MOM6
	-cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
	(cd $(@D); setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; aprun $(APARGS) ../../../build/solo.$(COMPILER).prod/MOM6 >& std.out)
	mv MOM6/examples/solo_ocean/benchmark/std.out $@
MOM6/examples/solo_ocean/benchmark/%.rank: NORANK=$(subst .rank,.norank,$@)
MOM6/examples/solo_ocean/benchmark/%.rank: PES=$(shell echo $(word 4,$(PARTS))| sed 's/.*-n\([0-9][0-9]*\).*/\1/')
MOM6/examples/solo_ocean/benchmark/%.rank: MOM6/examples/solo_ocean/benchmark/%.norank
	make $(NORANK)
	@echo cp *3*=`awk /X-AX/,/Y-AX/ $(NORANK) | grep -v "Y-AX" | sed 's/.*=//' | wc -w`x`fgrep "Y-AX" $(NORANK) | sed 's/.*=//' | wc -w`=$(PES) $(@D)/MPICH_RANK_ORDER
	@cp *3*=`awk /X-AX/,/Y-AX/ $(NORANK) | grep -v "Y-AX" | sed 's/.*=//' | wc -w`x`fgrep "Y-AX" $(NORANK) | sed 's/.*=//' | wc -w`=$(PES) $(@D)/MPICH_RANK_ORDER
	-cd $(dir $@); rm -rf RESTART; mkdir -p RESTART
	(cd $(@D); setenv PSC_OMP_AFFINITY FALSE; setenv OMP_NUM_THREADS 1; setenv MPICH_CPUMASK_DISPLAY; setenv MPICH_RANK_REORDER_METHOD 3; aprun $(APARGS) ../../../build/solo.$(COMPILER).prod/MOM6 >& std.out)
	rm $(@D)/MPICH_RANK_ORDER
	mv MOM6/examples/solo_ocean/benchmark/std.out $@

#@cp *3*=`fgrep "X-AX" $(NORANK) | sed 's/.*=//' | wc -w`x`fgrep "Y-AX" $(NORANK) | sed 's/.*=//' | wc -w`=$(PES) $(@D)/MPICH_RANK_ORDER
