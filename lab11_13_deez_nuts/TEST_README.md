# LW4 Testing Guide

This document provides instructions on how to run tests and generate test reports for the LW4 application.

## Types of Tests

The application includes the following types of tests:

1. **Unit Tests**: Test individual components in isolation
   - `connectivity_service_test.dart`
   - `database_helper_test.dart`
   - `firebase_service_test.dart`

2. **Widget Tests**: Test UI components
   - `sign_in_screen_widget_test.dart`
   - `create_worker_dialog_widget_test.dart`
   - `sign_in_button_widget_test.dart`
   - `create_worker_button_widget_test.dart`
   - `workers_list_drag_test.dart`

3. **Integration Test**: Test the entire app flow
   - `app_test.dart`

## Running Tests and Generating Reports

### Automated Method

#### For Windows:
```
run_tests_and_generate_reports.bat
```

#### For Linux/macOS:
```
chmod +x run_tests_and_generate_reports.sh
./run_tests_and_generate_reports.sh
```

### Manual Method

1. Run unit tests:
```
flutter test test/connectivity_service_test.dart test/database_helper_test.dart test/firebase_service_test.dart --machine > test_reports/unit_test_results.json
```

2. Run widget tests:
```
flutter test test/sign_in_screen_widget_test.dart test/create_worker_dialog_widget_test.dart test/sign_in_button_widget_test.dart test/create_worker_button_widget_test.dart test/workers_list_drag_test.dart --machine > test_reports/widget_test_results.json
```

3. Generate HTML reports:
```
flutter run test/test_report_generator.dart
```

4. Run integration test:
```
flutter test integration_test/app_test.dart
```

## Test Reports

After running the tests, HTML reports will be generated in the `test_reports` directory:
- `unit_tests_report.html`: Report for unit tests
- `widget_tests_report.html`: Report for widget tests

## Test Coverage

To generate test coverage reports, run:
```
flutter test --coverage
```

This will generate a `coverage/lcov.info` file. To convert it to an HTML report, you can use the `lcov` tool:
```
genhtml coverage/lcov.info -o coverage/html
```

Then open `coverage/html/index.html` in a web browser to view the coverage report. 