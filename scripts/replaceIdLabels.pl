#!/usr/bin/perl -w 
# This script replaces Folio ID Labels with real UUIDs
# Can be applied to all files *.idlabels below a directory, or to a single file.
# Author: Ingolf Kuss, HBZ-NRW
# Creation date: Dec. 7th, 2020
# Help page   :  perl replaceIdLabels.pl -h
# Sample call :  perl replaceIdLabels.pl -d ../sample_inventory

use File::Basename;
use File::Find;
use Getopt::Std;
use strict;
use utf8;
use open ':encoding(utf8)';
binmode STDOUT,':encoding(UTF-8)';

use constant {
    FCT_RC_OK      => 0,
    FCT_RC_NOTOK   => 1
};

#*************************
# Global script variables
# with default assignments
# *************************
my $script = basename( $0 );
my $log = *STDOUT;
my $logfile = $script;
$logfile =~ s/\.pl$/.log/;
my $input_dir = "../sample_inventory";
my $input_file = "../sample_inventory/instances/1891.json.idlabels";
my $scripts_out = "../scripts_out";
my $mapping_file=$scripts_out."/IdLabelsMap.csv";
my %mappingTable = ();

# **********************************
# Evaluate command line options
# **********************************
my %opts=();
getopts('d:f:hm:sS', \%opts) or usage("Invalid command line options!");
if( !defined($opts{s}) && !defined($opts{S}) ) {
  open LOG, ">$logfile" or die "Cannot open log file $logfile ($!)!\n";
  $log = *LOG;
  printf "Writing log to file %s\n", $logfile;
  }
if ( defined($opts{h}) ) {
  usage("Usage:");
  }
if ( defined($opts{d}) ) {
  $input_dir = $opts{d};
  }
if ( defined($opts{f}) ) {
  $input_file = $opts{f};
  }
if ( defined($opts{m}) ) {
  $mapping_file = $opts{m};
  }

# ****************************
#[Subroutines (Perl Functions)
# ****************************
sub readMappingTable {
  # Reads the mapping table (a .csv file)
  open MAP, "<$mapping_file" or die "Cannot open mapping file ($mapping_file) ($!)!";
  my $line = "";
  my @parts = ();
  my $lineno = 0;
  my $id_label = "";
  my $id = "";
  while (<MAP>) {
    $line = $_; chomp($line);
    $lineno++;
    if( ! defined $line || $line eq "" ) { next; }
    if( $line =~ m/^#/ ) { next; } # commentary line
    @parts = split /;/, $line;
    if( $#parts != 1 ) {
      print $log "WARN: Not exatly 2 fields (separated by semicola) in one line of the mapping file !\n";
      print $log "WARN:   in line number (%d) of file (%s)\n", $lineno, $mapping_file;
      print $log "WARN:   Content of line = (%s)\n", $line;
      print $log "WARN:   This line will be ignored.\n";
      next;
      } 
    $id_label = $parts[0];
    if ( $id_label !~ m/^\?/ || $id_label !~ m/\?$/ ) {
      print $log "WARN: ID-Label (%s) neither begins with \"?\" or it doesn't end with \"?\" !\n", $id_label;
      print $log "WARN:   Label will be processed anyway (it has possibly been defined erroneously) !\n";
      }
    $id_label =~ s/^\?//;
    $id_label =~ s/\?$//;
    $id = $parts[1];
    printf $log "INFO: Adding mapping rule: (%s) -> (%s)\n", $id_label, $id;
    $mappingTable{$id_label} = $id;
    }
  close MAP;
  printf $log "INFO: Function returns with return code (%d)\n", FCT_RC_OK;
  return FCT_RC_OK;
  }

sub process_file {
  if (($_ eq '.') || ($_ eq '..')) { return FCT_RC_OK; }
  if (-d && $_ eq 'fp'){
      $File::Find::prune = 1;
      return;
  }
  if( -d ) {
    printf $log "Processing directory: $_\n";
    return FCT_RC_OK;
    }
  if( -f ) {
    my $input_file = $_;
    if( $input_file !~ m/\.json\.idlabels$/ ) { return; }
    &bearb_datei( $input_file );
    }
  return FCT_RC_OK;
  }

sub bearb_datei {
  my $input_file = shift;
  
  printf $log "Processing file: $input_file\n";
  if( $input_file !~ m/\.idlabels$/ ) {
    printf $log "ERROR: Input file (%s) is no file of type .idlabels !\n", $input_file;
    printf $log "ERROR:   Input file is not being processed !\n";
    return FCT_RC_NOTOK;
    }
  # printf $log "INFO: Replace Folio-IDs in file (%s)\n", $input_file;
  my $output_file = $input_file;
  $output_file =~ s/\.idlabels$//;
  if( $output_file !~ m/\.json$/ ) {
    printf $log "ERROR: Output file (%s) doesn't have the ending .json !\n", $output_file;
    printf $log "ERROR:   Output file is not going to be created !\n";
    return FCT_RC_NOTOK;
    }
  open  IN, "<$input_file" or die "Cannot open input file ($input_file) ($!) !";
  open OUT, ">$output_file" or die "Cannot create output file ($output_file) ($!) !";
  my $line;
  my $id_label = "";
  while (<IN>) {
    $line = $_; chomp($line);
    if( ! defined $line || $line eq "") { print OUT "\n"; next; }
    if ($line =~ m/"\?([^"]+)\?"/) {
      $id_label = $1;
      printf $log "Found ID label (%s)", $id_label;
      if( ! exists $mappingTable{$id_label} ) {
        printf $log "\nERROR: Replacement is missing for ID label: (%s) !!\n", $id_label;
        }
      else {
        $line =~ s/"\?([^"]+)\?"/"$mappingTable{$id_label}"/;
        printf $log ", substituted by (%s)\n", $mappingTable{$id_label};
        }
      }
    # Replacement of the Boolean values:
    $line =~ s/"staffOnly" : ""/"staffOnly" : false/;
    $line =~ s/"staffOnly" : "1"/"staffOnly" : true/;
    $line =~ s/"primary" : ""/"primary" : false/;
    $line =~ s/"primary" : "1"/"primary" : true/;
    print OUT "$line\n";  
    }
  close OUT;
  close IN;
  return FCT_RC_OK;
  }
# ***************************
#] END of perl subroutines
# ***************************

# ************************
# Begin of Main Processing
# ************************
&readMappingTable();

if ( defined($opts{d}) ) {
  # Process all files with ending .json.idlabels below a directory 
  find(\&process_file, $input_dir); #provide list of paths as second argument.
  }
else {
  # Process a single file
  &bearb_datei( $input_file );
  }


printf $log "SUCCESS: $script terminating regularly.\n";
close LOG;
exit 0;

sub usage {
  my $msg = shift;
  print <<END;
  $script - Replace Folio ID labels in folio JSON files (to be loaded to inventory)
  $msg

  Call    :   perl $script
  Simple Options :
       -h :   Print this help page
    -s,-S :   Prints messages to screen; Default behavior: Prints messages to log file $logfile
  Parameter options :
       -f :   Input file (format: Folio-JSON) (This will be ignored if option -d is being used). Defaults to $input_file
       -m :   Mapping file (format: CSV). Defaults to $mapping_file
       -d :   Input directory (all JSON.idlabels files in and below this dir will be converted). Defaults to $input_dir

  Sample Call :   perl $script -d ../sample_inventory
END
  exit 0;
  }
