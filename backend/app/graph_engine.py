"""Backward-compatible graph engine wrapper.

The initial repository exposed WardrobeGraphEngine directly. The product now uses
OutfitEngine for India-first structured outfit recommendations, but this class is
kept so older imports/tests do not break.
"""
from __future__ import annotations

from typing import Dict, List

import networkx as nx


class WardrobeGraphEngine:
    def __init__(self):
        self.G = nx.Graph()

    def add_item(self, item_id: int, features: Dict):
        self.G.add_node(item_id, **features)

    def build_compatibility_graph(self):
        self.G.remove_edges_from(list(self.G.edges()))
        nodes = list(self.G.nodes)
        for idx, u in enumerate(nodes):
            for v in nodes[idx + 1 :]:
                if self._is_compatible(self.G.nodes[u], self.G.nodes[v]):
                    self.G.add_edge(u, v)

    def _is_compatible(self, f1: Dict, f2: Dict) -> bool:
        if not all(key in f1 and key in f2 for key in ["color", "style", "season"]):
            return False
        try:
            r_diff = abs(int(f1["color"][1:3], 16) - int(f2["color"][1:3], 16))
            g_diff = abs(int(f1["color"][3:5], 16) - int(f2["color"][3:5], 16))
            b_diff = abs(int(f1["color"][5:7], 16) - int(f2["color"][5:7], 16))
        except Exception:
            return False
        return (r_diff + g_diff + b_diff) < 160 and f1["style"] == f2["style"] and f1["season"] == f2["season"]

    def generate_outfits(self, occasion: str, max_combos: int = 50) -> List[List[int]]:
        """Return cliques/connected pairs instead of the previous broken all_simple_paths call."""
        outfits: List[List[int]] = []
        for clique in nx.find_cliques(self.G):
            if len(clique) >= 2 and self._matches_occasion(clique, occasion):
                outfits.append(sorted(clique))
                if len(outfits) >= max_combos:
                    return outfits
        if not outfits:
            for u, v in self.G.edges:
                outfits.append([u, v])
                if len(outfits) >= max_combos:
                    return outfits
        return outfits

    def _matches_occasion(self, item_ids: List[int], occasion: str) -> bool:
        return True

    def score_outfit(self, item_ids: List[int]) -> float:
        return min(100.0, len(item_ids) * 25.0)
