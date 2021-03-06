use v6;

#= Field repeat classes

module PB::RepeatClasses;


#= Ways a field can repeat (or not)
enum RepeatClass is export <
    REQUIRED
    OPTIONAL
    REPEATED
    >;
