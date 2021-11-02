#!/usr/bin/perl

##################################################################################
##################################################################################
######################  Made by Tytus Kurek on November 2012  ####################
##################################################################################
##################################################################################
####     This is a Nagios Plugin destined to check the number of Asterisk     ####
####                       channels of specified type                         ####
##################################################################################
##################################################################################

use strict;
use vars qw($channel $community $critical $IP $warning);

use Getopt::Long;
use Pod::Usage;

# Subroutines execution

getParameters ();
checkAsteriskChannels ();

# Subroutines definition

sub checkAsteriskChannels ()	# Checks Asterisk channels number
{
	my $channelOID = 'ASTERISK-MIB::astChanTypeChannels';
	my $nameOID = 'ASTERISK-MIB::astChanTypeName';
	my $version = '1';

	my $command = "/usr/bin/snmpwalk -v $version -c $community $IP asterisk 2>&1";
	my $result = `$command`;

	if ($result =~ m/^Timeout.*$/)
	{
		my $output = "UNKNOWN! No SNMP response from $IP.";
		my $code = 3;
		exitScript ($output, $code);
	}

	$command = "/usr/bin/snmpwalk -v $version -c $community $IP $nameOID";
	$result = `$command`;
	my $channelNumber;
	
	if ($result =~ m/$nameOID\.(\d+)\s=\sSTRING:\s$channel.*/)
	{
		$channelNumber = $1;
	}

	else
	{
		my $output = "UNKNOWN! No channels of specified type in Asterisk. Valid channel names are: Agent, DAHDI, IAX2, Local, MGCP, Phone, SIP, Skinny, Skype.";
		my $code = 3;
		exitScript ($output, $code);
	}

	my $channelOID = "$channelOID.$channelNumber";
	$command = "/usr/bin/snmpwalk -v $version -c $community $IP $channelOID";
	$result = `$command`;
	$result =~ m/ASTERISK-MIB::astChanTypeChannels.$channelNumber\s=\sGauge32:\s(\d+)/;
	my $number = $1;

	if (($warning ne '') && ($critical ne ''))
	{
		if ($number >= $critical)
		{
			my $output = "CRITICAL! Number of $channel channels - $number - exceeds threshold of $critical. | 'channels number'=$number";
			my $code = 2;
			exitScript ($output, $code);
		}

		if ($number >= $warning)
		{
			my $output = "WARNING! Number of $channel channels - $number - exceeds threshold of $warning. | 'channels number'=$number";
			my $code = 1;
			exitScript ($output, $code);
		}

		my $output = "OK! Number of $channel channels - $number. | 'channels number'=$number";
		my $code = 0;
		exitScript ($output, $code);
	}

	else
	{
		my $output = "OK! Number of $channel channels - $number. | 'channels number'=$number";
		my $code = 0;
		exitScript ($output, $code);
	}
}

sub exitScript ()	# Exits the script with an appropriate message and code
{
	print "$_[0]\n";
	exit $_[1];
}

sub getParameters ()	# Obtains script parameters and prints help if needed
{
	my $help = '';

	GetOptions ('help|?' => \$help,
		    'C=s' => \$community,
		    'H=s' => \$IP,
		    'T=s' => \$channel,
		    'warn:s' => \$warning,
		    'crit:s' => \$critical)

	or pod2usage (1);
	pod2usage (1) if $help;
	pod2usage (1) if (($channel eq '') || ($community eq '') || ($IP eq ''));
	if (($warning ne '') && ($critical ne ''))
	{
		pod2usage (1) if (($warning !~ m/^\d+$/) || ($critical !~ m/^\d+$/));
	}

=head1 SYNOPSIS

check_asterisk_channels.pl [options] (-help || -?)

=head1 OPTIONS

Mandatory:

-H	IP address of monitored Asterisk instance

-C	SNMP community

-T	Channel type

Optional:

-warn	Warning threshold

-crit	Critical threshold

=cut
}
