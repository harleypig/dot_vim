#!/usr/bin/perl

# This is shamelessly ripped from $VIMRUNTIME/tools/efm_perl.pl (which was last
# updated in 2001 according to the version history--but I'm willing to accept
# that someone has probably made changes to it since then.) Check that file for
# details and historical information.

use strict;
use warnings;

die "Too many arguments!\n" if @ARGV > 1;

my $file = shift or die "No filename to check!\n";

my $error = qr{(.*)\sat\s(.*)\sline\s(\d+)(\.|,\snear\s\".*\"?)};

# Add error messages to be skipped.
my @skip = (

  '"DB::single" used only once: possible typo',
  'BEGIN failed--compilation aborted',

);

my $skip = join '|', @skip;

# Thanks to
# http://blogs.perl.org/users/ovid/2011/01/warningsunused-versus-ppi.html for
# the 'warnings::unused' trick.
#
# Note: warnings::unused, indirect, uninit and warnings::method need to be
# installed.

my ( $message, $extracted_file, $lineno, $rest );

for my $line ( `perl -Mwarnings::unused -M-indirect -Muninit -Mwarnings::method -c $file 2>&1` ) {

  chomp $line;
  next if $line =~ /$skip/;
  $line =~ s/([()])/\\$1/g;

  if ( ( $message, $extracted_file, $lineno, $rest ) = $line =~ /^$error$/ ) {

    $message .= $rest if ($rest =~ s/^,//);
    print "$file:$lineno:$message\n";

  }
}
