use PB::Model::Message;
use PB::Model::Option;
use PB::Model::Enum;

class PB::Model::Package {
    has Str $.name;
    has PB::Model::Message @.messages;
    has PB::Model::Option @.options;
    has PB::Model::Enum @.enums;

    method gist() {
        "<Package {$.name} messages=[{join ', ', @.messages>>.gist}]>"
    }
}
