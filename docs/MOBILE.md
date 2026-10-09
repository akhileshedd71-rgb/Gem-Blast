# Mobile export and device testing

The project is configured for portrait orientation, a 720×1280 design stage, touch-to-mouse emulation, and the Compatibility renderer. Desktop mouse input exercises the same gameplay handler. Haptics are conditional on a mobile build and the player's setting.

## Android

An Android export preset is included in `export_presets.cfg`.

1. Install Godot 4.6.3's matching export templates using **Editor → Manage Export Templates**.
2. Install OpenJDK 17 and the Android SDK versions documented for Godot 4.6. Set **Java SDK Path** and **Android SDK Path** in Editor Settings → Export → Android.
3. Open **Project → Export → Android**. Choose a unique package ID for your eventual release; the preset currently uses `com.gemblast.prismisles`.
4. For local testing, export a debug APK. For Google Play, configure your own release signing securely and export an AAB. Never commit keystores or passwords.
5. Test touch gestures, safe-area behavior, pause/resume, save restoration, performance, audio, and haptics on actual hardware.

Godot's official instructions: https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_android.html

## iOS

Use a Mac with Xcode, the matching Godot export templates, and your Apple signing/team configuration. Add an iOS preset in Godot and choose portrait orientation. Export the Xcode project, configure signing, and deploy to a physical device. No Apple credentials are stored in this repository.

Official instructions: https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_ios.html

## Current validation boundary

The game was imported and run in Godot 4.6.3 on Linux, with both headless integration tests and a real software-rendered OpenGL window. No Android/iOS package, store upload, physical-device test, real payment, or ad integration has been performed. Device signing and store distribution remain separate release steps.
