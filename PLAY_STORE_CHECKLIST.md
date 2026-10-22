# Play Store Release Checklist

Steps required before submitting Mini Tower Defense to Google Play Store.

---

## 1. Create a release keystore (one-time)

```bash
keytool -genkey -v \
  -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias minitowerdefense
```

Keep `my-release-key.jks` somewhere safe — losing it means you can never update the app on Play Store.

---

## 2. Create `app/android/key.properties`

This file is gitignored — **never commit it**.

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=minitowerdefense
storeFile=<absolute-path-to>/my-release-key.jks
```

Example `storeFile` path on macOS: `/Users/rahul.shah/my-release-key.jks`

---

## 3. Build the release App Bundle

```bash
cd app
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

Or a release APK for direct install testing:

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 4. App identity — already done ✅

- `applicationId`: `com.antigravity.minitowerdefense`
- `namespace`: `com.antigravity.minitowerdefense`

---

## 5. App metadata to prepare in Play Console

- [ ] App name: **Mini Tower Defense** (30-char limit)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] App icon: 512×512 PNG (no alpha)
- [ ] Feature graphic: 1024×500 PNG
- [ ] Screenshots: at least 2 phone screenshots (minimum 320px, max 3840px)
- [ ] Content rating questionnaire (game — likely "Everyone")
- [ ] Privacy policy URL (required even for offline apps with no data collection)

---

## 6. Version bump before each release

In `app/pubspec.yaml`, increment `version`:

```yaml
version: 1.0.0+1   # format: versionName+versionCode
#         ↑ ↑
#         |  versionCode — integer, must increase with every upload
#         versionName — human-readable string shown on Play Store
```

---

## 7. Enable R8 / ProGuard shrinking (optional but recommended)

In `app/android/app/build.gradle.kts`, inside `release {}`:

```kotlin
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(
        getDefaultProguardFile("proguard-android-optimize.txt"),
        "proguard-rules.pro"
    )
    signingConfig = if (keyPropertiesFile.exists())
        signingConfigs.getByName("release")
    else
        signingConfigs.getByName("debug")
}
```

Create `app/android/app/proguard-rules.pro` (can start empty — Flutter adds its own rules automatically).

---

## 8. Final checks before upload

```bash
cd app
flutter analyze        # must be clean
flutter test           # all tests must pass
flutter build appbundle --release
```

- [ ] Install the release APK on a physical Android device and play through at least wave 5 on each level
- [ ] Verify "Back to Menu" works from both Victory and Game Over screens
- [ ] Verify endless mode wave counter increments correctly
- [ ] Verify best-wave score persists across app restarts

---

## 9. Play Console upload steps

1. Go to [Google Play Console](https://play.google.com/console)
2. Create app → select **Android** → **Free** → **Game**
3. Upload `app-release.aab` under **Production** → **Create new release**
4. Fill in release notes
5. Complete store listing (metadata from step 5 above)
6. Submit for review (typically 1–3 days)

---

## Known remaining gaps (not blocking, but worth polishing)

- App icon and splash screen are Flutter defaults — replace before submission
- No `android:label` localisation — English only is fine for initial release
- `android:allowBackup` not explicitly set — add `android:allowBackup="false"` to `<application>` in `AndroidManifest.xml` if you want to prevent ADB backup of save data
