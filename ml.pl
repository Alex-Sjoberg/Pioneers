#!/usr/bin/perl

%hsh = ();
%whsh = ();

sub r { return int(rand(9))+1 }
sub p {
  my $num = shift;
  my @arr = @_;
  $hsh[$num] = @arr;
  ($r1,$r2,$r3,$r4,$r5,$r6) = @arr;

  open OUT,">../weights$num.clp";
  print OUT <<END;
(defglobal
  ?*total-dots* = $r1
  ?*min-brick-lumber* = $r2
  ?*total-brick* = $r3
  ?*min-ore-grain* = $r4
  ?*total-ore* = $r5
  ?*resource-rarity* = $r6
)
END
  close OUT;
}

chdir 'temp';


@tarr = (r,r,r,r,r,r); p 1,@tarr;
@tarr = (r,r,r,r,r,r); p 2,@tarr;

for ($i=0;$i<1;$i++) {
  print "running server\n";
  system("../bin/pioneers-server-console -p 5557 -n 127.0.0.1 -P 2 -R 0 -T 1 -v 10 -x 2>server_log &");
  sleep 1;

  print "running client 1\n";
  system("bin/pioneersai1 -s 127.0.0.1 -p 5557 -n Computer_1 -t 0 -c -a expert 2>c1_log &");

  print "running client 2\n";
  system("bin/pioneersai2 -s 127.0.0.1 -p 5557 -n Computer_2 -t 0 -c -a expert 2>c2_log &");

  ($won) = (`cat server_log` =~ /player \w+_(\d) won/);
  print "player $won won\n";

  $whsh[$won]++;

  @tarr = (r,r,r,r,r,r); p (3-$won),@tarr;
}

foreach $player (@warr) {
  print "player $player won ".$whsh[$player]." times\n";
}
