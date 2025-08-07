# Description of the `kv` command for the main help output.
complete -c kv -d "Simple key-value store for Fish shell" -f

# Subcommand: set
complete -c kv -n __fish_use_subcommand -a set -d "Set a key-value pair"

# Subcommand: get
complete -c kv -n __fish_use_subcommand -a get -d "Get the value of a key"
# For the `get` subcommand, suggest existing keys from the kvstore.db file.
complete -c kv -n "__fish_seen_subcommand_from get" -a "(kv list | cut -d= -f1 2>/dev/null)"

# Subcommand: delete
complete -c kv -n __fish_use_subcommand -a delete -d "Delete a key-value pair"
# For the `delete` subcommand, suggest existing keys.
complete -c kv -n "__fish_seen_subcommand_from delete" -a "(kv list | cut -d= -f1 2>/dev/null)"

# Subcommand: list
complete -c kv -n __fish_use_subcommand -a list -d "List all keys in the store"
