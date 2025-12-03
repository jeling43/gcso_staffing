/// Represents a division within the Sheriff's Office
enum Division {
  jail('Jail'),
  patrol('Patrol'),
  courthouse('Courthouse');

  const Division(this.displayName);
  final String displayName;
}
