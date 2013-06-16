# use Grammar::Tracer;

grammar PB::Grammar {
    token TOP           { ^ <.ws> <proto> <.ws> $ <.ws> }
    token proto         { [<message> | <package> | <import> | <option> | <enum> | <extend> | <service> | ';']* }

    # comments and whitespace
    token comment       { '//' .*? $$ }
    token ws            { <!ww> [\s | <.comment>]* }

    # import
    token import        { 'import' <.ws> <str-lit> <.ws> ';' <.ws> }

    # package
    rule package        { 'package' <dotted-ident> ';' }

    # option
    rule option         { 'option' <opt-body> ';' }

    # enum
    rule enum           { 'enum' <ident> '{' [<option> | <enum-field> | ';']* '}' } # todo: translate into  '{' ~ '}'
    rule enum-field     { <ident> '=' <int-lit> ';' }

    # service/rpc
    rule service        { 'service' <ident> '{' [<option> | <rpc> | ';']* '}' }
    rule rpc            { 'rpc' <ident> '(' <user-type> ')' <.ws> 'returns' <.ws> '(' <user-type> ')' <.ws> ';' }

    # extend
    rule extend         { 'extend' <user-type> '{' [<field> | <group> | ';']* '}' }

    # message
    rule message        { 'message' <ident> <message-body> }
    rule message-body   { '{' [<message> | <field> | <extensions> | <option> | <group> | <enum> | <extend> | ';']* '}' }
    rule field          { <label> <type> <ident> '=' <field-num> <field-opts>? ';' }
    rule field-opts     { '[' (<field-opt> ','?)* ']' } # todo: make this turn into a prettier ast
    token field-opt     { [<default-opt> | <opt-body>] }    
    rule default-opt    { 'default' <.ws> '=' <constant> }
    rule extensions     { 'extensions' <extension> (',' <extension>)* ';' }
    rule extension      { <int-lit> 'to' [<int-lit> | 'max'] }
    rule group          { <label> 'group' <camel-ident> '=' <int-lit> <message-body> }

    # commonly used tokens

    rule opt-body       { <dotted-ident> '=' <constant> }

    token constant      { [<float-lit> | <int-lit> | <bool-lit> | <str-lit> | <ident>] }

    token type          { 'double' | 'float' | 'int32' | 'int64' | 'uint32' 
                        | 'uint64' | 'sint32' | 'sint64' | 'fixed32' 
                        | 'fixed64' | 'sfixed32' | 'sfixed64' | 'bool' 
                        |  'string' | 'bytes' }

    token user-type     { '.'? <dotted-ident> }

    token label         { 'required' | 'optional' | 'repeated' }

    token ident         { \w+ }

    token dotted-ident  { <ident> ('.' <ident>)* }

    token camel-ident   { <[A..Z]>\w* }

    token field-num     { <int-lit> }

    # int
    proto token int-lit     { * }
    token int-lit:sym<dec>  { <[1..9]>\d* }
    token int-lit:sym<hex>  { '0' <[xX]> <.xdigit>+ }
    token int-lit:sym<oct>  { '0' <[0..7]>+ }

    # other numbers
    token float-lit         { \d+ '.' [\d+]? [<[eE]> ['+'|'-']? \d+]? }
    token bool-lit          { 'true' | 'false' }

    # string
    proto token str-lit                 { * }
    token str-lit:sym<single-quoted>    { \' ~ \' ( <-[\\\x00\n']>+ | <str-escape> )* }
    token str-lit:sym<double-quoted>    { \" ~ \" ( <-[\\\x00\n"]>+ | <str-escape> )* }

    # this is basically like saying token str-escape { [<hex> | <oct> | <char> ] }
    proto token str-escape              { * }

    token str-escape:sym<hex>           { '\\' <[xX]> <.xdigit> ** 1..2 }
    token str-escape:sym<oct>           { '\\' <[0..7]> ** 1..3 }
    token str-escape:sym<char>          { '\\' <[abfnrtv\\?'"]> }       # ' <- stupid syntax highlighting
}
