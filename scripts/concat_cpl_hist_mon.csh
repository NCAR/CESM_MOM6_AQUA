#!/bin/csh

set echo
setenv CASE        $1
setenv DIR_DAILY   $2
setenv YEAR0       $3
setenv YEAR1       $4
setenv DIR_MONTHLY $5
unset echo

module load nco

cd $DIR_DAILY

if !(-d $DIR_MONTHLY) mkdir -p $DIR_MONTHLY

# days per month
set dpm = ( 31 28 31 30 31 30 31 31 30 31 30 31 )

set fnames_file = $DIR_MONTHLY/filelist.$$

foreach aname ( ha2x ha2x1hi ha2x1h ha2x3h ha2x1d hr2x )
  ls $CASE.cpl.$aname.????-??-??.nc >& /dev/null
  if $status then
    echo $aname files not found, skipping
  else
    # store list of files of this type, to avoid repeatedly running ls
    ls | grep cpl.$aname >! $fnames_file

    # determine, from first file of this type, how many samples per day are written
    set fname_in0 = `head -n 1 $fnames_file`
    set daily_samps = `ncdump -h $fname_in0 | grep 'time = ' | cut -f2 -d'(' | cut -f1 -d' '`
    echo $fname_in0 has $daily_samps samples per day

    # set dom_vars
    set dom_var0 = doma_aream
    set dom_vars = doma_lon,doma_lat,doma_mask
    if ($aname == "hr2x") then
      set dom_var0 = domrb_aream
      set dom_vars = domrb_lon,domrb_lat,domrb_mask
    endif

    @ yr = $YEAR0
    while ( $yr <= $YEAR1 )
      set yyyy = `printf "%04d" $yr`
      foreach m ( 1 2 3 4 5 6 7 8 9 10 11 12 )
        set mm = `printf "%02d" $m`

        set yyyymmdd0 = $yyyy-$mm-01
        # if output is daily, first input file is dd=02 of this month
        if ($daily_samps == 1) set yyyymmdd0 = $yyyy-$mm-02

        set fname_out = $DIR_MONTHLY/$CASE.cpl.$aname.$yyyy-$mm.nc
        echo creating $fname_out
        grep -A $dpm[$m] $yyyymmdd0 $fnames_file | head -n $dpm[$m] | ncrcat -O -o $fname_out

        # if $dom_var0 is not in Jan file, add it from first file of this type in the directory
        if ($m == 1) then
          ncdump -h $fname_out | grep $dom_var0 >& /dev/null
          if $status then
            echo appending $dom_var0,$dom_vars from $fname_in0 to $fname_out
            ncks -A -v $dom_var0,$dom_vars $fname_in0 $fname_out
          endif
        endif
      end
      @ yr++
    end
    rm -f $fnames_file
  endif
end

