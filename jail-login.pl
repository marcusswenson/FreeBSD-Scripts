#!/usr/bin/env perl


################################################################################
# Author: mswenson.dev
# Date: 2025.01.06
#
# This script makes it easier to select a FreeBSD jail to login to as root.
################################################################################


use strict;
use warnings;
use utf8;
use Data::Dumper;


# Capture a list of output showing which jails are running.
my @cmd_output = split("\n", my $cmd_output = `jls`);
shift(@cmd_output);

# Go through each jail and capture the jail_id, jail_name, and jail_path
my @jail_names;
foreach my $line (@cmd_output) {
    $line =~ /^\s+(\d+)\s+(\w+)\s+(\/.+)$/;
    my $jail_id = $1;
    my $jail_name = $2;
    my $jail_path = $3;

    push(@jail_names, $jail_name);
}

print "\n";
print ">> Select the number of the jail to login to:\n\n";

my $number = 1;
foreach (@jail_names) {
    print "\t${number}. ${_}\n";
    $number++;
}

print "\n>> Selection: ";
chomp(my $selection = <STDIN>);
$selection =~ s/\s//g; # Remove whitespace globally

# Now handle our selection - either print an error or drop to a login.
if ($selection =~ /^\d+$/ && $selection > 0 && defined($jail_names[$selection - 1])) {
    my $selected_jail_name = $jail_names[$selection - 1];
    print "\n>> Logging into '${selected_jail_name}' jail as root...\n\n";
    exec("jexec ${selected_jail_name} login -f root");
} else {
    print "\n>> '${selection}' is not a valid choice.\n\n";
}
