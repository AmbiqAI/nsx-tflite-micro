# Source provenance

This module is an adapter, not a TFLM source distribution. An immutable
application build must pin each source provider independently.

## Initial release dependency identities

The first release preparation was audited against these identities:

| Dependency | Repository | Revision | Role |
| --- | --- | --- | --- |
| Helia-RT source provider | `AmbiqAI/helia-rt` | `7c1b162c0fd2336876b69daaa20c87a1e7e2f508` | TFLM runtime source and canonical CMake source manifest |
| Helia-RT source baseline | `AmbiqAI/helia-rt` | `HELIA_RT_VERSION "v1.17.0"` at the revision above | Human-readable runtime identity |
| Arm CMSIS-NN | `AmbiqAI/arm-cmsis-nn` | `41e0cf520fe68d5e22298f98e1a0ffda1196f8d8` | Optional `nsx::arm_cmsis_nn` backend dependency |

These are the corresponding stable-channel identities in the NeuralSPOTX
registry audit. This repository does not change those registry entries.

## Upstream TFLM lineage

Helia-RT's `690a2d72517522b8d7988ff7ee9ea01c9715491f` commit describes the
runtime source tree as a replant onto upstream `tflm/main` “2.3a snapshot,”
with Helia-specific build and kernel changes reapplied. Its
`ci/sync_from_upstream_tf.sh` script subsequently clones
`google-ai-edge/LiteRT` and copies the listed shared files into the Helia-RT
tree.

The Helia-RT source-provider commit used here does not embed an immutable
LiteRT/TFLM upstream commit ID; the sync script uses a shallow upstream clone.
Consequently, the Helia-RT commit above is the authoritative reproducibility
identity for this release, while the upstream project identity is lineage
information rather than a separately reproducible input. Do not describe this
module as vendoring or independently pinning TFLM sources.

## License and notices

- The adapter code in this repository is released under the BSD 3-Clause
  License in [LICENSE](LICENSE).
- Helia-RT source is distributed under its repository license and
  `THIRD_PARTY_NOTICES.md`.
- TFLM/LiteRT-derived files retain their upstream Apache and copyright notices
  in the Helia-RT source tree.
- Arm CMSIS-NN source retains its upstream license and notices in the
  `arm-cmsis-nn` dependency.

Consumers must ship the notices for every vendored dependency with their
product artifacts.
