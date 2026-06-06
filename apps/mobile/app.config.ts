import type { ExpoConfig } from "expo/config";

const config: ExpoConfig = {
  name: "Take@Shoot",
  slug: "take-a-shoot",
  scheme: "takeashoot",
  version: "0.1.0",
  orientation: "portrait",
  userInterfaceStyle: "dark",
  icon: "./assets/images/icon.png",
  ios: {
    supportsTablet: false,
    bundleIdentifier: "app.takeashoot.mobile",
    infoPlist: {
      NSCameraUsageDescription:
        "Take@Shoot utilise la camera pour capturer tes Shoots et MugShoots.",
      NSLocationWhenInUseUsageDescription:
        "Take@Shoot utilise ta position pour proposer la ville, le pays et les lieux proches.",
      NSPhotoLibraryAddUsageDescription:
        "Take@Shoot peut enregistrer tes Shoots dans ta galerie quand tu le demandes.",
    },
  },
  android: {
    package: "app.takeashoot.mobile",
    adaptiveIcon: {
      backgroundColor: "#050608",
      foregroundImage: "./assets/images/android-icon-foreground.png",
      backgroundImage: "./assets/images/android-icon-background.png",
      monochromeImage: "./assets/images/android-icon-monochrome.png",
    },
    permissions: [
      "CAMERA",
      "ACCESS_COARSE_LOCATION",
      "ACCESS_FINE_LOCATION",
      "WRITE_EXTERNAL_STORAGE",
    ],
    predictiveBackGestureEnabled: false,
  },
  web: {
    output: "static",
    favicon: "./assets/images/favicon.png",
  },
  plugins: [
    "expo-router",
    [
      "expo-splash-screen",
      {
        backgroundColor: "#050608",
        android: {
          image: "./assets/images/splash-icon.png",
          imageWidth: 76,
        },
      },
    ],
    "expo-image",
    "expo-secure-store",
  ],
  experiments: {
    typedRoutes: true,
    reactCompiler: true,
  },
  extra: {
    appEnv: process.env.EXPO_PUBLIC_APP_ENV ?? "development",
    supabaseUrl: process.env.EXPO_PUBLIC_SUPABASE_URL,
  },
};

export default config;
