#!/usr/bin/perl -w

#################################################################################
# XomBot.pl                                                                     #
#                                                                               #
# Your friendly XOmB bot for #xomb                                              #
#################################################################################

package Bot;
use base qw(Bot::BasicBot);
use warnings;
use strict;
use URI::Title qw( title );
use URI::Find::Simple qw( list_uris );
use LWP 5.64;

my($thechannel) = '##l2l';
my $browser = LWP::UserAgent->new;
my $commitid = "";
my $first = 1;

my ($bot) = Bot->new(
		server => "irc.freenode.net",
		port => "8001",
		channels => [ $thechannel ],
		nick => 't3hp1ck',
		charset => 'utf-8',
		);

$bot->run();

sub connected {
		my $self = shift;
		$self->say(channel => $thechannel, body => 'XOmBot is online. !commands will show what I can do.');
}

sub tick {
		check_rss();
		return 60;
}

sub said {
		my $self = shift;
		my $message = shift;
		my $body = $message->{body};
		my $nick = $message->{who};
		my $channel = $message->{channel};
		my $address = $message->{address};

		if(my @urls = list_uris($body)){
				#$self->say(channel => $channel, body => title($_)) for (@urls);
				#$self->reply($message, title($_)) for (@urls);
				display_title($_) for (@urls);
		}

		if ($body =~ m/^\!wiki\s*([\w*\s]*)/){
				# check if article exists in the wiki
				get_wiki_entry($1);
		}

		if($body eq "hi" and $nick eq "duckinator"){
				$self->say(channel => $channel, who => $nick, body => "hi", address => "1");
		}
		
		if($body =~ m/^\!latest.*/){
				# show the latest commit the next loop around
				$commitid = "";
		}

		if($body =~ m/^\!commands.*/){
				# show all the commands that xombot listens to
				$self->say(channel => $channel, body => "!wiki [search term] - will search the wiki for the given word or phrase.");
				$self->say(channel => $channel, body => "!latest - will show the last commit to the offical XOmB repository.");
		}
	
		if ($address){ #($body =~ m/^XOmBot:(.*)/){
				my($compliment) = $body;
		
				if($compliment =~ m/good/){
						$self->emote(channel => $channel, body => "drools");
				}elsif($compliment =~ m/bad/){
						$self->emote(channel => $channel, body => "cowers");
				}elsif($compliment =~ m/google (.*) for (.*)/){
						my($term) = $1;
						my($target) = $2;
						
						$term =~ s/ /+/g;
						
						$self->say(channel => $channel, who => $target, address => "1", body => "http://lmgtfy.com/?q=$term");
						
				}else{
						$self->say(channel => $channel, who => $nick, address => "1", body => "brains...");
				}
		}

		return undef;
}

sub check_rss {
		my $response = $browser->get("http://github.com/feeds/xomboverlord/commits/xomb/master");

		if($response->is_success && $response->content =~ m/<entry>\s*<id>.*\/(\w*)<\/id>/){
				my $commiter = "Unknown";
				my $commit_msg = "Unspecified";
				my $orig_commitid = $commitid;			
			
				#if it's not the last one we announced
				if($commitid ne $1){
						$commitid = $1;
				
						# get try to get the info to announce it
						if($response->content =~ m/<entry>.*?<title>(.*?)<\/title>/s){
								$commit_msg = $1;
						}

						# get try to get the author to announce it
						if($response->content =~ m/<name>(\w*)<\/name>/){
								$commiter = $1;
						}				
				
						if($commit_msg ne "Sorry, this commit log is taking too long to generate."){
								unless($first){
										$bot->say(channel => $thechannel, body => "Commit made by $commiter: $commit_msg");
										$bot->say(channel => $thechannel, body => "View: http://github.com/xomboverlord/xomb/commit/$commitid");
								}else{
										$first = 0;
								}
						}else{
								# we don't know if there actually was a new commit
								$commitid = $orig_commitid;
						}
				}
		}
}


sub display_title {
  my $url = shift;

	#$bot->say(channel => $thechannel, body => $url);
		
	my $response = $browser->get("$url");
	
	if($response->is_success){
			$bot->say(channel => $thechannel, body => ($response->content) );
			
			if($response->content =~ m/<title>(.+)<\/title>/si){
					my($title) = $1;
					
					$title =~ s/\s/ /gs;
					$title =~ s/ +/ /gs;
					
					$title =~ s/^ //;
					$title =~ s/ $//;
					
					$bot->say(channel => $thechannel, body => "\"$title\"");	
			}
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
			$bot->say(channel => $thechannel, body => $1);
		}

		#replace spaces with _
		$articlename =~ s/\s/_/gs;

		$bot->say(channel => $thechannel, body => "Full article here: " . $response->base);
	}
	else
	{
		$bot->say(channel => $thechannel, body => "Sorry, there's no article by that name");
		# try to search for similar articles
		search_for_article($articlename);
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
			$bot->say(channel => $thechannel, body => "Did you mean $1: http://wiki.xomb.org/index.php?title=$1");	
		}
	}

}
