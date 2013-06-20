use PB::Model::Message;
use PB::Model::Option;

class PB::Model::Package {
    has Str $.name;
    has Array[PB::Model::Message] @.messages;
    has Array[PB::Model::Option] @.options;

    method gist() {
        "<Package {$.name} messages=[{join ', ', @.messages>>.gist}]>"
    }
}