# Pure local graph-based outfit engine (no LLM for combinations)
import networkx as nx
from typing import List, Dict

class WardrobeGraphEngine:
    def __init__(self):
        self.G = nx.Graph()

    def add_item(self, item_id: int, features: Dict):
        self.G.add_node(item_id, **features)

    def build_compatibility_graph(self):
        for u, v in list(self.G.edges()):
            self.G.remove_edge(u, v)
        for u in self.G.nodes:
            for v in self.G.nodes:
                if u < v and self._is_compatible(self.G.nodes[u], self.G.nodes[v]):
                    self.G.add_edge(u, v)

    def _is_compatible(self, f1: Dict, f2: Dict) -> bool:
        color_diff = abs(int(f1['color'][1:3], 16) - int(f2['color'][1:3], 16))
        return (color_diff < 60 and 
                f1['style'] == f2['style'] and 
                f1['season'] == f2['season'])

    def generate_outfits(self, occasion: str, max_combos: int = 50) -> List[List[int]]:
        outfits = []
        for node in self.G.nodes:
            for path in nx.all_simple_paths(self.G, node, cutoff=3):
                if len(path) >= 2 and self._matches_occasion(path, occasion):
                    outfits.append(path)
                    if len(outfits) >= max_combos:
                        return outfits
        return outfits

    def _matches_occasion(self, item_ids: List[int], occasion: str) -> bool:
        return True

    def score_outfit(self, item_ids: List[int]) -> float:
        return len(item_ids) * 25.0