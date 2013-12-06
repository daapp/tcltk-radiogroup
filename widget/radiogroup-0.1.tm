package require Tk
package require Ttk
package require snit


snit::widget widget::radiogroup {
    hulltype ttk::labelframe

    delegate option * to hull
    delegate method * to hull

    variable defaultVariable ""

    option -columns -default 1 -type {snit::integer -min 1}
    option -variable -configuremethod SetVariable
    option -command  -configuremethod SetCommand

    delegate option -title to hull as -text

    variable count 0


    constructor {args} {
        $self configurelist $args
        if {$options(-variable) eq ""} {
            set options(-variable) [myvar defaultVariable]
        }
    }


    method add {label value} {
        ttk::radiobutton $win.rb$count -text $label -value $value -variable $options(-variable)
        grid $win.rb$count -sticky ew

        incr count

        return
    }


    method get {} {
        return [set $options(-variable)]
    }


    method set {value} {
        foreach w [winfo children $win] {
            if {[$w cget -value] eq $value} {
                $w invoke
                return
            }
        }
        error "invalid value \"$value\" for radiogroup $win"
    }


    method SetCommand {option value} {
        foreach w [winfo children $win] {
            $w configure -command [mymethod RunCommand]
        }
        set options($option) $value

        return
    }


    method RunCommand {} {
        uplevel #0 $options(-command) [set $options(-variable)]
    }


    method SetVariable {option value} {
        if {$value eq ""} {
            set value [myvar defaultVariable]
        } else {
            # make sure, that value contain full qualified name
            set value ::[string trimleft $value :]
        }

        foreach w [winfo children $win] {
            $w configure -variable $value
        }

        set options($option) $value

        return
    }
}

if {[info exists argv0] && [file tail [info script]] eq [file tail $argv0]} {

    pack [widget::radiogroup .rg -title demo1] \
        -fill both -expand true

    .rg add "Yes" yes
    .rg add "No" no
    .rg add "I don't know" dontknow
}
