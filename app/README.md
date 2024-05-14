# app

A Flutter project.

## File Structure

```bash
./lib/pubspec.yaml
	- Dependencies
./lib/main.dart
	- Load the main app
	- Set up Firebase
	- Load the log in pop-up
	- Check if uid in admin database
	- load public_view.dart or admin_view.dart
./lib/public_view.dart
	- Load the public view
./lib/admin_view.dart
	- Load the admin view
./lib/components.dart
	- Shared widgets across admin_view.dart and public_view.dart
./lib/login.dart
	- Load the login pop-up
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Dev Hosting

To allow other to view the hot-reloading demo, set up ngrok and run a command l ike

```bash
ngrok http --domain=shark-learning-fawn.ngrok-free.app 58644
```
