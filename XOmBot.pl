#!/usr/bin/perl -w

#################################################################################
# XomBot.pl                                                                     #
#                                                                               #
# Your friendly XOmB bot for #xomb                                              #
#################################################################################

use Net::IRC;
use LWP 5.64;
use strict;


my $irc = new Net::IRC;
my $browser = LWP::UserAgent->new;
my $commitid = "";

my $conn = $irc->newconn(
	Server 		=> shift || 'irc.freenode.net',      # the network to connect to
	Port		=> shift || '8001',                  # the port to use for the connection
	Nick		=> 'XOmBot',
	Ircname		=> 'Resident XOmbie',
	Username	=> 'bot'
);

$conn->{channel} = shift || '#xomb';                 # the channel to join on successful connect



sub on_connect {

	# shift in our connection object that is passed automatically
	my $conn = shift;

	$conn->join($conn->{channel});
	$conn->privmsg($conn->{channel}, 'XOmBot is online. !commands will show what I can do.');
	$conn->{connected} = 1;
}

sub on_public {

	my ($conn, $event) = @_;

	# grab what was said
	my $text = $event->{args}[0];

	if($text =~ m/(http:\/\/[^ ]*)/)
	{
	  display_title($1);
	}
	
	if ($text =~ m/^\!wiki\s*([\w*\s]*)/)
	{
		# check if article exists in the wiki
		get_wiki_entry($1);
	}

	if($text eq "hi" and $event->{nick} eq "duckinator")
	{
		$conn->privmsg($conn->{channel}, "duckinator: hi");
	}
	
	if($text =~ m/^\!latest.*/)
	{
		# show the latest commit the next loop around
		$commitid = "";
	}

	if($text =~ m/^\!commands.*/)
	{
		# show all the commands that xombot listens to
		$conn->privmsg($conn->{channel}, "!wiki [search term] - will search the wiki for the given word or phrase.");
		$conn->privmsg($conn->{channel}, "!latest - will show the last commit to the offical XOmB repository.");
	}
	
	if ($text =~ m/^XOmBot:.*/)
	{
		$conn->privmsg($conn->{channel}, "$event->{nick}: brains...");
	}

}

sub get_wiki_entry {

	my $articlename = shift;
	
	#replace spaces with +
	$articlename =~ s/\s/\+/gs;

	# searching for the article rather than going directly to it allows us to ignore the issue of case sensitivity
	my $response = $browser->get("http://wiki.xomb.org/index.php?search=$articlename&go=Go");

	#check if article exists
	my $exists = 1;
	if($response->content =~ m/There is no page titled/)
	{
		$exists = 0;
	}

	my $content = $response->content;

	# remove the html tags
	# the following line breaks syntax highlighting in intype :( 
	$content =~ s/<(?:[^>'"]*|(['"]).*?\1)*>//gs;

	#replace + with spaces
	$articlename =~ s/\+/ /gs;

	if ($response->is_success && $exists)
	{
		# try to get a definition
		if( $content =~ m/(.*?$articlename.*?\.)/i)
		{
			$conn->privmsg($conn->{channel}, $1);
		}

		#replace spaces with _
		$articlename =~ s/\s/_/gs;

		$conn->privmsg($conn->{channel}, "Full article here: " . $response->base);
	}
	else
	{
		$conn->privmsg($conn->{channel}, "Sorry, there's no article by that name");
		# try to search for similar articles
		search_for_article($articlename);
	}

}

sub display_title {
  my $url = shift;
		
	my $response = $browser->get("$url");
		
	if($response->is_success)
	{
	  if($response->content =~ m/<title>(.+)<\/title>/gsi)
		{
		  $conn->privmsg($conn->{channel}, "\"$1\"");	
		}
	}
}

sub search_for_article {

	my $searchterm = shift;
	
	# replace spaces with +
	$searchterm =~ s/\s/\+/gs;
	
	my $response = $browser->get("http://wiki.xomb.org/index.php?search=$searchterm&go=Go");
	
	if($response->is_success)
	{
		if($response->content =~ m/<li><a href="\/index\.php\?title=(\w*)/)
		{
			$conn->privmsg($conn->{channel}, "Did you mean $1: http://wiki.xomb.org/index.php?title=$1");	
		}
	}

}

sub check_rss {

	my $response = $browser->get("http://github.com/feeds/xomboverlord/commits/xomb/master");

	if($response->is_success && $response->content =~ m/<entry>\s*<id>.*\/(\w*)<\/id>/)
	{
			my $commiter = "Unknown";
			my $commit_msg = "Unspecified";
			my $orig_commitid = $commitid;			
			
			#if it's not the last one we announced
			if($commitid ne $1)
			{

				$commitid = $1;
				
				# get try to get the info to announce it
				if($response->content =~ m/<entry>.*?<title>(.*?)<\/title>/s)
				{
					$commit_msg = $1;
				}

				# get try to get the author to announce it
				if($response->content =~ m/<name>(\w*)<\/name>/)
				{
					$commiter = $1;
				}				
				
				if($commit_msg ne "Sorry, this commit log is taking too long to generate.")
				{
					$conn->privmsg($conn->{channel}, "Commit made by $commiter: $commit_msg");
					$conn->privmsg($conn->{channel}, "View: http://github.com/xomboverlord/xomb/commit/$commitid");
				}
				else
				{
					# we don't know if there actually was a new commit
					$commitid = $orig_commitid;
				}
			}
	}

}



$conn->add_handler('public', \&on_public);

# The end of MOTD (message of the day), numbered 376 signifies we've connected
$conn->add_handler('376', \&on_connect);


# while bot is running ping the RSS and handle incoming commands
while(1) {

	
	# check the RSS
	check_rss();
	
	$irc->do_one_loop();
}
