#!/home/tahiry/too/ns/ns-allinone-2.35/tcl8.5.10/unix/tclsh

set arguments(-f) ""
set arguments(-col) 0
set arguments(-alpha) 0.05
set arguments(-txt) "******  Test 1   ******"
array set arguments $argv


if {$arguments(-f) == ""} {
   	puts "Calcul d'estimation de la moyenne -- Tahiry 2005"
		puts "usage: ./estimation_moyenne -f datafile -col NumeroColonne"
   	exit -1
} else {
	set fd [open $arguments(-f)]
}

set realisation 0
set somme 0
set ecart_type 0


# CALCUL de la MOYENNE #
while { [gets $fd line] != -1 } {
	set items [split $line " "]
	set somme [expr $somme+ [lindex $items $arguments(-col)] ]	
	incr realisation 1
}
set moyenne [expr $somme/($realisation-0.)]

close $fd
set fd [open $arguments(-f)]


# CALCUL de la variance #
set somme 0
set ecart 0
while { [gets $fd line] != -1 } {
	set items [split $line " "]
	set ecart [expr ([lindex $items $arguments(-col)] - $moyenne)*([lindex $items $arguments(-col)] - $moyenne)]
	set somme [expr $somme + $ecart]
}
set variance [expr $somme/($realisation-1.)]


# CALCUL de l'ecart type #
set ecart_type [expr sqrt($variance)]
close $fd

# integration de la table de student
set student [open "/home/tahiry/bin/student_table"]
set i 0

set sortie 0
while { [gets $student line] != -1 } {
	set j 0
	set items [split $line " "]
	foreach value $items {
		set student_table($i,$j) $value
		incr j 1
	}	
	incr i 1
}
set nb_ligne $i
set nb_colonne $j

# CALCUL intervalle de confiance de la moyenne#
if { [expr $realisation-1] > 30 &&  [expr $realisation-1] < 35 } {
	set degre_liberte 30
} elseif { [expr $realisation-1] >= 35 &&  [expr $realisation-1] < 45 } {
	set degre_liberte 40
} elseif { [expr $realisation-1] >= 45 &&  [expr $realisation-1] < 55 } {
	set degre_liberte 50
} elseif { [expr $realisation-1] >= 55 &&  [expr $realisation-1] < 65 } {
	set degre_liberte 60
} elseif { [expr $realisation-1] >= 65 &&  [expr $realisation-1] < 75 } {
	set degre_liberte 70
} elseif { [expr $realisation-1] >= 75 &&  [expr $realisation-1] < 85 } {
	set degre_liberte 80
} elseif { [expr $realisation-1] >= 85 &&  [expr $realisation-1] < 95 } {
	set degre_liberte 90
} elseif { [expr $realisation-1] >= 95 &&  [expr $realisation-1] < 150 } {
	set degre_liberte 100
} elseif { [expr $realisation-1] >= 150} {
	set degre_liberte 200
} else {
	set degre_liberte [expr $realisation-1]
}

for { set p 0 } { $p < $nb_colonne } { incr p } {
	if { $student_table(0,$p) == $arguments(-alpha) } {
		#set T $student_table($degre_liberte,$p)
		set col $p
	}	
}
for { set q 0 } { $q < $nb_ligne } { incr q } {
	if { $student_table($q,0) == $degre_liberte } {
		#set T $student_table($degre_liberte,$p)
		set li $q
	}	
}
set T $student_table($li,$col)

puts "$moyenne [expr $moyenne-$T*($ecart_type/sqrt($realisation))] [expr $moyenne+$T*($ecart_type/sqrt($realisation))]"
#puts "$moyenne [expr $moyenne-$T*($ecart_type/sqrt($realisation))] [expr $moyenne+$T*($ecart_type/sqrt($realisation))] $ecart_type"


#puts "$realisation $T $p $q $student_table($degre_liberte,$col)"
#puts "$arguments(-txt)"
#puts "taille echantillon = $realisation"
#puts "moyenne sur les données = $moyenne"
#puts "variance sur les données = $variance"
#puts "ecart type  sur les données = $ecart_type"
#puts "intervalle de confiance à $arguments(-alpha) de la moyenne = \[[expr $moyenne-$T*($ecart_type/sqrt($realisation))] ; [expr $moyenne+$T*($ecart_type/sqrt($realisation))]\] "
#puts ""


