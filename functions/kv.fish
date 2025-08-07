# Define the SQLite database file path for the key-value store
function __kv_db_file
    set -l data_home "$HOME/.local/share"
    set -l data_dir "$data_home/fish"
    if not test -d "$data_dir"
        mkdir -p "$data_dir"
    end
    echo "$data_dir/kvstore.sqlite3"
end

# Initialize the SQLite database if it doesn't exist
function __kv_init_db
    set -l db (__kv_db_file)
    if not test -f "$db"
        command -v sqlite3 >/dev/null 2>&1; or begin
            echo "Error: sqlite3 command not found. Please install it." >&2
            return 1
        end
        sqlite3 "$db" "CREATE TABLE IF NOT EXISTS kv (key TEXT PRIMARY KEY, value TEXT);"
    end
end

function __kv_execute_sql
    set -l sql "$argv[1]"
    set -l db (__kv_db_file)
    __kv_init_db
    sqlite3 -noheader -list "$db" "$sql" 2>/dev/null
end

function __kv_escape_sql
    # Escape single quotes by doubling them for SQL
    string replace --all "'" "''" -- "$argv[1]"
end

function __kv_show_help
    echo "Usage: kv [OPTIONS] COMMAND [ARGS]..."
    echo "A simple key-value store for fish shell using SQLite"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message and exit"
    # echo "  -v, --version  Show version information and exit"
    echo
    echo "Commands:"
    echo "  set KEY VALUE   Set a key-value pair"
    echo "  get KEY         Get the value for a key"
    echo "  list            List all key-value pairs"
    echo "  delete KEY      Delete a key-value pair"
end

# function __kv_show_version
#     echo "kv - fish key-value store with SQLite backend"
#     echo "Version 2.1.0"
# end

# Get a lock file path
function __kv_lock_file
    echo (__kv_db_file).lock
end

# Acquire a lock with timeout (in seconds)
function __kv_acquire_lock
    set -l lock_file (__kv_lock_file)
    set -l timeout
    if set -q argv[1]
        set timeout $argv[1]
    else
        set timeout 5 # Default 5 seconds timeout
    end
    set -l start_time (date +%s)

    while true
        # Try to create the lock file atomically
        if command mkdir "$lock_file" 2>/dev/null
            # Set up trap to ensure lock is released on script exit
            function __kv_release_lock_on_exit --on-process %self
                __kv_release_lock
            end
            return 0
        end

        # Check if we've timed out
        set -l current_time (date +%s)
        if test (math "$current_time - $start_time") -ge $timeout
            echo "Error: Could not acquire lock after $timeout seconds" >&2
            return 1
        end

        # Wait a bit before retrying
        sleep 0.1
    end
end

# Release the lock
function __kv_release_lock
    set -l lock_file (__kv_lock_file)
    if test -d "$lock_file"
        command rmdir "$lock_file" 2>/dev/null
    end
    functions -e __kv_release_lock_on_exit 2>/dev/null
end

function kv
    set -l options h/help
    argparse -n kv $options -- $argv
    or return 1

    # Handle help flag
    if set -q _flag_help
        __kv_show_help
        return 0
    end

    # if set -q _flag_version
    #     __kv_show_version
    #     return 0
    # end

    # Initialize the database if it doesn't exist
    __kv_init_db

    # Acquire lock before performing operations
    if not __kv_acquire_lock
        return 1
    end

    # Get subcommand
    set -l cmd (string lower -- $argv[1] 2>/dev/null)
    set -e argv[1]

    switch "$cmd"
        case set
            if test (count $argv) -ne 2
                echo "Error: 'set' requires exactly 2 arguments (key and value)" >&2
                __kv_release_lock
                return 1
            end
            set -l key (__kv_escape_sql "$argv[1]")
            set -l value (__kv_escape_sql "$argv[2]")
            __kv_execute_sql "INSERT OR REPLACE INTO kv (key, value) VALUES ('$key', '$value');"

        case get
            if test (count $argv) -ne 1
                echo "Error: 'get' requires exactly 1 argument (key)" >&2
                __kv_release_lock
                return 1
            end
            set -l key (__kv_escape_sql "$argv[1]")
            __kv_execute_sql "SELECT value FROM kv WHERE key = '$key';"

        case list
            __kv_execute_sql "SELECT key || '=' || value FROM kv ORDER BY key;"

        case delete
            if test (count $argv) -ne 1
                echo "Error: 'delete' requires exactly 1 argument (key)" >&2
                __kv_release_lock
                return 1
            end
            set -l key (__kv_escape_sql "$argv[1]")
            __kv_execute_sql "DELETE FROM kv WHERE key = '$key';"

        case ''
            __kv_show_help
            __kv_release_lock
            return 1

        case '*'
            echo "Error: Unknown command '$cmd'" >&2
            __kv_show_help
            __kv_release_lock
            return 1
    end

    # Release lock after performing operations
    __kv_release_lock
end
