# Fish Shell Key-Value Store

A simple and efficient key-value store implemented as a fish shell function, using SQLite for reliable data storage.

## Features

- **Simple Commands**: Easy-to-use interface for managing key-value pairs
- **Persistent Storage**: Data is stored in an SQLite database
- **Thread-Safe**: Safe for concurrent access
- **Tab Completion**: Intelligent command and key completion
- **Special Character Support**: Handles special characters in keys and values

## Installation

```shell
fisher install dtkvn/kv_store
```

## Usage

### Set a key-value pair

```fish
kv set <key> <value>
```

### Get a value by key

```fish
kv get <key>
```

### List all key-value pairs

```fish
kv list
```

### Delete a key-value pair

```fish
kv delete <key>
```

### Show help

```fish
kv --help
```

### Show version

```fish
kv --version
```

## Examples

Store and retrieve a simple value:

```fish
kv set username john_doe
kv get username  # Outputs: john_doe
```

Store a value with spaces and special characters:

```fish
kv set "full name" "John O'Connor"
kv get "full name"  # Outputs: John O'Connor
```

List all stored values:

```fish
kv list
# Outputs:
# full name=John O'Connor
# username=john_doe
```

## Data Storage

Key-value pairs are stored in an SQLite database located at:

```bash
~/.local/share/fish/kvstore.sqlite3
```

## Requirements

- fish shell (tested with version 3.0.0 and above)
- sqlite3 (usually pre-installed on most systems)

## License

This project is open source and available under the [MIT License](LICENSE).
