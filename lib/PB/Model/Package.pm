use PB::Model::Message;
use PB::Model::Option;
use PB::Model::Enum;

class PB::Model::Package {
    has Str $.name;
    has Array[PB::Model::Message] @.messages;
    has Array[PB::Model::Option] @.options;
    has Array[PB::Model::Enum] @.enums;

    method gist() {
        "<Package {$.name} messages=[{join ', ', @.messages>>.gist}]>"
    }
}
