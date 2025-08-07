# Define the data file path for the key-value store.
function __kv_data_file
    set -l data_home "$HOME/.local/share"
    set -l data_dir (dirname "$data_home/fish/kvstore.db")
    if not test -d "$data_dir"
        mkdir -p "$data_dir"
    end
    echo "$data_home/fish/kvstore.db"
end

# Show help message for specific subcommand
function __kv_subcommand_help
    set -l subcommand $argv[1]

    switch "$subcommand"
        case set
            echo "Usage: kv set [OPTIONS] KEY VALUE"
            echo
            echo "  Set a key-value pair in the store."
            echo
            echo "Options:"
            echo "  -h, --help    Show this message and exit."

        case get
            echo "Usage: kv get [OPTIONS] KEY"
            echo
            echo "  Get the value for a key."
            echo
            echo "Options:"
            echo "  -h, --help    Show this message and exit."

        case delete
            echo "Usage: kv delete [OPTIONS] KEY"
            echo
            echo "  Delete a key-value pair from the store."
            echo
            echo "Options:"
            echo "  -h, --help    Show this message and exit."

        case list
            echo "Usage: kv list [OPTIONS]"
            echo
            echo "  List all keys in the store."
            echo
            echo "Options:"
            echo "  -h, --help    Show this message and exit."

        case '*'
            echo "Unknown subcommand: $subcommand" >&2
            return 1
    end
    return 0
end

# Show main help message
function __kv_help
    echo "Usage: kv [OPTIONS] COMMAND [ARGS]..."
    echo "A simple key-value store for Fish shell"
    echo
    echo "Commands:"
    echo "  set KEY VALUE    Set a key-value pair"
    echo "  get KEY            Get the value for a key"
    echo "  delete KEY         Delete a key-value pair"
    echo "  list                 List all key-value pairs"
    echo
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -v, --version        Show version information"
    echo
    echo "Run 'kv COMMAND --help' for more information on a command."
    return 0
end

# Show version information
function __kv_version
    echo "kv (Fish Key-Value Store) 1.0.0"
    return 0
end

# Main `kv` function to handle subcommands and options
# Usage: kv [OPTIONS] COMMAND [ARGS]...
function kv -d "A simple key-value store for Fish shell"
    # Define options
    set -l options h/help v/version

    # Handle help and version flags first
    if contains -- --help $argv || contains -- -h $argv
        __kv_help
        return 0
    end

    if contains -- --version $argv || contains -- -v $argv
        __kv_version
        return 0
    end

    # Extract subcommand and its arguments
    set -l subcommand
    set -l subcommand_args

    # First, check if we have any arguments
    if not set -q argv[1]
        __kv_help >&2
        return 1
    end

    # The first argument is the subcommand
    set subcommand "$argv[1]"
    set subcommand_args $argv[2..-1]

    # Check for help flag in subcommand arguments
    if contains -- --help $subcommand_args || contains -- -h $subcommand_args
        __kv_subcommand_help "$subcommand"
        return 0
    end

    # Check if a subcommand was provided
    if not set -q subcommand[1]
        __kv_help >&2
        return 1
    end

    set -l data_file (__kv_data_file)
    set -l temp_file "$data_file.tmp"

    switch "$subcommand"
        case set
            if test (count $subcommand_args) -ne 2
                echo "Usage: kv set [OPTIONS] KEY VALUE"
                return 1
            end
            set -l key "$subcommand_args[1]"
            set -l value "$subcommand_args[2]"

            # Escape the key to ensure it can be safely used in regex.
            set -l escaped_key (printf '%s' "$key" | sed 's/[][\/\.^$*+?(){}|]/\\&/g')

            # Use a temporary file to avoid data corruption if an error occurs.
            if test -f "$data_file"
                sed "/^$escaped_key=/d" "$data_file" >"$temp_file"
            end

            # Append the new key-value pair to the end of the file.
            echo "$key=$value" >>"$temp_file"

            # Replace the old file with the new one.
            mv "$temp_file" "$data_file"
            echo "Set key '$key'."

        case get
            if test (count $subcommand_args) -ne 1
                echo "Usage: kv get [OPTIONS] KEY"
                return 1
            end
            set -l key "$subcommand_args[1]"

            if not test -f "$data_file"
                echo ""
                return 0
            end

            # Search for the key and extract the value.
            set -l value (grep "^$key=" "$data_file" | head -n 1 | cut -d= -f2-)

            echo "$value"

        case delete
            if test (count $subcommand_args) -ne 1
                echo "Usage: kv delete [OPTIONS] KEY" >&2
                return 1
            end
            set -l key "$subcommand_args[1]"

            if not test -f "$data_file"
                echo "Key '$key' not found."
                return 0
            end

            set -l initial_line_count (wc -l < "$data_file")

            # Use sed to remove the line with the matching key.
            sed "/^$key=/d" "$data_file" >"$temp_file"
            mv "$temp_file" "$data_file"

            set -l final_line_count (wc -l < "$data_file")

            if test "$initial_line_count" -gt "$final_line_count"
                echo "Deleted key '$key'."
            else
                echo "Key '$key' not found."
            end

        case list
            if not test -f "$data_file"
                echo "No keys in store."
                return 0
            end

            echo "Keys:"
            cat "$data_file" | cut -d= -f1

        case "*"
            echo "Usage: kv [OPTIONS] COMMAND [ARGS]..."
            echo "Try 'kv --help' for help."
            echo ""
            echo "Error: No such command '$subcommand'"
            return 1
    end
end
