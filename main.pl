#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

# N = 8 - standart table
#1  2  3  4  5  6  7  8 
#9  10 11 12 13 14 15 16
#17 18 19 20 21 22 23 24
#25 26 . . . 

# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9 10 11
# 12 13 14 15

sub getRowMin{
	my $pos = shift;
	my $n =  shift;
	
 	my $row = int($pos / $n);
	$row*$n;
}

sub getRowMax{
	my $pos = shift;
	my $n =  shift;
	
 	my $row = int($pos / $n);
	$row*$n+($n-1);
}



sub genField {
	my $n = shift;
	my @field = (undef) x ($n*$n);  
	#print Dumper @field;
}

sub copyField {
	my $n = shift;
	my @copy_n = @{$n};
	\@copy_n;
}

sub putPiece{
	my $field = shift;
	my $color = shift;
	my $type = shift;
	my $pos = shift;

	#colors set of [w,b]
	#types set of [b,k,q,r]
	
	${$field}[$pos] = {	'color'=>$color, 
				'type'=>$type};
}



sub drawField {
	my $field = shift;
	my $size = shift;
	
	my $row = 0;
	for (my $i=0; $i<$size*$size; $i++){
		if ($row == $size){ 
			print "\n"; $row=0;
		}
 		if (defined ${$field}[$i]){
			print ${$field}[$i]->{color}.${$field}[$i]->{type};
		} else {print "#";}
		$row++;
	} 
	print "\n";
}

sub getFieldInRow{
	my $field = shift;
	my $size = shift;

	my $str = '';
	for (my $i=0; $i<$size*$size; $i++){
		if (defined ${$field}[$i]){
			$str.=${$field}[$i]->{color};	
			$str.=${$field}[$i]->{type};	
		} else {
			$str.='#';
		}
	}
	return $str;
}

# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 12 13 14 15

sub traceBishop{
	my $field = shift;
	my $pos = shift;
	my $size = shift;
	
	return () unless (defined ${$field}[$pos]);
	
	my @moves;
	my $curCol = ${$field}[$pos]->{color};

	#up left
	my $minPos = getRowMin($pos,$size);
	my $steps = $pos - $minPos;
	my $newPos = $pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos - $size - 1;
		last if ($newPos < 0);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}	

	#up rigth
	my $maxPos = getRowMax($pos,$size);
	$steps = $maxPos - $pos;
	$newPos= $pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos - $size + 1;
		last if ($newPos < 0);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}

	#down left
	$steps = $pos - $minPos;
	$newPos = $pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos + $size - 1;
		last if ($newPos < 0) || ($newPos >= $size*$size);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}	

	#down rigth
	$steps = $maxPos - $pos;
	$newPos=$pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos + $size + 1;
		last if ($newPos < 0) || ($newPos >= $size*$size);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}
	
	return @moves;
}

# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 12 13 14 15

sub traceRock{
	my $field = shift;
	my $pos = shift;
	my $size = shift;
	
	return () unless (defined ${$field}[$pos]);
	
	my @moves;
	my $curCol = ${$field}[$pos]->{color};

	#up 
	my $steps = int($pos/$size);
	my $newPos = $pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos - $size;
		last if ($newPos < 0);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}	
	
	#down
	$steps = $size;
	$newPos = $pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos + $size;
		last if ($newPos >= $size*$size);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}
	
	#left
	my $minPos = getRowMin($pos,$size);
	$steps = $pos-$minPos;
	$newPos = $pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos - 1 ;
		last if ($newPos < $minPos);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}

	#rigth
	my $maxPos = getRowMax($pos,$size);
	$steps = $maxPos - $pos;
	$newPos = $pos;
	for (my $i = 1;$i <= $steps; $i++){
		$newPos = $newPos + 1;
		last if ($newPos < $minPos);
		if (not defined ${$field}[$newPos]){ #if empty field
			unshift @moves, $newPos;
		} else {
			if (${$field}[$newPos]->{color} ne $curCol) { # if i can eat piece
				unshift @moves, $newPos;
			} 
			last; #anyway its last move in ray
		}
	}

	return @moves;
}

sub traceQueen{
	my $field = shift;
	my $pos = shift;
	my $size = shift;
	
	return () unless (defined ${$field}[$pos]);
	
	my @moves;
	
	push @moves, traceBishop($field,$pos,$size);
	push @moves, traceRock($field,$pos,$size);
	
	return @moves;
}

sub knightCount{
	my $pos = shift;
	my $n = shift;

	my @cells;
	if ($pos+($n*2)< $n*$n){
		unshift  @cells, $pos+($n*2)+1 if ($pos+($n*2)+1 <= getRowMax($pos+($n*2),4));
		unshift  @cells, $pos+($n*2)-1 if ($pos+($n*2)-1 >= getRowMin($pos+($n*2),4));
	}

	if ($pos-($n*2)>0){
		unshift  @cells, $pos-($n*2)+1 if ($pos-($n*2)+1 <= getRowMax($pos-($n*2),4));
		unshift  @cells, $pos-($n*2)-1 if ($pos-($n*2)-1 >= getRowMin($pos-($n*2),4));
	}

	unshift  @cells, $pos+2-$n if ($pos+2 <= getRowMax($pos,$n));
	unshift  @cells, $pos+2+$n if ($pos+2 <= getRowMax($pos,$n));
	unshift  @cells, $pos-2-$n if ($pos-2 >= getRowMin($pos,$n));
	unshift  @cells, $pos-2+$n if ($pos-2 >= getRowMin($pos,$n));

	my $max = $n*$n;
	return grep ($_<$max && $_>=0, @cells);
}

sub traceKnight{
	my $field = shift;
	my $pos = shift;
	my $size = shift;

	return () unless (defined ${$field}[$pos]);
	my $col = ${$field}[$pos]->{color};

	return grep ( (!defined ${$field}[$_] ) || (${$field}[$_]->{color} ne $col), knightCount($pos,$size));	
}

sub makeMove{
	my $field = shift;
	my $posFrom = shift;
	my $posTo = shift;
	my $size = shift;

	return () unless (defined ${$field}[$posFrom]);
	
	${$field}[$posTo] = ${$field}[$posFrom]; 
	${$field}[$posFrom] = undef;
}

sub makeAllMoves{
	my $field = shift;
	my $color = shift;
	my $size = shift;
	
	#take all pieces with color = $color;
	my @newFields = ();
	foreach my $i (0..$size*$size-1){
		if ((defined ${$field}[$i]) && (${$field}[$i]->{color} eq $color)){
			my $t = ${$field}[$i]->{type};
			my @moves = ();
			if ($t eq 'k') {@moves = traceKnight($field,$i,$size);}
				elsif ($t eq 'b') {@moves = traceBishop($field,$i,$size);}
				elsif ($t eq 'r') {@moves = traceRock($field,$i,$size);}
				elsif ($t eq 'q') {@moves = traceQueen($field,$i,$size);}
			foreach my $m (@moves){
				my $newF = copyField($field);
				makeMove($newF,$i,$m,$size);
				push @newFields, $newF;
			}
		}
	}
	return @newFields;
}

sub searchPiece{
	my $field = shift;
	my $color = shift;
	my $type  = shift;
	my $size  = shift;

	foreach my $i (0..$size*$size-1){
		return $i if ((defined ${$field}[$i])&&(${$field}[$i]->{color} eq $color) && ( ${$field}[$i]->{type} eq $type));
	}
	return -1;
}

#white  
#bq bb 2  3
#bb 5  6  7
#8  9  wb 11
#12 13 14 wq

	#black  
	#bq bb 2  3
	#bb 5  6  7
	#8  9  10 11
	#12 13 14 wq

	#black  
	#bq bb 2  3
	#bb wb 6  7
	#8  9  10 11
	#12 13 14 wq

	#black  
	#wb bb 2  3
	#bb 5  6  7
	#8  9  10 11
	#12 13 14 wq

	#black  
	#bq bb 2  3
	#bb 5  6  7
	#8  9  10 11
	#12 wb 14 wq

	#black  
	#bq bb 2  3
	#bb 5  6  wb
	#8  9  10 11
	#12 13 14 wq

sub catchTheQueen{
	my $field = shift;
	my $size = shift;
	my $color = shift || 'w';
	my $deep = shift || 0;
	my $maxDeep = shift || 2;
	
	#Если глубина больше максимально, то сворачиваемся
	return -1 if ($deep >= $maxDeep);
	#Поиск текущего ферзя. Если нет, то значит проигрышь.
	return -2 if (searchPiece($field, $color, 'q', $size) == -1);
	#Если нет вражеского, значит победа.
	return 1 if (searchPiece($field, ($color eq 'w')?'b':'w', 'q', $size) == -1);
	
	my @moves = makeAllMoves($field, $color, $size);
	
}


sub tests{
		sub union{
			my $vals = shift;
			join "-", sort {$a<=>$b} @{$vals};
		}
	my $fail = 0;
	$fail++ if (getRowMin(1,4) !=0);
	$fail++ if (getRowMin(4,4) !=4);
	$fail++ if (getRowMin(7,4) !=4);
	$fail++ if (getRowMin(8,4) !=8);
	$fail++ if (getRowMin(11,4) !=8);
	$fail++ if (getRowMin(15,4) !=12);
	print "getRowMin FAILED" if $fail > 0; $fail =0 ;

	$fail++ if (getRowMax(0,4) !=3);
	$fail++ if (getRowMax(5,4) !=7);
	$fail++ if (getRowMax(10,4) !=11);
	$fail++ if (getRowMax(15,4) !=15);
	print "getRowMax FAILED" if $fail > 0; $fail =0 ;

	$fail++ if("0-2-7-15" ne (join "-", sort {$a<=>$b} knightCount(9,4)));
	$fail++ if("5-10" ne (join "-", sort {$a<=>$b} knightCount(3,4)));
	$fail++ if("5-10" ne (join "-", sort {$a<=>$b} knightCount(12,4)));
	$fail++ if("6-9" ne (join "-", sort {$a<=>$b} knightCount(15,4)));
	$fail++ if("6-9" ne (join "-", sort {$a<=>$b} knightCount(0,4)));
	$fail++ if("3-11-12-14" ne (join "-", sort {$a<=>$b} knightCount(5,4)));
	$fail++ if("0-8-13-15" ne (join "-", sort {$a<=>$b} knightCount(6,4)));
	print "knigthCount FAILED" if $fail > 0; $fail =0 ;
# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 12 13 14 15

	my @f = genField(4);	

	sub check_bishop_trace {
		my $fff = shift;
		my $pos = shift;
		my $acceptance = shift;
		my $add_white = shift;
		my $add_black = shift;
		putPiece($fff,'w','b',$pos);
		putPiece($fff,'w','q',$add_white) if (defined $add_white);
		putPiece($fff,'b','q',$add_black) if (defined $add_black);
		my @bmoves = traceBishop($fff,$pos,4);
		${$fff}[$pos]=undef;
		${$fff}[$add_white]=undef if (defined $add_white);
		${$fff}[$add_black]=undef if (defined $add_black);
		print union(\@bmoves)."\n";
		my $fail = 0;
		$fail++ if ($acceptance ne union(\@bmoves));
		return $fail;
	}

	$fail += check_bishop_trace(\@f,3,"6-9-12");
	$fail += check_bishop_trace(\@f,4,"1-9-14");
	$fail += check_bishop_trace(\@f,0,"5-10-15");
	$fail += check_bishop_trace(\@f,12,"3-6-9");
	$fail += check_bishop_trace(\@f,15,"0-5-10");
	$fail += check_bishop_trace(\@f,9,"3-4-6-12-14");
	$fail += check_bishop_trace(\@f,2,"5-7-8");
	$fail += check_bishop_trace(\@f,11,"1-6-14");
	$fail += check_bishop_trace(\@f,8,"2-5-13");
	$fail += check_bishop_trace(\@f,13,"7-8-10");

	$fail += check_bishop_trace(\@f,9,"4-12-14",6);
	$fail += check_bishop_trace(\@f,9,"4-6-12-14",0,6);
	$fail += check_bishop_trace(\@f,15,"10",0,10);
	$fail += check_bishop_trace(\@f,15,"",10);

	putPiece(\@f,'w','b',5);
	putPiece(\@f,'w','b',7);
	$fail += check_bishop_trace(\@f,2,"");
	$f[5]=undef;
	$f[7]=undef;

	putPiece(\@f,'b','b',5);
	putPiece(\@f,'b','b',7);
	$fail += check_bishop_trace(\@f,2,"5-7");
	$f[5]=undef;
	$f[7]=undef;
	print "traceBishop FAILED" if $fail > 0; $fail =0 ;

# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 12 13 14 15

	sub check_rock_trace {
		my $fff = shift;
		my $pos = shift;
		my $acceptance = shift;
		my $add_white = shift;
		my $add_black = shift;
		putPiece($fff,'w','r',$pos);
		putPiece($fff,'w','q',$add_white) if (defined $add_white);
		putPiece($fff,'b','q',$add_black) if (defined $add_black);
		my @bmoves = traceRock($fff,$pos,4);
		${$fff}[$pos]=undef;
		${$fff}[$add_white]=undef if (defined $add_white);
		${$fff}[$add_black]=undef if (defined $add_black);
		print union(\@bmoves)."\n";
		my $fail = 0;
		$fail++ if ($acceptance ne union(\@bmoves));
		return $fail;
	}

	$fail += check_rock_trace(\@f,0,"1-2-3-4-8-12"); #!!
	$fail += check_rock_trace(\@f,12,"0-4-8-13-14-15");
	$fail += check_rock_trace(\@f,3,"0-1-2-7-11-15");
	$fail += check_rock_trace(\@f,15,"3-7-11-12-13-14");
	$fail += check_rock_trace(\@f,1,"0-2-3-5-9-13");
	$fail += check_rock_trace(\@f,7,"3-4-5-6-11-15");
	$fail += check_rock_trace(\@f,14,"2-6-10-12-13-15");
	$fail += check_rock_trace(\@f,8,"0-4-9-10-11-12");

	putPiece(\@f,'w','b',1);
	putPiece(\@f,'w','b',6);
	putPiece(\@f,'b','b',4);
	putPiece(\@f,'b','b',9);
	$fail += check_rock_trace(\@f,5,"4-9");
	$f[1]=undef;
	$f[6]=undef;
	$f[4]=undef;
	$f[9]=undef;
	print "traceRock FAILED" if $fail > 0; $fail =0 ;

# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 12 13 14 15
	sub check_queen_trace {
		my $fff = shift;
		my $pos = shift;
		my $acceptance = shift;
		my $add_white = shift;
		my $add_black = shift;
		putPiece($fff,'w','q',$pos);
		putPiece($fff,'w','b',$add_white) if (defined $add_white);
		putPiece($fff,'b','b',$add_black) if (defined $add_black);
		my @bmoves = traceQueen($fff,$pos,4);
		${$fff}[$pos]=undef;
		${$fff}[$add_white]=undef if (defined $add_white);
		${$fff}[$add_black]=undef if (defined $add_black);
		print union(\@bmoves)."\n";
		my $fail = 0;
		$fail++ if ($acceptance ne union(\@bmoves));
		return $fail;
	}

	putPiece(\@f,'b','b',5);
	putPiece(\@f,'w','b',10);
	$fail += check_queen_trace(\@f,9,"3-4-5-6-8-12-13-14");
	$f[5]=undef;
	$f[10]=undef;
	print "traceQueen FAILED" if $fail > 0; $fail =0 ;

# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 12 13 14 15
	
	sub check_knigth_trace {
		my $fff = shift;
		my $pos = shift;
		my $acceptance = shift;
		my $add_white = shift;
		my $add_black = shift;
		putPiece($fff,'w','k',$pos);
		putPiece($fff,'w','b',$add_white) if (defined $add_white);
		putPiece($fff,'b','b',$add_black) if (defined $add_black);
		my @bmoves = traceKnight($fff,$pos,4);
		${$fff}[$pos]=undef;
		${$fff}[$add_white]=undef if (defined $add_white);
		${$fff}[$add_black]=undef if (defined $add_black);
		print union(\@bmoves)."\n";
		my $fail = 0;
		$fail++ if ($acceptance ne union(\@bmoves));
		return $fail;
	}

	putPiece(\@f,'b','q',8);
	putPiece(\@f,'w','q',13);
	$fail += check_knigth_trace(\@f,6,"0-8-15");
	$f[8]=undef;
	$f[13]=undef;
	print "traceKnight FAILED" if $fail > 0; $fail =0 ;


	print "getFieldInRow:\n";
	putPiece(\@f,'w','q',13);
#	print getFieldInRow(\@f,4);
	print "getFieldInRow FAILED\n" if (getFieldInRow(\@f,4) ne "#############wq##");
	$f[13]=undef;
	
	print "drawField + copyField:\n";
	my $copyf = copyField(\@f);
	putPiece($copyf,'w','q',5);
	drawField(\@f,4);
	print "\n"x2;
	drawField($copyf,4);
	print "\n"x2;
	drawField(\@f,4);
	$copyf = undef;
	
	print "make move:\n";
	putPiece(\@f,'w','q',13);
	makeMove(\@f,13,7,4);
	print "makeMove failed\n:" if (getFieldInRow(\@f,4) ne "#######wq########");
	$f[7]=undef;



	print "makeAllmoves:\n";
	putPiece(\@f,'w','k',5);
	#print "Original:\n".getFieldInRow(\@f,4)."\nmoved:\n";
	my @fields = makeAllMoves(\@f,'w',4);
	foreach my $ff (@fields){
		print "makeAllMoves failed\n" unless (defined ${$ff}[3] || defined ${$ff}[11] ||defined ${$ff}[12] ||defined ${$ff}[14]);
	}
	
	putPiece(\@f,'w','b',3);
	@fields = makeAllMoves(\@f,'w',4);
	
	foreach my $ff (@fields){
		my $str = getFieldInRow($ff,4);
		print "makeAllMoves failed\n" unless ($str eq '###wb#######wk####'||
		$str eq '###wb########wk###'||
		$str eq '###wb##########wk#'||
		$str eq '#####wkwb#########'||
		$str eq '#####wk###wb######'||
		$str eq '#####wk######wb###');
	}

	print "searchPiece:\n";
	print "searchPiece if FAILED" if (searchPiece(\@f,'w','b',4) != 3);
	print "searchPiece if FAILED" if (searchPiece(\@f,'w','q',4) != -1);

# N = 4 
# 0  1  2  3
# 4  5  6  7
# 8  9  10 11
# 12 13 14 15
	
}



sub main{
	tests();
}

main();
