enum Madhab {
  Hanafi,
  Hanbali,
  Jafari,
  Maliki,
  Shafi,
}

int shadowLength(Madhab madhab) {
  switch (madhab) {
    case Madhab.Hanafi:
      return 2;
    default:
      return 1;
  }
}
