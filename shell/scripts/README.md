# Build Scripts

## Single Build Script

Use `build.sh` to build any event app by providing the config file path:

```bash
./build.sh <config_file> [--dev|--release]
```

### Examples

```bash
# Build Melbourne 2026 for development/testing
./build.sh configs/melb2026.yaml --dev

# Build Gold Coast 2026 for release
./build.sh configs/gc2026.yaml --release

# List available configs
ls ../configs/*.yaml
```

### Usage

The script:
1. Validates the config file exists
2. Extracts the event name from the config filename
3. Calls the Dart build script with the appropriate parameters
4. Shows helpful error messages if config file is missing

### Direct Dart Usage

You can also call the Dart build script directly:

```bash
cd ..
dart run tool/build_app.dart configs/melb2026.yaml --dev
dart run tool/build_app.dart configs/melb2026.yaml --release
```


