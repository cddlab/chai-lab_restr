# Copyright (c) 2024 Chai Discovery, Inc.
# Licensed under the Apache License, Version 2.0.
# See the LICENSE file for details.

from chai_lab.data.sources.rdkit import RefConformerGenerator


def test_ref_conformer_from_smiles():
    """Test ref conformer generation from SMILES."""
    smiles = "Cc1cc2nc3c(=O)[nH]c(=O)nc-3n(C[C@H](O)[C@H](O)[C@H](O)CO)c2cc1C"
    rcg = RefConformerGenerator()

    conformer = rcg.generate(smiles)

    assert len(set(conformer.atom_names)) == conformer.num_atoms


def test_ref_conformer_falls_back_from_random_coordinates():
    """A large fused glycoside should survive random-coordinate embed failure."""
    smiles = (
        "CC(=O)O[C@@H]1[C@@H](O)[C@H](O[C@H]2[C@H](OC(=O)[C@H]3CC[C@@H]4"
        "[C@H](C3)O[C@@]3(C[C@H](OC(=O)/C=C/c5ccccc5)[C@H](C)CO3)[C@]43CO3)"
        "O[C@H](C)[C@@H](O)[C@@H]2OC(C)=O)O[C@H](C)[C@H]1O"
    )
    rcg = RefConformerGenerator()

    conformer = rcg.generate(smiles)

    assert conformer.num_atoms == 57
    assert len(set(conformer.atom_names)) == conformer.num_atoms


def test_ref_conformer_glycan_ccd():
    """Ref conformer from CCD code for a sugar ring."""
    rcg = RefConformerGenerator()
    conformer = rcg.get("MAN")
    assert conformer is not None

    assert len(set(conformer.atom_names)) == conformer.num_atoms
