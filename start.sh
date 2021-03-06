#!/bin/bash
### Set important parameters ###
run=testy_test
readme="testing brave_new_SCF scripting"
resolution=HR  
#Options for resolution are LR, HR, SHR
work_dir=/work/kkadam/scf_runs
greens=".true."
greens_repo=/work/kkadam/scf_runs/tmr_smz_arrays


### Edit main.F90 to incorporate green's function array ###
sed -i -e '195d' main.F90
sed -i "195i\ have_green_funcs = $greens" main.F90


### Edit runscf.h file ###
if [ $resolution == "LR" ]
then
   sed -i -e '1,3d' runscf.h
   sed -i "1i\    integer, parameter :: numr = 130" runscf.h
   sed -i "2i\    integer, parameter :: numz = 130" runscf.h
   sed -i "3i\    integer, parameter :: numphi = 256" runscf.h
   tm=tmr_array_130x130x256
   sm=smz_array_130x130x256

elif [ $resolution == "HR" ] 
then
   sed -i -e '1,3d' runscf.h
   sed -i "1i\    integer, parameter :: numr = 258" runscf.h
   sed -i "2i\    integer, parameter :: numz = 258" runscf.h
   sed -i "3i\    integer, parameter :: numphi = 512" runscf.h
   tm=tmr_array_258x258x512
   sm=smz_array_258x258x512

elif [ $resolution == "SHR" ] 
then
   sed -i -e '1,3d' runscf.h
   sed -i "1i\    integer, parameter :: numr = 258" runscf.h
   sed -i "2i\    integer, parameter :: numz = 258" runscf.h
   sed -i "3i\    integer, parameter :: numphi = 512" runscf.h
   tm=tmr_array_514x514x1024
   sm=smz_array_514x514x1024
else
   echo "================================================="
   echo "Wrong resolution! Allowed values are LR, HR, SHR."
   echo "================================================="
   exit
fi

### Edit init file ??###
#sed -i -e '1,2d' init


### Make the binary ###
make clean
make

if [ $? -eq 0 ]
then  
   echo "========================================================"
   echo " Binary file "scf" successfully compiled!"
   echo "========================================================"
else
   echo "========================================================"
   echo "ERROR: COMPILATION FAILED"
   echo "========================================================"
   exit
fi


### Make run_dir and copy files ###
if [ -d $run ]; then
   rm -r $run
fi

mkdir $run
cp scf $run
cp init $run
cp runscf.h $run
echo $readme > $run/readme

sed -i -e '8d' bs
sed -i "8i\#PBS -N $run" bs
sed -i -e '11d' bs
sed -i "11i\\$work_dir\/$run\/scf" bs

cp bs $run
if [ -d $work_dir\/$run ]; then
   echo "========================================================"
   echo "The run \"$run\" is ready in current working directory,"
   echo "because a directory with the same name is present in "
   echo "$work_dir "
   if [ $greens == ".true." ]; then
      echo "tmr_array and smz array are not copied in $run"
   fi
   echo "========================================================"
else
   mv $run $work_dir
   if [ $greens == ".true." ]; then 
      echo "Copying tmr_array and smz_array..."
      cp "$greens_repo/$tm" "$work_dir/$run/tmr_array"
      cp "$greens_repo/$sm" "$work_dir/$run/smz_array"
   fi
   echo "============================================================"
   echo "The run \"$run\" is ready in $work_dir!"
   echo "============================================================"
fi







