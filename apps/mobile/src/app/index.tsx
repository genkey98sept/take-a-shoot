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
    backgroundColor: "#000000",
  },
  content: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    gap: 12,
    paddingHorizontal: 24,
  },
  logo: {
    color: "#F4F2F0",
    fontSize: 44,
    fontWeight: "900",
  },
  at: {
    color: "#E6215A",
  },
  tagline: {
    color: "#A8A6A8",
    fontSize: 15,
    textAlign: "center",
  },
});
