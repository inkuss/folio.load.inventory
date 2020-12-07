#!/usr/bin/perl -w
# Purpose of script: Creates a mapping table @ID-Label@ ==> actual uuid in your Folio instance
# Author: Ingolf Kuss, HBZ-NRW
# Creation date: Dec. 07th, 2020
# Output: A mapping table file ../scripts_out/IdLabelsMap.csv
# Please provide an authentication file login.json with the following content:
#     { "tenant" : "$tenant", "username" : "$username", "password" : "$password" }
# For Help call:  perl createIdLabels.pl -h

use Getopt::Std;
use File::Basename;
use JSON::Parse 'json_file_to_perl';
use strict;
use utf8;
use open ':encoding(utf8)';

use constant {
    FCT_RC_OK      => 0,
    FCT_RC_NOTOK   => 1
};

# *************************
# Global script variables
# with default assignments
# *************************
my $script = basename( $0 );
my $log = *STDOUT;
my $logfile = $script;
$logfile =~ s/\.pl$/.log/;
my $scripts_out = "../scripts_out";
my $mapping_file=$scripts_out."/IdLabelsMap.csv";
my $okapi_url = "api.localhost/okapi";
my $tenant = "diku";
my $login_file = "login.json";

# Folio table names which contain type definitions, status definitions or other definitions of system identifiers (UUIDs)
my @tableNames = ( "AlternativeTitleTypes"
	# , "CallNumberTypes"
	# , "ClassificationTypes"
	#  , "ContributorNameTypes"
	# , "ContributorTypes"
	# , "ElectronicAccessRelationships"
	# , "IdentifierTypes"
	# , "InstanceFormats"
	# , "InstanceNoteTypes"
	# , "InstanceRelationshipTypes"
	# , "InstanceStatuses"
	# , "InstanceTypes"
	# , "ItemDamageStatuses"
	# , "ItemNoteTypes"
	# , "LoanTypes"
	# , "Locations"
	# , "MaterialTypes"
	# , "IssuanceModes"
	# , "NatureOfContentTerms"
	# , "ServicePoints"
                 ## , "ShelfLocations"
		 # , "StatisticalCodes"
                 );

# **********************************
# Evaluate command line options
# **********************************
my %opts=();
getopts('hl:m:o:sSt:u:', \%opts) or usage("Invalid command line options");
if( !defined($opts{s}) && !defined($opts{S}) ) {
  open LOG, ">$logfile" or die "Cannot open log file $logfile ($!)!\n";
  $log = *LOG;
  printf "Writing log to file %s\n", $logfile;
  }
if ( defined($opts{h}) ) {
  usage("Usage:");
  }
if ( defined($opts{l}) ) {
  $login_file = $opts{l};
  }
if ( defined($opts{m}) ) {
  $mapping_file = $opts{m};
  }
if ( defined($opts{o}) ) {
  $scripts_out = $opts{o};
  }
if ( defined($opts{t}) ) {
  $tenant = $opts{t};
  }
if ( defined($opts{u}) ) {
  $okapi_url = $opts{u};
  }

# ************************
# Print script parameters
# ************************
print $log "Starting $script.\n";
printf $log "Mapping file: %s\n", $mapping_file;
printf $log "Okapi-URL: %s\n", $okapi_url;
printf $log "Tenant: %s\n", $tenant;
printf $log "Authentications file: %s\n", $login_file;
printf $log "Scripts output directory: %s\n", $scripts_out;

# ****************************
# Subroutines (Perl Functions)
# ****************************
sub process_tableName {
  # Processes one Folio table
  my $tableName = shift;
  printf $log "Table name: %s\n", $tableName;
  # Read contents of the table and write it into a file (format: JSON)
  system("sh get".$tableName.".sh -u $okapi_url -t $tenant -l $login_file > $scripts_out/get${tableName}.json");
  # Read the json file which has just been created
  my $perl_json_object = json_file_to_perl("$scripts_out/get${tableName}.json");
  my $content="";
  my $idDef="";
  my $code="";
  my $id="";
  foreach my $key (keys %{$perl_json_object}) {
    # print $log "key=$key\n";
    if( $key ne "totalRecords" ) {
      $content = $perl_json_object->{$key};
      # This should be a list. Go through this list, finde key-value pairs name/id and write values into the mapping file
      $tableName =~ s/s$//;
      foreach my $idDef (@{$content}) {
        if( defined $idDef->{code} ) {
          $code = $idDef->{code};
          }
        else {
          $code = $idDef->{name};
          }
        $id = $idDef->{id};
        $code =~ s/[ \t]/_/g;
        $code =~ s/\?/\\?/g;
        printf $log "  Found code: %s\n", $code;
        printf CSV "?${tableName}_$code?;$id;\n";
        }
      last;
      } 
    }
  return FCT_RC_OK;
  }

# ************************
# Begin of Main Processing
# ************************
open CSV, ">$mapping_file";
for my $tableName ( @tableNames ) {
  &process_tableName( $tableName );
  }
close CSV;

printf $log "SUCCESS: $script terminating regularly.\n";
close LOG;
exit 0;

sub usage {
  my $msg = shift;
  print <<END;
  $script - Create a mapping table for Folio ID Labels.
  $msg
  Please provide an authentication file login.json with the following content:
      { "tenant" : "<your tenant>", "username" : "<your user name>", "password" : "<your password>" }

  Call   :   perl $script
  Options:
       -h :   Print this help page
    -s,-S :   Prints messages to screen; Default behavior: Prints messages to log file $logfile
  Parameter Options:
       -l :   Authentication file: Defaults to $login_file
       -m :   The Mapping table file. Defaults to $mapping_file
       -o :   Output directory for dependent scripts. Will contain output of endpoints of your Folio instance in JSON format.
              Defaults to $scripts_out
       -t :   Folio Tenant. Defaults to $tenant
       -u :   Your Okapi URL. Defaults to $okapi_url
END
  exit 0;
  }
