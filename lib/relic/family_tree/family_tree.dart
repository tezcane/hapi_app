import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// Isim=("Name" in Arabic). Used to identify a prophet/leader/person as they
/// are known in scripture/history (Bible/Torah/Quran relations) in different
/// languages. Possibly is also used if the names are certain or not, so the
/// user isn't presented possibly wrong information as truth.
class Isim {
  const Isim({
    this.trKeyLaqab,
    this.trValAramaic,
    this.trValHebrew,
    this.trKeyHebrewMeaning,
    this.trValGreek,
    this.trValLatin,
    this.possibly = false,
  });
  final List<String>? trKeyLaqab; // Laqab = Nicknames
  final String? trValAramaic;
  final String? trValHebrew;
  final String? trKeyHebrewMeaning;
  final String? trValGreek;
  final String? trValLatin;
  // Something in data is unsure, e.g. Hud is Eber in Bible.
  final bool possibly; // TODO convert to string with why possibly

  /// Add * to mark something as "Possibly" being true
  String addPossibly(String trVal) => trVal + (possibly ? '*' : '');

  // String get trValArabic => LanguageC.to.ar('a.${e.name}');
}

enum RELATIVE {
  Possibly, // Possibly a distant relative TODO PossiblyMother, etc.
  Uncle,
  Grandson,
  Grandfather,
  Daughter,
  Nephew,
  HalfBrother,
  Brother,
  Sister,
  FosterMother,
  DistantCousin,
}

/// Used to save all we can about a Prophet's/Leader's/Person's family lineauge
/// so we use to build a family tree or nice UI about this relic.  A few rules:
///   1. If Father->Son are both relics, Father must declare son in trValSons.
///   2. If Father->Son are both relics, Son must have trValPredecessors = []
///   3. The root node must have trValPredecessors = []
abstract class FamilyTree extends Relic {
  FamilyTree({
    // TimelineEntry data:
    required String trValEra,
    required double startMs,
    required double endMs,
    required TimelineAsset asset,
    // Relic data:
    required RELIC_TYPE relicType,
    required String trKeySummary,
    required String trKeySummary2,
    // Fam Required
    required this.e,
    required this.trValPredecessors,
    // Fam Optional
    this.trValFather,
    this.trValMother,
    this.trValSpouses,
    this.trValSons,
    this.trValDaughters,
    this.trValRelatives,
    this.trValRelativesTypes,
    this.trValSuccessors,
  }) : super(
          // TimelineEntry data:
          trValEra: trValEra,
          trKeyEndTagLabel: e.name,
          startMs: startMs,
          endMs: endMs,
          asset: asset,
          // Relic data:
          relicType: relicType,
          relicId: e.index,
          trKeySummary: trKeySummary,
          trKeySummary2: trKeySummary2,
        );
  // Required Fam data:
  final Enum e;
  final List<Enum> trValPredecessors;
  // Optional Fam data:
  final Enum? trValFather;
  final Enum? trValMother;
  final List<Enum>? trValSpouses;
  final List<Enum>? trValDaughters;
  final List<Enum>? trValSons;
  final List<Enum>? trValRelatives;
  final List<RELATIVE>? trValRelativesTypes;
  final List<Enum>? trValSuccessors;
}

Graph getFamilyTreeGraph(RELIC_TYPE relicType, int gapIdx) {
  final Graph graph = Graph()..isTree = true;
  for (Relic relic in RelicC.to.getRelicSet(relicType).relics) {
    addFamilyNodes(graph, relic as FamilyTree, gapIdx);
  }
  return graph;
}

/// Init tree with all relics and the relic's ancestors, parents, and kids.
addFamilyNodes(Graph graph, FamilyTree ft, int gapIdx) {
  Node? lastNode;
  bool paintGapEdgeNext = false;

  /// Embedded function so we can use this methods variables
  addEdge(int idx, String dbgMsg, String name, {bool updateLastNode = true}) {
    Node node = Node.Id(idx);

    if (lastNode == null) {
      lastNode = node; // lastNode inits to whoever calls addEdge() first
      l.d('FAM_NODE:INIT:$dbgMsg: ${lastNode!.key}->$idx $name');
      return;
    }

    l.d('FAM_NODE:$dbgMsg: ${lastNode!.key}->$idx $name');

    graph.addEdge(
      lastNode!,
      node,
      paint: Paint()
        ..color = paintGapEdgeNext ? Colors.red : Colors.green
        ..strokeWidth = 3,
    );

    paintGapEdgeNext = false; // if it was set we clear it now
    if (updateLastNode) lastNode = node; // needed to add next node
  }

  // add predecessors, is [] on root and when Father->Son set previously
  for (Enum e in ft.trValPredecessors) {
    if (e.index == gapIdx) {
      paintGapEdgeNext = true;
      l.d('FAM_NODE:Predecessors:GAP: set flag paintGapEdgeNext=true');
      continue; // don't add "Gap" edge, flag makes next edge red
    }
    addEdge(e.index, 'Predecessors', e.name);
  }

  // add mother (Nothing for now, can handle on UI or special case init area)

  // add father, may already been created, e.g. Ibrahim->Ismail/Issac
  if (ft.trValFather != null) {
    addEdge(ft.trValFather!.index, 'Father', ft.trValFather!.name);
  }

  // Add Prophet (Handles case of Adam fine)
  addEdge(ft.relicId, 'Prophet', ft.trKeyEndTagLabel);

  // add daughters to Prophet node
  for (Enum e in ft.trValDaughters ?? []) {
    addEdge(e.index, 'Daughters', e.name, updateLastNode: false);
  }
  // add sons to Prophet node
  for (Enum e in ft.trValSons ?? []) {
    addEdge(e.index, 'Sons', e.name, updateLastNode: false);
  }
}
