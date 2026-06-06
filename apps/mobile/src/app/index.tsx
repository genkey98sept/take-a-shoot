import { colors, typography } from "@take-a-shoot/ui";
import { StyleSheet, Text, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

export default function HomeScreen() {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.logo}>
          Take<Text style={styles.at}>@</Text>Shoot
        </Text>
        <Text style={styles.tagline}>Les souvenirs disparaissent du feed, pas de ta mémoire.</Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    gap: 12,
    paddingHorizontal: 24,
  },
  logo: {
    color: colors.text,
    fontSize: typography.size.display,
    fontWeight: typography.weight.black,
  },
  at: {
    color: colors.brand,
  },
  tagline: {
    color: colors.textSecondary,
    fontSize: typography.size.body,
    textAlign: "center",
  },
});
