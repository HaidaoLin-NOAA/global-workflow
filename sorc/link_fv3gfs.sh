#!/bin/ksh
set -ex

#--make symbolic links for EMC installation and hardcopies for NCO delivery

RUN_ENVIR=${1}
machine=${2}

if [ $# -lt 2 ]; then
    echo '***ERROR*** must specify two arguements: (1) RUN_ENVIR, (2) machine'
    echo ' Syntax: link_fv3gfs.sh ( nco | emc ) ( cray | dell | theia | hera )'
    exit 1
fi

if [ $RUN_ENVIR != emc -a $RUN_ENVIR != nco ]; then
    echo 'Syntax: link_fv3gfs.sh ( nco | emc ) ( cray | dell | theia | hera )'
    exit 1
fi
if [ $machine != cray -a $machine != theia -a $machine != dell -a $machine != hera ]; then
    echo 'Syntax: link_fv3gfs.sh ( nco | emc ) ( cray | dell | theia | hera )'
    exit 1
fi

LINK="ln -fs"
SLINK="ln -fs"
[[ $RUN_ENVIR = nco ]] && LINK="cp -rp"

pwd=$(pwd -P)

#------------------------------
#--model fix fields
#------------------------------
if [ $machine == "cray" ]; then
    FIX_DIR="/gpfs/hps3/emc/global/noscrub/emc.glopara/git/fv3gfs/fix"
elif [ $machine = "dell" ]; then
    FIX_DIR="/gpfs/dell2/emc/modeling/noscrub/emc.glopara/git/fv3gfs/fix"
elif [ $machine = "theia" ]; then
    FIX_DIR="/scratch4/NCEPDEV/global/save/glopara/git/fv3gfs/fix"
elif [ $machine = "hera" ]; then
    FIX_DIR="/scratch1/NCEPDEV/global/glopara/fix"
fi
cd ${pwd}/../fix                ||exit 8
for dir in fix_am fix_chem fix_fv3 fix_orog fix_fv3_gmted2010 fix_verif; do
    [[ -d $dir ]] && rm -rf $dir
done
$LINK $FIX_DIR/* .

# if [ -d ${pwd}/ufs_utils.fd ]; then
#   cd ${pwd}/ufs_utils.fd/sorc
#   ./link_fixdirs.sh $RUN_ENVIR $machine
# fi

#---------------------------------------
#--add files from external repositories
#---------------------------------------
cd ${pwd}/../jobs               ||exit 8
    $LINK ../sorc/gfs_post.fd/jobs/JGLOBAL_POST_MANAGER      .
    $LINK ../sorc/gfs_post.fd/jobs/JGLOBAL_NCEPPOST          .
cd ${pwd}/../parm               ||exit 8
    [[ -d post ]] && rm -rf post
    $LINK ../sorc/gfs_post.fd/parm                           post
cd ${pwd}/../scripts            ||exit 8
    $LINK ../sorc/gfs_post.fd/scripts/exgdas_nceppost.sh.ecf .
    $LINK ../sorc/gfs_post.fd/scripts/exgfs_nceppost.sh.ecf  .
    $LINK ../sorc/gfs_post.fd/scripts/exglobal_pmgr.sh.ecf   .
    $LINK ../sorc/ufs_utils.fd/scripts/exemcsfc_global_sfc_prep.sh.ecf .
cd ${pwd}/../ush                ||exit 8
    for file in fv3gfs_downstream_nems.sh  fv3gfs_dwn_nems.sh  gfs_nceppost.sh  \
        gfs_transfer.sh  link_crtm_fix.sh  trim_rh.sh fix_precip.sh; do
        $LINK ../sorc/gfs_post.fd/ush/$file                  .
    done
    for file in emcsfc_ice_blend.sh  fv3gfs_driver_grid.sh  fv3gfs_make_orog.sh  global_cycle_driver.sh \
        emcsfc_snow.sh  fv3gfs_filter_topo.sh  global_chgres_driver.sh  global_cycle.sh \
        fv3gfs_chgres.sh  fv3gfs_make_grid.sh  global_chgres.sh chgres_cube.sh; do
        $LINK ../sorc/ufs_utils.fd/ush/$file                  .
    done
cd ${pwd}/../util               ||exit 8
    for file in sub_slurm sub_wcoss_c sub_wcoss_d ; do
        $LINK ../sorc/ufs_utils.fd/util/$file
    done



#------------------------------
#--add gfs_wafs link if on Dell
# if [ $machine = dell -o $machine = hera ]; then 
# #------------------------------
#  cd ${pwd}/../jobs               ||exit 8
#      $LINK ../sorc/gfs_wafs.fd/jobs/*                         .
#  cd ${pwd}/../parm               ||exit 8
#      [[ -d wafs ]] && rm -rf wafs
#     $LINK ../sorc/gfs_wafs.fd/parm/wafs                      wafs
#  cd ${pwd}/../scripts            ||exit 8
#     $LINK ../sorc/gfs_wafs.fd/scripts/*                      .
#  cd ${pwd}/../ush                ||exit 8
#     $LINK ../sorc/gfs_wafs.fd/ush/*                          .
#  cd ${pwd}/../fix                ||exit 8
#     $LINK ../sorc/gfs_wafs.fd/fix/*                          .
# fi


#------------------------------
#--add GSI/EnKF file
#------------------------------
cd ${pwd}/../jobs               ||exit 8
    $LINK ../sorc/gsi.fd/jobs/JGDAS_ENKF_FCST            .
    $LINK ../sorc/gsi.fd/jobs/JGDAS_ENKF_POST            .
cd ${pwd}/../scripts            ||exit 8
cd ${pwd}/../fix                ||exit 8
    [[ -d fix_gsi ]] && rm -rf fix_gsi
    $LINK ../sorc/gsi.fd/fix  fix_gsi


#------------------------------
#--add DA Monitor file (NOTE: ensure to use correct version)
#------------------------------
cd ${pwd}/../fix                ||exit 8
    [[ -d gdas ]] && rm -rf gdas
    mkdir -p gdas
    cd gdas
    $LINK ../../sorc/gsi.fd/util/Minimization_Monitor/nwprod/gdas.v1.0.0/fix/gdas_minmon_cost.txt            .
    $LINK ../../sorc/gsi.fd/util/Minimization_Monitor/nwprod/gdas.v1.0.0/fix/gdas_minmon_gnorm.txt           .
    $LINK ../../sorc/gsi.fd/util/Ozone_Monitor/nwprod/gdas_oznmon.v2.0.0/fix/gdas_oznmon_base.tar            .
    $LINK ../../sorc/gsi.fd/util/Ozone_Monitor/nwprod/gdas_oznmon.v2.0.0/fix/gdas_oznmon_satype.txt          .
    $LINK ../../sorc/gsi.fd/util/Radiance_Monitor/nwprod/gdas_radmon.v3.0.0/fix/gdas_radmon_base.tar         .
    $LINK ../../sorc/gsi.fd/util/Radiance_Monitor/nwprod/gdas_radmon.v3.0.0/fix/gdas_radmon_satype.txt       .
    $LINK ../../sorc/gsi.fd/util/Radiance_Monitor/nwprod/gdas_radmon.v3.0.0/fix/gdas_radmon_scaninfo.txt     .
cd ${pwd}/../jobs               ||exit 8
cd ${pwd}/../parm               ||exit 8
    [[ -d mon ]] && rm -rf mon
    mkdir -p mon
    cd mon
    $LINK ../../sorc/gsi.fd/util/Radiance_Monitor/nwprod/gdas_radmon.v3.0.0/parm/gdas_radmon.parm            da_mon.parm
#   $LINK ../../sorc/gsi.fd/util/Minimization_Monitor/nwprod/gdas.v1.0.0/parm/gdas_minmon.parm               .
#   $LINK ../../sorc/gsi.fd/util/Minimization_Monitor/nwprod/gfs.v1.0.0/parm/gfs_minmon.parm                 .
    $LINK ../../sorc/gsi.fd/util/Ozone_Monitor/nwprod/gdas_oznmon.v2.0.0/parm/gdas_oznmon.parm               .
#   $LINK ../../sorc/gsi.fd/util/Radiance_Monitor/nwprod/gdas_radmon.v3.0.0/parm/gdas_radmon.parm            .
cd ${pwd}/../scripts            ||exit 8
cd ${pwd}/../ush                ||exit 8
    $LINK ../sorc/gsi.fd/util/Minimization_Monitor/nwprod/minmon_shared.v1.0.1/ush/minmon_xtrct_costs.pl     .
    $LINK ../sorc/gsi.fd/util/Minimization_Monitor/nwprod/minmon_shared.v1.0.1/ush/minmon_xtrct_gnorms.pl    .
    $LINK ../sorc/gsi.fd/util/Minimization_Monitor/nwprod/minmon_shared.v1.0.1/ush/minmon_xtrct_reduct.pl    .
    $LINK ../sorc/gsi.fd/util/Ozone_Monitor/nwprod/oznmon_shared.v2.0.0/ush/ozn_xtrct.sh                     .
    $LINK ../sorc/gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/ush/radmon_ck_stdout.sh           .
    $LINK ../sorc/gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/ush/radmon_err_rpt.sh             .
    $LINK ../sorc/gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/ush/radmon_verf_angle.sh          .
    $LINK ../sorc/gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/ush/radmon_verf_bcoef.sh          .
    $LINK ../sorc/gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/ush/radmon_verf_bcor.sh           .
    $LINK ../sorc/gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/ush/radmon_verf_time.sh           .

#------------------------------
#--add prep-chem files
#------------------------------
cd ${pwd}/../jobs               ||exit 8
    $LINK ../sorc/gsd_prep_chem.fd/workflow/emc-global/jobs/JGLOBAL_PREP_CHEM          .
cd ${pwd}/../scripts            ||exit 8
    $LINK ../sorc/gsd_prep_chem.fd/workflow/emc-global/scripts/exglobal_prep_chem.sh .

#------------------------------
#--link executables 
#------------------------------

cd $pwd/../exec
[[ -s global_fv3gfs.x ]] && rm -f global_fv3gfs.x
$LINK ../sorc/fv3gfs.fd/NEMS/exe/global_fv3gfs.x .
if [ -d ../sorc/fv3gfs.fd/WW3/exec ]; then # Wave execs
  for waveexe in ww3_gint ww3_grib ww3_grid ww3_multi ww3_ounf ww3_ounp ww3_outf ww3_outp ww3_prep ww3_prnc; do
    [[ -s $waveexe ]] && rm -f $waveexe
    $LINK ../sorc/fv3gfs.fd/WW3/exec/$waveexe .
  done
fi

[[ -s gfs_ncep_post ]] && rm -f gfs_ncep_post
$LINK ../sorc/gfs_post.fd/exec/ncep_post gfs_ncep_post

if [ $machine = dell -o $machine = hera ]; then 
    for wafsexe in wafs_awc_wafavn  wafs_blending  wafs_cnvgrib2  wafs_gcip  wafs_makewafs  wafs_setmissing; do
        [[ -s $wafsexe ]] && rm -f $wafsexe
        $LINK ../sorc/gfs_wafs.fd/exec/$wafsexe .
    done
fi

for ufs_utilsexe in chgres_cube nemsio_get nemsio_read global_chgres ; do
    [[ -s $ufs_utilsexe ]] && rm -f $ufs_utilsexe
    $LINK ../sorc/ufs_utils.fd/exec/$ufs_utilsexe .
done

for gsiexe in  global_gsi.x global_enkf.x calc_increment_ens.x getsfcensmeanp.x \
    getsigensmeanp_smooth.x getsigensstatp.x recentersigp.x oznmon_horiz.x \
    oznmon_time.x radmon_angle.x radmon_bcoef.x radmon_bcor.x radmon_time.x ;do
    [[ -s $gsiexe ]] && rm -f $gsiexe
    $LINK ../sorc/gsi.fd/exec/$gsiexe .
done

[[ -s prep_chem_sources_RADM_FV3_SIMPLE.exe ]] && rm -f prep_chem_sources_RADM_FV3_SIMPLE.exe
$LINK ../sorc/gsd_prep_chem.fd/workflow/emc-global/exec/prep_chem_sources_RADM_FV3_SIMPLE.exe .

#------------------------------
#--link source code directories
#------------------------------

cd ${pwd}/../sorc   ||   exit 8
    $SLINK gsi.fd/util/EnKF/gfs/src/calc_increment_ens.fd                                  calc_increment_ens.fd
    $SLINK gsi.fd/util/EnKF/gfs/src/calc_increment_ens_gsdchem.fd                          calc_increment_ens_gsdchem.fd
    $SLINK gsi.fd/util/EnKF/gfs/src/getsfcensmeanp.fd                                      getsfcensmeanp.fd
    $SLINK gsi.fd/util/EnKF/gfs/src/getsigensmeanp_smooth.fd                               getsigensmeanp_smooth.fd
    $SLINK gsi.fd/util/EnKF/gfs/src/getsigensstatp.fd                                      getsigensstatp.fd
    $SLINK gsi.fd/src                                                                      global_enkf.fd
    $SLINK gsi.fd/src                                                                      global_gsi.fd
    $SLINK gsi.fd/util/Ozone_Monitor/nwprod/oznmon_shared.v2.0.0/sorc/oznmon_horiz.fd      oznmon_horiz.fd
    $SLINK gsi.fd/util/Ozone_Monitor/nwprod/oznmon_shared.v2.0.0/sorc/oznmon_time.fd       oznmon_time.fd
    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radang.fd    radmon_angle.fd
    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radbcoef.fd  radmon_bcoef.fd
    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radbcor.fd   radmon_bcor.fd 
    $SLINK gsi.fd/util/Radiance_Monitor/nwprod/radmon_shared.v3.0.0/sorc/verf_radtime.fd   radmon_time.fd 
    $SLINK gsi.fd/util/EnKF/gfs/src/recentersigp.fd                                        recentersigp.fd

    $SLINK gfs_post.fd/sorc/ncep_post.fd                                                   gfs_ncep_post.fd

    $SLINK ufs_utils.fd/sorc/fre-nctools.fd/tools/shave.fd                                 shave.fd
    for prog in filter_topo fregrid make_hgrid make_solo_mosaic ; do
        $SLINK ufs_utils.fd/sorc/fre-nctools.fd/tools/$prog                                ${prog}.fd                                
    done
    for prog in  chgres_cube.fd       global_cycle.fd   nemsio_read.fd \
                 mkgfsnemsioctl.fd  nst_tf_chg.fd \
                 global_chgres.fd  nemsio_get.fd      orog.fd ;do
        $SLINK ufs_utils.fd/sorc/$prog                                                     $prog
    done


    if [ $machine = dell -o $machine = hera ]; then
        $SLINK gfs_wafs.fd/sorc/wafs_awc_wafavn.fd                                              wafs_awc_wafavn.fd
        $SLINK gfs_wafs.fd/sorc/wafs_blending.fd                                                wafs_blending.fd
        $SLINK gfs_wafs.fd/sorc/wafs_cnvgrib2.fd                                                wafs_cnvgrib2.fd
        $SLINK gfs_wafs.fd/sorc/wafs_gcip.fd                                                    wafs_gcip.fd
        $SLINK gfs_wafs.fd/sorc/wafs_makewafs.fd                                                wafs_makewafs.fd
        $SLINK gfs_wafs.fd/sorc/wafs_setmissing.fd                                              wafs_setmissing.fd
    fi


#------------------------------
#--choose dynamic config.base for EMC installation 
#--choose static config.base for NCO installation 
cd $pwd/../parm/config
[[ -s config.base ]] && rm -f config.base 
if [ $RUN_ENVIR = nco ] ; then
 cp -p config.base.nco.static config.base
else
 cp -p config.base.emc.dyn config.base
fi
#------------------------------


exit 0



