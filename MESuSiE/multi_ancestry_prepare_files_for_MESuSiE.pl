$fam_path = shift;
$out_dir  = shift;

if ( !$out_dir ) {
  $out_dir = "multi_out";
}

$lmm_suf = shift; #lmm suf
if ( !$lmm_suf ) {
  $lmm_suf = ".gemma.lmm.assoc.txt";
}

open( FP, "$fam_path" );
while (<FP>) {
  if (/(\S+)\s+(\S+)/) {
    $path{$2} = `readlink -f $1`;
    chomp( $path{$2} );
  }
}

foreach $r ( sort keys %path ) {
  #    print "$r\t$path{$r}\n";

  $this_path = $path{$r};
  if ( $this_path =~ /(\S+)\// ) {
    $root = $1;
  }
  open( TH, "$this_path" );
  while (<TH>) {
    if (/((\S+\/(\S+?))\.\S+)\.fam/) {
      $prefix     = $1;
      $lmm_prefix = $2;
      $gene       = $3;
      #$bed=$prefix.".bed";
      #$bim=$prefix.".bim";
      #$fam=$prefix.".fam";
      $plink{$gene}{$r} = $root . "/$prefix";
      $lmm{$gene}{$r}   = $root . "/$lmm_prefix" . $lmm_suf;
    }
  }
}

foreach $g ( sort keys %plink ) {
  `mkdir -p $out_dir/$g`;
  chdir("$out_dir/$g");
  open( PL, ">plink.race.list" );
  open( PR, ">plink.race" );
  open( PN, ">plink.race.num" );
  $n = 0;
  foreach $r ( sort keys %{ $plink{$g} } ) {
    $check_bed = $plink{$g}{$r} . ".bed";
    if ( !-e $check_bed ) {
      print STDERR "no $check_bed\n";
      next;
    }

    `ln -s $plink{$g}{$r}".bed" "$r.bed"`;
    `ln -s $plink{$g}{$r}".bim" "$r.bim"`;
    `ln -s $plink{$g}{$r}".fam" "$r.fam"`;

    `ln -s $lmm{$g}{$r} "$r.lmm.assoc.txt"`;

    print PL "$r\n";
    print PR "$r\t$r\n";
    $n++;
    $race = $r;

  }
  if ( !$n ) {
    print STDERR "no data for $g; omit this gene \n";
    chdir("../../");
    `rm -rf $out_dir/$g`;
    next;
  }
  print PN "$n\n";

  #use the last race bim for match alleles
  `ln -s $race.bim bim_for_match_alleles`;

  chdir("../../");
}
