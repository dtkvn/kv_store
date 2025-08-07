# Fish Shell Key-Value Store

A simple and efficient key-value store implemented as a fish shell function, using SQLite for reliable data storage.

## Features

- **Simple Commands**: Easy-to-use interface for managing key-value pairs
- **Persistent Storage**: Data is stored in an SQLite database
- **Thread-Safe**: Safe for concurrent access
- **Tab Completion**: Intelligent command and key completion
- **Special Character Support**: Handles special characters in keys and values

## Installation

### Install using Fisher

```bash
fisher install dtkvn/kv_store
```

### Install manually using Fisher

```bash
git clone https://github.com/dtkvn/kv_store.git
cd kv_store
fisher install .
```

### Install manually using Git

```bash
git clone https://github.com/dtkvn/kv_store.git
cp -r kv_store/functions/kv.fish ~/.config/fish/functions/
cp -r kv_store/completions/kv.fish ~/.config/fish/completions/
```

## Usage

### Set a key-value pair

```bash
kv set <key> <value>
```

### Get a value by key

```bash
kv get <key>
```

### List all key-value pairs

```bash
kv list
```

### Delete a key-value pair

```bash
kv delete <key>
```

### Show help

```bash
kv --help
```

### Show version

```bash
kv --version
```

## Examples

Store and retrieve a simple value:

```bash
kv set username john_doe
kv get username  # Outputs: john_doe
```

Store a value with spaces and special characters:

```bash
kv set "full name" "John O'Connor"
kv get "full name"  # Outputs: John O'Connor
```

List all stored values:

```bash
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
