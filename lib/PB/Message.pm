#= Base class for all generated message classes
class PB::Message {
    # NOTE: Use at least one hyphen in method and attribute names to ensure
    #       they won't collide with message field names.

    has @.unknown-fields;
}
