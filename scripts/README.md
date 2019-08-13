From Keith Lindsey (klindsay@ucar.edu)

When the coupler writes it aux hist files, it writes out files that have
a day's worth of output. This is done independently of the frequency
at which the fields are averaged. datm and drof scripts are hard-coded
to expect files with a month's worth of output. So the raw daily output
needs to be concatenated into monthly files.

The attached csh script performs this concatenation. The script is on
NCAR/CISL systems at ~klindsay/bin/concat_cpl_hist_mon.csh. The script
takes 5 command line arguments that you'll need to pass in for your
particular usage. The script relies on nco, and uses the command 'module
load nco' to add nco tools to your path. If you are running this on a
non-NCAR/CISL computer system, I expect that you will need to change this.

There is some subtle logic in the script to ensure that the generated
monthly files have time samples precisely from the desired month. This
is a little tricky for streams with daily averages, because the model
date stamp in the filename of coupler generated output is from the next
day. So simple wildcard patterns are not sufficient.

Additionally, the coupler only writes domain information for each stream
in the first file written in each job submission. I think it does this to
have reduced output size. However, the datm and drof scripts are expecting
this domain information to be in the first file that they are using. So
my concatenation script takes some steps to ensure that the needed domain
information is included in every January file. This way, you can have
your datm run start on an arbitrary year for which you have forcing.
