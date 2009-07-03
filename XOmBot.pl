#!/usr/bin/perl -w

#################################################################################
# XomBot.pl                                                                     #
#                                                                               #
# Your friendly XOmB bot for #xomb                                              #
#################################################################################

use Net::IRC;
use LWP 5.64;
use Time::HiRes qw( usleep gettimeofday tv_interval stat );
use strict;


my $irc = new Net::IRC;
my $browser = LWP::UserAgent->new;

my $conn = $irc->newconn(
	Server 		=> shift || 'irc.freenode.net',      # the network to connect to
	Port		=> shift || '6667',                  # the port to use for the connection
	Nick		=> 'XOmBot',
	Ircname		=> 'Resident XOmbie',
	Username	=> 'bot'
);

$conn->{channel} = shift || '#testchan';                  # the channel to join on successful connect


sub on_connect {

	# shift in our connection object that is passed automatically
	my $conn = shift;

	$conn->join($conn->{channel});
	$conn->privmsg($conn->{channel}, 'Brains...');
	$conn->{connected} = 1;
}

sub on_public {

	my ($conn, $event) = @_;

	# grab what was said
	my $text = $event->{args}[0];
	
	if ($text =~ m/^\!wiki\s*([\w*\s]*)/)
	{
		#check if article exists in the wiki
		my $articlename = $1;
		
		#replace spaces with _
		$articlename =~ s/\s/_/gs;
		
		my $response = $browser->get("http://wiki.xomb.org/index.php?title=$articlename"); 
		
		#check if article exists
		my $exists = 1;
		if($response->content =~ m/There is currently no text in this page/)
		{
			$exists = 0;
		}
		
		my $content = $response->content;

		# remove the html tags
		# the following line breaks syntax highlighting :( 
		$content =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;
		
		#replace _ with spaces
		$articlename =~ s/_/ /gs;
		
		if ($response->is_success && $exists == 1)
		{
			#try to get a definition
			if( $content =~ m/($articlename.*?\.)/)
			{
				$conn->privmsg($conn->{channel}, $1);
			}
			
			#replace spaces with _
			$articlename =~ s/\s/_/gs;
			
			$conn->privmsg($conn->{channel}, "Full article here: http://wiki.xomb.org/index.php?title=$articlename");
			
		}
		else
		{
			$conn->privmsg($conn->{channel}, "Sorry, there's no article by that name");
		}
	}
	
	if ($text =~ m/^XOmBot:.*/)
	{
		$conn->privmsg($conn->{channel}, "$event->{nick}: brains...");
	}

}



$conn->add_handler('public', \&on_public);

# The end of MOTD (message of the day), numbered 376 signifies we've connected
$conn->add_handler('376', \&on_connect);


# while bot is running ping the RSS and handle incoming commands
while(1) {

	
	# check the RSS
	
	$irc->do_one_loop();
}