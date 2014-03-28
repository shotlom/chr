@rem = ' Perl Script
@echo off
set mycd=homedir_%cd:\=\\%
perl -wS %0 %1 %2 %mycd%
goto :EOF
';
undef @rem; 

use strict;
use warnings;
use Git::Wrapper;
use Time::Local;
use local::lib '';
use Env;
use Env qw(PATH HOME TERM);
use Pod::Select;
use Cwd;

#Chromicon modules
use FindBin qw($Bin);
use DevLog;


=head1 DevLog

Chr dos commands - wondering whether we need to MOOSIFY all of this in modules themselves, which becomes a little recursive!?

=head1 VERSION

Version 0.08

=cut

our $VERSION = '0.04';

=head1 SYNOPSIS

     
=cut


main: {

my $file = 'C:\\Dev\\Log.txt';
#print "opening file [$file]\n";
open (my $fh,">>",$file);

#print "Looking at argv [$ARGV[0]]\n";
my $thing = $ARGV[0];
#print "Bin [$Bin]\n";
#print "thing [$thing]\n";
 
 
#foreach my $rem ( @rem ) {
#  print $fh "rem [$rem]\n\n"
#} 

 
my $dir = 'C:\\Dev\\Logger\\';
my $git = Git::Wrapper->new($dir);

#print $fh "git dir [".$git->dir."]\n"; 
  my $homedir;
  foreach my $arg ( @ARGV ){
    if ( $arg =~ m{^homedir_} ) {
    
      my @h = split(/_/, $arg);
      $homedir = $h[1];
    }  
    
  }

  my $statuses = $git->status;
  for my $type (qw<indexed changed unknown conflict>) {
      my @states = $statuses->get($type)
          or next;
      print $fh "Files in state $type\n";
      for (@states) {
          print $fh '  ', $_->mode, ' ', $_->from;
          print $fh ' renamed to ', $_->to
              if $_->mode eq 'renamed';
          print $fh "\n";
      }
  } 

  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);

  my $errmsg  = 'Error message test';
  my $status  = 'FAIL';
  my $site    = 'TEST2';
  my $comment = 'imported somethink';
  my $keyword = 'IMPTEST';

  my %functions = ( 
                    start=>{
                      'doco'=>'Start logging current project',
                      'use'=>'chr start [project]'
                    }, 
                    new=>{
                      'doco'=>'Create a new module from git template',
                      'use'=>'chr new [project]'
                    }, 
                    list=>{
                      'doco'=>'List logs of projects from SQLite.db',
                      'use'=>'chr list '
                      
                    }, 
                    'git.update'=>{
                      'doco'=>'git.push remote repo. Default repo is current dir',
                      'use'=>'chr git.update comment'
                      
                    }, 
                    makepod=>{
                      'doco'=>'Makepod for project',
                      'use'=>'chr makepod'
                      
                    }, 
                    'cpanm.inichr'=>{
                      'doco'=>'Fetch git repo, install to INIPATH',
                      'use'=>'chr cpanm.inichr [repo]'
                    }, 
                    'cpanm.local'=>{
                      'doco'=>'Fetch git repo, install local Perl',
                      'use'=>'chr cpanm.local [repo]'
                    } 
                  ) ;
    
    
    my $logpath = 'C:\\Dev\\data\\';
    
    
    my $devlog = DevLog->new( 
      comment => $comment,
      status  => $status,
      keyword => $keyword,
      script  => $homedir,
      errmsg  => $errmsg,
      logpath => $logpath
    );

  
  if ( lc($ARGV[0]) =~ m{^--|-help} ){
    print "\nChromicon Utils \n==================\n";
    my $header = sprintf ("%-15s %-25s %-30s","Function","Usage","Doco");
    my $separator = sprintf ("%-15s %-25s %-30s","---------------","-------------------------","------------------------------");
    print "$header\n$separator\n";
    foreach (sort keys %functions){
      my $list = sprintf ("%-15s %-25s %-30s",$_, $functions{$_}->{use},$functions{$_}->{doco}); #$_->{use} ,$_->{doco});
      print "$list\n";
    }
  }
  elsif ( lc($ARGV[0]) eq 'start'){
    print "ARGV [$ARGV[1]]\n";
    
    $devlog->dev_log($ARGV[1]);
  }
  elsif( lc($ARGV[0]) eq 'list'){
    my $href = $devlog->list(); 
    my %hash = %$href;
    print "\nProject List\n------------\n";
    foreach my $script ( keys %hash ){
      print "$script\n";
    }
  }
  elsif ( lc($ARGV[0]) eq 'new'){
    my $new_dir = $ENV{HOME}.'\\'.$ARGV[1];
    mkdir $new_dir if (! -d $new_dir);
    my $devlog = DevLog->new( 
      comment => "Created project",
      keyword => 'INITIATED',
      script  => $ARGV[1],
    );
    $devlog->dev_log;
    print "New project created at [$new_dir]\n";
    chdir $new_dir;
  }
  elsif ( lc($ARGV[0]) eq 'cpanm.inichr'){
    my $repo = $ARGV[1];
    my $git_repo = 'git://github.com/shotlom/'.$repo.'.git';
    #my $sys_command = "cpanm $git_repo --install_base $ENV{INICHR}";
    #$ENV{PERL_MM_OPT} = 'INSTALL_BASE=C:/temp/inichr';
    $ENV{PERL_MM_OPT} = 'INSTALL_BASE=S:/Hydstra/prod/hyd/dat/ini/chr';
    my $sys_command = qq(cpanm $git_repo); #  --local-lib "$ENV{INICHR}");
    #print "fetching [$repo] saving to [$ENV{INICHR}]\n"; 
    print "PERL_MM_OPT [$ENV{PERL_MM_OPT}] \n"; 
    my $system = system ($sys_command);
    print "system output [ $system ]\n"; 
  }
  elsif ( lc($ARGV[0]) eq 'cpanm.local'){
    my $repo = $ARGV[1];
    my $git_repo = 'git://github.com/shotlom/'.$repo.'.git';
    #my $sys_command = "cpanm $git_repo --install_base $ENV{INICHR}";
    #my $sys_command = qq(cpanm $git_repo); #  --local-lib "$ENV{INICHR}");
    #print "fetching [$repo] saving to [$ENV{INICHR}]\n"; 
    print "PERL_MM_OPT [$ENV{PERL_MM_OPT}] \n"; 
    #my $system = system ($sys_command);
    #print "system output [ $system ]\n"; 
  }
  elsif ( lc($ARGV[0]) eq 'git.update'){
    my @pm_files = <./lib/*.pm>;
    print "home dir [$homedir]\n";
    my $msg = ( $ARGV[1] =~ m{^homedir_} ) ? "Standard commit to correct bugs etc." : $ARGV[1];
    print "Making POD files\n";
    foreach my $file ( @pm_files ){ 
      print "problem with [$file]\n" if ( ! podselect({-output => "README.pod"}, $file) );
    }
    print "Running Tests\n";
    if ( system("dmake test") == 0 ){
      print "\nUpdating Git Repository\n";
      my $dir = getcwd;
      my @dir_components = split(/\//,$dir);
      my $repo = $dir_components[$#dir_components];
      my $git = Git::Wrapper->new($dir);
      my $status = $git->status;
      
      print "\n[$repo] repo status\n-------------------\n";
      for my $type (qw<indexed changed unknown conflict>) {
        my @states = $status->get($type)
            or next;
        print "Files in $type state\n";
        for (@states) {
            print '  ', $_->mode, ' ', $_->from;
            print ' renamed to ', $_->to
                if $_->mode eq 'renamed';
            print "\n";
        }
      }
      print "Adding all files to [$repo] repo\n";
      my $add = $git->add(qw / * /, {all=>1});
      print "Add returned [$add]\n";
      my @message = ('--message', qq{$msg});
      print "Commiting. -m [$msg]\n";
      my $result  = $git->commit(@message,{ all => 1});
      print "git commit ok\n" if ($result ==0);
      #print $_->message for $git->log;
      my $git_repo = 'https://github.com/shotlom/'.$repo.'.git';
      print "Git Repo [$git_repo]\n";
      my @push = ($git_repo,'master');
      my $push    = $git->push(@push);
      print "git push ok\n" if ($push == 0 );
      my $devlog = DevLog->new( 
        comment => $msg,
        status  => 'ok',
        keyword => 'git.update',
        script  => $homedir,
        user    => 'smaud',
        errmsg  => ''
      );
      $devlog->dev_log;
    }
    else{
      print "ERROR!!\nProblem with dmake test.\n    Please run dmake test manually from cmd window.\n"
    }
  }
  elsif ( lc($ARGV[0]) eq 'makepod'){
    my $pm = $ARGV[2].'\\lib\\'.$ARGV[1].'.pm';
    print "Making POD from [$pm]\n";
    #system( podselect $pm > 'README.pod');
    podselect({-output => "README.pod"}, $pm);
    print "Done\n";
  }
  elsif ( lc($ARGV[0]) eq 'test'){
    my @pm_files = </lib/*.pm>;
    foreach my $file ( @pm_files ){ 
      print "Making POD from [$file]\n";
      podselect({-output => "README.pod"}, $file);
      print "Done\n";
    }
    print "dmake test\n";
    my $err = system("dmake test");
    print "Output from dmake [$err]\n";
  }
  else {
    print "command [$ARGV[0]] not recognised. Quitting.\n";
  }
  
  
  #my $all = $logger->log_hash(logpath=>$log_path);
  #my %log_hash = %$all;
  #foreach my $record ( keys %log_hash ){
  #  print $fh "printing loghash $log_hash{$record}\n";
  #}
  

  print $fh "Hello from the Perl part of this job\n";
  
  close ($fh);
  
}

