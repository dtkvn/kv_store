# Define the data file path for the key-value store.
# Uses the standard XDG data directory, falling back to a default if not set.
function __kv_data_file
    set -l data_home "$HOME/.local/share"
    set -l data_dir (dirname "$data_home/fish/kvstore.db")
    if not test -d "$data_dir"
        mkdir -p "$data_dir"
    end
    echo "$data_home/fish/kvstore.db"
end

# Main `kv` function to handle subcommands.
# Usage: kv <command> [arguments...]
function kv
    # Check if a subcommand was provided.
    if test (count $argv) -lt 1
        echo "Usage: kv <command>" >&2
        echo "Commands: set, get, delete, list" >&2
        return 1
    end

    set -l subcommand "$argv[1]"
    set -l data_file (__kv_data_file)
    set -l temp_file "$data_file.tmp"

    switch "$subcommand"
        case set
            if test (count $argv) -ne 3
                echo "Usage: kv set <key> <value>" >&2
                return 1
            end
            set -l key "$argv[2]"
            set -l value "$argv[3]"

            # Escape the key to ensure it can be safely used in regex.
            set -l escaped_key (printf '%s' "$key" | sed 's/[][\/.^$*+?(){}|]/\\&/g')

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
            if test (count $argv) -ne 2
                echo "Usage: kv get <key>" >&2
                return 1
            end
            set -l key "$argv[2]"

            if not test -f "$data_file"
                echo ""
                return 0
            end

            # Search for the key and extract the value.
            set -l value (grep "^$key=" "$data_file" | head -n 1 | cut -d= -f2-)

            echo "$value"

        case delete
            if test (count $argv) -ne 2
                echo "Usage: kv delete <key>" >&2
                return 1
            end
            set -l key "$argv[2]"

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
            set -l data_file (__kv_data_file)
            if not test -f "$data_file"
                echo "No keys in store."
                return 0
            end

            echo "Keys:"
            cat "$data_file" | cut -d= -f1

        case "*"
            echo "Unknown subcommand: '$subcommand'" >&2
            echo "Commands: set, get, delete, list" >&2
            return 1
    end
end
