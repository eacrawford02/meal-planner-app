class RecipeModel {
  String imagePath;
  String name;
  String time;
  int servings;
  List<String> ingredients;
  String instructions;
  Map<String, int> nutrition; // TODO: safety - default value, default keys

  RecipeModel({this.imagePath, this.name, this.time, this.servings,
    this.ingredients, this.instructions, this.nutrition});

  // Human-readable time duration format
  String getDurationS() {
    int i = time.indexOf(":");
    return time.substring(0, i) + " hr " + time.substring(i + 1) + " min";
  }

  int getDurationI() {
    int i = time.indexOf(":");
    return int.parse(time.substring(0, i)) * 100
        + int.parse(time.substring(i + 1));
  }

  void setDuration(int hours, int minutes) {
    time = "$hours:$minutes";
  }
}